import 'package:rxdart/rxdart.dart';
import 'package:tic_tac_toe/controllers/game_intelligence_controller.dart';
import 'package:tic_tac_toe/utils/injector.dart';

///
/// Indicates a position on the grid by cell numbers (column and row).
///
typedef GridPos = ({int col, int row});

///
/// Indicates a line on the grid by [GridPos] from and to.
///
typedef GridLine = ({GridPos from, GridPos to});

///
/// Representation of the type of a tick on the grid.
///
enum GameTickType {
  none,
  circle,
  cross;

  GameTickType get other => switch (this) {
    none => none,
    circle => cross,
    cross => circle,
  };
}

///
/// Game status (or state).
///
enum GameStatus {
  none,
  playing,
  winner,
  draw,
}

enum GameMode {
  humanVsHuman,
  humanVsAi,
}

abstract class IGameController {
  static const int gridSize = 3;
  static const GameTickType humanPlayerTickType = GameTickType.cross;
  static const GameTickType aiPlayerTickType = GameTickType.circle;

  ///
  /// Stream of the current player playing.
  ///
  ValueStream<GameTickType> get playerTurnStream;

  ///
  /// Stream of the player who won.
  ///
  ValueStream<GameTickType> get winnerStream;

  ///
  /// Stream of the grid values.
  ///
  ValueStream<List<List<GameTickType>>> get gridStream;

  ///
  /// Stream of the game status.
  ///
  ValueStream<GameStatus> get gameStatusStream;

  ///
  /// Stream of the coordinates (as cell numbers) of the winning line on the grid.
  ///
  ValueStream<GridLine?> get winnerLineStream;

  ///
  /// Stream of the score of the `cross` player.
  ///
  ValueStream<int> get scoreCrossStream;

  ///
  /// Stream of the score of the `circle` player.
  ///
  ValueStream<int> get scoreCircleStream;

  ///
  /// Stream of the last move played.
  ///
  ValueStream<GridPos?> get lastMoveStream;

  ///
  /// Initialize the game controller.
  ///
  void init();

  ///
  /// Reset the game controller.
  ///
  void reset();

  ///
  /// Set the player that place its first tick.
  ///
  void setGameMode(GameMode gameMode);

  ///
  /// Start a new game, do not reset the score and alternate the player to start.
  ///
  void startNewGame();

  ///
  /// Place the player at the given grid position.
  ///
  void placeTickAt(int rowIndex, int colIndex);

  ///
  /// Set the player that place its first tick.
  ///
  void setFirstPlayer(GameTickType tickType);
}

class GameController implements IGameController {
  late final IGameIntelligenceController gameIntelligenceController = Injector.get<IGameIntelligenceController>();

  ///
  /// Game mode.
  ///
  GameMode _gameMode = GameMode.humanVsAi;

  ValueStream<List<List<GameTickType>>> get gridStream => _gridSubject.stream;
  BehaviorSubject<List<List<GameTickType>>> _gridSubject = BehaviorSubject.seeded([]);

  ValueStream<GameTickType> get playerTurnStream => _playerTurnSubject.stream;
  BehaviorSubject<GameTickType> _playerTurnSubject = BehaviorSubject.seeded(GameTickType.circle);

  ValueStream<GameTickType> get winnerStream => _winnerSubject.stream;
  BehaviorSubject<GameTickType> _winnerSubject = BehaviorSubject.seeded(GameTickType.none);

  ValueStream<GridLine?> get winnerLineStream => _winnerLineSubject.stream;
  BehaviorSubject<GridLine?> _winnerLineSubject = BehaviorSubject.seeded(null);

  ValueStream<int> get scoreCrossStream => _scoreCrossSubject.stream;
  BehaviorSubject<int> _scoreCrossSubject = BehaviorSubject.seeded(0);

  ValueStream<int> get scoreCircleStream => _scoreCircleSubject.stream;
  BehaviorSubject<int> _scoreCircleSubject = BehaviorSubject.seeded(0);

  ValueStream<GameStatus> get gameStatusStream => _gameStatusSubject.stream;
  BehaviorSubject<GameStatus> _gameStatusSubject = BehaviorSubject.seeded(GameStatus.none);

  ValueStream<GridPos?> get lastMoveStream => _lastMoveSubject.stream;
  BehaviorSubject<GridPos?> _lastMoveSubject = BehaviorSubject.seeded(null);

  void init() {
    reset();

    if (_gameMode == GameMode.humanVsAi && _playerTurnSubject.value == IGameController.aiPlayerTickType) {
      _aiPlay();
    }
  }

  void reset() {
    _resetSubjects();
    _generateEmptyGrid();
  }

  void setFirstPlayer(GameTickType tickType) {
    _playerTurnSubject.value = tickType;
  }

  void setGameMode(GameMode gameMode) {
    _gameMode = gameMode;
  }

  void startNewGame() {
    _resetSubjects(soft: true);
    _playerTurnSubject.value = _playerTurnSubject.value;
    _generateEmptyGrid();
    gameIntelligenceController.reset();
    if (_gameMode == GameMode.humanVsAi && _playerTurnSubject.value == IGameController.aiPlayerTickType) {
      _aiPlay();
    }
  }

  void placeTickAt(int rowIndex, int colIndex) {
    _setGridValue(rowIndex, colIndex);

    final winnerLine = gameIntelligenceController.checkWin(_gridSubject.value);
    if (winnerLine != null) {
      _onWinnerFound(winnerLine);
      return;
    }

    final isDraw = _drawCheck();
    if (isDraw) {
      _gameStatusSubject.value = GameStatus.draw;
      return;
    }

    _onPlayerPlayed(rowIndex, colIndex);
  }

  void _generateEmptyGrid() {
    final List<List<GameTickType>> grid = [];

    for (int row = 0; row < IGameController.gridSize; row++) {
      final List<GameTickType> newRow = [];
      grid.add(newRow);
      for (int col = 0; col < IGameController.gridSize; col++) {
        newRow.add(GameTickType.none);
      }
    }

    _gridSubject.add(grid);
  }

  ///
  /// Reset the streams (subjects).
  ///
  /// `soft` is set to true when we don't want to loose the game score history. We don't reset all streams.
  ///
  void _resetSubjects({bool soft = true}) {
    _gridSubject.value = [];
    if (!soft) _playerTurnSubject.value = IGameController.humanPlayerTickType;
    _winnerSubject.value = GameTickType.none;
    _winnerLineSubject.value = null;
    _gameStatusSubject.value = GameStatus.none;
    _lastMoveSubject.value = null;
  }

  ///
  /// Set the current player at the given position in the grid.
  ///
  void _setGridValue(int rowIndex, int colIndex) {
    if (_gridSubject.value[rowIndex][colIndex] != GameTickType.none) return;

    _gridSubject.value[rowIndex][colIndex] = _playerTurnSubject.value;

    // To trigger a stream refresh (not clean).
    _gridSubject.value = _gridSubject.value;
  }

  ///
  /// Callback when a winner had been found on the grid.
  ///
  void _onWinnerFound(GridLine winnerLine) {
    _winnerSubject.value = _playerTurnSubject.value;
    _winnerLineSubject.value = winnerLine;
    _gameStatusSubject.value = GameStatus.winner;
    final winner = _winnerSubject.value;
    if (winner == GameTickType.circle) {
      _scoreCircleSubject.value = _scoreCircleSubject.value + 1;
    } else {
      _scoreCrossSubject.value = _scoreCrossSubject.value + 1;
    }
  }

  ///
  /// Callback when a player has played.
  ///
  /// It changes the player to play.
  ///
  void _onPlayerPlayed(int rowIndex, int colIndex) {
    _lastMoveSubject.value = (col: colIndex, row: rowIndex);

    _playerTurnSubject.value = _playerTurnSubject.value.other;

    if (_gameMode == GameMode.humanVsAi && _playerTurnSubject.value == IGameController.aiPlayerTickType) {
      _aiPlay();
    }
  }

  ///
  /// Play the AI.
  ///
  void _aiPlay() {
    final nextMove = gameIntelligenceController.getNextMove(
      _gridSubject.value,
      opponentLastMove: _lastMoveSubject.value,
    );
    if (nextMove != null) {
      placeTickAt(nextMove.row, nextMove.col);
    }
  }

  ///
  /// Check if there is no space left in the grid.
  ///
  bool _drawCheck() {
    return !_gridSubject.value.any((r) => r.any((c) => c == GameTickType.none));
  }
}
