import 'package:dio/dio.dart';
import 'package:wanandroid/config/config.dart';

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

  CancelToken _cancelToken;

  ApiClient([this._cancelToken]);

  void dispose(){
    _cancelToken?.cancel("cancel");
  }

  ///
  /// 首页数据
  ///
  Future<List> getHomeData(int page, [CancelToken cancelToken]) async {
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
  Future<List<CategoryEntity>> getProjectCategoryList() {
    return _getAndExactListData<CategoryEntity>("/project/tree/json");
  }

  ///
  /// 最新项目
  ///
  Future<PageData<ArticleEntity>> getNewsProjectList(int page) async {
    return _getAndExactPageData<ArticleEntity>(
        "/article/listproject/$page/json");
  }

  ///
  /// 项目列表
  ///
  Future<PageData<ArticleEntity>> getProjectList(int page, [int cid]) async {
    return _getAndExactPageData<ArticleEntity>("/project/list/$page/json",
        queryParameters: cid == null ? {} : {"cid": cid});
  }

  ///
  /// 文章体系分类数据
  ///
  Future<List<CategoryEntity>> getArticleCategoryList() {
    return _getAndExactListData<CategoryEntity>("/tree/json");
  }

  ///
  /// 置顶文章
  ///
  Future<List<ArticleEntity>> _getTopArticleList() async {
    return _getAndExactListData<ArticleEntity>("/article/top/json");
  }

  ///
  /// 文章列表
  ///
  Future<PageData<ArticleEntity>> getArticleList(int page, [int cid]) async {
    return _getAndExactPageData<ArticleEntity>("/article/list/$page/json",
        queryParameters: cid == null ? {} : {"cid": cid});
  }

  Future<List<BannerEntity>> _getBanner() async {
    return _getAndExactListData<BannerEntity>("/banner/json");
  }

  Future<List<HotWordEntity>> getHotWord([CancelToken cancelToken]) async {
    return _getAndExactListData<HotWordEntity>("/hotkey/json");
  }

  Future<List<T>> _getAndExactListData<T>(String url,
      {Map<String, dynamic> queryParameters}) async {
    List list = await _getAndExactData(url, queryParameters: queryParameters);
    return list.map((e) => EntityFactory.generateOBJ<T>(e)).toList();
  }

  Future<PageData<T>> _getAndExactPageData<T>(String url,
      {Map<String, dynamic> queryParameters}) async {
    dynamic dataJson =
        await _getAndExactData(url, queryParameters: queryParameters);
    return PageData<T>.fromJson(dataJson);
  }

  Future<dynamic> _getAndExactData(String url,
      {Map<String, dynamic> queryParameters}) async {
    Response response = await _dio.get(url,
        cancelToken: _cancelToken, queryParameters: queryParameters);
    RespEntity repoEntity = RespEntity.fromJson(response.data);
    if (repoEntity.errorCode == 0) {
      return repoEntity.data;
    }
    throw ApiException(repoEntity.errorMsg);
  }
}
