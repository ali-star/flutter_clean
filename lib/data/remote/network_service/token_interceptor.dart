import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_app/data/account_manager.dart';
import 'package:flutter_app/data/model/account.dart';

class AuthenticationInterceptor extends InterceptorsWrapper {

  Dio _mainDio;
  Dio _dio;

  AuthenticationInterceptor(Dio mainDio) {
    this._mainDio = mainDio;
    BaseOptions options = new BaseOptions(
        baseUrl: "http://192.168.10.45:8385",
        connectTimeout: 20000,
        receiveTimeout: 20000
    );
    _dio = new Dio(options);
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest:(RequestOptions options) {
          print("_dio onRequest");
        }
    ));
  }

  @override
  Future onRequest(RequestOptions options) async {
    Account account = AccountManager().getAccount();
    if (account != null) {
      print(account.accessToken);
      options.headers["Authorization"] = "Bearer " + account.accessToken;
    }

    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) async {
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) async {
    Account account = AccountManager().getAccount();
    if (err.response.statusCode == 401) {
      if (account != null) {
        if (account.accessToken != null && account.tokenExpiresOn > new DateTime.now().millisecondsSinceEpoch) {
          var options = err.response.request;
          options.headers["Authorization"] = "Bearer " + account.accessToken;

          return await _mainDio.request(options.path,
              data: options.data,
              queryParameters: options.queryParameters,
              options: options).then((e) {
            return _mainDio.request(options.path, options: options);
          });
        } else {
          _mainDio.lock();
          _mainDio.interceptors.responseLock.lock();
          _mainDio.interceptors.errorLock.lock();

          print("Refreshing Token...");
          var response = await _dio.get(
              "/identity/v1/Auth/authRefreshToken",
              options: Options(
                  headers: {"RefreshToken": account.refreshToken}));

          if (response.statusCode == 401) {
            _mainDio.unlock();
            _mainDio.interceptors.responseLock.unlock();
            _mainDio.interceptors.errorLock.unlock();
            return err;
          }

          if (!(response is DioError)) {
            print(response.data);

            final mJson = json.decode(response.data);
            var map = Map<String, dynamic>.from(mJson);

            account.accessToken = map["Data"]["access_token"];
            account.refreshToken = map["Data"]["refresh_token"];
            account.expiresIn = map["Data"]["expires_in"];
            account.tokenExpiresOn = new DateTime.now()
                .millisecondsSinceEpoch + (account.expiresIn.toInt() * 1000);


            var options = err.response.request;

            options.headers["Authorization"] = "Bearer " + account.accessToken;

            print("/////////////////// ${options.headers.keys}");

            _mainDio.unlock();
            _mainDio.interceptors.responseLock.unlock();
            _mainDio.interceptors.errorLock.unlock();

            return await _mainDio.request(options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: options).whenComplete(() {}).then((e) {
              return _mainDio.request(options.path, options: options);
            });
          } else {
            _mainDio.unlock();
            _mainDio.interceptors.responseLock.unlock();
            _mainDio.interceptors.errorLock.unlock();
            print(response);
            return response;
          }

        }
      } else {
        print("Account is null");
      }
    }
    return super.onError(err);
  }

/*static Future<Response<dynamic>> retry(
      Dio dio, RequestOptions requestOptions) async {
    print('retry path:${requestOptions.path}');
    final Options options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    isRetryCall = true;
    return dio
        .request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options)
        .whenComplete(() => isRetryCall = false);
  }*/

}