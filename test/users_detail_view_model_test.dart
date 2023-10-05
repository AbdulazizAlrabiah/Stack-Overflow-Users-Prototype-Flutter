import 'package:flutter_test/flutter_test.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/detail/user_detail_view_model.dart';

void main() async {
  group('Fetch User details', () {
    test('Test fetch user details', () async {
      final vm = UserDetailViewModel();

      await vm.getUserDetails(userId: 22656, pageNumber: 1);

      expect(vm.userDetails.length, 30);
    });

    test('Test fetching user details with loader', () async {
      final vm = UserDetailViewModel();

      await vm.getUserDetailsWithLoader(userId: 22656);

      expect(vm.userDetails.length, 30);
    });
  });
}
