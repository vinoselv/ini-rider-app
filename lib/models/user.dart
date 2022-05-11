

class User{
  String name;
  String iconKey;
  String email;
  String id;

  User({
    this.email,
    this.name,
    this.iconKey,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "iconKey": iconKey,
  };

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      iconKey: data['iconKey']
    );
  }

}