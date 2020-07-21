import 'package:dio/dio.dart';
import 'package:flutter_app/data/account_manager.dart';
import 'package:flutter_app/data/model/account.dart';
import 'package:flutter_app/data/remote/network_service/token_interceptor.dart';

class NetworkService {

  static final NetworkService _networkService = NetworkService._internal();

  factory NetworkService() {
    return _networkService;
  }

  Dio _dio;
  AuthenticationInterceptor _tokenInterceptor;

  Dio _initDio(String baseUrl) {
    BaseOptions baseOptions = new BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 20000,
        receiveTimeout: 20000
    );

    Dio dio = new Dio(baseOptions);

    _tokenInterceptor = new AuthenticationInterceptor(dio);
    dio.interceptors.add(_tokenInterceptor);

    return dio;
  }

  Dio getDio() {
    return _dio;
  }

  NetworkService._internal() {
    _dio = _initDio("http://192.168.10.45:8385/");
  }

}