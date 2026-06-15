import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/core/enums/staff_role.dart";

abstract class StaffRepository {
  List<Staff> getAllStaff();
  List<Staff> getStaffByRole(StaffRole role);
  Staff? getStaffById(String id);
  Future<void> addStaff(Staff staff);
  Future<void> updateStaff(Staff staff);
  Future<void> deleteStaff(String id);
}
