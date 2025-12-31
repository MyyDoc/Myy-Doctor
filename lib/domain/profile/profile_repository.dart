import 'package:myydoctor/data/user/user_model.dart';
import 'package:myydoctor/services/rtdb_services.dart';

class ProfileRepository {
  final UserRTDBService _userService;

  ProfileRepository({UserRTDBService? userService})
      : _userService = userService ?? UserRTDBService();

  /// Get user once
  Future<UserModel?> getUser() async {
    return _userService.getUser();
  }

  /// Stream user for real-time updates
  Stream<UserModel?> userStream() {
    return _userService.userStream();
  }

  /// Save/update user
  Future<void> saveUser(UserModel user) async {
    await _userService.saveUser(user);
  }
}
