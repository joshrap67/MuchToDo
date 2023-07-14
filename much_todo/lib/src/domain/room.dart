class Room {
  // todo rename to something generic like "Section"
  String id;
  String name;
  List<String> todos = [];
  // todo sort val for custom sort
  // todo area
  // todo area unit
  // todo generic note
  // todo house? that might be too much. how many people have more than one house... this aint a landlord app

  Room(this.id, this.name, this.todos);

  @override
  String toString() {
    return '{Id: $id name: $name todos: $todos}';
  }
}
