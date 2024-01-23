// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stretchable_widgets/widget/stretchable_panel_view.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Home()));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// the left top one
        Positioned(
          left: 0,
          right: 0,
          top: 80,
          child: getStretchableWidget(
            isInitShowStretchWidget: false,
            alignment: Alignment.centerLeft,
          ),
        ),

        /// the right top one
        Positioned(
          left: 0,
          right: 0,
          top: 80,
          child: getStretchableWidget(
            isInitShowStretchWidget: false,
            alignment: Alignment.centerRight,
            isWrappedWithScrollView: true,
            text: textShort,
          ),
        ),

        /// the left bottom one
        Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: getStretchableWidget(
            isInitShowStretchWidget: true,
            alignment: Alignment.centerLeft,
          ),
        ),

        /// the right bottom one
        Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: getStretchableWidget(
            isInitShowStretchWidget: false,
            alignment: Alignment.centerRight,
            isWrappedWithScrollView: true,
            text: textLong,
          ),
        ),
      ],
    );
  }

  static const String textShort = ''
      'Why is processing a sorted array faster than processing an unsorted array?'
      '\n'
      'Now for the sake of argument, suppose this is back in the 1800s - before long-distance or radio communication.'
      '\n'
      '';
  static const String textLong = ''
      '1、Client is an office worker around 30 years old'
      '\n'
      '2、I want a family car, about 200,000'
      '\n'
      '3、Urban TESLA assisted driving'
      '\n'
      '4、Faster car ~~'
      '\n'
      '5、I want to buy a car in 2 months, I want to buy a car in 2 months, I want to buy a car in 2 months'
      '\n'
      '6、If you guess wrong too often'
      '\n'
      '7、If you guess right every time'
      '\n'
      '8、If you guessed right, it continues on'
      '\n'
      '9、If you guessed wrong, the driver will stop'
      '\n'
      '10、Then it can restart down the other path'
      '\n'
      '10、In other words, you try to identify a pattern and follow it'
      '\n'
      '';

  Widget getStretchableWidget({
    bool isInitShowStretchWidget = false,
    AlignmentGeometry alignment = Alignment.centerRight,
    bool isWrappedWithScrollView = false,
    String text = textShort,
  }) {
    return StretchablePanelWidget(
      isShowStretchWidgetOnInit: isInitShowStretchWidget,
      widgetsBuilder: (context, state) {
        if (state.isShowingTriggeredWidget) {
          return Container(
            alignment: alignment,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.zero,
            decoration: null,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
              onPressed: () {
                state.show().then((value) {
                  print('########## show done!');
                });
              },
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      flex: 6,
                      child: Text(
                        'Please take 5 minutes to introduce P7',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Flexible(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(Icons.close_outlined, color: Colors.white, size: 24),
                        onPressed: () {
                          state.hide().then((value) {
                            print('########## hide done!');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (isWrappedWithScrollView)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  )
                else
                  Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          );
        }
      },
      decorateChildOnAnimating: (context, child, animation, animatingW, animatingH) {
        return Container(
          alignment: alignment,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: animatingW,
            height: animatingH,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              // color: Colors.black.withOpacity(animation.value),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
