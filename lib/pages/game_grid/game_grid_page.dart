import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:tic_tac_toe/widgets/winner_overlay.dart';

class GameGridPage extends ConsumerWidget {
  static const String path = '/game-grid';

  const GameGridPage({super.key});

  static Widget separator(BuildContext context) => Container(height: 5, color: AppTheme.of(context).foregroundColor);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameGridState = ref.watch(gameGridProvider);

    ref.listen<GameGridState>(gameGridProvider, (previous, next) {
      if (previous?.winnerLine == null && next.winnerLine != null) {
        final controller = ref.read(gameControllerProvider);

        WinnerOverlay.trigger(
          context,
          controller.winnerStream.value,
        );
      }
    });

    return Material(
      child: Column(
        children: [
          _topBar(context, gameGridState, ref),
          separator(context),
          Expanded(
            child: Stack(
              children: [
                _gameGrid(gameGridState, context, ref),
                if (!gameGridState.isGameOngoing)
                  Positioned(
                    bottom: AppPadding.medium,
                    left: AppPadding.medium,
                    right: AppPadding.medium,
                    child: _newGameButton(context),
                  ),
              ],
            ),
          ),
          separator(context),
          _bottomBar(context),
        ],
      ),
    );
  }

  Widget _newGameButton(BuildContext context) {
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

  Widget _bottomBar(BuildContext context) {
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

  Widget _gameGrid(GameGridState gameGridState, BuildContext context, WidgetRef ref) {
    final gameActions = ref.watch(gameActionsProvider);

    return IgnorePointer(
      ignoring: !gameGridState.isGameOngoing,
      child: CustomPaint(
        foregroundPainter: _WinnerLinePainter(
          from: gameGridState.winnerLine?.from,
          to: gameGridState.winnerLine?.to,
          color: AppTheme.status(context).error,
          gridSize: GameController.gridSize,
        ),
        child: CustomPaint(
          foregroundPainter: _GridPainter(
            gridSize: GameController.gridSize,
            color: AppTheme.of(context).foregroundColor,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: gameGridState.grid
                  .mapIndexed(
                    (rowIndex, row) => Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: row
                            .mapIndexed(
                              (colIndex, col) => Expanded(
                                child: GestureDetector(
                                  onTap: () => gameActions.onTileTap(rowIndex, colIndex),
                                  child: GameTickWidget(
                                    type: gameGridState.grid[rowIndex][colIndex] ?? GameTickType.none,
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

  Widget _topBar(BuildContext context, GameGridState gameGridState, WidgetRef ref) {
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
            _scoreIndicator(stream: gameController.scoreCrossStream, type: GameTickType.cross),
            _playerPlayingIndicator(gameGridState, context),

            _scoreIndicator(
              stream: gameController.scoreCircleStream,
              type: GameTickType.circle,
              rightSide: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerPlayingIndicator(GameGridState gameGridState, BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      child: switch (gameGridState.playerTurn) {
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

  Widget _scoreIndicator({
    required GameTickType type,
    required Stream stream,
    bool rightSide = false,
  }) => StreamBuilder(
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
