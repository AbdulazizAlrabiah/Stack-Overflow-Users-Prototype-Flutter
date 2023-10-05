import 'dart:math';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stack_overflow_users_prototype_flutter/model/db/database_manager.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/home/users_view_model.dart';
import 'package:test/test.dart';

void main() async {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseManager.shared.openDB();
  });

  group('Fetch Users', () {
    test('Test fetching users', () async {
      final vm = UsersViewModel();

      await vm.getUsers(pageNumber: 1);

      expect(vm.users.length, 30);
    });

    test('Test fetching users with loader', () async {
      final vm = UsersViewModel();

      await vm.getUsersWithLoader();

      expect(vm.users.length, 30);
    });
  });

  group('Bookmark', () {
    test('Test toggle bookmark', () async {
      final vm = UsersViewModel();

      await vm.getUsers(pageNumber: 1);

      final random = Random();
      final randomIndex = random.nextInt(vm.users.length);

      final user = vm.users[randomIndex];

      await vm.toggleBookMarkUser(user);

      expect(vm.users[randomIndex].isBookmarked, true);
    });
  });
}
