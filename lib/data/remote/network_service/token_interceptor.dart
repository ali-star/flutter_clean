import 'package:dio/dio.dart';

class TokenInterceptor extends InterceptorsWrapper {

  Dio _dio;

  TokenInterceptor() {
    BaseOptions options = new BaseOptions(
      baseUrl: "https://api.3soot.ir/",
      connectTimeout: 20000,
      receiveTimeout: 20000
    );
    _dio = new Dio(options);
  }

  @override
  Future onRequest(RequestOptions options) {
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    if (response.statusCode  == 401) {

    }
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    return super.onError(err);
  }

}