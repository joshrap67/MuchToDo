import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final double size;
  final double offset;

  const LoginHeader({super.key, required this.size, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: Clipper(),
          child: Container(
            height: size * offset,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF9ea7de),
                  Color(0xFFb1f4cf),
                ],
              ),
            ),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Much To Do',
              style: TextStyle(
                fontSize: 45,
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    double xCenter = size.width * 0.5;
    double yCenter = size.height - 100;
    path.quadraticBezierTo(xCenter, yCenter, size.width, size.height);

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
