import 'package:archive_editor/features/home/home_page.dart';
import 'package:archive_editor/features/settings/presentation/settings_page.dart';
import 'package:archive_editor/features/zip_editor/presentation/zip_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

final router = GoRouter(
  routes: $appRoutes,
  errorBuilder: (context, state) {
    return const Center(
      child: Text('error'),
    );
  },
);

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<ZipEditorRoute>(path: 'editor'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class ZipEditorRoute extends GoRouteData with $ZipEditorRoute {
  const ZipEditorRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ZipEditorPage();
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}
