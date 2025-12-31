import 'package:get/get.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';

class CurrentUser extends GetxController {
  // FIX: Added default 'customer' role and empty '' shop_name to match the new User model
  final Rx<User> _currentUser = User(0, '', '', '', '', 'customer', '','').obs;

  User get user => _currentUser.value;
  String get userName => _currentUser.value.user_name;

  getUserInfo() async {
    User? getUserInfoFromLocalStorage = await RemUSer.readUSerInfo();
    // Safety check: only update if data exists
    if (getUserInfoFromLocalStorage != null) {
      _currentUser.value = getUserInfoFromLocalStorage;
    }
  }
}