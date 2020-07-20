import 'package:dio/dio.dart';
import 'package:flutter_app/data/remote/network_service/token_interceptor.dart';

class NetworkService {

  Dio _dio;
  TokenInterceptor _tokenInterceptor;

  NetworkService() {
    _dio = _initDio("https://api.3soot.ir/");
  }

  Dio _initDio(String baseUrl) {
    BaseOptions baseOptions = new BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 20000,
        receiveTimeout: 20000
    );

    Dio dio = new Dio(baseOptions);

    _tokenInterceptor = new TokenInterceptor();
    dio.interceptors.add(_tokenInterceptor);

    return new Dio(baseOptions);
  }

  Dio getDio() {
    return _dio;
  }

}