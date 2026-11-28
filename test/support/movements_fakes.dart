import 'dart:async';

import 'package:financial_between_us/features/balances/data/movements_repository.dart';
import 'package:financial_between_us/features/balances/data/receipt_picker.dart';
import 'package:financial_between_us/features/balances/data/receipt_uploader.dart';
import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/balances/domain/movement_failure.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';

/// Movements in memory, per group. Writes show up in [watchGroup] right
/// away, like Firestore's local cache.
class FakeMovementsRepository implements MovementsRepository {
  FakeMovementsRepository([Iterable<LedgerMovement> movements = const []]) {
    for (final m in movements) {
      _byGroup.putIfAbsent(m.groupId, () => []).add(m);
    }
  }

  final Map<String, List<LedgerMovement>> _byGroup = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextId = 1;

  /// What every write did, like `registerDebt:d1` or `reject:p1`.
  final List<String> calls = [];

  /// Thrown by the next write.
  Object? writeError;

  /// Every movement of [groupId].
  List<LedgerMovement> movementsOf(String groupId) =>
      List.unmodifiable(_byGroup[groupId] ?? const []);

  /// Pages read with [fetchPairHistory] (what the server would send).
  int fetchedPages = 0;

  List<LedgerMovement> _active(String groupId) => [
    for (final m in movementsOf(groupId))
      if (m.isActive) m,
  ];

  @override
  Stream<List<LedgerMovement>> watchGroup(String groupId) async* {
    yield _active(groupId);
    yield* _changes.stream.map((_) => _active(groupId));
  }

  /// Movements of the pair, newest first, like the Firestore query.
  List<LedgerMovement> _pair(String me, String other, String? groupId) {
    final key = pairKeyOf(me, other);
    return [
      for (final entry in _byGroup.entries)
        if (groupId == null || entry.key == groupId)
          for (final m in entry.value)
            if (m.pairKey == key) m,
    ]..sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  }

  MovementPage _pageFrom(List<LedgerMovement> all, int start, int limit) {
    final items = all.skip(start).take(limit).toList();
    return MovementPage(
      items: items,
      cursor: items.isEmpty ? null : items.last.id,
      hasMore: items.length >= limit,
    );
  }

  @override
  Stream<MovementPage> watchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
  }) async* {
    yield _pageFrom(_pair(me, other, groupId), 0, limit);
    yield* _changes.stream.map(
      (_) => _pageFrom(_pair(me, other, groupId), 0, limit),
    );
  }

  @override
  Future<MovementPage> fetchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
    required Object after,
  }) async {
    fetchedPages++;
    final all = _pair(me, other, groupId);
    final start = all.indexWhere((m) => m.id == after) + 1;
    return _pageFrom(all, start, limit);
  }

  @override
  Stream<List<LedgerMovement>> watchRecent({
    required String groupId,
    required String me,
    required int limit,
  }) async* {
    List<LedgerMovement> recent() => ([
      for (final m in movementsOf(groupId))
        if (m.involves(me)) m,
    ]..sort((a, b) => b.date.compareTo(a.date))).take(limit).toList();
    yield recent();
    yield* _changes.stream.map((_) => recent());
  }

  @override
  Future<List<String>> registerPayments(List<LedgerMovement> payments) async {
    _throwIfNeeded();
    final ids = [for (final p in payments) _add(p, 'p')];
    calls.add('registerPayments:${ids.join(',')}');
    _changes.add(null);
    return ids;
  }

  @override
  Future<String> registerDebt(LedgerMovement debt) async {
    _throwIfNeeded();
    final id = _add(debt, 'd');
    calls.add('registerDebt:$id');
    _changes.add(null);
    return id;
  }

  @override
  Future<void> reject({
    required LedgerMovement movement,
    required String uid,
    required RejectReason reason,
    String? note,
  }) async {
    _throwIfNeeded();
    if (!movement.canReject(uid)) throw const MovementNotAllowed();
    calls.add('reject:${movement.id}:${reason.wire}');
    _replace(
      movement,
      (m) => m.copyWith(
        status: MovementStatus.rejected,
        rejectedAt: DateTime(2026, 11, 27, 10),
        rejectedBy: uid,
        rejectReason: reason,
        rejectNote: note,
        seenBy: {...m.seenBy, uid}.toList(),
      ),
    );
  }

  @override
  Future<void> delete({
    required LedgerMovement movement,
    required String uid,
  }) async {
    _throwIfNeeded();
    if (!movement.canDelete(uid)) throw const MovementNotAllowed();
    calls.add('delete:${movement.id}');
    _replace(
      movement,
      (m) => m.copyWith(
        status: MovementStatus.deleted,
        deletedAt: DateTime(2026, 11, 27, 10),
      ),
    );
  }

  @override
  Future<LedgerMovement?> fetchMovement({
    required String groupId,
    required String movementId,
  }) async => movementsOf(groupId).where((m) => m.id == movementId).firstOrNull;

  @override
  Future<void> markSeen({
    required LedgerMovement movement,
    required String uid,
  }) async {
    if (movement.seenBy.contains(uid)) return;
    calls.add('markSeen:${movement.id}');
    _replace(movement, (m) => m.copyWith(seenBy: {...m.seenBy, uid}.toList()));
  }

  String _add(LedgerMovement movement, String prefix) {
    final id = '$prefix${_nextId++}';
    _byGroup
        .putIfAbsent(movement.groupId, () => [])
        .add(
          movement.copyWith(
            id: id,
            createdAt: DateTime(2026, 11, 27, 9, _nextId),
            seenBy: [movement.createdBy],
          ),
        );
    return id;
  }

  void _replace(
    LedgerMovement movement,
    LedgerMovement Function(LedgerMovement) change,
  ) {
    final list = _byGroup[movement.groupId]!;
    final i = list.indexWhere((m) => m.id == movement.id);
    list[i] = change(list[i]);
    _changes.add(null);
  }

  void _throwIfNeeded() {
    final error = writeError;
    if (error != null) {
      writeError = null;
      throw error;
    }
  }
}

/// Returns [next] instead of opening the camera or the gallery.
class FakeReceiptPicker implements ReceiptPicker {
  PickedReceipt? next = const PickedReceipt(
    path: '/tmp/recibo.jpg',
    name: 'recibo.jpg',
    bytes: 240 * 1024,
  );

  /// Thrown instead of returning [next].
  Object? error;

  final List<ReceiptSource> sources = [];

  @override
  Future<PickedReceipt?> pick(ReceiptSource source) async {
    sources.add(source);
    final e = error;
    if (e != null) throw e;
    return next;
  }
}

/// Records uploads instead of calling Cloudinary.
class FakeReceiptUploader implements ReceiptUploader {
  final List<String> uploads = [];

  /// Fail every upload.
  bool fail = false;

  @override
  Future<MovementAttachment> upload(
    String filePath, {
    required String groupId,
  }) async {
    if (fail) throw const MovementAttachmentFailure();
    uploads.add('$groupId:$filePath');
    return const MovementAttachment(
      url: 'https://example.com/recibo.jpg',
      width: 1200,
      height: 1600,
      bytes: 240 * 1024,
    );
  }
}

// --- Data of the design captures (section 11.2 of the handoff) -----------

const String sampleMe = 'me';
const String sampleGroupId = 'low-iq';
const String sampleFutbolId = 'futbol';
const String sampleTripId = 'villa';

/// Profiles of the people in the captures.
const Map<String, UserProfile> sampleProfiles = {
  'santi': UserProfile(
    uid: 'santi',
    displayName: 'Santiago Ruiz',
    nickname: 'santi',
    email: 'santi@correo.com',
    colorValue: 0xFF3DB8FF,
  ),
  'juliana': UserProfile(
    uid: 'juliana',
    displayName: 'Juliana Pardo',
    nickname: 'juliana',
    email: 'juliana@correo.com',
    colorValue: 0xFFFF5FA2,
  ),
  'nico': UserProfile(
    uid: 'nico',
    displayName: 'Nicolás Gómez',
    nickname: 'nico',
    email: 'nico@correo.com',
    colorValue: 0xFFFF8A3D,
  ),
  'valen': UserProfile(
    uid: 'valen',
    displayName: 'Valentina Ríos',
    nickname: 'valen',
    email: 'valen@correo.com',
    colorValue: 0xFFF4D35E,
  ),
  'carlosm': UserProfile(
    uid: 'carlosm',
    displayName: 'Carlos Medina',
    nickname: 'carlosm',
    email: 'carlos@correo.com',
    colorValue: 0xFF2EC4B6,
  ),
  'feli': UserProfile(
    uid: 'feli',
    displayName: 'Felipe Castro',
    nickname: 'feli',
    email: 'feli@correo.com',
    colorValue: 0xFF9B8CFF,
  ),
  'dani': UserProfile(
    uid: 'dani',
    displayName: 'Daniela Torres',
    nickname: 'dani',
    email: 'dani@correo.com',
    colorValue: 0xFF7BD389,
  ),
  'laura': UserProfile(
    uid: 'laura',
    displayName: 'Laura Méndez',
    nickname: 'laura',
    email: 'laura@correo.com',
    colorValue: 0xFFFF7A7A,
  ),
  'tomas': UserProfile(
    uid: 'tomas',
    displayName: 'Tomás Vélez',
    nickname: 'tomas',
    email: 'tomas@correo.com',
    colorValue: 0xFF5EC8E5,
  ),
};

/// Members of "Low IQ Group" besides [sampleMe].
const List<String> sampleLowIqMembers = [
  'santi',
  'juliana',
  'nico',
  'valen',
  'carlosm',
  'feli',
  'dani',
  'laura',
];

LedgerMovement _debt(
  String id,
  String from,
  String to,
  int amount,
  int day, {
  String group = sampleGroupId,
  String concept = '',
  String? event,
  String? createdBy,
  bool seen = true,
}) => LedgerMovement(
  id: id,
  groupId: group,
  type: LedgerMovementType.debt,
  debtorUid: from,
  creditorUid: to,
  amount: amount,
  kind: event == null ? DebtKind.direct : DebtKind.event,
  eventId: event == null ? null : 'e-$id',
  eventName: event,
  concept: concept,
  date: DateTime(2026, 11, day, 20),
  createdBy: createdBy ?? to,
  createdAt: DateTime(2026, 11, day, 20),
  seenBy: seen ? [from, to] : [createdBy ?? to],
);

/// Movements of the captures: Low IQ Group, Fútbol de los jueves and Viaje
/// a Villa de Leyva.
List<LedgerMovement> sampleMovements() => [
  // Santiago owes $ 72.000 in 3 pending items.
  _debt('taxi', 'santi', sampleMe, 15000, 18, concept: 'Taxi al aeropuerto'),
  _debt('bolos', 'santi', sampleMe, 26000, 21, event: 'Bolos en Unicentro'),
  _debt('carne', 'santi', sampleMe, 41000, 22, event: 'Andrés Carne de Res'),
  LedgerMovement(
    id: 'abono',
    groupId: sampleGroupId,
    type: LedgerMovementType.payment,
    debtorUid: 'santi',
    creditorUid: sampleMe,
    amount: 10000,
    appliedTo: const [PaymentApplication(targetId: 'bolos', amount: 10000)],
    date: DateTime(2026, 11, 24, 12),
    createdBy: 'santi',
    createdAt: DateTime(2026, 11, 24, 12),
    seenBy: const ['santi', sampleMe],
  ),
  // Juliana owes $ 58.500 in 2 pending items.
  _debt('almuerzo', 'juliana', sampleMe, 30000, 15, concept: 'Almuerzo'),
  _debt('cine', 'juliana', sampleMe, 28500, 20, event: 'Cine Andino'),
  // Nicolás owes $ 31.500 (Noche de karaoke).
  _debt('karaoke', 'nico', sampleMe, 31500, 14, event: 'Noche de karaoke'),
  // The user owes Valentina $ 45.000 and Carlos $ 41.500.
  _debt('mercado', sampleMe, 'valen', 45000, 16, concept: 'Mercado'),
  _debt('bbc', sampleMe, 'carlosm', 41500, 22, event: 'Bogotá Beer Company'),
  // Felipe is even.
  _debt('pizza', 'feli', sampleMe, 22000, 8, event: 'Pizza del viernes'),
  LedgerMovement(
    id: 'pizza-pago',
    groupId: sampleGroupId,
    type: LedgerMovementType.payment,
    debtorUid: 'feli',
    creditorUid: sampleMe,
    amount: 22000,
    appliedTo: const [PaymentApplication(targetId: 'pizza', amount: 22000)],
    date: DateTime(2026, 11, 15, 12),
    createdBy: sampleMe,
    createdAt: DateTime(2026, 11, 15, 12),
    seenBy: const ['feli', sampleMe],
  ),
  // Fútbol de los jueves: Santi owes $ 18.000.
  _debt(
    'cancha',
    'santi',
    sampleMe,
    18000,
    20,
    group: sampleFutbolId,
    concept: 'Cancha',
  ),
  // Viaje a Villa de Leyva: Tomás owes $ 34.000; the user owes Valentina
  // $ 15.000.
  _debt(
    'hotel',
    'tomas',
    sampleMe,
    34000,
    10,
    group: sampleTripId,
    concept: 'Hotel',
  ),
  _debt(
    'gasolina',
    sampleMe,
    'valen',
    15000,
    11,
    group: sampleTripId,
    concept: 'Gasolina',
  ),
];
