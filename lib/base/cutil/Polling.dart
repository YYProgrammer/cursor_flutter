import "dart:async";
import "package:app/base/cutil/Empty.dart";
import "package:app/base/cutil/Lazyload.dart";
import "package:app/base/cutil/Logger.dart";

class Polling<T> {
  bool _stopStatus = false;
  num spaceTime;
  Timer? timer;
  Lazyload<T> task;
  int pollingCount;
  int currentPollingCount = 0;
  void Function(T result) callBack;
  late final _logger = LoggerFactory.getLogger(this);
  Polling({required this.spaceTime, required this.task, required this.callBack, this.pollingCount = 0});

  void start() {
    this._stopStatus = false;
    _logger.i("start polling");
    currentPollingCount = 0;
    _executeTask();
  }

  _executeTask() async {
    this.task.dirty();
    final result = await this.task.get();
    currentPollingCount++;
    if (this._stopStatus) {
      this.timer?.cancel();
      _logger.i("stop by this.stopStatus = true;");
      return Empty();
    }

    this.timer?.cancel();
    this.timer = Timer(Duration(milliseconds: this.spaceTime.toInt()), () {
      if (this._stopStatus) {
        _logger.i("stop by timer");
        return;
      }
      _executeTask();
    });
    this.callBack(result);
    if (this.pollingCount > 0 && currentPollingCount >= this.pollingCount) {
      this._stopStatus = true;
      _logger.i("stop by pollingCount");
    }
  }

  void stop() {
    _logger.i("stop polling by user");
    this._stopStatus = true;
    this.timer?.cancel();
  }
}
