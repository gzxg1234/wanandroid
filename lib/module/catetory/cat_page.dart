import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/widget/common_button.dart';

import 'cat_bloc.dart';

class CatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<CatPage> with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<CatBloc>(
      blocBuilder: (BuildContext context) {
        return CatBloc();
      },
      child: BlocConsumer<CatBloc>(
        builder: (context,bloc){
          return Column(
            mainAxisSize: MainAxisSize.max,

          );
        },
      ),
    );
  }
}
