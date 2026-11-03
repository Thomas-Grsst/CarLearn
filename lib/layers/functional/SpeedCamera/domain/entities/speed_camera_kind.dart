enum SpeedCameraKind {
  fixed('ETF', 'radar fixe'),
  discriminating('ETD', 'radar discriminant'),
  turret('ETT', 'radar tourelle'),
  urban('ETU', 'radar urbain'),
  averageSpeed('ETVM', 'radar tronçon'),
  redLight('ETFR', 'radar feu rouge'),
  levelCrossing('ETPN', 'radar passage à niveau'),
  other('', 'radar');

  const SpeedCameraKind(this.code, this.label);

  final String code;
  final String label;

  static SpeedCameraKind fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    return values.firstWhere((kind) => kind.code == normalized, orElse: () => other);
  }
}
