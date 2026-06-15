import "package:tailor_app/domain/entities/customer.dart";

abstract class CustomerRepository {
  /// Get all customers sorted by name
  List<Customer> getAllCustomers();

  /// Get customer by ID
  Customer? getCustomerById(String id);

  /// Search customers by name or phone
  List<Customer> searchCustomers(String query);

  /// Add a new customer
  Future<void> addCustomer(Customer customer);

  /// Update an existing customer
  Future<void> updateCustomer(Customer customer);

  /// Delete a customer by ID
  Future<void> deleteCustomer(String id);

  /// Get total customer count
  int get customerCount;
}
