import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/bloc/bloc.dart';

class AppBloc extends Bloc {
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
