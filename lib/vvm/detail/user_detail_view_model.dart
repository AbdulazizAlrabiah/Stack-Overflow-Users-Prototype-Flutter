import 'package:flutter/material.dart';
import 'package:stack_overflow_users_prototype_flutter/model/response/user_detail_response.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking_generic_response.dart';
import 'package:stack_overflow_users_prototype_flutter/shared_utilities/shared_logger.dart';

class UserDetailViewModel with ChangeNotifier {
  NetworkingGenericResponse<UserDetailResponse>? _userDetailResponse;
  NetworkingGenericResponse<UserDetailResponse>? get userDetailResponse =>
      _userDetailResponse;
  // Data source for the list view
  List<UserDetailData> userDetails = [];

  // Pagination
  final pageSize = 30;
  int get nextPageNumber => (userDetails.length / pageSize).ceil() + 1;
  bool isLoadingPaignation = false;

  Future<void> getUserDetails({
    required int userId,
    required int pageNumber,
  }) async {
    SharedLogger.shared.i("Will get user details for page $pageNumber");

    final response = await Networking.shared.makeRequest(
      "/users/$userId/reputation-history",
      params: {
        "page": pageNumber.toString(),
        "pagesize": pageSize.toString(),
        "site": "stackoverflow",
      },
    );

    if (response.success) {
      _userDetailResponse = NetworkingGenericResponse.completed(
        UserDetailResponse.fromJson(response.data),
      );

      if (pageNumber == 1) {
        userDetails = _userDetailResponse?.data?.items ?? [];
      } else {
        userDetails += _userDetailResponse?.data?.items ?? [];
      }

      notifyListeners();
    } else {
      _userDetailResponse = NetworkingGenericResponse.error(
        response.error?.message ?? "General error please try again",
      );

      notifyListeners();
    }
  }

  Future<void> getUserDetailsWithLoader({required int userId}) async {
    _userDetailResponse = NetworkingGenericResponse.loading();
    notifyListeners();

    await getUserDetails(
      userId: userId,
      pageNumber: 1,
    );
  }

  Future<void> getUserDetailsFromPaging({required int userId}) async {
    if (_userDetailResponse?.status != Status.loading &&
        _userDetailResponse?.status != Status.error &&
        (_userDetailResponse?.data?.hasMore ?? false) &&
        !isLoadingPaignation) {
      isLoadingPaignation = true;
      notifyListeners();
      await getUserDetails(
        userId: userId,
        pageNumber: nextPageNumber,
      );
      isLoadingPaignation = false;
    }
  }
}
