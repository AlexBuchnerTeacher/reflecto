import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class ReflectoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final String? titleEmoji;
  final String? title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback? onTap;
  final bool? isCollapsible;
  final bool? isCollapsed;
  final ValueChanged<bool>? onCollapsedChanged;

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
    this.isCollapsible = false,
    this.isCollapsed,
    this.onCollapsedChanged,
  });

  @override
  State<ReflectoCard> createState() => _ReflectoCardState();
}

class _ReflectoCardState extends State<ReflectoCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late bool _internalCollapsed;
  late AnimationController _collapseController;
  late Animation<double> _collapseAnimation;

  @override
  void initState() {
    super.initState();
    _internalCollapsed = widget.isCollapsed ?? false;
    _collapseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: _internalCollapsed ? 0.0 : 1.0,
    );
    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ReflectoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != null &&
        widget.isCollapsed != _internalCollapsed) {
      _internalCollapsed = widget.isCollapsed!;
      if (_internalCollapsed) {
        _collapseController.reverse();
      } else {
        _collapseController.forward();
      }
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _internalCollapsed = !_internalCollapsed;
      if (_internalCollapsed) {
        _collapseController.reverse();
      } else {
        _collapseController.forward();
      }
      widget.onCollapsedChanged?.call(_internalCollapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = cs.surfaceCard;
    final activeBg = cs.surfaceContainerHighest;
    final isActive = widget.isActive;
    final bg = isActive ? activeBg : baseColor;
    final blur = isActive ? 10.0 : (_hover ? 8.0 : 4.0);
    final shadowColor = Colors.black.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08,
    );
    final borderColor = cs.borderSubtle;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ReflectoRadii.card),
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
                child: Row(
                  children: [
                    Expanded(
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
                    if (widget.isCollapsible == true)
                      IconButton(
                        icon: AnimatedRotation(
                          turns: _internalCollapsed ? 0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                        onPressed: _toggleCollapse,
                        tooltip:
                            _internalCollapsed ? 'Aufklappen' : 'Einklappen',
                      ),
                  ],
                ),
              ),
            SizeTransition(
              sizeFactor: _collapseAnimation,
              axisAlignment: -1.0,
              child: widget.child,
            ),
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
