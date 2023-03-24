import 'package:archive_editor/pages/home.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'root',
      builder: (context, state) => const MyHomePage(),
    ),
  ],
);
