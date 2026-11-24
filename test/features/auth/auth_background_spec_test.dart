import 'dart:math' as math;

import 'package:financial_between_us/features/auth/presentation/background/auth_background_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const epsilon = 1e-9;

  void expectPose(LayerPose actual, LayerPose expected) {
    expect(actual.dx, closeTo(expected.dx, epsilon), reason: 'dx');
    expect(actual.dy, closeTo(expected.dy, epsilon), reason: 'dy');
    expect(actual.scaleX, closeTo(expected.scaleX, epsilon), reason: 'scaleX');
    expect(actual.scaleY, closeTo(expected.scaleY, epsilon), reason: 'scaleY');
    expect(
      actual.rotation,
      closeTo(expected.rotation, epsilon),
      reason: 'rotation',
    );
  }

  double deg(double value) => value * math.pi / 180;

  group('core (16 s, 4 segments)', () {
    final core = AuthBackgroundSpec.core;

    test('hits every keyframe', () {
      expectPose(core.poseAt(0), const LayerPose());
      expectPose(
        core.poseAt(4),
        const LayerPose(dx: 0.0325, dy: 0.0062, scaleX: 1.14, scaleY: 0.92),
      );
      expectPose(
        core.poseAt(8),
        const LayerPose(dx: 0.065, dy: 0.0248, scaleX: 1.04, scaleY: 1.16),
      );
      expectPose(
        core.poseAt(12),
        const LayerPose(dx: 0.026, dy: 0.0155, scaleX: 0.90, scaleY: 1.06),
      );
    });

    test('loops without a jump', () {
      expectPose(core.poseAt(16), core.poseAt(0));
      expectPose(core.poseAt(16 + 4), core.poseAt(4));
    });

    test('eases each segment (midpoint is halfway with easeInOutSine)', () {
      final mid = core.poseAt(2);
      expect(mid.dx, closeTo(0.0325 / 2, 1e-6));
      // Before the midpoint the eased value lags behind a linear one.
      expect(core.poseAt(1).dx, lessThan(0.0325 / 4));
    });
  });

  test('waves rotate between their keyframes', () {
    expectPose(
      AuthBackgroundSpec.waveA.poseAt(0),
      LayerPose(dx: -0.04, rotation: deg(-8)),
    );
    expectPose(
      AuthBackgroundSpec.waveA.poseAt(8.5),
      LayerPose(dx: 0.04, dy: 0.0052, rotation: deg(-5)),
    );
    expectPose(
      AuthBackgroundSpec.waveB.poseAt(12.5),
      LayerPose(dx: -0.0375, dy: -0.004, rotation: deg(3)),
    );
    expectPose(
      AuthBackgroundSpec.teal.poseAt(11.5),
      const LayerPose(dx: -0.063, dy: 0.0102),
    );
  });

  test('amplified scales translation and scale but not rotation', () {
    final pose = LayerPose(
      dx: 0.04,
      dy: -0.02,
      scaleX: 1.1,
      scaleY: 0.9,
      rotation: deg(-8),
    ).amplified(1.5);
    expectPose(
      pose,
      LayerPose(
        dx: 0.06,
        dy: -0.03,
        scaleX: 1.15,
        scaleY: 0.85,
        rotation: deg(-8),
      ),
    );
    expectPose(const LayerPose().amplified(1.5), const LayerPose());
  });

  test('layers are painted core → teal → wave B → wave A', () {
    expect(AuthBackgroundSpec.layers.map((layer) => layer.name), [
      'core',
      'teal',
      'waveB',
      'waveA',
    ]);
  });

  test('breathing goes 0.9 → 1.1 → 0.9 every 8 s', () {
    expect(AuthBackgroundSpec.breathFactor(0), closeTo(0.9, epsilon));
    expect(AuthBackgroundSpec.breathFactor(4), closeTo(1.1, epsilon));
    expect(AuthBackgroundSpec.breathFactor(2), closeTo(1.0, 1e-6));
    expect(AuthBackgroundSpec.breathFactor(8), closeTo(0.9, epsilon));
  });

  test('variant transform interpolates welcome → form', () {
    final welcome = GlowGroupTransform.lerp(0);
    final form = GlowGroupTransform.lerp(1);
    final half = GlowGroupTransform.lerp(0.5);
    expect(welcome.scale, 1);
    expect(welcome.opacity, 1);
    expect(form.scale, closeTo(0.72, epsilon));
    expect(form.dx, closeTo(-0.06, epsilon));
    expect(form.dy, closeTo(-0.08, epsilon));
    expect(form.opacity, closeTo(0.6, epsilon));
    expect(half.scale, closeTo(0.86, epsilon));
    expect(half.opacity, closeTo(0.8, epsilon));
  });
}
