# flutter_stretchable_widgets

[![pub package](https://img.shields.io/pub/v/flutter_stretchable_widgets.svg)](https://pub.dev/packages/flutter_stretchable_widgets)

Flutter widgets with stretchable capacity

### Demonstrations

<div align="center">
    <img src="https://raw.githubusercontent.com/isaacselement/flutter_stretchable_widgets/master/example/resources/gif/20240111-181735.gif" width="50%">
</div>

### Usage

    ````
    import 'package:flutter_stretchable_widgets/widget/stretchable_panel_view.dart';

    ...
    @override
    Widget build(BuildContext context) {
        return Stack(
          children: [
            /// the left top one
            Positioned(
              left: 0,
              right: 0,
              top: 80,
              child: StretchablePanelWidget(
                triggerWidget: const Icon(Icons.add),
                stretchWidget: Text('Hello world', style: TextStyle(color: Colors.grey.withAlpha(128))),
              ),
            ),

            /// the right top one
            Positioned(
              left: 0,
              right: 0,
              top: 80,
              child: StretchablePanelWidget(
                widgetsBuilder: (context, state) {
                  return state.isShowingTriggeredWidget ? const Icon(Icons.add) : const Text('Hello world');
                },
              ),
            ),
          ],
        );
    }
    ...
    ````


### Features and bugs

Please feel free to: request new features and bugs at the [issue tracker][tracker]



[tracker]: https://github.com/isaacselement/flutter_stretchable_widgets/issues