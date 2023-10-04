import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users_prototype_flutter/model/db/database_manager.dart';
import 'package:stack_overflow_users_prototype_flutter/route_name.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/detail/user_detail_screen.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/detail/user_detail_view_model.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/home/users_screen.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/home/users_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Will not await for better performance
  DatabaseManager.shared.openDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersViewModel>(
          create: (context) => UsersViewModel(),
        ),
        ChangeNotifierProvider<UserDetailViewModel>(
          create: (context) => UserDetailViewModel(),
        ),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) {
          return "SOF Prototype";
        },
        home: const UsersScreen(),
        onGenerateRoute: (RouteSettings settings) {
          final routes = <String, WidgetBuilder>{
            RouteName.userDetailRouteName: (ctx) {
              final args = settings.arguments as Map<String, Object>;
              final userId = args["user_id"] as int;
              final name = args["name"] as String;

              return UserDetailScreen(
                userId: userId,
                name: name,
              );
            },
          };

          WidgetBuilder builder = routes[settings.name]!;
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
      ),
    );
  }
}
