import 'package:flutter/material.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/module/web/web_bloc.dart';

class WebPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<WebPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocProvider<WebBloc>(
      blocBuilder: (context) => WebBloc(),
      child: BlocConsumer<WebBloc>(builder: (context, bloc) {
        return Material(
          child: Column(
            children: <Widget>[
              buildTopBar(context, bloc)
            ],
          ),

        );
      }),
    );
  }

  Widget buildTopBar(BuildContext context, WebBloc bloc) {
    return Container(
      color: MyApp
          .getTheme(context)
          .primaryColor,
      child: SafeArea(child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back),
          )
        ],
      )),
    );
  }
}
