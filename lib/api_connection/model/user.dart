// // ignore_for_file: non_constant_identifier_names

// class User {
//   int user_id;
//   String user_name;
//   String user_email;
//   String user_password;
//   String user_phone;
//   String role;       // <--- MUST BE HERE
//   String shop_name;  // <--- MUST BE HERE

//   User(
//     this.user_id, 
//     this.user_name, 
//     this.user_email, 
//     this.user_password,
//     this.user_phone,
//     this.role,
//     this.shop_name,
//   );

//   factory User.fromJson(Map<String, dynamic> json) => User(
//     int.parse(json['user_id']),
//     json['user_name'],
//     json['user_email'],
//     json['user_password'],
//     json['user_phone'],
//     json['role'] ?? 'customer',      // <--- CRITICAL LINE
//     json['shop_name'] ?? '',         
//   );

//   Map<String, dynamic> toJson() => {
//     'user_id': user_id.toString(),
//     'user_name': user_name,
//     'user_email': user_email,
//     'user_password': user_password,
//     'user_phone': user_phone,
//     'role': role,
//     'shop_name': shop_name,
//   };
// }


// ignore_for_file: non_constant_identifier_names

class User {
  int user_id;
  String user_name;
  String user_email;
  String user_password;
  String user_phone;
  String role;
  String shop_name;
  String user_image; // <--- NEW FIELD

  User(
    this.user_id, 
    this.user_name, 
    this.user_email, 
    this.user_password,
    this.user_phone,
    this.role,
    this.shop_name,
    this.user_image, // <--- Add to constructor
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    int.parse(json['user_id']),
    json['user_name'],
    json['user_email'],
    json['user_password'],
    json['user_phone'],
    json['role'] ?? 'customer',
    json['shop_name'] ?? '',
    json['user_image'] ?? '', // <--- Read from JSON (default empty)
  );

  Map<String, dynamic> toJson() => {
    'user_id': user_id.toString(),
    'user_name': user_name,
    'user_email': user_email,
    'user_password': user_password,
    'user_phone': user_phone,
    'role': role,
    'shop_name': shop_name,
    'user_image': user_image, // <--- Save to JSON
  };
}