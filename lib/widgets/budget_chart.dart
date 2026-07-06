import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BudgetChart extends StatefulWidget {
  final Map<String, double> categoryData;
  final double totalAmount;

  const BudgetChart({
    super.key,
    required this.categoryData,
    required this.totalAmount,
  });

  @override
  State<BudgetChart> createState() => _BudgetChartState();
}

class _BudgetChartState extends State<BudgetChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(BudgetChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation on data change to make it feel dynamic
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.analytics_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              // Custom paint for chart
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: _DonutChartPainter(
                      data: widget.categoryData,
                      total: widget.totalAmount,
                      animationValue: _animation.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
              // Text in the center of donut
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL SPENT',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Legend list
          if (widget.categoryData.isEmpty)
            Center(
              child: Text(
                'No transactions logged yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: widget.categoryData.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final color = AppTheme.getCategoryColor(category);
                final percentage = widget.totalAmount > 0 
                    ? (amount / widget.totalAmount * 100).toStringAsFixed(1)
                    : '0.0';

                return IntrinsicWidth(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$category ($percentage%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  final double animationValue;
  final bool isDark;

  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16; // Margin for stroke width
    const strokeWidth = 20.0;

    // Draw background empty ring
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF334155).withOpacity(0.3) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, bgPaint);

    if (total == 0 || data.isEmpty) return;

    var startAngle = -math.pi / 2; // Start from top (12 o'clock)

    for (var entry in data.entries) {
      final category = entry.key;
      final amount = entry.value;
      
      final sweepAngle = (amount / total) * 2 * math.pi * animationValue;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = AppTheme.getCategoryColor(category)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw the segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.total != total || 
           oldDelegate.data.length != data.length;
  }
}
