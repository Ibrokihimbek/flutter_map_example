part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.getCompaniesStatus = ApiStatus.initial,
    this.companies = const [],
  });

  final ApiStatus getCompaniesStatus;
  final List<Results> companies;

  HomeState copyWith({
    ApiStatus? getCompaniesStatus,
    List<Results>? companies,
  }) =>
      HomeState(
        getCompaniesStatus: getCompaniesStatus ?? ApiStatus.initial,
        companies: companies ?? this.companies,
      );

  @override
  List<Object?> get props => [
        getCompaniesStatus,
        companies,
      ];
}

enum ApiStatus {
  initial,
  loading,
  success,
  error;

  bool get isInitial => this == ApiStatus.initial;

  bool get isLoading => this == ApiStatus.loading;

  bool get isSuccess => this == ApiStatus.success;

  bool get isError => this == ApiStatus.error;
}
