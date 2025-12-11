import '../../../../core/constants/app_constants.dart';

class ComboSystem {
  int incrementCombo(int currentCombo) {
    return (currentCombo + 1).clamp(0, AppConstants.maxCombo);
  }

  int resetCombo() {
    return 0;
  }
}
