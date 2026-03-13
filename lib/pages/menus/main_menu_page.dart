import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/pages/menus/game_mode_selection_page.dart';
import 'package:tic_tac_toe/utils/extensions/extensions.dart';
import 'package:tic_tac_toe/utils/theme/app_padding.dart';
import 'package:tic_tac_toe/utils/theme/app_theme.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.go(GameModeSelectionPage.path),
              child: Container(
                alignment: Alignment.center,
                color: AppTheme.of(context).primaryColor,
                child: Text(
                  "Play",
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
              "Choose an option",
              style: TextStyle(fontSize: 16, color: AppTheme.of(context).primaryColor),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<AppTheme>().switchMode(),
              child: Container(
                alignment: Alignment.center,
                color: AppTheme.of(context).secondaryColor,
                child: Text(
                  "Theme mode",
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
}
