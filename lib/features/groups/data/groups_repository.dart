import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';
import '../domain/active_group.dart';
import '../domain/group.dart';
import '../domain/group_code.dart';
import '../domain/group_code_lookup.dart';
import '../domain/group_failure.dart';
import '../domain/group_member.dart';
import '../domain/join_outcome.dart';
import '../domain/leave_plan.dart';
import 'group_mapper.dart';
import 'group_password_hasher.dart';

/// Groups of the signed-in user: list, create, join and leave. Every method
/// throws a [GroupFailure] on error.
abstract interface class GroupsRepository {
  /// Live groups where [uid] is an active or pending member, in selector
  /// order (see [sortGroupsFor]). Soft-deleted groups are left out.
  Stream<List<Group>> watchMyGroups(String uid);

  /// Creates a group with a unique join code; [uid] is its admin.
  /// An empty or `null` [password] means no password.
  Future<CreatedGroup> createGroup({
    required String uid,
    required String name,
    required bool requiresApproval,
    String? password,
  });

  /// The group of a normalized join [code]. Throws [GroupCodeNotFound].
  Future<GroupCodeLookup> lookupCode(String code);

  /// Whether [uid] is already a member (active or pending) of [groupId].
  /// Someone who left is not.
  Future<bool> isMember({required String groupId, required String uid});

  /// Joins [group]. Pass [password] when `group.hasPassword`; a wrong one
  /// throws [WrongGroupPassword].
  Future<JoinOutcome> join({
    required GroupCodeLookup group,
    required String uid,
    String? password,
  });

  /// [uid] leaves [groupId] (or withdraws a pending request), as decided by
  /// [planLeave]: the owner hands the group to the oldest member, or
  /// archives it when alone. The membership is soft deleted. Throws
  /// [NotAMember] if [uid] is no longer in the group.
  Future<void> leave({required String groupId, required String uid});

  /// Live current members (active and pending) of [groupId], unordered
  /// (see [sortMembers]). Only active members can list them.
  Stream<List<GroupMember>> watchMembers(String groupId);

  /// The admin [adminUid] removes the active member [memberUid] (soft
  /// delete; they may join again with the code). Throws [NotGroupAdmin] or
  /// [NotAMember].
  Future<void> removeMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  });

  /// The admin approves the pending request of [memberUid], who becomes an
  /// active member from now on.
  Future<void> approveMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  });

  /// The admin rejects the pending request of [memberUid] (they may ask
  /// again with the code).
  Future<void> rejectMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  });
}

class FirestoreGroupsRepository implements GroupsRepository {
  FirestoreGroupsRepository(
    this._firestore, {
    GroupPasswordHasher? hasher,
    Random? random,
  }) : _hasher = hasher ?? GroupPasswordHasher(),
       _random = random ?? Random.secure();

  final FirebaseFirestore _firestore;
  final GroupPasswordHasher _hasher;
  final Random _random;

  /// Join codes tried before giving up with [CodeGenerationExhausted].
  static const int maxCodeAttempts = 5;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection(FirestoreCollections.groups);

  DocumentReference<Map<String, dynamic>> _code(String code) =>
      _firestore.collection(FirestoreCollections.groupCodes).doc(code);

  DocumentReference<Map<String, dynamic>> _member(String gid, String uid) =>
      _groups.doc(gid).collection(FirestoreCollections.groupMembers).doc(uid);

  DocumentReference<Map<String, dynamic>> _password(String gid) => _groups
      .doc(gid)
      .collection(FirestoreCollections.groupSecrets)
      .doc(FirestoreCollections.groupPasswordDoc);

  DocumentReference<Map<String, dynamic>> _joinProof(String gid, String uid) =>
      _groups
          .doc(gid)
          .collection(FirestoreCollections.groupJoinProofs)
          .doc(uid);

  DocumentReference<Map<String, dynamic>> _newAuditEntry(String gid) =>
      _groups.doc(gid).collection(FirestoreCollections.groupAuditLog).doc();

  @override
  Stream<List<Group>> watchMyGroups(String uid) {
    // Two queries (active and pending) merged; neither needs an index.
    Stream<List<Group>> query(String field) => _groups
        .where(field, arrayContains: uid)
        .snapshots()
        .map(
          (s) => [
            for (final doc in s.docs)
              GroupMapper.fromFirestore(doc.id, doc.data()),
          ],
        );

    return _combineLatest(
      query(GroupFields.members),
      query(GroupFields.pendingMembers),
      (active, pending) {
        final byId = {
          for (final g in [...active, ...pending]) g.id: g,
        };
        return sortGroupsFor(
          uid,
          byId.values.where((g) => g.deletedAt == null),
        );
      },
    ).handleError((Object error, StackTrace stackTrace) {
      throw _map(error, stackTrace);
    });
  }

  @override
  Future<CreatedGroup> createGroup({
    required String uid,
    required String name,
    required bool requiresApproval,
    String? password,
  }) => _guard(() async {
    final groupName = name.trim();
    final withPassword = password != null && password.isNotEmpty;
    final salt = withPassword ? _hasher.newSalt() : null;
    final groupRef = _groups.doc();
    final gid = groupRef.id;

    for (var attempt = 0; attempt < maxCodeAttempts; attempt++) {
      final code = GroupCode.generate(groupName, _random);
      final codeRef = _code(code);
      final created = await _firestore.runTransaction((tx) async {
        if ((await tx.get(codeRef)).exists) return false;
        tx
          ..set(
            groupRef,
            GroupMapper.newGroup(
              name: groupName,
              code: code,
              ownerUid: uid,
              requiresApproval: requiresApproval,
              hasPassword: withPassword,
            ),
          )
          ..set(
            _member(gid, uid),
            GroupMapper.member(isAdmin: true, isActive: true),
          )
          ..set(
            codeRef,
            GroupMapper.codeEntry(
              groupId: gid,
              name: groupName,
              requiresApproval: requiresApproval,
              salt: salt,
            ),
          )
          ..set(
            _newAuditEntry(gid),
            GroupMapper.auditEntry(
              action: AuditLogFields.actionCreate,
              entity: AuditLogFields.entityGroup,
              entityId: gid,
              uid: uid,
              after: {
                GroupFields.name: groupName,
                GroupFields.code: code,
                GroupFields.requiresApproval: requiresApproval,
                GroupFields.hasPassword: withPassword,
              },
            ),
          );
        if (salt != null) {
          tx.set(_password(gid), {
            GroupSecretFields.hash: _hasher.hash(
              salt: salt,
              password: password!,
            ),
          });
        }
        return true;
      });
      if (created) {
        return CreatedGroup(
          groupId: gid,
          name: groupName,
          code: code,
          hasPassword: withPassword,
        );
      }
    }
    throw const CodeGenerationExhausted();
  });

  @override
  Future<GroupCodeLookup> lookupCode(String code) => _guard(() async {
    // From the server: a cached answer could hide a new group.
    final snapshot = await _code(code)
        .get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    final lookup = data == null
        ? null
        : GroupMapper.lookupFromFirestore(code, data);
    if (lookup == null) throw const GroupCodeNotFound();
    return lookup;
  });

  @override
  Future<bool> isMember({required String groupId, required String uid}) =>
      _guard(
        () async => GroupMapper.isCurrentMember(
          (await _member(groupId, uid).get()).data(),
        ),
      );

  @override
  Future<JoinOutcome> join({
    required GroupCodeLookup group,
    required String uid,
    String? password,
  }) => _guard(() async {
    final gid = group.groupId;
    final active = !group.requiresApproval;
    final batch = _firestore.batch();
    // Someone who left joins again by overwriting their old member document
    // (and join proof); the rules allow it only from status `left`.
    if (group.hasPassword) {
      final salt = group.passwordSalt;
      if (salt == null || password == null) throw const WrongGroupPassword();
      batch.set(_joinProof(gid, uid), {
        GroupSecretFields.hash: _hasher.hash(salt: salt, password: password),
      });
    }
    final status = active
        ? MemberFields.statusActive
        : MemberFields.statusPending;
    batch
      ..set(
        _member(gid, uid),
        GroupMapper.member(isAdmin: false, isActive: active),
      )
      ..update(_groups.doc(gid), {
        active ? GroupFields.members : GroupFields.pendingMembers:
            FieldValue.arrayUnion([uid]),
        GroupFields.updatedAt: FieldValue.serverTimestamp(),
      })
      ..set(
        _newAuditEntry(gid),
        GroupMapper.auditEntry(
          action: active
              ? AuditLogFields.actionJoin
              : AuditLogFields.actionRequest,
          entity: AuditLogFields.entityMember,
          entityId: uid,
          uid: uid,
          after: {MemberFields.status: status},
        ),
      );
    try {
      await batch.commit();
    } on FirebaseException catch (error) {
      // The rules reject a wrong password hash (the only rule a valid
      // join can break), so it is reported as such.
      if (group.hasPassword && error.code == 'permission-denied') {
        throw const WrongGroupPassword();
      }
      rethrow;
    }
    return active ? Joined(gid) : PendingApproval(group.groupName);
  });

  @override
  Future<void> leave({required String groupId, required String uid}) =>
      _guard(() async {
        final groupRef = _groups.doc(groupId);
        await _firestore.runTransaction((tx) async {
          final DocumentSnapshot<Map<String, dynamic>> snapshot;
          try {
            snapshot = await tx.get(groupRef);
          } on FirebaseException catch (error) {
            // Only current members can read the group.
            if (error.code == 'permission-denied') throw const NotAMember();
            rethrow;
          }
          final data = snapshot.data();
          if (data == null) throw const NotAMember();
          final group = GroupMapper.fromFirestore(groupId, data);
          final plan = planLeave(group, uid);
          final wasPending = plan is CancelRequest;
          final now = FieldValue.serverTimestamp();

          tx
            ..update(groupRef, {
              wasPending ? GroupFields.pendingMembers : GroupFields.members:
                  FieldValue.arrayRemove([uid]),
              GroupFields.updatedAt: now,
              if (plan case LeaveAndTransfer(:final newOwnerUid))
                GroupFields.ownerUid: newOwnerUid,
              if (plan is LeaveAndArchive) GroupFields.deletedAt: now,
            })
            ..update(_member(groupId, uid), GroupMapper.leftMember())
            ..set(
              _newAuditEntry(groupId),
              GroupMapper.auditEntry(
                action: wasPending
                    ? AuditLogFields.actionCancelRequest
                    : AuditLogFields.actionLeave,
                entity: AuditLogFields.entityMember,
                entityId: uid,
                uid: uid,
                before: {
                  MemberFields.status: wasPending
                      ? MemberFields.statusPending
                      : MemberFields.statusActive,
                },
                after: {MemberFields.status: MemberFields.statusLeft},
              ),
            );

          switch (plan) {
            case LeaveAndTransfer(:final newOwnerUid):
              tx
                ..update(_member(groupId, newOwnerUid), {
                  MemberFields.role: MemberFields.roleAdmin,
                })
                ..set(
                  _newAuditEntry(groupId),
                  GroupMapper.auditEntry(
                    action: AuditLogFields.actionTransferOwnership,
                    entity: AuditLogFields.entityGroup,
                    entityId: groupId,
                    uid: uid,
                    before: {GroupFields.ownerUid: uid},
                    after: {GroupFields.ownerUid: newOwnerUid},
                  ),
                );
            case LeaveAndArchive():
              tx
                ..update(_code(group.code), {GroupCodeFields.deletedAt: now})
                ..set(
                  _newAuditEntry(groupId),
                  GroupMapper.auditEntry(
                    action: AuditLogFields.actionArchive,
                    entity: AuditLogFields.entityGroup,
                    entityId: groupId,
                    uid: uid,
                    before: {GroupFields.deletedAt: null},
                    after: {GroupFields.deletedAt: now},
                  ),
                );
            case LeaveAsMember() || CancelRequest():
              break;
          }
        });
      });

  @override
  Stream<List<GroupMember>> watchMembers(String groupId) => _groups
      .doc(groupId)
      .collection(FirestoreCollections.groupMembers)
      .where(
        MemberFields.status,
        whereIn: [MemberFields.statusActive, MemberFields.statusPending],
      )
      .snapshots()
      .map(
        (s) => [
          for (final doc in s.docs)
            GroupMapper.memberFromFirestore(doc.id, doc.data()),
        ],
      )
      .handleError((Object error, StackTrace stackTrace) {
        throw _map(error, stackTrace);
      });

  @override
  Future<void> removeMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) => _adminChange(groupId, adminUid, (tx, group) {
    if (memberUid == adminUid || !group.isActiveMember(memberUid)) {
      throw const NotAMember();
    }
    tx
      ..update(_groups.doc(groupId), {
        GroupFields.members: FieldValue.arrayRemove([memberUid]),
        GroupFields.updatedAt: FieldValue.serverTimestamp(),
      })
      ..update(_member(groupId, memberUid), GroupMapper.removedMember(adminUid))
      ..set(
        _newAuditEntry(groupId),
        _memberAudit(
          AuditLogFields.actionRemove,
          adminUid: adminUid,
          memberUid: memberUid,
          from: MemberFields.statusActive,
          to: MemberFields.statusRemoved,
        ),
      );
  });

  @override
  Future<void> approveMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) => _adminChange(groupId, adminUid, (tx, group) {
    if (!group.isPending(memberUid)) throw const NotAMember();
    tx
      ..update(_groups.doc(groupId), {
        GroupFields.pendingMembers: FieldValue.arrayRemove([memberUid]),
        // Appended last, so `members` stays in join order.
        GroupFields.members: FieldValue.arrayUnion([memberUid]),
        GroupFields.updatedAt: FieldValue.serverTimestamp(),
      })
      ..update(_member(groupId, memberUid), {
        MemberFields.status: MemberFields.statusActive,
        MemberFields.joinedAt: FieldValue.serverTimestamp(),
      })
      ..set(
        _newAuditEntry(groupId),
        _memberAudit(
          AuditLogFields.actionApprove,
          adminUid: adminUid,
          memberUid: memberUid,
          from: MemberFields.statusPending,
          to: MemberFields.statusActive,
        ),
      );
  });

  @override
  Future<void> rejectMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) => _adminChange(groupId, adminUid, (tx, group) {
    if (!group.isPending(memberUid)) throw const NotAMember();
    tx
      ..update(_groups.doc(groupId), {
        GroupFields.pendingMembers: FieldValue.arrayRemove([memberUid]),
        GroupFields.updatedAt: FieldValue.serverTimestamp(),
      })
      ..update(_member(groupId, memberUid), GroupMapper.removedMember(adminUid))
      ..set(
        _newAuditEntry(groupId),
        _memberAudit(
          AuditLogFields.actionReject,
          adminUid: adminUid,
          memberUid: memberUid,
          from: MemberFields.statusPending,
          to: MemberFields.statusRemoved,
        ),
      );
  });

  /// Reads the group fresh in a transaction, checks that [adminUid] is its
  /// admin and lets [write] queue the changes.
  Future<void> _adminChange(
    String groupId,
    String adminUid,
    void Function(Transaction tx, Group group) write,
  ) => _guard(() async {
    await _firestore.runTransaction((tx) async {
      final data = (await tx.get(_groups.doc(groupId))).data();
      if (data == null) throw const NotAMember();
      final group = GroupMapper.fromFirestore(groupId, data);
      if (group.deletedAt != null) throw const NotAMember();
      if (!group.isAdmin(adminUid)) throw const NotGroupAdmin();
      write(tx, group);
    });
  });

  static Map<String, Object?> _memberAudit(
    String action, {
    required String adminUid,
    required String memberUid,
    required String from,
    required String to,
  }) => GroupMapper.auditEntry(
    action: action,
    entity: AuditLogFields.entityMember,
    entityId: memberUid,
    uid: adminUid,
    before: {MemberFields.status: from},
    after: {MemberFields.status: to},
  );

  /// Runs [action] and converts any error into a [GroupFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      throw _map(error, stackTrace);
    }
  }

  static GroupFailure _map(Object error, StackTrace stackTrace) {
    if (error is GroupFailure) return error;
    developer.log(
      'Group request failed',
      name: 'fbu.groups',
      error: error,
      stackTrace: stackTrace,
    );
    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' || 'deadline-exceeded' => const GroupNetworkFailure(),
        _ => UnknownGroupFailure(error.code),
      };
    }
    return const UnknownGroupFailure();
  }
}

/// Emits [combine] of the latest values of [a] and [b] once both emitted.
Stream<R> _combineLatest<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combine,
) {
  late final StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  A? lastA;
  B? lastB;
  var hasA = false;
  var hasB = false;
  var done = 0;

  void emit() {
    if (hasA && hasB) controller.add(combine(lastA as A, lastB as B));
  }

  void onDone() {
    if (++done == 2) controller.close();
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (value) {
          lastA = value;
          hasA = true;
          emit();
        },
        onError: controller.addError,
        onDone: onDone,
      );
      subB = b.listen(
        (value) {
          lastB = value;
          hasB = true;
          emit();
        },
        onError: controller.addError,
        onDone: onDone,
      );
    },
    onPause: () {
      subA?.pause();
      subB?.pause();
    },
    onResume: () {
      subA?.resume();
      subB?.resume();
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return controller.stream;
}
