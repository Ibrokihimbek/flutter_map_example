part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class GetCompaniesEvent extends HomeEvent {
  const GetCompaniesEvent();

  @override
  List<Object?> get props => [];
}