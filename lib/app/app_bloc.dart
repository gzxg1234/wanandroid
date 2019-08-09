import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/base/base_bloc.dart';

class AppBloc extends BaseBloc {
  AppTheme _theme = AppTheme();

  AppTheme get theme => _theme;

  void changeTheme(AppTheme appTheme) {
    _theme = appTheme;
    notifyListeners();
  }
}
