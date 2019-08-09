import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/util/auto_size.dart';

///
/// 文章item
///
class ArticleItem extends StatelessWidget {
  final ArticleEntity item;
  final bool showFlag;

  ArticleItem(this.item, {this.showFlag = false});

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
                              Row(children: <Widget>[
                                Offstage(
                                    offstage: !item.fresh,
                                    child: Container(
                                        margin:
                                            EdgeInsets.only(right: sizeW(4)),
                                        padding: EdgeInsets.all(sizeW(1)),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: appTheme.flagTextColor),
                                            borderRadius: BorderRadius.circular(
                                                sizeW(2))),
                                        child: Text("新",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    appTheme.flagTextColor)))),
                                Offstage(
                                    offstage: item.type == 0,
                                    child: Container(
                                        margin:
                                            EdgeInsets.only(right: sizeW(4)),
                                        padding: EdgeInsets.all(sizeW(1)),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: appTheme.flagTextColor),
                                            borderRadius: BorderRadius.circular(
                                                sizeW(2))),
                                        child: Text("置顶",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    appTheme.flagTextColor)))),
                                Icon(Icons.account_circle,
                                    size: sizeW(20),
                                    color: appTheme.textColorPrimary),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: sizeW(4)),
                                    constraints:
                                        BoxConstraints(maxWidth: sizeW(150)),
                                    child: Text("${item.author}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: sizeW(12),
                                            color:
                                                appTheme.textColorPrimary)),
                                  ),
                                ),
                                Text(item.niceDate,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: sizeW(12),
                                        color: appTheme.textColorPrimary))
                              ]),
                              Container(
                                margin: EdgeInsets.only(top: sizeW(8)),
                                child: Html(
                                    data: item.title,
                                    customTextStyle: (node, style) {
                                      if (node is dom.Element) {
                                        if (node.localName == 'em') {
                                          return style.copyWith(
                                              fontStyle: FontStyle.normal,
                                              color: appTheme.searchHighLight);
                                        }
                                      }
                                      return style;
                                    },
                                    defaultTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sizeW(14),
                                        color: appTheme.textColorPrimary)),
                              ),
                              Offstage(
                                offstage: item.desc.isEmpty,
                                child: Container(
                                  margin: EdgeInsets.only(top: sizeW(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text('${item.desc}',
                                            maxLines: 6,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: sizeW(13),
                                                color: appTheme
                                                    .textColorSecondary)),
                                      ),
                                      Offstage(
                                        offstage:
                                            item.envelopePic?.isEmpty ?? true,
                                        child: Container(
                                          margin:
                                              EdgeInsets.only(left: sizeW(8)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(sizeW(4)),
                                            child: CachedNetworkImage(
                                                imageUrl: item.envelopePic,
                                                width: sizeW(60),
                                                height: sizeW(100),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: sizeW(12)),
                                  child: NotificationListener(
                                    child: GestureDetector(
                                        onTap: () {
                                          EventBus.post(SwitchHomeTabEvent(1));
                                          EventBus.postSticky(JumpCategoryEvent(
                                              item.chapterId));
                                        },
                                        child: Text.rich(TextSpan(children: [
                                          WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    right: sizeW(4)),
                                                child: Icon(Icons.category,
                                                    size: sizeW(13),
                                                    color: appTheme
                                                        .textColorPrimary),
                                              )),
                                          TextSpan(
                                              text: "${[
                                                item.superChapterName,
                                                item.chapterName
                                              ].join('/')}",
                                              style: TextStyle(
                                                  fontSize: sizeW(13),
                                                  color: appTheme
                                                      .textColorPrimary))
                                        ]))),
                                  ))
                            ]))))));
  }
}
