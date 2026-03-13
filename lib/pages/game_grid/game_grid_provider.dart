import 'package:flutter/material.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';
import 'package:tic_tac_toe/models/abstract.dart';
import 'package:tic_tac_toe/utils/injector.dart';
import 'package:tic_tac_toe/widgets/winner_overlay.dart';

class GameGridState {
  ///
  /// Current grid of the game.
  ///
  List<List<GameTickType?>> grid = [];

  ///
  /// Player expected to play.
  ///
  GameTickType playerTurn;

  ///
  /// `true` if the game can go on.
  /// `false` if the game is stopped.
  ///
  bool isGameOngoing = true;

  ///
  /// If any winner, store the position of the winning line.
  ///
  GridLine? winnerLine;

  GameGridState({required this.playerTurn});
}

class GameGridProvider extends BaseProvider<GameGridState> {
  final IGameController gameController = Injector.get<IGameController>();

  int get gridSize => IGameController.gridSize;

  BuildContext context;

  GameGridProvider(this.context)
    : super(
        GameGridState(
          playerTurn: Injector.get<IGameController>().playerTurnStream.value,
        ),
      ) {
    _setListeners();
  }

  @override
  void dispose() {
    gameController.reset();

    super.dispose();
  }

  void _setListeners() {
    gameController.playerTurnStream.listen(_playerTurnListener).store(this);
    gameController.gridStream.listen(_gridListener).store(this);
    gameController.winnerLineStream.listen(_winnerLineListener).store(this);
    gameController.gameStatusStream.listen(_gameStatusListener).store(this);
  }

  ///
  /// Function callback when a grid tile is tapped.
  ///
  void onTileTap(int rowIndex, int colIndex) => gameController.placeTickAt(rowIndex, colIndex);

  ///
  /// Get the player (if any) at a given grid position.
  ///
  GameTickType getTickTypeFor(int rowIndex, int colIndex) {
    return state.grid[rowIndex][colIndex] ?? GameTickType.none;
  }

  void _playerTurnListener(playerTurn) {
    state.playerTurn = playerTurn;

    notifyListeners();
  }

  void _gridListener(grid) {
    state.grid = grid;

    notifyListeners();
  }

  void _winnerLineListener(winnerLine) {
    state.winnerLine = winnerLine;

    notifyListeners();
  }

  void _gameStatusListener(GameStatus gameStatus) {
    state.isGameOngoing = gameStatus == GameStatus.none || gameStatus == GameStatus.playing;

    final bool hasWinner = gameStatus == GameStatus.winner;
    final bool isDraw = gameStatus == GameStatus.draw;

    if (hasWinner) {
      WinnerOverlay.trigger(context, gameController.winnerStream.value);
    } else if (isDraw) {
      WinnerOverlay.trigger(context, GameTickType.none);
    }

    notifyListeners();
  }
}
