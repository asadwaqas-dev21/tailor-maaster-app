import "package:tailor_app/core/constants/hive_boxes.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:tailor_app/data/models/staff_model.dart";
import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/domain/repositories/staff_repository.dart";

class StaffRepositoryImpl implements StaffRepository {
  final _box = Hive.box<StaffModel>(HiveBoxes.staff);

  @override
  List<Staff> getAllStaff() {
    return _box.values.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  List<Staff> getStaffByRole(StaffRole role) {
    return _box.values
        .where((model) => model.role == role && model.isActive)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Staff? getStaffById(String id) {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> addStaff(Staff staff) async {
    final model = StaffModel.fromEntity(staff);
    await _box.put(staff.id, model);
  }

  @override
  Future<void> updateStaff(Staff staff) async {
    final model = StaffModel.fromEntity(staff);
    await _box.put(staff.id, model);
  }

  @override
  Future<void> deleteStaff(String id) async {
    await _box.delete(id);
  }
}
