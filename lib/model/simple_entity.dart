
class SimpleEntity {
  final String id;
  final String name;

  SimpleEntity({
    required this.id,
    required this.name,
  });

  @override
  String toString() => name;
}