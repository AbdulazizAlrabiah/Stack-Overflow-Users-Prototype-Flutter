import 'package:flutter/material.dart';
import 'package:stack_overflow_users_prototype_flutter/model/response/user_response.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking_generic_response.dart';

class UsersViewModel with ChangeNotifier {
  NetworkingGenericResponse<UsersResponse>? _usersResponse;
  NetworkingGenericResponse<UsersResponse>? get usersResponse => _usersResponse;
  // Data source for the list view
  List<UserData> users = [];

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
}
