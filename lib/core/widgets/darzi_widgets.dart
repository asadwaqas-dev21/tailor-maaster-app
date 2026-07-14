import "package:flutter/material.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/app/theme/darzi_theme_colors.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/domain/entities/order.dart";

/// Dashed stitch divider from the mockup.
class StitchDivider extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const StitchDivider({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final c = DarziThemeColors.of(context);
    return Padding(
      padding: margin,
      child: CustomPaint(
        painter: _DashPainter(color: c.line),
        size: const Size(double.infinity, 2),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 1), Offset((x + dash).clamp(0, size.width), 1), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small measuring-tape strip.
class MeasuringTapeBar extends StatelessWidget {
  final String label;
  final double height;

  const MeasuringTapeBar({
    super.key,
    this.label = "INCHES",
    this.height = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.brassSoft, AppColors.brass],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _TapeTicksPainter()),
          ),
          PositionedDirectional(
            start: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                label,
                style: AppTypography.mono(
                  size: 10,
                  weight: FontWeight.w700,
                  color: const Color(0xFF4A3A12),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapeTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.55), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pine / brass stat chip on Orders home.
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool brass;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.brass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: brass ? null : AppColors.pine,
        gradient: brass ? AppColors.brassGradient : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.ui(
              size: 10,
              color: brass
                  ? const Color(0xFF20180A).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.mono(
              size: 20,
              weight: FontWeight.w700,
              color: brass ? const Color(0xFF20180A) : const Color(0xFFEEF4F2),
              height: 1.1,
            ),
          ),
          Text(
            unit,
            style: AppTypography.ui(
              size: 9,
              color: brass
                  ? const Color(0xFF20180A).withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient avatar with initials.
class DarziAvatar extends StatelessWidget {
  final String name;
  final double size;
  final LinearGradient? gradient;
  final Color? textColor;

  const DarziAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.gradient,
    this.textColor,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty || parts.first.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  LinearGradient get _gradient {
    if (gradient != null) return gradient!;
    final hash = name.hashCode.abs();
    final options = [
      AppColors.avatarPine,
      AppColors.avatarBrass,
      AppColors.avatarCrimson,
    ];
    return options[hash % options.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: _gradient,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTypography.display(
          size: size * 0.38,
          weight: FontWeight.w700,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}

/// Status pill with colored dot.
class StatusPill extends StatelessWidget {
  final OrderStatus status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.pillBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.labelEn,
            style: AppTypography.ui(
              size: 10.5,
              weight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pipeline track: Mila → Cutting → Silai → Ready → Diya
/// [compact] hides Diya (4 dots) for home order cards.
class OrderTrack extends StatelessWidget {
  final OrderStatus status;
  final bool showLabels;
  final bool compact;

  const OrderTrack({
    super.key,
    required this.status,
    this.showLabels = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final values = compact
        ? OrderStatus.values
            .where((s) => s != OrderStatus.delivered)
            .toList()
        : OrderStatus.values;
    final displayStatus = compact && status == OrderStatus.delivered
        ? OrderStatus.ready
        : status;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < values.length; i++) ...[
              _Dot(
                done: values[i].index < displayStatus.index,
                on: values[i] == displayStatus,
              ),
              if (i < values.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: values[i].index < displayStatus.index
                        ? AppColors.pine
                        : DarziThemeColors.of(context).line,
                  ),
                ),
            ],
          ],
        ),
        if (showLabels) ...[
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: values.map((s) {
              final isCurrent = s == displayStatus;
              return Text(
                s.shortLabel,
                style: AppTypography.mono(
                  size: 9,
                  color: isCurrent
                      ? DarziThemeColors.of(context).brass
                      : DarziThemeColors.of(context).muted,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool done;
  final bool on;
  const _Dot({required this.done, required this.on});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
                color: on
            ? AppColors.brass
            : done
                ? AppColors.pine
                : DarziThemeColors.of(context).line,
      ),
    );
  }
}

/// Order card matching mockup (rush ribbon, status, due, track).
class DarziOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const DarziOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  bool get _rush {
    if (order.isRush) return true;
    final notes = (order.designNotes ?? "").toLowerCase();
    return notes.contains("rush") ||
        notes.contains("shaadi") ||
        notes.contains("eid") ||
        (order.deliveryDate.difference(DateTime.now()).inDays <= 1 &&
            order.status != OrderStatus.ready &&
            order.status != OrderStatus.delivered);
  }

  @override
  Widget build(BuildContext context) {
    final c = DarziThemeColors.of(context);
    final dueText = order.status == OrderStatus.ready ||
            order.status == OrderStatus.delivered
        ? "Ho gaya"
        : _rush
            ? order.deliveryDate.rushRelative
            : order.deliveryDate.relative;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _rush
                ? AppColors.crimson.withValues(alpha: 0.35)
                : c.line,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            if (_rush)
              PositionedDirectional(
                top: -2,
                end: -28,
                child: Transform.rotate(
                  angle: Directionality.of(context) == TextDirection.rtl
                      ? -0.785
                      : 0.785,
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.crimson,
                    alignment: Alignment.center,
                    child: Text(
                      "RUSH",
                      style: AppTypography.ui(
                        size: 9,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              children: [
                Row(
                  children: [
                    DarziAvatar(name: order.customerName),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: AppTypography.ui(
                              size: 14,
                              weight: FontWeight.w600,
                              color: c.ink,
                              letterSpacing: -0.1,
                            ),
                          ),
                          Text(
                            order.garmentTitle,
                            style: AppTypography.ui(
                              size: 11.5,
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(status: order.status),
                    Row(
                      children: [
                        Icon(
                          order.status == OrderStatus.ready
                              ? Icons.check
                              : Icons.schedule,
                          size: 13,
                          color: c.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dueText,
                          style: AppTypography.mono(
                            size: 11,
                            weight: _rush ? FontWeight.w700 : FontWeight.w400,
                            color: _rush ? AppColors.crimson : c.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (order.status != OrderStatus.ready &&
                    order.status != OrderStatus.delivered) ...[
                  const SizedBox(height: 12),
                  OrderTrack(status: order.status, compact: true),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded icon button used in app bars.
class DarziIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const DarziIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = DarziThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.iconBtn,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 19,
          color: c.ink,
          matchTextDirection: true,
        ),
      ),
    );
  }
}

/// Brass / pine / WhatsApp primary button.
class DarziButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final DarziButtonVariant variant;
  final bool expanded;

  const DarziButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = DarziButtonVariant.brass,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (variant) {
      case DarziButtonVariant.brass:
        bg = AppColors.brass;
        fg = AppColors.pineDeep;
      case DarziButtonVariant.pine:
        bg = AppColors.pine;
        fg = Colors.white;
      case DarziButtonVariant.whatsapp:
        bg = AppColors.whatsapp;
        fg = Colors.white;
    }

    final child = Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: variant == DarziButtonVariant.brass
            ? AppColors.brassGradient
            : null,
        color: variant == DarziButtonVariant.brass ? null : bg,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.ui(
              size: 15,
              weight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: expanded ? child : IntrinsicWidth(child: child),
      ),
    );
  }
}

enum DarziButtonVariant { brass, pine, whatsapp }
