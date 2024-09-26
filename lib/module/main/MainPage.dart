import 'package:app/module/chat/ChatModule.dart';
import 'package:app/module/editor/EditorModule.dart';
import 'package:app/module/file/FileModule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MainPage extends HookWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leftWidth = useState<double>(300);
    final middleWidth = useState<double>(500);

    void updateLeftWidth(double delta) {
      leftWidth.value = (leftWidth.value + delta).clamp(100.0, 500.0);
    }

    void updateMiddleWidth(double delta) {
      middleWidth.value = (middleWidth.value + delta).clamp(100.0, 700.0);
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: leftWidth.value,
            child: const FileModule(),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) => updateLeftWidth(details.delta.dx),
            onDoubleTap: () => leftWidth.value = 300,
            child: const MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: SizedBox(width: 8, child: VerticalDivider()),
            ),
          ),
          SizedBox(
            width: middleWidth.value,
            child: const EditorModule(),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) => updateMiddleWidth(details.delta.dx),
            onDoubleTap: () => middleWidth.value = 300,
            child: const MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: SizedBox(width: 8, child: VerticalDivider()),
            ),
          ),
          const Expanded(child: ChatModule()),
        ],
      ),
    );
  }
}
