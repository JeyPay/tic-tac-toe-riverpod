import 'package:riverpod/riverpod.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';

class GameGridState {
  final List<List<GameTickType?>> grid;
  final GameTickType playerTurn;
  final bool isGameOngoing;
  final GridLine? winnerLine;

  const GameGridState({
    required this.grid,
    required this.playerTurn,
    required this.isGameOngoing,
    required this.winnerLine,
  });
}

final gameGridProvider = Provider<GameGridState>((ref) {
  final grid = ref.watch(_gridProvider).value ?? [];
  final playerTurn = ref.watch(_playerTurnProvider).value ?? GameTickType.none;
  final winnerLine = ref.watch(_winnerLineProvider).value;

  final gameStatus = ref.watch(_gameStatusProvider).value;

  final playable = gameStatus == GameStatus.none || gameStatus == GameStatus.playing;

  return GameGridState(
    grid: grid,
    playerTurn: playerTurn,
    isGameOngoing: playable,
    winnerLine: winnerLine,
  );
});

final gameActionsProvider = Provider((ref) {
  final controller = ref.watch(gameControllerProvider);

  return (
    onTileTap: (int row, int col) {
      controller.placeTickAt(row, col);
    },
  );
});

final _gridProvider = StreamProvider<List<List<GameTickType?>>>((ref) {
  final controller = ref.watch(gameControllerProvider);
  return controller.gridStream;
});

final _playerTurnProvider = StreamProvider<GameTickType>((ref) {
  final controller = ref.watch(gameControllerProvider);
  return controller.playerTurnStream;
});

final _winnerLineProvider = StreamProvider<GridLine?>((ref) {
  final controller = ref.watch(gameControllerProvider);
  return controller.winnerLineStream;
});

final _gameStatusProvider = StreamProvider<GameStatus>((ref) {
  final controller = ref.watch(gameControllerProvider);
  return controller.gameStatusStream;
});
