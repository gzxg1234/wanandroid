import 'package:dio/dio.dart';

import '../entity_factory.dart';
import 'bean/bean.dart';

class ApiException implements Exception {
  final String msg;

  ApiException(this.msg);
}

class ApiClient {
  static Dio ___dio;

  static const LOG_ENABLE = true;

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

  CancelToken _cancelToken;

  ApiClient([this._cancelToken]);

  void dispose() {
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
  Future<List<CategoryEntity>> getProjectCategoryList() async {
    Response response = await _dio.get("/project/tree/json");
    return transferList<CategoryEntity>(response);
  }

  ///
  /// 最新项目
  ///
  Future<PageData<ArticleEntity>> getNewsProjectList(int page) async {
    Response response = await _dio.get("/article/listproject/$page/json",
        cancelToken: _cancelToken);
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 项目列表
  ///
  Future<PageData<ArticleEntity>> getProjectList(int page, [int cid]) async {
    Response response = await _dio.get("/project/list/$page/json",
        queryParameters: cid == null ? {} : {"cid": cid});
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 文章体系分类数据
  ///
  Future<List<CategoryEntity>> getArticleCategoryList() async {
    Response response = await _dio.get("/tree/json");
    return transferList<CategoryEntity>(response);
  }

  ///
  /// 置顶文章
  ///
  Future<List<ArticleEntity>> _getTopArticleList() async {
    Response response = await _dio.get("/article/top/json");
    return transferList<ArticleEntity>(response);
  }

  ///
  /// 文章列表
  ///
  Future<PageData<ArticleEntity>> getArticleList(int page, [int cid]) async {
    Response response = await _dio.get("/article/list/$page/json",
        queryParameters: cid == null ? {} : {"cid": cid});
    return transferPageData<ArticleEntity>(response);
  }

  ///
  /// 文章列表
  ///
  Future<PageData<ArticleEntity>> search(String word, int page) async {
    print('$word,$page');
    Response response =
    await _dio.post(
        "/article/query/$page/json", data: FormData.from({'k':'$word'}));
    return transferPageData<ArticleEntity>(response);
    }

    Future<List<BannerEntity>> _getBanner() async {
    Response response = await _dio.get("/banner/json");
    return transferList<BannerEntity>(response);
    }

        ///搜索热词
        Future<List<HotWordEntity>> getHotWord()
    async {
      Response response = await _dio.get("/hotkey/json");
      return transferList<HotWordEntity>(response);
    }

    List<T> transferList<T>(Response response) {
      List list = exactData(response);
      return list.map((e) => EntityFactory.generateOBJ<T>(e)).toList();
    }

    PageData<T> transferPageData<T>(Response response) {
      dynamic jsonData = exactData(response);
      return PageData<T>.fromJson(jsonData);
    }

    dynamic exactData(Response response) {
      RespEntity repoEntity = RespEntity.fromJson(response.data);
      if (repoEntity.errorCode == 0) {
        return repoEntity.data;
      }
      throw ApiException(repoEntity.errorMsg);
    }
  }
