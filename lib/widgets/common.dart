import 'package:flutter/material.dart';

import '../theme.dart';

/// Shows a bundled asset (path starting with `assets/`) or a network image
/// with a loading/error placeholder.
class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(loading: true),
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) => Container(
    width: width,
    height: height,
    color: AppColors.lightGrey,
    alignment: Alignment.center,
    child: loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.grey,
            ),
          )
        : const Icon(Icons.image_outlined, color: AppColors.grey),
  );
}

class StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const StarRow({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = rating >= i + 0.75
            ? Icons.star_rounded
            : rating >= i + 0.25
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: AppColors.green);
      }),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onShowAll;

  const SectionHeader({super.key, required this.title, this.onShowAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onShowAll,
            style: TextButton.styleFrom(foregroundColor: AppColors.grey),
            child: const Text('Show all', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

enum DesignIconKind { menu, glasses, lipstick }

class DesignIcon extends StatelessWidget {
  final DesignIconKind kind;
  final Color color;
  const DesignIcon(this.kind, {super.key, this.color = AppColors.dark});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 26,
    height: 26,
    child: CustomPaint(painter: _DesignIconPainter(kind, color)),
  );
}

class _DesignIconPainter extends CustomPainter {
  final DesignIconKind kind;
  final Color color;
  _DesignIconPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (kind == DesignIconKind.menu) {
      canvas.drawLine(const Offset(3, 5), const Offset(14, 5), paint);
      canvas.drawLine(const Offset(3, 13), const Offset(22, 13), paint);
      canvas.drawLine(const Offset(3, 21), const Offset(18, 21), paint);
    } else if (kind == DesignIconKind.glasses) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 11, 8, 8),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(15, 11, 8, 8),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.drawLine(const Offset(11, 13), const Offset(15, 13), paint);
      canvas.drawLine(const Offset(3, 11), const Offset(7, 6), paint);
      canvas.drawLine(const Offset(23, 11), const Offset(19, 6), paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(10, 14, 6, 10),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.drawRect(const Rect.fromLTWH(11, 7, 4, 7), paint);
      canvas.drawPath(
        Path()
          ..moveTo(11, 7)
          ..lineTo(11, 3)
          ..lineTo(15, 2)
          ..lineTo(15, 7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DesignIconPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}
