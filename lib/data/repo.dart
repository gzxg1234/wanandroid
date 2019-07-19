import 'package:dio/dio.dart';

import '../data/bean/banner_entity.dart';
import '../entity_factory.dart';
import 'bean/page_data.dart';
import 'bean/resp_entity.dart';
import 'bean/article_entity.dart';

class ApiException implements Exception {
  final String msg;

  ApiException(this.msg);
}

class Repo {
  static Dio ___dio;

  static Dio get dio {
    if (___dio == null) {
      ___dio = Dio(BaseOptions(
          baseUrl: "https://www.wanandroid.com",
          method: "get",
          connectTimeout: 15000,
          receiveTimeout: 3000));
      ___dio.interceptors.add(LogInterceptor(
          request: true,
          responseBody: true,
          error: true,
          requestBody: true,
          responseHeader: true));
    }
    return ___dio;
  }
  static Future<List> getHomeData(int page) async {
    List data = List(2);
    if(page ==0){
      data[0] = await getBanner();
    }
    data[1]= await getArticleList(page);
    return data;
  }

  static Future<PageData<ArticleEntity>> getArticleList(int page) async {
    return getAndExactPageData<ArticleEntity>("/article/list/$page/json");
  }

  static Future<List<BannerEntity>> getBanner() async {
    return getAndExactListData<BannerEntity>("/banner/json");
  }

  static Future<PageData<T>> getAndExactPageData<T>(String url,
      {Map<String, dynamic> queryParameters}) async {
    dynamic dataJson =
        await getAndExactData(url, queryParameters: queryParameters);
    return PageData<T>.fromJson(dataJson);
  }

  static Future<List<T>> getAndExactListData<T>(String url,
      {Map<String, dynamic> queryParameters}) async {
    List list = await getAndExactData(url, queryParameters: queryParameters);
    return list.map((e) => EntityFactory.generateOBJ<T>(e)).toList();
  }

  static Future<dynamic> getAndExactData(String url,
      {Map<String, dynamic> queryParameters}) async {
    Response response = await dio.get(url, queryParameters: queryParameters);
    RespEntity repoEntity = RespEntity.fromJson(response.data);
    if (repoEntity.errorCode == 0) {
      return repoEntity.data;
    }
    throw ApiException(repoEntity.errorMsg);
  }
}
