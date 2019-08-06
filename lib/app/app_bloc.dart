import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/base/base_view_model.dart';

class AppBloc extends BaseViewModel {
  AppTheme _theme = AppTheme();

  AppTheme get theme => _theme;

  void changeTheme(AppTheme appTheme) {
    _theme = appTheme;
    notifyListeners();
  }
}
