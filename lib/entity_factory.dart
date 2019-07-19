import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/banner_entity.dart';
import 'package:wanandroid/data/bean/resp_entity.dart';

class EntityFactory {
  static T generateOBJ<T>(json) {
    if (1 == 0) {
      return null;
    } else if (T.toString() == "ArticleEntity") {
      return ArticleEntity.fromJson(json) as T;
    } else if (T.toString() == "BannerEntity") {
      return BannerEntity.fromJson(json) as T;
    } else if (T.toString() == "RespEntity") {
      return RespEntity.fromJson(json) as T;
    } else {
      return null;
    }
  }
}