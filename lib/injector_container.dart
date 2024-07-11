import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_retry_plus/dio_retry_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'feature/home/domain/repository/home_repository.dart';
import 'feature/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  /// Dio
  sl.registerLazySingleton(
    () => Dio()
      ..options = BaseOptions(
        contentType: 'application/json',
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )
      ..interceptors.add(
        LogInterceptor(
          request: kDebugMode,
          requestHeader: kDebugMode,
          requestBody: kDebugMode,
          responseHeader: kDebugMode,
          responseBody: kDebugMode,
          error: kDebugMode,
          logPrint: (object) {
            if (kDebugMode) {
              log('dio: $object');
            }
          },
        ),
      ),
  );

  sl<Dio>().interceptors.addAll(
    [
      RetryInterceptor(
        dio: sl<Dio>(),
        toNoInternetPageNavigator: () async {},
        accessTokenGetter: () => '',
        refreshTokenFunction: () async {},
        logPrint: (message) {
          if (kDebugMode) {
            log('dio: $message');
          }
        },
      ),
    ],
  );


  /// Features
  homeFeature();
}

void homeFeature() {
  /// Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(dio: sl()),
  );

  /// Bloc
  sl.registerFactory<HomeBloc>(() => HomeBloc(homeRepository: sl()));
}

