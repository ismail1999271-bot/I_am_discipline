import 'package:flutter/material.dart';
import 'package:i_am_disiplin/services/store.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final female = AppStore.I.gender == 'kadin';
    final asset = female ? 'assets/splash_female.jpg' : 'assets/splash_male.jpg';
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            painter: _StatuePainter(female: female),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _StatuePainter extends CustomPainter {
  final bool female;
  const _StatuePainter({required this.female});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(Offset.zero & size, bg);
    final gold = Paint()
      ..color = const Color(0xFFE8A317)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final fill = Paint()
      ..color = const Color(0xFF1A1408)
      ..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    final head = Offset(cx, size.height * 0.22);
    canvas.drawCircle(head, size.width * 0.07, fill);
    canvas.drawCircle(head, size.width * 0.07, gold);
    if (female) {
      final tail = Path()
        ..moveTo(cx + size.width * 0.05, size.height * 0.20)
        ..quadraticBezierTo(cx + size.width * 0.16, size.height * 0.28, cx + size.width * 0.04, size.height * 0.36);
      canvas.drawPath(tail, gold);
    } else {
      canvas.drawLine(
        Offset(cx - size.width * 0.05, size.height * 0.175),
        Offset(cx + size.width * 0.05, size.height * 0.175),
        gold,
      );
    }
    final body = Path();
    final top = size.height * 0.31;
    if (female) {
      body.moveTo(cx, top);
      body.lineTo(cx - size.width * 0.16, size.height * 0.72);
      body.lineTo(cx + size.width * 0.16, size.height * 0.72);
      body.close();
    } else {
      body.addRect(Rect.fromCenter(
        center: Offset(cx, size.height * 0.48),
        width: size.width * 0.22,
        height: size.height * 0.28,
      ));
    }
    canvas.drawPath(body, fill);
    canvas.drawPath(body, gold);
    canvas.drawLine(Offset(cx, size.height * 0.29), Offset(cx, top), gold);
    canvas.drawLine(Offset(cx - size.width * 0.08, size.height * 0.38), Offset(cx - size.width * 0.2, size.height * 0.52), gold);
    canvas.drawLine(Offset(cx + size.width * 0.08, size.height * 0.38), Offset(cx + size.width * 0.2, size.height * 0.52), gold);
    if (!female) {
      canvas.drawLine(Offset(cx - size.width * 0.06, size.height * 0.62), Offset(cx - size.width * 0.07, size.height * 0.84), gold);
      canvas.drawLine(Offset(cx + size.width * 0.06, size.height * 0.62), Offset(cx + size.width * 0.07, size.height * 0.84), gold);
    } else {
      canvas.drawLine(Offset(cx - size.width * 0.05, size.height * 0.72), Offset(cx - size.width * 0.06, size.height * 0.88), gold);
      canvas.drawLine(Offset(cx + size.width * 0.05, size.height * 0.72), Offset(cx + size.width * 0.06, size.height * 0.88), gold);
    }
  }

  @override
  bool shouldRepaint(covariant _StatuePainter oldDelegate) => oldDelegate.female != female;
}
