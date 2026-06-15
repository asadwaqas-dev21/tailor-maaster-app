import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/domain/repositories/customer_repository.dart";
import "package:tailor_app/presentation/blocs/customer/customer_event.dart";
import "package:tailor_app/presentation/blocs/customer/customer_state.dart";

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  CustomerBloc({required this._repository}) : super(const CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  void _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) {
    emit(const CustomerLoading());
    try {
      final customers = _repository.getAllCustomers();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  void _onSearchCustomers(SearchCustomers event, Emitter<CustomerState> emit) {
    try {
      final customers = event.query.isEmpty
          ? _repository.getAllCustomers()
          : _repository.searchCustomers(event.query);
      emit(CustomerLoaded(customers: customers, searchQuery: event.query));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _repository.addCustomer(event.customer);
      final customers = _repository.getAllCustomers();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _repository.updateCustomer(event.customer);
      final customers = _repository.getAllCustomers();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _repository.deleteCustomer(event.id);
      final customers = _repository.getAllCustomers();
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
