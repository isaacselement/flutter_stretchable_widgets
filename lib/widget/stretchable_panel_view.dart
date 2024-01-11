import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef StretchWidgetsBuilder = Widget Function(BuildContext context, StretchablePanelState state);
typedef StretchAnimatingBuilder = Widget Function(BuildContext context, Widget? child, double w, double h);

class StretchablePanelWidget extends StatefulWidget {
  const StretchablePanelWidget({
    super.key,
    this.isInitShowStretchWidget = false,
    this.triggerWidget,
    this.stretchWidget,
    this.animatingBuilder,
    this.onStateInited,
    this.widgetsBuilder,
  }) : assert(widgetsBuilder != null || (triggerWidget != null && stretchWidget != null),
            'WidgetsBuilder or triggerWidget & stretchWidget must not be null at the same time');

  final bool isInitShowStretchWidget;
  final Widget? triggerWidget;
  final Widget? stretchWidget;
  final StretchAnimatingBuilder? animatingBuilder;
  final void Function(StretchablePanelState state)? onStateInited;

  final StretchWidgetsBuilder? widgetsBuilder;

  @override
  State<StretchablePanelWidget> createState() => StretchablePanelState();
}

class StretchablePanelState extends State<StretchablePanelWidget> with SingleTickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    controller?.addListener(() {
      // print('### controller.value: ${controller.value}');
      /// do not call setState() here, otherwise the controller.value always be 0.0, please use AnimatedBuilder instead
      // setState(() {});
    });
    widget.onStateInited?.call(this);

    _isStretchForwardFromShow = widget.isInitShowStretchWidget ? false : true;
    showingTriggeredWidget = widget.isInitShowStretchWidget ? false : true;
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  Size stretchedSize = Size.zero;

  bool get isNeedCalculateSize => stretchedSize == Size.zero;

  bool showingTriggeredWidget = true;

  Completer? _showedCompleter;
  bool _isStretchForwardFromShow = true;

  Future show() {
    _isStretchForwardFromShow = true;

    showingTriggeredWidget = false; // hide the trigger widget & show the stretch widget
    stretchedSize = Size.zero;
    controller?.reset();
    setState(() {});

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
      showingTriggeredWidget = true; // show the trigger widget after the animation effect done
      stretchedSize = Size.zero;
      setState(() {});
    });
  }

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
    if (showingTriggeredWidget) return getTriggeredWidget();

    /// Wrap a Offstage for calculating the size of [stretchWidget]
    return Offstage(
      offstage: isNeedCalculateSize,
      child: Builder(builder: (context) {
        if (isNeedCalculateSize) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (context.mounted) {
              stretchedSize = context.size ?? Size.zero;

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
        if (isNeedCalculateSize) return stretchChild;

        /// Do the show animation
        Animation animation = controller!;
        return AnimatedBuilder(
          animation: animation,
          child: stretchChild,
          builder: (BuildContext context, Widget? child) {
            double width = stretchedSize.width * animation.value;
            double height = stretchedSize.height * animation.value;

            /// Wrap with SingleChildScrollView for removing vertical overflow warning
            Widget view = SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: child);
            return widget.animatingBuilder?.call(context, view, width, height) ??
                SizedBox(width: width, height: height, child: view);
          },
        );
      }),
    );
  }
}
