import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/module/web/web_bloc.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final String url;

  WebPage(this.url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<WebPage> with SingleTickerProviderStateMixin {
  WebViewController _webViewController;
  bool _loading = false;
  String _title = "";
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null) {
          bool canGoBack = await _webViewController.canGoBack();
          if (canGoBack) {
            await _webViewController.goBack();
            return Future.value(false);
          }
        }
        return Future.value(true);
      },
      child: BlocProvider<WebBloc>(
        blocBuilder: (context) => WebBloc(),
        child: BlocConsumer<WebBloc>(builder: (context, bloc) {
          return Material(
            child: Scaffold(
                appBar: buildAppBar(context, bloc),
                body: Stack(children: <Widget>[
                  buildWebView(context, bloc),
                  Offstage(
                      offstage: !_loading,
                      child: Container(
                        color: Colors.green,
                        height: size(2),
                        width: size(100),
                      ))
                ])),
          );
        }),
      ),
    );
  }

  Widget buildAppBar(BuildContext context, WebBloc bloc) {
    return AppBar(
      elevation: 4.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: MyApp.getTheme(context).iconColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        tooltip: "后退",
      ),
      title: _loading
          ? LoadingText()
          : Text(
              _title,
              style: TextStyle(
                  fontSize: size(16),
                  color: MyApp.getTheme(context).textColorPrimaryInverse),
            ),
      actions: buildActions(),
    );
  }

  List<Widget> buildActions() {
    return <Widget>[
      Offstage(
          offstage: _webViewController == null,
          child: IconButton(
            icon: Icon(Icons.refresh),
            color: MyApp.getTheme(context).iconColor,
            onPressed: () {
              setState(() {
                _loading = true;
              });
              _webViewController?.reload();
            },
            tooltip: "刷新",
          )),
      Offstage(
        offstage: _webViewController == null,
        child: PopupMenuButton<MenuItem>(
            tooltip: "更多",
            offset: Offset(0, kToolbarHeight),
            onSelected: (item) {
              switch (item) {
                case MenuItem.openInBrowser:
                  _openInBrowser();
                  break;
              }
            },
            itemBuilder: (context) => [
                  PopupMenuItem<MenuItem>(
                      value: MenuItem.openInBrowser,
                      child: Text(
                        "浏览器打开",
                        style: TextStyle(
                            color: MyApp.getTheme(context).textColorPrimary,
                            fontSize: size(14)),
                      )),
                ]),
      ),
    ];
  }

  void _openInBrowser() async {
    String url = await _webViewController?.currentUrl();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast(msg: "没有可打开的浏览器");
    }
  }

  void _handleOtherScheme(String url) async {
    if (url.startsWith("tel:") ||
        url.startsWith("sms:") ||
        url.startsWith("mailto:")) {
      if (await canLaunch(url)) {
        await launch(url);
      }
    } else {
      if (Platform.isAndroid) {
        AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: url,
        );
        await intent.launch();
      }
    }
  }

  Widget buildWebView(BuildContext context, WebBloc bloc) {
    return Offstage(
        offstage: _webViewController == null,
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (request) {
            if (!request.url.startsWith("http://") &&
                !request.url.startsWith("https://")) {
              _handleOtherScheme(request.url);
              return NavigationDecision.prevent;
            }
            if (request.isForMainFrame) {
              setState(() {
                _loading = true;
              });
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: _onPageFinished,
          onWebViewCreated: _onWebViewCreated,
        ));
  }

  void _onWebViewCreated(WebViewController controller) {
    setState(() {
      _webViewController = controller;
      _webViewController.loadUrl(widget.url);
      _loading = true;
    });
  }

  void _onPageFinished(String url) {
    dLog(this.runtimeType.toString(), "pageFinished");
    _webViewController.evaluateJavascript("document.title").then((result) {
      print(result);
      String title = exceptQuotation(result);
      setState(() {
        this._title = title;
      });
    }).catchError((e) {
      this._title = "加载完成";
    });
    setState(() {
      _loading = false;
    });
  }

  static String exceptQuotation(String str) {
    RegExp reg = new RegExp("\"([^\"]*)\"");
    var firstMatch = reg.firstMatch(str);
    if (firstMatch != null && firstMatch.groupCount > 0) {
      return firstMatch.group(1);
    }
    return str;
  }
}

enum MenuItem { openInBrowser }

class LoadingText extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoadingTextState();
  }
}

class _LoadingTextState extends State<LoadingText>
    with SingleTickerProviderStateMixin {
  Animation<int> _animation;
  AnimationController _animationController;
  String text = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear);
    _animation = IntTween(begin: 0, end: 4).animate(curvedAnimation)
      ..addListener(() {
        setState(() {
          var length = _animation.value == 4 ? 0 : _animation.value;
          text = "加载中${List.filled(length, ".").join()}";
        });
      });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      text,
      style: TextStyle(
          fontSize: size(16),
          color: MyApp.getTheme(context).textColorPrimaryInverse),
    );
  }
}
