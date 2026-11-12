import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Fukaha's theme reveal: 900ms expanding circle, ease-in-out cubic.
const Duration kThemeRippleDuration = Duration(milliseconds: 900);

/// Fukaha language fallback: old snapshot fades + eases to 0.995 scale.
const Duration kLanguageFadeDuration = Duration(milliseconds: 420);
const Curve kLanguageMotion = Cubic(0.2, 0, 0, 1);

/// Distance from [origin] to the farthest corner of [size].
double themeRevealRadius(Size size, Offset origin) {
  final farthest = [
    Offset.zero,
    Offset(size.width, 0),
    Offset(0, size.height),
    Offset(size.width, size.height),
  ].fold<double>(0, (max, corner) => math.max(max, (corner - origin).distance));
  return farthest;
}

/// Punches an expanding hole in the frozen old UI so the new theme shows through.
class ThemeRevealClipper extends CustomClipper<Path> {
  const ThemeRevealClipper({required this.origin, required this.radius});

  final Offset origin;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: origin, radius: radius));
  }

  @override
  bool shouldReclip(ThemeRevealClipper oldClipper) =>
      oldClipper.origin != origin || oldClipper.radius != radius;
}

/// Looks up [ThemeRippleHost] and plays a circular reveal from [context].
abstract final class ThemeRipple {
  static Future<void> apply(
    BuildContext context,
    Future<void> Function() change, {
    ThemeMode? nextMode,
    Offset? origin,
    Future<void> Function()? prepare,
  }) async {
    if (!context.mounted) {
      await change();
      return;
    }

    final host = context
        .getInheritedWidgetOfExactType<_ThemeRippleScope>()
        ?.state;
    if (host != null && host.isBusy) {
      await change();
      return;
    }

    if (nextMode != null) {
      final next = switch (nextMode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system => MediaQuery.platformBrightnessOf(context),
      };
      if (next == Theme.of(context).brightness) {
        await change();
        return;
      }
    }

    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      await change();
      return;
    }

    final resolvedOrigin = origin ?? _globalCenter(context) ?? Offset.zero;

    if (host == null) {
      await change();
      return;
    }
    await host.revealFrom(resolvedOrigin, change, prepare: prepare);
  }

  static Offset? _globalCenter(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  /// Crossfades locale by freezing the old page, swapping, then fading it out.
  static Future<void> fadeLocale(
    BuildContext context,
    Future<void> Function() change,
  ) async {
    if (!context.mounted) {
      await change();
      return;
    }

    final host = context
        .getInheritedWidgetOfExactType<_ThemeRippleScope>()
        ?.state;
    if (host != null && host.isBusy) {
      await change();
      return;
    }

    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      await change();
      return;
    }

    if (host == null) {
      await change();
      return;
    }
    await host.fadeThrough(change);
  }
}

/// Freezes the current frame, switches the theme underneath, then opens a
/// circle from the control that triggered the change.
class ThemeRippleHost extends StatefulWidget {
  const ThemeRippleHost({required this.child, this.overlay, super.key});

  final Widget child;

  /// Drawn above the captured page so chrome (language / theme) stays live.
  final Widget? overlay;

  @override
  State<ThemeRippleHost> createState() => _ThemeRippleHostState();
}

class _ThemeRippleHostState extends State<ThemeRippleHost>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();

  late final AnimationController _controller;
  late final Animation<double> _progress;

  ui.Image? _overlay;
  Offset _origin = Offset.zero;
  var _fadeLocale = false;
  bool _busy = false;

  bool get isBusy => _busy;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kThemeRippleDuration,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _clearOverlay();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlay?.dispose();
    super.dispose();
  }

  Future<void> revealFrom(
    Offset globalOrigin,
    Future<void> Function() change, {
    Future<void> Function()? prepare,
  }) async {
    if (!mounted) {
      await change();
      return;
    }
    if (_busy) return;
    _busy = true;

    final snapshot = _capture();
    if (snapshot == null || !mounted) {
      _busy = false;
      await change();
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    setState(() {
      _overlay?.dispose();
      _overlay = snapshot;
      _origin = box?.globalToLocal(globalOrigin) ?? globalOrigin;
      _fadeLocale = false;
    });
    _controller.duration = kThemeRippleDuration;
    await SchedulerBinding.instance.endOfFrame;

    try {
      await change();
    } catch (_) {
      _clearOverlay();
      rethrow;
    }
    if (!mounted) return;

    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    if (prepare != null) {
      await prepare();
      if (!mounted) return;
      await SchedulerBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    try {
      await _controller.forward(from: 0);
    } on TickerCanceled {
      _clearOverlay();
      return;
    }
  }

  Future<void> fadeThrough(Future<void> Function() change) async {
    if (!mounted) {
      await change();
      return;
    }
    if (_busy) return;
    _busy = true;

    final snapshot = _capture();
    if (snapshot == null || !mounted) {
      _busy = false;
      await change();
      return;
    }

    setState(() {
      _overlay?.dispose();
      _overlay = snapshot;
      _fadeLocale = true;
    });
    _controller.duration = kLanguageFadeDuration;
    await SchedulerBinding.instance.endOfFrame;

    try {
      await change();
    } catch (_) {
      _clearOverlay();
      rethrow;
    }
    if (!mounted) return;

    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    try {
      await _controller.forward(from: 0);
    } on TickerCanceled {
      _clearOverlay();
      return;
    }
  }

  ui.Image? _capture() {
    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null || !boundary.hasSize) return null;
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
      return boundary.toImageSync(pixelRatio: dpr.clamp(1.0, 3.0));
    } catch (_) {
      // HTML renderer and widget tests cannot always snapshot the layer.
      return null;
    }
  }

  void _clearOverlay() {
    final image = _overlay;
    _overlay = null;
    _busy = false;
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => image?.dispose());
    } else {
      image?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeRippleScope(
      state: this,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(key: _boundaryKey, child: widget.child),
          if (_overlay != null)
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, child) {
                      if (_fadeLocale) {
                        final t = kLanguageMotion.transform(_controller.value);
                        return Opacity(
                          opacity: 1 - t,
                          child: Transform.scale(
                            scale: 1 - (0.005 * t),
                            child: child,
                          ),
                        );
                      }
                      final size = MediaQuery.sizeOf(context);
                      final radius =
                          themeRevealRadius(size, _origin) * _progress.value;
                      return ClipPath(
                        clipper: ThemeRevealClipper(
                          origin: _origin,
                          radius: radius,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: child,
                      );
                    },
                    child: RawImage(
                      image: _overlay,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.overlay != null) widget.overlay!,
        ],
      ),
    );
  }
}

class _ThemeRippleScope extends InheritedWidget {
  const _ThemeRippleScope({required this.state, required super.child});

  final _ThemeRippleHostState state;

  @override
  bool updateShouldNotify(_ThemeRippleScope oldWidget) => false;
}
