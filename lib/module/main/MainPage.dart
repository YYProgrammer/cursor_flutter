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
    final middleWidth = useState<double>(300);

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: leftWidth.value,
            child: const FileModule(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                leftWidth.value += details.delta.dx;
              },
              child: const SizedBox(width: 8, child: VerticalDivider()),
            ),
          ),
          SizedBox(
            width: middleWidth.value,
            child: const EditorModule(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                middleWidth.value += details.delta.dx;
              },
              child: const SizedBox(width: 8, child: VerticalDivider()),
            ),
          ),
          Expanded(child: const ChatModule()),
        ],
      ),
    );
  }
}
