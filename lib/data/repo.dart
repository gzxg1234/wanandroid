import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;

import '../entity_factory.dart';
import 'bean/bean.dart';

class ApiException implements Exception {
  final String msg;

  ApiException(this.msg);
}

class ApiClient {
  static Dio ___dio;

  static const LOG_ENABLE = false;

  static Dio get _dio {
    if (___dio == null) {
      ___dio = Dio(BaseOptions(
          receiveDataWhenStatusError: false,
          baseUrl: "https://www.wanandroid.com",
          method: "get",
          connectTimeout: 15000,
          receiveTimeout: 3000));
      if (LOG_ENABLE) {
        ___dio.interceptors.add(LogInterceptor(
            request: true,
            responseBody: true,
            error: true,
            requestBody: true,
            responseHeader: true));
      }
    }
    return ___dio;
  }

  ApiClient._();

  ///
  /// 首页数据
  ///
  static Future<List> getHomeData(int page, [CancelToken cancelToken]) async {
    List data = List(2);
    List<ArticleEntity> topArticles;
    data[1] = await getArticleList(page);
    if (page == 0) {
      data[0] = await _getBanner();
      topArticles = await _getTopArticleList();
      data[1].datas?.insertAll(0, topArticles);
    }
    return data;
  }

  ///
  /// 项目分类数据
  ///
  static Future<List<CategoryEntity>> getProjectCategoryList(
      [CancelToken cancelToken]) async {
    Response response =
        await _dio.get("/project/tree/json", cancelToken: cancelToken);
    return transferList<CategoryEntity>(response);
  }

  ///
  /// 最新项目
  ///
  static Future<PageData<ArticleEntity>> getNewsProjectList(int page,
      [CancelToken cancelToken]) async {
    Response response = await _dio.get("/article/listproject/$page/json",
        cancelToken: cancelToken);
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 项目列表
  ///
  static Future<PageData<ArticleEntity>> getProjectList(int page,
      [int cid, CancelToken cancelToken]) async {
    Response response = await _dio.get("/project/list/$page/json",
        queryParameters: cid == null ? {} : {"cid": cid},
        cancelToken: cancelToken);
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 文章体系分类数据
  ///
  static Future<List<CategoryEntity>> getArticleCategoryList(
      [CancelToken cancelToken]) async {
    Response response = await _dio.get("/tree/json", cancelToken: cancelToken);
    return transferList<CategoryEntity>(response);
  }

  ///
  /// 文章体系分类数据
  ///
  static Future<List<CategoryEntity>> getWOAList(
      [CancelToken cancelToken]) async {
    Response response =
        await _dio.get("/wxarticle/chapters/json", cancelToken: cancelToken);
    return transferList<CategoryEntity>(response);
  }

  ///
  /// 文章体系分类数据
  ///
  static Future<PageData<ArticleEntity>> getWOAArticleList(int page, int id,
      [CancelToken cancelToken]) async {
    Response response = await _dio.get("/wxarticle/list/$id/$page/json",
        cancelToken: cancelToken);
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 置顶文章
  ///
  static Future<List<ArticleEntity>> _getTopArticleList(
      [CancelToken cancelToken]) async {
    Response response =
        await _dio.get("/article/top/json", cancelToken: cancelToken);
    return transferList<ArticleEntity>(response);
  }

  ///
  /// 文章列表
  ///
  static Future<PageData<ArticleEntity>> getArticleList(int page,
      [int cid, CancelToken cancelToken]) async {
    Response response = await _dio.get("/article/list/$page/json",
        queryParameters: cid == null ? {} : {"cid": cid},
        cancelToken: cancelToken);
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 文章列表
  ///
  static Future<PageData<ArticleEntity>> search(String word, int page,
      [CancelToken cancelToken]) async {
    Response response = await _dio.post("/article/query/$page/json",
        data: FormData.from({'k': '$word'}), cancelToken: cancelToken);
    return transferPageData<ArticleEntity>(response);
  }

  static Future<List<BannerEntity>> _getBanner(
      [CancelToken cancelToken]) async {
    Response response =
        await _dio.get("/banner/json", cancelToken: cancelToken);
    return transferList<BannerEntity>(response);
  }

  ///搜索热词
  static Future<List<HotWordEntity>> getHotWord(
      [CancelToken cancelToken]) async {
    Response response =
        await _dio.get("/hotkey/json", cancelToken: cancelToken);
    return transferList<HotWordEntity>(response);
  }

  static List<T> transferList<T>(Response response) {
    List<T> list = (exactData(response) as List<dynamic>)
        .map((e) => EntityFactory.generateOBJ<T>(e))
        .toList();
    if (T == ArticleEntity) {
      list.forEach((e) {
        dynamic x = e;
        x.desc = dom.Document.html(x.desc).body.text;
      });
    }
    return list;
  }

  static PageData<T> transferPageData<T>(Response response) {
    dynamic jsonData = exactData(response);
    PageData<T> result = PageData<T>.fromJson(jsonData);
    if (T == ArticleEntity) {
      result.datas.forEach((e) {
        dynamic x = e;
        x.desc = dom.Document.html(x.desc).body.text;
      });
    }
    return result;
  }

  static dynamic exactData(Response response) {
    RespEntity repoEntity = RespEntity.fromJson(response.data);
    if (repoEntity.errorCode == 0) {
      return repoEntity.data;
    }
    throw ApiException(repoEntity.errorMsg);
  }
}
