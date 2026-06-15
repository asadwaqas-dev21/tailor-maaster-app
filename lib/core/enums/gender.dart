import "package:hive/hive.dart";

part "gender.g.dart";

@HiveType(typeId: 10)
enum Gender {
  @HiveField(0)
  male,

  @HiveField(1)
  female,
}
