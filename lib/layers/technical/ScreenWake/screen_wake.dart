abstract interface class ScreenWake {
  Future<void> keepOn();
  Future<void> release();
}
