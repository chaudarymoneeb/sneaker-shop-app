import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const AnimatedPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.black.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(label, key: const ValueKey('label')),
        ),
      ),
    );
  }
}

/// Wrap any widget (e.g. a form) in this to trigger a horizontal shake animation on error.
class ShakeErrorWrapper extends StatefulWidget {
  final Widget child;
  final bool triggerShake;

  const ShakeErrorWrapper({
    super.key,
    required this.child,
    required this.triggerShake,
  });

  @override
  State<ShakeErrorWrapper> createState() => _ShakeErrorWrapperState();
}

class _ShakeErrorWrapperState extends State<ShakeErrorWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animation =
        Tween<double>(
            begin: 0,
            end: 24,
          ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller)
          ..addListener(() {});
  }

  @override
  void didUpdateWidget(covariant ShakeErrorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerShake && !oldWidget.triggerShake) {
      _controller.forward(from: 0).then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset =
            (1 - _controller.value) *
            _animation.value *
            ((_controller.value * 10).floor().isEven ? 1 : -1);
        return Transform.translate(
          offset: Offset(offset * 0.2, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
