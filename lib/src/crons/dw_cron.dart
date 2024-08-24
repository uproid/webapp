import 'package:cron/cron.dart';

class DwCron {
  String schedule;

  final _cron = Cron();
  late final int registerTime;
  Future Function(int count, DwCron cron) onCorn;
  int get counter => _counter;
  int _counter = 0;
  bool delayFirstMoment = true;
  CronStatus _status = CronStatus.notStarted;
  CronStatus get status => _status;

  DwCron({
    required this.onCorn,
    required this.schedule,
    this.delayFirstMoment = true,
  }) {
    registerTime = DateTime.now().microsecondsSinceEpoch;
  }

  DwCron start() {
    _status = CronStatus.running;

    if (delayFirstMoment == false) {
      _counter++;
      onCorn(_counter, this);
    }

    _cron.schedule(Schedule.parse(schedule), () async {
      _counter++;
      onCorn(_counter, this);
    });

    return this;
  }

  static String durationToCron(Duration duration) {
    int sec = duration.inSeconds;
    if (sec < 1) {
      throw ArgumentError('Duration must be at least 1 sec.');
    }
    String cronExpression = '*/$sec * * * * *';

    return cronExpression;
  }

  void close() {
    _cron.close();
    _status = CronStatus.stoped;
  }
}

enum CronStatus {
  running,
  stoped,
  notStarted,
}
