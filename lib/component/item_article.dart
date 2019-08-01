import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/base/view_model_provider.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/util/auto_size.dart';

///
/// 文章item
///
class ArticleItem extends StatelessWidget {
  final ArticleEntity item;
  final bool showFlag;

  ArticleItem(this.item, [this.showFlag = false]);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = Provider.of<AppBloc>(context);
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size(4))),
        color: appBloc.theme.cardColor,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.WEB,
                arguments: {Routes.WEB_ARG_URL: item.link});
          },
          borderRadius: BorderRadius.circular(size(4)),
          child: Padding(
            padding: EdgeInsets.all(size(8)),
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
                                      margin: EdgeInsets.only(right: size(4)),
                                      padding: EdgeInsets.all(size(1)),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  appBloc.theme.flagTextColor),
                                          borderRadius:
                                              BorderRadius.circular(size(2))),
                                      child: Text("新",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: appBloc
                                                  .theme.flagTextColor))))),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Offstage(
                                  offstage: item.type == 0,
                                  child: Container(
                                      margin: EdgeInsets.only(right: size(4)),
                                      padding: EdgeInsets.all(size(1)),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  appBloc.theme.flagTextColor),
                                          borderRadius:
                                              BorderRadius.circular(size(2))),
                                      child: Text("置顶",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: appBloc
                                                  .theme.flagTextColor)))))
                        ];
                      }(),
                      TextSpan(
                        text: item.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size(14),
                            color: appBloc.theme.textColorPrimary),
                      )
                    ]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2),
                Container(
                  margin: EdgeInsets.only(top: size(8)),
                  child: Text(
                      "分类：${item.chapterName}${() {
                        if (item.tags != null && item.tags.isNotEmpty) {
                          return "/" + item.tags.map((v) => v.name).join("/");
                        }
                        return "";
                      }()}",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: size(13),
                          color: appBloc.theme.textColorSecondary)),
                ),
                Container(
                  margin: EdgeInsets.only(top: size(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size(150)),
                        child: Text("作者：${item.author}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: size(13),
                                color: appBloc.theme.textColorSecondary)),
                      ),
                      Expanded(
                        child: Text(item.niceDate,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: size(13),
                                color: appBloc.theme.textColorSecondary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
