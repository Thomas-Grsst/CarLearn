import 'package:wakelock_plus/wakelock_plus.dart';

import 'screen_wake.dart';

class WakelockScreenWake implements ScreenWake {
  const WakelockScreenWake();

  @override
  Future<void> keepOn() => WakelockPlus.enable();

  @override
  Future<void> release() => WakelockPlus.disable();
}
