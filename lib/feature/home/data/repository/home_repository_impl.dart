part of '../../domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required this.dio,
  });

  final Dio dio;


  @override
  Future<Either<Failure, GetCompanyLogoResponse>> fetchCompany() async {
    try {
      final Response response = await dio.get(
        'https://commeta.uz/review/a/api/v1/CompanyMapList/',
        queryParameters: {
          'lat': 41.311081,
          'long': 69.240562,
          'radius': 7000,
          'category_slug' : 'restaurants-and-bars',
        },
      );
      return Right(GetCompanyLogoResponse.fromJson(response.data));
    } on DioException catch (error, stacktrace) {
      log('Exception occurred: $error stacktrace: $stacktrace');
      return Left(ServerError.withDioError(error: error).failure);
    } on Exception catch (error, stacktrace) {
      log('Exception occurred: $error stacktrace: $stacktrace');
      return Left(ServerError.withError(message: error.toString()).failure);
    }
  }

}
