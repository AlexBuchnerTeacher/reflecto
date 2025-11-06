import 'package:flutter/material.dart';

class ReflectoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final String? titleEmoji;
  final String? title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback? onTap;

  const ReflectoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.titleEmoji,
    this.title,
    this.subtitle,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<ReflectoCard> createState() => _ReflectoCardState();
}

class _ReflectoCardState extends State<ReflectoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = cs.surfaceContainerHigh;
    final activeBg = cs.surfaceContainerHighest;
    final isActive = widget.isActive;
    final bg = isActive ? activeBg : baseColor;
    final blur = isActive ? 10.0 : (_hover ? 8.0 : 4.0);
    final shadowColor = Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08);
    final borderColor = cs.outlineVariant.withValues(alpha: 0.5);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blur,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null || widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.title != null)
                      Text(
                        '${widget.titleEmoji ?? ''}${widget.titleEmoji != null ? ' ' : ''}${widget.title}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            widget.child,
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(onTap: widget.onTap, child: card),
    );
  }
}
