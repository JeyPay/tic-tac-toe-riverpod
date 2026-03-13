import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';
import 'package:tic_tac_toe/pages/game_grid/game_grid_provider.dart';
import 'package:tic_tac_toe/utils/extensions/context_extension.dart';
import 'package:tic_tac_toe/utils/extensions/extensions.dart';
import 'package:tic_tac_toe/utils/extensions/radius_extension.dart';
import 'package:tic_tac_toe/utils/injector.dart';
import 'package:tic_tac_toe/utils/theme/app_padding.dart';
import 'package:tic_tac_toe/utils/theme/app_radius.dart';
import 'package:tic_tac_toe/utils/theme/app_theme.dart';
import 'package:tic_tac_toe/widgets/game_tick.dart';

class GameGridPage extends StatelessWidget {
  static const String path = '/game-grid';

  const GameGridPage({super.key});

  static Widget separator(BuildContext context) => Container(height: 5, color: AppTheme.of(context).foregroundColor);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider<GameGridProvider>(
        create: (context) => GameGridProvider(context),
        child: Consumer<GameGridProvider>(
          builder: (context, gameGridProvider, child) {
            return Column(
              children: [
                _TopBar(),
                separator(context),
                Expanded(
                  child: Stack(
                    children: [
                      _GameGrid(),
                      if (!gameGridProvider.state.isGameOngoing)
                        Positioned(
                          bottom: AppPadding.medium,
                          left: AppPadding.medium,
                          right: AppPadding.medium,
                          child: _NewGameButton(),
                        ),
                    ],
                  ),
                ),
                separator(context),
                _BottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameGrid extends StatelessWidget {
  const _GameGrid();

  @override
  Widget build(BuildContext context) {
    final gameGridProvider = context.read<GameGridProvider>();
    final isGameOngoing = context.select<GameGridProvider, bool>(
      (gameGridProvider) => gameGridProvider.state.isGameOngoing,
    );
    final winnerLine = context.select<GameGridProvider, GridLine?>(
      (gameGridProvider) => gameGridProvider.state.winnerLine,
    );
    final grid = context.select<GameGridProvider, List<List<GameTickType?>>>(
      (gameGridProvider) => gameGridProvider.state.grid,
    );

    return IgnorePointer(
      ignoring: !isGameOngoing,
      child: CustomPaint(
        foregroundPainter: _WinnerLinePainter(
          from: winnerLine?.from,
          to: winnerLine?.to,
          color: AppTheme.status(context).error,
          gridSize: IGameController.gridSize,
        ),
        child: CustomPaint(
          foregroundPainter: _GridPainter(
            gridSize: IGameController.gridSize,
            color: AppTheme.of(context).foregroundColor,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: grid
                  .mapIndexed(
                    (rowIndex, row) => Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: row
                            .mapIndexed(
                              (colIndex, col) => Expanded(
                                child: GestureDetector(
                                  onTap: () => gameGridProvider.onTileTap(rowIndex, colIndex),
                                  child: GameTickWidget(
                                    type: grid[rowIndex][colIndex] ?? GameTickType.none,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.popToRoot(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryColor,
        ),
        padding: EdgeInsets.only(
          top: AppPadding.large,
          bottom: max(MediaQuery.paddingOf(context).bottom, AppPadding.large),
        ),
        child: Text(
          "Menu",
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

class _NewGameButton extends StatelessWidget {
  const _NewGameButton();

  @override
  Widget build(BuildContext context) {
    final IGameController gameController = Injector.get<IGameController>();

    return GestureDetector(
      onTap: () => gameController.startNewGame(),
      child: Container(
        alignment: Alignment.center,
        padding: AppPadding.medium.verticalInsets(),
        decoration: BoxDecoration(
          color: AppTheme.status(context).warning,
          borderRadius: AppRadius.medium.allRadius(),
        ),
        child: Text("New game", style: TextStyle(fontSize: 17)),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final IGameController gameController = Injector.get<IGameController>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryColor,
      ),
      padding: EdgeInsets.only(
        top: max(MediaQuery.paddingOf(context).top, AppPadding.large),
        bottom: AppPadding.large,
      ),
      child: Padding(
        padding: AppPadding.large.horizontalInsets(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ScoreIndicator(
              stream: gameController.scoreCrossStream,
              type: GameTickType.cross,
            ),
            _PlayerPlayingIndicator(),
            _ScoreIndicator(
              stream: gameController.scoreCircleStream,
              type: GameTickType.circle,
              rightSide: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final GameTickType type;
  final Stream stream;
  final bool rightSide;

  const _ScoreIndicator({
    required this.type,
    required this.stream,
    this.rightSide = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: 0,
      builder: (context, asyncSnapshot) {
        var children = [
          switch (type) {
            GameTickType.none => Icon(Icons.question_mark, size: 36, color: AppTheme.of(context).foregroundColor),
            GameTickType.circle => Icon(Icons.circle_outlined, size: 32, color: AppTheme.of(context).foregroundColor),
            GameTickType.cross => Icon(Icons.close, size: 36, color: AppTheme.of(context).foregroundColor),
          },
          Text(
            asyncSnapshot.data.toString(),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ];
        if (rightSide) {
          children = children.reversed.toList();
        }
        return Row(
          spacing: AppPadding.medium,
          children: children,
        );
      },
    );
  }
}

class _PlayerPlayingIndicator extends StatelessWidget {
  const _PlayerPlayingIndicator();

  @override
  Widget build(BuildContext context) {
    final playerTurn = context.select<GameGridProvider, GameTickType>(
      (gameGridProvider) => gameGridProvider.state.playerTurn,
    );

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      child: switch (playerTurn) {
        GameTickType.none => Icon(
          Icons.question_mark,
          size: 32,
          color: AppTheme.of(context).foregroundColor,
          key: Key("PlayerToPlay: none"),
        ),
        GameTickType.circle => Icon(
          Icons.circle_outlined,
          size: 32,
          color: AppTheme.of(context).foregroundColor,
          key: Key("PlayerToPlay: circle"),
        ),
        GameTickType.cross => Icon(
          Icons.close,
          size: 32,
          color: AppTheme.of(context).foregroundColor,
          key: Key("PlayerToPlay: cross"),
        ),
      },
    );
  }
}

class _WinnerLinePainter extends CustomPainter {
  final GridPos? from;
  final GridPos? to;
  final Color color;
  final int gridSize;

  _WinnerLinePainter({
    required this.from,
    required this.to,
    required this.color,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (from == null || to == null) return;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final double divx = size.width / gridSize;
    final double divy = size.height / gridSize;
    final double halfx = divx / 2;
    final double halfy = divy / 2;

    final Offset p1 = Offset(divx * from!.col, divy * from!.row).translate(halfx, halfy);
    final Offset p2 = Offset(divx * to!.col, divy * to!.row).translate(halfx, halfy);
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter {
  final int gridSize;
  final Color color;

  _GridPainter({
    required this.gridSize,
    required this.color,
  });

  static const double offset = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withAlpha(128)
      ..strokeWidth = 0.5;

    final double divx = size.width / gridSize;
    final double divy = size.height / gridSize;

    for (int i = 1; i < gridSize; i++) {
      final double x = divx * i;
      canvas.drawLine(Offset(x, offset), Offset(x, size.height - offset), paint);
    }

    for (int i = 1; i < gridSize; i++) {
      final double y = divy * i;
      canvas.drawLine(Offset(offset, y), Offset(size.width - offset, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
