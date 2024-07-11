import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../either/either.dart';
import '../../../../error/failure.dart';
import '../../../../error/server_error.dart';
import '../../data/modles/get_company_logo.dart';

part '../../data/repository/home_repository_impl.dart';

sealed class HomeRepository {
  Future<Either<Failure, GetCompanyLogoResponse>> fetchCompany();
}
