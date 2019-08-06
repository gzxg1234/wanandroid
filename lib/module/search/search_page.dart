import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/hot_word_bloc.dart';
import 'package:wanandroid/base/base_state.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/data/bean/hot_word_entity.dart';
import 'package:wanandroid/module/search/search_clear_button.dart';
import 'package:wanandroid/module/search/search_list.dart';
import 'package:wanandroid/module/search/search_vm.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/widget_utils.dart';
import 'package:wanandroid/widget/clear_text_field.dart';
import 'package:wanandroid/widget/common_button.dart';

import '../../main.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> with BaseStateMixin {
  TextEditingController _inputController;
  FocusNode _wordFocus = FocusNode();
  SearchVM _vm;
  final GlobalKey<HistoryClearButtonState> _clearBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _vm = SearchVM();
    _inputController = TextEditingController();
    _wordFocus.addListener(() {
      if (_wordFocus.hasFocus) {
        _vm.resetWord();
      }
    });
  }

  @override
  void dispose() {
    _wordFocus.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  void afterInitState() {
    super.afterInitState();
    Provider.of<HotWordVM>(context).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BaseViewModelProvider<SearchVM>(viewModelBuilder: (context) {
      return _vm;
    }, child: Consumer<SearchVM>(builder: (context, vm, _) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (e) {
          if (_clearBtnKey.currentState?.showing ?? false) {
            _clearBtnKey.currentState.close();
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        child: Material(
            color: MyApp.getTheme(context).backgroundColor,
            child: Column(children: <Widget>[
              buildTopBar(context, vm),
              buildContent(context, vm)
            ])),
      );
    }));
  }

  Widget buildTopBar(BuildContext context, SearchVM bloc) {
    return DecoratedBox(
        decoration: BoxDecoration(color: MyApp.getTheme(context).primaryColor),
        child: SafeArea(
            child: Container(
                padding: EdgeInsets.only(right: sizeW(8)),
                constraints: BoxConstraints.expand(height: sizeW(50)),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: MyApp.getTheme(context).iconColor),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Expanded(
                          child: ClearableTextField(
                              clearIcon: Icon(Icons.clear,
                                  color: MyApp.getTheme(context).iconColor,
                                  size: sizeW(24)),
                              child: TextField(
                                  focusNode: _wordFocus,
                                  textInputAction: TextInputAction.search,
                                  maxLength: 20,
                                  maxLines: 1,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: ''),
                                  cursorColor: Colors.white,
                                  onSubmitted: (text) {
                                    bloc.onSearch(text);
                                  },
                                  controller: _inputController,
                                  style: TextStyle(
                                    fontSize: sizeW(16),
                                    color: MyApp.getTheme(context)
                                        .textColorPrimaryInverse,
                                  ))))
                    ]))));
  }

  Widget buildContent(BuildContext context, SearchVM vm) {
    return Expanded(
        child: ValueListenableBuilder<String>(
            valueListenable: vm.searchWord,
            builder: (BuildContext context, String word, Widget child) {
              return Container(
                  constraints: BoxConstraints.expand(),
                  child: word.isEmpty
                      ? buildHistoryWord(context, vm)
                      : SearchList(word: word));
            }));
  }

  Widget buildHistoryWord(BuildContext context, SearchVM vm) {
    return Container(
        padding: EdgeInsets.all(sizeW(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          ValueListenableBuilder<List<HotWordEntity>>(
              valueListenable: Provider.of<HotWordVM>(context).hotWordList,
              builder: (BuildContext context, List<HotWordEntity> list,
                  Widget child) {
                return list != null && list.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text("热门搜索",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: sizeW(14),
                                    color: MyApp.getTheme(context)
                                        .textColorPrimary)),
                            Container(
                                padding:
                                    EdgeInsets.symmetric(vertical: sizeW(12)),
                                child: Wrap(
                                    spacing: sizeW(12),
                                    runSpacing: sizeW(12),
                                    children: buildHotWord(context, vm,
                                        list.map((e) => e.name).toList())))
                          ])
                    : Container();
              }),
          Container(
              margin: EdgeInsets.only(top: sizeW(16)),
              child: ValueListenableBuilder<List<String>>(
                  valueListenable: vm.searchHistory,
                  builder:
                      (BuildContext context, List<String> list, Widget child) {
                    return list != null && list.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Row(children: <Widget>[
                                  Expanded(
                                    child: Text("历史搜索",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: sizeW(14),
                                            color: MyApp.getTheme(context)
                                                .textColorPrimary)),
                                  ),
                                  HistoryClearButton(
                                      key: _clearBtnKey,
                                      onPressed: vm.clearHistory)
                                ]),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: sizeW(12)),
                                    child: Wrap(
                                        spacing: sizeW(12),
                                        runSpacing: sizeW(12),
                                        children:
                                            buildHotWord(context, vm, list)))
                              ])
                        : Container();
                  }))
        ]));
  }

  void confirmClear(BuildContext context, SearchVM vm) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text("确认清空？"), actions: <Widget>[
            FlatButton(
                onPressed: () {
                  popRoute(ModalRoute.of(context));
                  vm.clearHistory();
                },
                child: Text("确定")),
            FlatButton(
                onPressed: () {
                  popRoute(ModalRoute.of(context));
                },
                child: Text("取消")),
          ]);
        });
  }

  List<Widget> buildHotWord(
      BuildContext context, SearchVM vm, List<String> list) {
    return list.map((e) {
      return CommonButton(e,
          constraints: BoxConstraints.tightFor(height: sizeW(24)),
          padding: EdgeInsets.symmetric(horizontal: sizeW(8)),
          bgColor: MyApp.getTheme(context).unCheckedWidgetBgColor,
          onPressed: () {
        _inputController.text = e;
        FocusScope.of(context).unfocus();
        vm.onSearch(e);
      },
          shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizeW(12))));
    }).toList();
  }
}
