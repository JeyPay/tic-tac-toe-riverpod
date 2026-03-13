import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';
import 'package:tic_tac_toe/pages/game_grid/game_grid_page.dart';
import 'package:tic_tac_toe/utils/extensions/extensions.dart';
import 'package:tic_tac_toe/utils/injector.dart';
import 'package:tic_tac_toe/utils/theme/app_padding.dart';
import 'package:tic_tac_toe/utils/theme/app_theme.dart';

class FirstPlayerChoicePage extends StatelessWidget {
  static const String path = '/first-player-choice';

  const FirstPlayerChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _startGame(context, IGameController.aiPlayerTickType),
              child: Container(
                alignment: Alignment.center,
                color: AppTheme.of(context).primaryColor,
                child: Text(
                  "AI",
                  style: optionStyle,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            color: AppTheme.of(context).foregroundColor,
            padding: AppPadding.medium.verticalInsets(),
            child: Text(
              "Who starts ?",
              style: TextStyle(fontSize: 16, color: AppTheme.of(context).primaryColor),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _startGame(context, IGameController.humanPlayerTickType),
              child: Container(
                alignment: Alignment.center,
                color: AppTheme.of(context).secondaryColor,
                child: Text(
                  "Player",
                  style: optionStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get optionStyle => TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  void _startGame(BuildContext context, GameTickType tickType) {
    final IGameController gameController = Injector.get<IGameController>();

    gameController.setFirstPlayer(tickType);
    gameController.init();

    context.go(GameGridPage.path);
  }
}
