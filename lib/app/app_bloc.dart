import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/base/view_model.dart';

class AppBloc extends ViewModel {
  AppTheme _theme = AppTheme();

  AppTheme get theme => _theme;

  void changeTheme(AppTheme appTheme) {
    _theme = appTheme;
    notifyListeners();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onDispose() {
    // TODO: implement onDispose
    super.onDispose();
  }
}
