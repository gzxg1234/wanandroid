//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
//import 'package:provider/provider.dart';
//import 'package:wanandroid/app/app_bloc.dart';
//import 'package:wanandroid/data/bean/article_entity.dart';
//import 'package:wanandroid/main.dart';
//import 'package:wanandroid/util/auto_size.dart';
//import 'package:wanandroid/util/widget_utils.dart';
//
/////
///// 项目item
/////
//class ProjectItem extends StatelessWidget {
//  final ArticleEntity item;
//
//  ProjectItem(this.item);
//
//  @override
//  Widget build(BuildContext context) {
//    AppVM appBloc = Provider.of<AppVM>(context);
//    return Semantics(
//      hint: "hello",
//      child: Card(
//          elevation: 2,
//          shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.circular(sizeW(4))),
//          color: appBloc.theme.cardColor,
//          child: InkWell(
//            onTap: () {
//              Navigator.of(context).pushNamed(Routes.WEB,
//                  arguments: {Routes.WEB_ARG_URL: item.link});
//            },
//            borderRadius: BorderRadius.circular(sizeW(4)),
//            child: Padding(
//              padding: EdgeInsets.all(sizeW(8)),
//              child: Column(
//                  mainAxisSize: MainAxisSize.min,
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Row(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Expanded(
//                          child: Column(
//                            mainAxisSize: MainAxisSize.min,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: <Widget>[
//                              Text(
//                                item.title,
//                                maxLines: 2,
//                                semanticsLabel: item.title,
//                                overflow: TextOverflow.ellipsis,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold,
//                                    fontSize: sizeW(14),
//                                    color: appBloc.theme.textColorPrimary),
//                              ),
//                              Container(
//                                margin: EdgeInsets.only(top: sizeW(8)),
//                                child: Text(item.desc,
//                                    maxLines: 4,
//                                    style: TextStyle(
//                                        fontSize: sizeW(13),
//                                        color:
//                                            appBloc.theme.textColorSecondary)),
//                              )
//                            ],
//                          ),
//                        ),
//                        Offstage(
//                          offstage: item.envelopePic?.isEmpty ?? true,
//                          child: Container(
//                            margin: EdgeInsets.only(left: sizeW(8)),
//                            child: GestureDetector(
//                              onLongPress: () {
//                                showBigImage(context, item.envelopePic);
//                              },
//                              child: CachedNetworkImage(
//                                  imageUrl: item.envelopePic,
//                                  height: sizeW(120),
//                                  width: sizeW(60),
//                                  fit: BoxFit.fitWidth),
//                            ),
//                          ),
//                        )
//                      ],
//                    ),
//                    Container(
//                      margin: EdgeInsets.only(top: sizeW(16)),
//                      child: Row(
//                        mainAxisSize: MainAxisSize.max,
//                        crossAxisAlignment: CrossAxisAlignment.baseline,
//                        textBaseline: TextBaseline.alphabetic,
//                        children: <Widget>[
//                          ConstrainedBox(
//                            constraints: BoxConstraints(maxWidth: sizeW(150)),
//                            child: Text("作者：${item.author}",
//                                maxLines: 1,
//                                overflow: TextOverflow.ellipsis,
//                                style: TextStyle(
//                                    fontSize: sizeW(13),
//                                    color: appBloc.theme.textColorSecondary)),
//                          ),
//                          Expanded(
//                            child: Text(item.niceDate,
//                                textAlign: TextAlign.end,
//                                style: TextStyle(
//                                    fontSize: sizeW(13),
//                                    color: appBloc.theme.textColorSecondary)),
//                          ),
//                        ],
//                      ),
//                    )
//                  ]),
//            ),
//          )),
//    );
//  }
//
//  void showBigImage(BuildContext context, String image) {
//    showDialog(
//        context: context,
//        builder: (context) {
//          return Dialog(
//            backgroundColor: Colors.transparent,
//            child: GestureDetector(
//              onTap: () {
//                popRoute(ModalRoute.of(context));
//              },
//              child: ClipRRect(
//                borderRadius: BorderRadius.circular(sizeW(8)),
//                child: ConstrainedBox(
//                  constraints: BoxConstraints(
//                      maxWidth: sizeH(designSize.height * 0.8),
//                      maxHeight: sizeH(designSize.height * 0.8)),
//                  child: CachedNetworkImage(
//                    imageUrl: item.envelopePic,
//                    fit: BoxFit.contain,
//                  ),
//                ),
//              ),
//            ),
//          );
//        });
//  }
//}
