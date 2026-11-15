import 'dart:math';
import 'package:flutter/material.dart';

enum DogMood { idle, typing, password, sad, happy }

class DogMascot extends StatefulWidget {
  final DogMood mood;

  /// Hacia dónde miran los ojos: -1 (izquierda) a 1 (derecha)
  final double lookX;
  final double size;

  const DogMascot({
    super.key,
    required this.mood,
    this.lookX = 0,
    this.size = 120,
  });

  @override
  State<DogMascot> createState() => _DogMascotState();
}

class _DogMascotState extends State<DogMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cover = widget.mood == DogMood.password ? 1.0 : 0.0;
    final tilt = widget.mood == DogMood.typing ? -0.02 : 0.0;

    // Patitas que suben a tapar los ojos
    return TweenAnimationBuilder<double>(
      tween: Tween(end: cover),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, coverValue, _) {
        // Ojos que siguen el texto
        return TweenAnimationBuilder<double>(
          tween: Tween(end: widget.lookX),
          duration: const Duration(milliseconds: 200),
          builder: (context, look, _) {
            return AnimatedRotation(
              turns: tilt,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _DogPainter(
                          t: _ctrl.value,
                          cover: coverValue.clamp(0.0, 1.0),
                          lookX: look,
                          mood: widget.mood,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DogPainter extends CustomPainter {
  final double t;
  final double cover;
  final double lookX;
  final DogMood mood;

  _DogPainter({
    required this.t,
    required this.cover,
    required this.lookX,
    required this.mood,
  });

  static const _fur = Color(0xFFD9A066);
  static const _earColor = Color(0xFF8D5524);
  static const _muzzle = Color(0xFFF5DEB3);
  static const _dark = Color(0xFF3E2723);
  static const _paw = Color(0xFFC68642);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);

    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = _dark;

    // Animaciones suaves
    final wagSpeed = mood == DogMood.happy
        ? 6.0
        : mood == DogMood.typing
            ? 3.0
            : 1.0;
    final wag = sin(t * 2 * pi * wagSpeed);
    final bob = sin(t * 2 * pi * 2) * 1.5;
    final blinkPhase = (t - 0.9) / 0.06;
    final blink = (blinkPhase >= 0 && blinkPhase <= 1)
        ? sin(blinkPhase * pi)
        : 0.0;

    canvas.translate(0, bob);

    // ---------- OREJAS ----------
    final earBase = mood == DogMood.sad ? 0.8 : 0.35;
    void ear(double cx, double angle) {
      canvas.save();
      canvas.translate(cx, 44);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 26, height: 44),
        fill..color = _earColor,
      );
      canvas.restore();
    }

    final earMove = mood == DogMood.sad ? 0.0 : wag * 0.12;
    ear(26, earBase + earMove);
    ear(94, -earBase - earMove);

    // ---------- CABEZA ----------
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 64), width: 78, height: 72),
      fill..color = _fur,
    );

    // Mancha en un ojo
    canvas.drawCircle(const Offset(76, 56), 13, fill..color = _earColor);

    // Hocico
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 80), width: 44, height: 32),
      fill..color = _muzzle,
    );

    // ---------- OJOS ----------
    void eye(double cx) {
      if (mood == DogMood.happy) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, 58), width: 12, height: 10),
          pi,
          pi,
          false,
          line,
        );
        return;
      }
      final open = (1 - blink).clamp(0.1, 1.0);
      final ox = lookX * 2.5;
      final oy = mood == DogMood.typing ? 2.0 : 0.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + ox, 56 + oy),
          width: 11,
          height: 11 * open,
        ),
        fill..color = _dark,
      );
      if (open > 0.5) {
        canvas.drawCircle(
          Offset(cx + ox + 2, 54 + oy),
          1.8,
          fill..color = Colors.white,
        );
      }
    }

    eye(44);
    eye(76);

    // Cejas tristes
    if (mood == DogMood.sad) {
      canvas.drawLine(const Offset(37, 50), const Offset(51, 45), line);
      canvas.drawLine(const Offset(69, 45), const Offset(83, 50), line);
    }

    // ---------- NARIZ ----------
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 72), width: 16, height: 11),
      fill..color = _dark,
    );
    canvas.drawCircle(
      const Offset(57, 70), 1.5, fill..color = Colors.white54);

    // ---------- BOCA ----------
    canvas.drawLine(const Offset(60, 77), const Offset(60, 81), line);

    if (mood == DogMood.happy || mood == DogMood.typing) {
      // Lengüita
      final lengua = mood == DogMood.happy ? 13.0 + wag.abs() * 2 : 8.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(54, 84, 12, lengua),
          const Radius.circular(6),
        ),
        fill..color = const Color(0xFFFF8A9B),
      );
    }

    if (mood == DogMood.sad) {
      canvas.drawArc(const Rect.fromLTWH(48, 85, 12, 10), pi, pi, false, line);
      canvas.drawArc(const Rect.fromLTWH(60, 85, 12, 10), pi, pi, false, line);
    } else {
      canvas.drawArc(const Rect.fromLTWH(48, 78, 12, 10), 0, pi, false, line);
      canvas.drawArc(const Rect.fromLTWH(60, 78, 12, 10), 0, pi, false, line);
    }

    // ---------- PATITAS (tapan los ojos) ----------
    if (cover > 0.01) {
      final y = 125 - (125 - 56) * cover;
      void paw(double cx) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, y), width: 28, height: 24),
          fill..color = _paw,
        );
        final toe = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = _earColor;
        canvas.drawLine(Offset(cx - 4, y - 8), Offset(cx - 4, y - 2), toe);
        canvas.drawLine(Offset(cx + 4, y - 8), Offset(cx + 4, y - 2), toe);
      }

      paw(46);
      paw(74);
    }
  }

  @override
  bool shouldRepaint(covariant _DogPainter old) => true;
}