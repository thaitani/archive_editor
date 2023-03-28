import 'package:archive_editor/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

final router = GoRouter(routes: $appRoutes);

@TypedGoRoute<HomeRoute>(
  path: '/',
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MyHomePage();
}
