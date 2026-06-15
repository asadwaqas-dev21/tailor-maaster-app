import "package:hive/hive.dart";
import "package:tailor_app/core/constants/hive_boxes.dart";
import "package:tailor_app/data/models/customer_model.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/domain/repositories/customer_repository.dart";

class CustomerRepositoryImpl implements CustomerRepository {
  Box<CustomerModel> get _box => Hive.box<CustomerModel>(HiveBoxes.customers);

  @override
  List<Customer> getAllCustomers() {
    final models = _box.values.toList();
    models.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Customer? getCustomerById(String id) {
    try {
      final model = _box.values.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  List<Customer> searchCustomers(String query) {
    final lowerQuery = query.toLowerCase();
    final models = _box.values.where((m) {
      return m.name.toLowerCase().contains(lowerQuery) ||
          m.phone.contains(lowerQuery);
    }).toList();
    models.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    await _box.put(customer.id, model);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    await _box.put(customer.id, model);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
  }

  @override
  int get customerCount => _box.length;
}
