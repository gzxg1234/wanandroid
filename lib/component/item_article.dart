import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/util/auto_size.dart';

///
/// 文章item
///
class ArticleItem extends StatelessWidget {
  final ArticleEntity item;
  final bool parseTitle;
  final bool showFlag;

  ArticleItem(this.item, {this.parseTitle = false, this.showFlag = false});

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = Provider.of<AppBloc>(context).theme;
    return Semantics(
      label: item.title,
      child: ExcludeSemantics(
        child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizeW(4))),
            color: appTheme.cardColor,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.WEB,
                    arguments: {Routes.WEB_ARG_URL: item.link});
              },
              borderRadius: BorderRadius.circular(sizeW(4)),
              child: Padding(
                padding: EdgeInsets.all(sizeW(8)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(
                        TextSpan(children: [
                          ...() {
                            if (!showFlag) {
                              return [];
                            }
                            return [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Offstage(
                                      offstage: !item.fresh,
                                      child: Container(
                                          margin:
                                              EdgeInsets.only(right: sizeW(4)),
                                          padding: EdgeInsets.all(sizeW(1)),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      appTheme.flagTextColor),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      sizeW(2))),
                                          child: Text("新",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: appTheme
                                                      .flagTextColor))))),
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Offstage(
                                      offstage: item.type == 0,
                                      child: Container(
                                          margin:
                                              EdgeInsets.only(right: sizeW(4)),
                                          padding: EdgeInsets.all(sizeW(1)),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      appTheme.flagTextColor),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      sizeW(2))),
                                          child: Text("置顶",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: appTheme
                                                      .flagTextColor)))))
                            ];
                          }(),
                          parseTitle
                              ? WidgetSpan(
                                  child: Html(
                                      data: item.title,
                                      customTextStyle: (node, style) {
                                        if (node is dom.Element) {
                                          if (node.localName == 'em') {
                                            return style.copyWith(
                                              fontStyle: FontStyle.normal,
                                                color:
                                                    appTheme.searchHighLight);
                                          }
                                        }
                                        return style;
                                      },
                                      defaultTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: sizeW(14),
                                          color: appTheme.textColorPrimary)))
                              : TextSpan(
                                  text: item.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: sizeW(14),
                                      color: appTheme.textColorPrimary),
                                )
                        ]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2),
                    Container(
                      margin: EdgeInsets.only(top: sizeW(8)),
                      child: Text(
                          "分类：${[item.superChapterName,item.chapterName].join('/')}",
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: sizeW(13),
                              color: appTheme.textColorSecondary)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: sizeW(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: sizeW(150)),
                            child: Text("作者：${item.author}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: sizeW(13),
                                    color: appTheme.textColorSecondary)),
                          ),
                          Expanded(
                            child: Text(item.niceDate,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: sizeW(13),
                                    color: appTheme.textColorSecondary)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
