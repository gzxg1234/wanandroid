import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/util/auto_size.dart';

class ArticleItem extends StatelessWidget {
  ArticleEntity item;

  ArticleItem(this.item);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size(4))),
        color: appBloc.theme.cardColor,
        margin: EdgeInsets.symmetric(horizontal: size(16)),
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
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: size(14),
                      color: appBloc.theme.textColorPrimary),
                ),
                Container(
                  margin: EdgeInsets.only(top: size(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Offstage(
                        offstage: !item.fresh,
                        child: Container(
                          margin: EdgeInsets.only(right: size(4)),
                          padding: EdgeInsets.all(size(1)),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: appBloc.theme.flagTextColor),
                              borderRadius: BorderRadius.circular(size(2))),
                          child: Text("新",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: appBloc.theme.flagTextColor)),
                        ),
                      ),
                      Offstage(
                        offstage: item.type == 0,
                        child: Container(
                          margin: EdgeInsets.only(right: size(4)),
                          padding: EdgeInsets.all(size(1)),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: appBloc.theme.flagTextColor),
                              borderRadius: BorderRadius.circular(size(2))),
                          child: Text("置顶",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: appBloc.theme.flagTextColor)),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size(110)),
                        child: Text("作者:${item.author}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                color: appBloc.theme.textColorSecondary)),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size(110)),
                        child: Container(
                          margin: EdgeInsets.only(left: size(16)),
                          child: Text("分类:${item.chapterName}",
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: size(13),
                                  color: appBloc.theme.textColorSecondary)),
                        ),
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
