import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/modles/get_company_logo.dart';
import '../../domain/repository/home_repository.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this.homeRepository,
  }) : super(const HomeState()) {
    on<GetCompaniesEvent>(_getCompanies);
  }

  final HomeRepository homeRepository;

  Future<void> _getCompanies(
    GetCompaniesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getCompaniesStatus: ApiStatus.loading));
    final result = await homeRepository.fetchCompany();
    result.fold(
      (failure) {
        emit(state.copyWith(getCompaniesStatus: ApiStatus.error));
      },
      (response) {
        emit(
          state.copyWith(
            getCompaniesStatus: ApiStatus.success,
            companies: response.results,
          ),
        );
      },
    );
  }
}
