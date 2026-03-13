import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';
import 'package:tic_tac_toe/controllers/game_intelligence_controller.dart';
import 'package:tic_tac_toe/pages/game_grid/game_grid_page.dart';
import 'package:tic_tac_toe/pages/menus/first_player_choice_page.dart';
import 'package:tic_tac_toe/pages/menus/game_mode_selection_page.dart';
import 'package:tic_tac_toe/pages/menus/main_menu_page.dart';
import 'package:tic_tac_toe/utils/injector.dart';
import 'package:tic_tac_toe/utils/preferences.dart';
import 'package:tic_tac_toe/utils/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await preferences.init();

  Injector.register<IGameController>(GameController());
  Injector.register<IGameIntelligenceController>(GameIntelligenceController(gridSize: IGameController.gridSize));

  runApp(AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppTheme>(
      create: (context) => AppTheme(),
      child: Consumer<AppTheme>(
        builder: (context, appTheme, child) {
          return MaterialApp.router(
            theme: appTheme.theme,
            darkTheme: appTheme.darkTheme,
            themeMode: appTheme.mode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainMenuPage();
      },
      routes: <RouteBase>[
        for (final page in [
          (GameGridPage.path, GameGridPage()),
          (GameModeSelectionPage.path, GameModeSelectionPage()),
          (FirstPlayerChoicePage.path, FirstPlayerChoicePage()),
        ])
          GoRoute(
            path: page.$1,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 200),
              child: page.$2,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ),
      ],
    ),
  ],
);
