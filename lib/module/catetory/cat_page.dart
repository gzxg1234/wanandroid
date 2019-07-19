import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/base/base_page.dart';

import 'cat_bloc.dart';

class CatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseBlocProvider<CatBloc>(
      blocBuilder: (BuildContext context) {
        return CatBloc();
      },
      child: Container(
        color: Colors.blue,
      ),
    );
  }
}
