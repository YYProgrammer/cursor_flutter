import "dart:io";

import "package:dartx/dartx.dart";

const dartRoot = "lib";
final dartRegex = RegExp("class (\\w+) extends Msg {");
const dartTargetFile = "lib/config/MsgRegistry.dart";

const swiftRootPath = "../FlutterKit";
const swiftTargetFile = "../FlutterKit/FlutterMsgRegistry.swift";
final swiftRegex = RegExp("public class (\\w+)\\s*:\\s*CodableMsg\\s*{");

/// 根据后缀名加载目录下的所有文件
void readFiles(List<FileSystemEntity> files, Directory dir, String extension) {
  List<FileSystemEntity> list = dir.listSync();

  for (var file in list) {
    if (file is Directory) {
      readFiles(files, file, extension);
    } else if (file is File) {
      if (file.path.endsWith(extension)) {
        files.add(file);
      }
    }
  }
}

List<_ClassCodeGen> readClassCodeGens(String path, RegExp reg) {
  List<_ClassCodeGen> result = [];
  var file = File(path);
  if (!file.existsSync()) return result;

  var lines = file.readAsLinesSync();
  for (var line in lines) {
    var matches = reg.allMatches(line);
    for (var match in matches) {
      var className = match.group(1);
      result.add(_ClassCodeGen(
        path: path,
        className: className!,
      ));
    }
  }

  return result.sortedWith((e1, e2) => e1.className.compareTo(e2.className));
}

List<_ClassCodeGen> getCodeGens(String root, RegExp regExp, String extension) {
  List<_ClassCodeGen> result = [];
  List<FileSystemEntity> files = [];
  readFiles(files, Directory(root), extension);

  for (var file in files) {
    var path = file.path;
    var classNames = readClassCodeGens(path, regExp);
    result.addAll(classNames);
  }

  return result.sortedWith((e1, e2) => e1.className.compareTo(e2.className));
}

/// 生成dart代码文件
/// 1. 读取lib目录下的所有dart文件
/// 2. 遍历所有dart文件，读取class名称
/// 3. 根据class名称生成import语句和class名称的映射
/// 4. 将生成好的代码文件输出到指定的目录
void writeDartFile() {
  var content = File("make/MsgRegistry.dart.tmpl").readAsStringSync();
  var importContent = "";
  var classContent = "";

  var classCodeGens = getCodeGens(dartRoot, dartRegex, ".dart");
  for (var element in classCodeGens) {
    importContent += element.import;
    classContent += element.classLine;
  }
  classContent = classContent.removeSuffix("\n");
  content = content.replaceAll("{{import}}", importContent);
  content = content.replaceAll("{{class}}", classContent);

  File(dartTargetFile).writeAsStringSync(content, flush: true);
}

/// 生成dart代码文件
/// 1. 读取../FlutterKit目录下的所有swift文件
/// 2. 遍历所有swift文件，读取class名称
/// 3. 根据class名称生成class名称的映射
/// 4. 将生成好的代码文件输出到指定的目录
void writeSwiftFile() {
  var content = File("make/FlutterMsgRegistry.swift.tmpl").readAsStringSync();
  var classContent = "";

  var classCodeGens = getCodeGens(swiftRootPath, swiftRegex, ".swift");
  for (var element in classCodeGens) {
    classContent += element.swiftClassLine;
  }
  classContent = classContent.removeSuffix("\n");
  content = content.replaceAll("{{class}}", classContent);

  File(swiftTargetFile).writeAsStringSync(content, flush: true);
}

void main() {
  writeDartFile();

  if (Directory(swiftRootPath).existsSync()) {
    writeSwiftFile();
  }
}

class _ClassCodeGen {
  String get import => 'import "package:${path.replaceAll("lib", "app").replaceAll("\\", "/")}";\n';

  String get classLine => "    naming($className): $className.fromJson,\n";
  String get swiftClassLine => "        naming($className.self): { Objects.fromJson(\$0, $className.self) },\n";

  String path;
  String className;

  _ClassCodeGen({
    required this.path,
    required this.className,
  });
}
