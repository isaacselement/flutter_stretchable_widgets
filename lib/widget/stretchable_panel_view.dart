import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef StretchWidgetsBuilder = Widget Function(BuildContext context, StretchablePanelState state);
typedef StretchAnimatedBuilder = AnimatedWidget Function(
    BuildContext context, Widget child, AnimationController animationController);
typedef StretchAnimatingBuilder = Widget Function(
    BuildContext context, Widget child, Animation animation, double animatingWidth, double animatingHeight);

class StretchablePanelWidget extends StatefulWidget {
  const StretchablePanelWidget({
    super.key,
    this.triggerWidget,
    this.stretchWidget,
    this.widgetsBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.isShowStretchWidgetOnInit = false,
    this.animatedBuilder,
    this.decorateChildOnAnimating,
    this.onStateInited,
    this.onStateDisposed,
    this.curve = Curves.ease,
  }) : assert((triggerWidget != null && stretchWidget != null) || widgetsBuilder != null,
            'WidgetsBuilder or triggerWidget & stretchWidget must not be null at the same time');

  /// If [widgetsBuilder] is null, then [triggerWidget] & [stretchWidget] must not be null
  final Widget? triggerWidget;
  final Widget? stretchWidget;
  final StretchWidgetsBuilder? widgetsBuilder;

  /// Animation duration
  final Duration? duration;
  final Duration? reverseDuration;

  /// Show [stretchWidget] first preferred
  final bool isShowStretchWidgetOnInit;

  /// AnimatedWidget builder, if null we use AnimatedBuilder default
  final StretchAnimatedBuilder? animatedBuilder;

  /// Builder that give a chance for you can decorate your child when animating
  final StretchAnimatingBuilder? decorateChildOnAnimating;

  /// Callback on initState
  final void Function(StretchablePanelState state)? onStateInited;
  final void Function(StretchablePanelState state)? onStateDisposed;

  /// An parametric animation easing curve
  final Curve? curve;

  @override
  State<StretchablePanelWidget> createState() => StretchablePanelState();
}

class StretchablePanelState extends State<StretchablePanelWidget> with SingleTickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration, reverseDuration: widget.reverseDuration);
    controller?.addListener(() {
      // print('### controller.value: ${controller.value}');
      /// do not call setState() here, otherwise the controller.value always be 0.0, please use AnimatedBuilder instead
      // setState(() {});
    });
    widget.onStateInited?.call(this);

    _isStretchForwardFromShow = widget.isShowStretchWidgetOnInit ? false : true;
    isShowingTriggeredWidget = widget.isShowStretchWidgetOnInit ? false : true;
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    widget.onStateDisposed?.call(this);
    super.dispose();
  }

  /// The size of [stretchWidget] we auto calculated
  Size autoCalculatedSize = Size.zero;

  bool get _isNeedCalculateSize => autoCalculatedSize == Size.zero;

  /// Flag indicate showing the [triggerWidget]
  bool isShowingTriggeredWidget = true;

  /// Completer that telling that [stretchWidget] is showed or not
  Completer? _showedCompleter;

  /// If show [stretchWidget] from show method (true) or init phase (false)
  bool _isStretchForwardFromShow = true;

  Future show() {
    /// Reset the states
    _isStretchForwardFromShow = true;
    isShowingTriggeredWidget = false;
    autoCalculatedSize = Size.zero;
    controller?.reset();
    if (mounted) setState(() {});

    /// Return the future to the caller
    Completer? previous = _showedCompleter;
    if (previous != null && !previous.isCompleted) {
      previous.complete();
    }
    _showedCompleter = null;
    Completer completer = Completer();
    _showedCompleter = completer;
    return completer.future;
  }

  Future hide() {
    return controller!.reverse().then((value) {
      /// Reset the states
      isShowingTriggeredWidget = true;
      autoCalculatedSize = Size.zero;
      setState(() {});
    });
  }

  /// Default false and wrapped a CupertinoButton/GestureDetector on triggeredWidget/stretchWidget
  bool isCallerManuallyShowOrHide = false;

  Widget getTriggeredWidget() {
    if (widget.widgetsBuilder != null) {
      return widget.widgetsBuilder!.call(context, this);
    }

    /// If builder is null, then triggerWidget & stretchWidget must not be null
    Widget triggeredWidget = widget.triggerWidget!;
    if (isCallerManuallyShowOrHide) {
      return triggeredWidget;
    }
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: show,
      child: triggeredWidget,
    );
  }

  Widget getStretchableWidget() {
    if (widget.widgetsBuilder != null) {
      return widget.widgetsBuilder!.call(context, this);
    }

    /// If builder is null, then triggerWidget & stretchWidget must not be null
    Widget stretchWidget = widget.stretchWidget!;
    if (isCallerManuallyShowOrHide) {
      return stretchWidget;
    }
    return GestureDetector(
      onTap: hide,
      child: stretchWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isShowingTriggeredWidget) return getTriggeredWidget();

    /// Wrap a Offstage for calculating the size of [stretchWidget]
    return Offstage(
      offstage: _isNeedCalculateSize,
      child: Builder(builder: (context) {
        if (_isNeedCalculateSize) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (context.mounted) {
              autoCalculatedSize = context.size ?? Size.zero;

              /// The size is determined, so we need to rebuild the widget
              setState(() {});
              controller?.reset();
              controller?.forward(from: _isStretchForwardFromShow ? 0.0 : 1.0).then((value) {
                _showedCompleter?.complete();
              });
            }
          });
        }

        Widget stretchChild = getStretchableWidget();

        /// Return the invisible widget for calculating its size
        if (_isNeedCalculateSize) return stretchChild;

        AnimationController animationController = controller!;

        /// Show your own animated widget if you specified
        if (widget.animatedBuilder != null) {
          return widget.animatedBuilder!.call(context, stretchChild, animationController);
        }

        /// Do the show animation
        Animation animation = animationController;
        if (widget.curve != null) {
          animation = CurveTween(curve: widget.curve!).animate(animationController);
        }
        return AnimatedBuilder(
          animation: animation,
          child: stretchChild,
          builder: (BuildContext context, Widget? child) {
            double width = autoCalculatedSize.width * animation.value;
            double height = autoCalculatedSize.height * animation.value;

            /// Wrap with SingleChildScrollView for removing vertical overflow warning
            Widget view = SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: child);
            return widget.decorateChildOnAnimating?.call(context, view, animation, width, height) ??
                SizedBox(width: width, height: height, child: view);
          },
        );
      }),
    );
  }
}
