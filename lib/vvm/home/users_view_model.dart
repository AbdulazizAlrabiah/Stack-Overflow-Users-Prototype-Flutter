import 'package:flutter/material.dart';
import 'package:stack_overflow_users_prototype_flutter/model/db/user_manager.dart';
import 'package:stack_overflow_users_prototype_flutter/model/response/user_response.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking_generic_response.dart';
import 'package:stack_overflow_users_prototype_flutter/shared_utilities/shared_logger.dart';

class UsersViewModel with ChangeNotifier {
  NetworkingGenericResponse<UsersResponse>? _usersResponse;
  NetworkingGenericResponse<UsersResponse>? get usersResponse => _usersResponse;
  // Data source for the list view
  List<UserData> users = [];

  bool isBookmarkMode = false;

  // Pagination
  int pageSize = 30;
  int get nextPageNumber => (users.length / pageSize).ceil() + 1;
  bool isLoadingPaignation = false;

  UsersViewModel() {
    getUsersWithLoader();
  }

  Future<void> getUsers({
    required int pageNumber,
  }) async {
    if (isBookmarkMode) {
      _usersResponse = NetworkingGenericResponse.normal();
      return;
    }
    SharedLogger.shared.i("Will get users for page $pageNumber");

    final response = await Networking.shared.makeRequest(
      "/users",
      params: {
        "page": pageNumber.toString(),
        "pagesize": pageSize.toString(),
        "site": "stackoverflow",
      },
    );

    if (response.success) {
      _usersResponse = NetworkingGenericResponse.completed(
        UsersResponse.fromJson(response.data),
      );

      await checkIfBookmarkedAndSet(_usersResponse?.data?.items ?? []);

      if (pageNumber == 1) {
        users = _usersResponse?.data?.items ?? [];
      } else {
        users += _usersResponse?.data?.items ?? [];
      }

      notifyListeners();
    } else {
      _usersResponse = NetworkingGenericResponse.error(
        response.error?.message ?? "General error please try again",
      );

      notifyListeners();
    }
  }

  Future<void> getUsersWithLoader() async {
    _usersResponse = NetworkingGenericResponse.loading();
    notifyListeners();

    await getUsers(
      pageNumber: 1,
    );
  }

  Future<void> getUsersFromPaging() async {
    if (_usersResponse?.status != Status.loading &&
        _usersResponse?.status != Status.error &&
        (_usersResponse?.data?.hasMore ?? false) &&
        !isLoadingPaignation) {
      isLoadingPaignation = true;
      notifyListeners();
      await getUsers(pageNumber: nextPageNumber);
      isLoadingPaignation = false;
    }
  }

  Future<void> toggleBookmarkedUsersMode() async {
    isBookmarkMode = !isBookmarkMode;
    if (isBookmarkMode) {
      users = await UserManager.shared.users();
    } else {
      await getUsersWithLoader();
    }

    notifyListeners();
  }

  Future<void> toggleBookMarkUser(UserData user) async {
    if (await isBookMarkedUser(user)) {
      SharedLogger.shared.i("Will delete $user from bookmarks");
      await UserManager.shared.deleteUser(user.accountId);
      if (isBookmarkMode) {
        users.remove(user);
      } else {
        user.isBookmarked = false;
      }
    } else {
      SharedLogger.shared.i("Will insert $user in bookmarks");
      await UserManager.shared.insertUser(user);
      user.isBookmarked = true;
    }

    notifyListeners();
  }

  Future<void> checkIfBookmarkedAndSet(List<UserData> users) async {
    for (final user in users) {
      user.isBookmarked = await isBookMarkedUser(user);
    }

    notifyListeners();
  }

  Future<bool> isBookMarkedUser(UserData user) async {
    final userFromDB = await UserManager.shared.user(user.accountId);
    return userFromDB != null;
  }
}
