class Option {
  String name;
  String shortName;
  String description;
  String value;
  bool existsInArgs = false;

  Option(
      {required this.name,
      this.description = '',
      this.value = '',
      this.shortName = ''});
}
