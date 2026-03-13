import 'dart:math';

import 'package:tic_tac_toe/controllers/game_controller.dart';

abstract class IGameIntelligenceController {
  void reset();
  GameTickType get aiPlayerTickType;
  GridLine? checkWin(List<List<GameTickType>> grid);
  GridPos? getNextMove(List<List<GameTickType>> grid, {required GridPos? opponentLastMove});
}

class GameIntelligenceController implements IGameIntelligenceController {
  final int gridSize;

  GameIntelligenceController({
    required this.gridSize,
  });

  void reset() {}

  GameTickType get aiPlayerTickType => IGameController.aiPlayerTickType;

  ///
  /// Check if there is a winner on the current grid.
  ///
  GridLine? checkWin(List<List<GameTickType>> grid) {
    // --- Horizontal check ---
    final horizontalWin = _checkHorizontalWin(grid);
    if (horizontalWin != null) return horizontalWin;

    // --- Vertical check ---
    final verticalWin = _checkVerticalWin(grid);
    if (verticalWin != null) return verticalWin;

    // --- Diagonal check (top-left to bottom-right) ---
    final diagonalWin = _checkDiagonalWin(grid);
    if (diagonalWin != null) return diagonalWin;

    // --- Diagonal check (top-right to bottom-left) ---
    final antiDiagonalWin = _checkAntiDiagonalWin(grid);
    if (antiDiagonalWin != null) return antiDiagonalWin;

    // --- No winning line found ---
    return null;
  }

  GridLine? _checkHorizontalWin(List<List<GameTickType>> grid) {
    int lastRow = 0;
    for (int row = 0; row < gridSize; row++) {
      GameTickType first = grid[row][0];
      if (first == GameTickType.none) continue;
      bool allSame = true;
      for (int col = 1; col < gridSize; col++) {
        if (grid[row][col] != first) {
          allSame = false;
          break;
        }
        lastRow = row;
      }
      if (allSame)
        return (
          from: (col: 0, row: lastRow),
          to: (col: gridSize - 1, row: lastRow),
        );
    }

    return null;
  }

  GridLine? _checkVerticalWin(List<List<GameTickType>> grid) {
    int lastCol = 0;
    for (int col = 0; col < gridSize; col++) {
      GameTickType first = grid[0][col];
      if (first == GameTickType.none) continue;
      bool allSame = true;
      for (int row = 1; row < gridSize; row++) {
        if (grid[row][col] != first) {
          allSame = false;
          break;
        }
        lastCol = col;
      }
      if (allSame) {
        return (
          from: (col: lastCol, row: 0),
          to: (col: lastCol, row: gridSize - 1),
        );
      }
    }

    return null;
  }

  ///
  /// From top-left to bottom-right.
  ///
  GridLine? _checkDiagonalWin(List<List<GameTickType>> grid) {
    GameTickType firstMainDiagonal = grid[0][0];
    if (firstMainDiagonal != GameTickType.none) {
      bool allSame = true;
      for (int i = 1; i < gridSize; i++) {
        if (grid[i][i] != firstMainDiagonal) {
          allSame = false;
          break;
        }
      }
      if (allSame) {
        return (
          from: (col: 0, row: 0),
          to: (col: gridSize - 1, row: gridSize - 1),
        );
      }
    }

    return null;
  }

  ///
  /// From top-right to bottom-left.
  ///
  GridLine? _checkAntiDiagonalWin(List<List<GameTickType>> grid) {
    GameTickType firstAntiDiagonal = grid[0][gridSize - 1];
    if (firstAntiDiagonal != GameTickType.none) {
      bool allSame = true;
      for (int i = 1; i < gridSize; i++) {
        if (grid[i][gridSize - i - 1] != firstAntiDiagonal) {
          allSame = false;
          break;
        }
      }
      if (allSame) {
        return (
          from: (col: 0, row: gridSize - 1),
          to: (col: gridSize - 1, row: 0),
        );
      }
    }

    return null;
  }

  ///
  /// Check if [toCheck] can complete a line in one move (two in a row with one empty).
  ///
  GridPos? _checkPotentialWin(
    List<List<GameTickType>> grid,
    GameTickType toCheck,
  ) {
    if (gridSize != 3 || grid.length < 3 || grid[0].length < 3) {
      return null;
    }

    int? x;
    int? y;
    bool hasMatch() => x != null && y != null;

    bool _isCellEmpty(int col, int row) {
      if (grid[row][col] != GameTickType.none) return false;
      x = col;
      y = row;

      return true;
    }

    // --- Horizontal ---
    for (int row = 0; row < 3; row++) {
      if (grid[row][0] == toCheck && grid[row][2] == toCheck && _isCellEmpty(1, row)) break;
      if (grid[row][0] == toCheck && grid[row][1] == toCheck && _isCellEmpty(2, row)) break;
      if (grid[row][1] == toCheck && grid[row][2] == toCheck && _isCellEmpty(0, row)) break;
    }

    if (!hasMatch()) {
      // --- Vertical ---
      for (int col = 0; col < 3; col++) {
        if (grid[0][col] == toCheck && grid[2][col] == toCheck && _isCellEmpty(col, 1)) break;
        if (grid[0][col] == toCheck && grid[1][col] == toCheck && _isCellEmpty(col, 2)) break;
        if (grid[1][col] == toCheck && grid[2][col] == toCheck && _isCellEmpty(col, 0)) break;
      }
    }

    if (!hasMatch()) {
      // --- Main diagonal (0,0)-(2,2) ---
      if (grid[0][0] == toCheck && grid[2][2] == toCheck && _isCellEmpty(1, 1)) {}
      if (grid[0][0] == toCheck && grid[1][1] == toCheck && _isCellEmpty(2, 2)) {}
      if (grid[1][1] == toCheck && grid[2][2] == toCheck && _isCellEmpty(0, 0)) {}
    }

    if (!hasMatch()) {
      // --- Anti-diagonal (0,2)-(2,0) ---
      if (grid[0][2] == toCheck && grid[2][0] == toCheck && _isCellEmpty(1, 1)) {}
      if (grid[0][2] == toCheck && grid[1][1] == toCheck && _isCellEmpty(0, 2)) {}
      if (grid[1][1] == toCheck && grid[2][0] == toCheck && _isCellEmpty(2, 0)) {}
    }

    if (hasMatch() && grid[y!][x!] == GameTickType.none) return (col: x!, row: y!);

    return null;
  }

  static final Random _random = Random();

  ///
  /// Returns the next move for the AI, or null if no valid move.
  ///
  /// Strategy (3x3 only). Step is inferred from how many [aiPlayer] cells are on the grid:
  /// 1. Prefer winning or blocking immediately.
  /// 2. First move (0 AI pieces): take a random corner.
  /// 3. Second move (1 AI piece): take the opposite corner, or block along the opponent's row/col.
  /// 4. Third move (2 AI pieces): take center if free.
  /// 5. Else: win if possible, else block, else random empty cell.
  ///
  /// [opponentLastMove] = opponent's last move (for step 1 block fallback).
  ///
  GridPos? getNextMove(
    List<List<GameTickType>> grid, {
    required GridPos? opponentLastMove,
  }) {
    if (gridSize != 3 || grid.length < 3 || grid[0].length < 3) return null;

    final opponent = aiPlayerTickType.other;

    // 1. Try to win, then try to block.
    GridPos? pos = _checkPotentialWin(grid, aiPlayerTickType);
    if (pos != null && _isEmpty(grid, pos.col, pos.row)) return pos;
    pos = _checkPotentialWin(grid, opponent);
    if (pos != null && _isEmpty(grid, pos.col, pos.row)) return pos;

    final aiPieceCount = _countPieces(grid, aiPlayerTickType);

    // 2. Take a random corner.
    if (aiPieceCount == 0) {
      final col = _random.nextInt(2) * 2;
      final row = _random.nextInt(2) * 2;
      if (_isEmpty(grid, col, row)) return (col: col, row: row);
    }

    // 3. Take the opposite corner, or block along the opponent's row/col.
    if (aiPieceCount == 1) {
      final aiFirstPos = _findSinglePiece(grid, aiPlayerTickType);
      if (aiFirstPos != null) {
        final oppositeCol = (aiFirstPos.col - 2).abs();
        final oppositeRow = (aiFirstPos.row - 2).abs();
        if (_isEmpty(grid, oppositeCol, oppositeRow)) {
          return (col: oppositeCol, row: oppositeRow);
        }
        if (opponentLastMove != null) {
          int x = opponentLastMove.col;
          int y = opponentLastMove.row;
          if (_random.nextInt(2) == 0) {
            if (x == 0 && _isEmpty(grid, 1, y) && _isEmpty(grid, 2, y)) {
              return (col: 1, row: y);
            }
            if (x == 2 && _isEmpty(grid, 0, y) && _isEmpty(grid, 1, y)) {
              return (col: 1, row: y);
            }
          } else {
            if (y == 0 && _isEmpty(grid, x, 1) && _isEmpty(grid, x, 2)) {
              return (col: x, row: 1);
            }
            if (y == 2 && _isEmpty(grid, x, 0) && _isEmpty(grid, x, 1)) {
              return (col: x, row: 1);
            }
          }
        }
      }
    }

    // 4. Take center if free.
    if (aiPieceCount == 2 && _isEmpty(grid, 1, 1)) {
      return (col: 1, row: 1);
    }

    // 5. Win if possible, else block, else random empty cell.
    pos = _checkPotentialWin(grid, aiPlayerTickType);
    if (pos != null && _isEmpty(grid, pos.col, pos.row)) return pos;
    pos = _checkPotentialWin(grid, opponent);
    if (pos != null && _isEmpty(grid, pos.col, pos.row)) return pos;

    final empty = <GridPos>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (_isEmpty(grid, col, row)) empty.add((col: col, row: row));
      }
    }
    if (empty.isEmpty) return null;
    return empty[_random.nextInt(empty.length)];
  }

  ///
  /// Count the number of pieces of the given type on the grid.
  ///
  int _countPieces(List<List<GameTickType>> grid, GameTickType piece) {
    int count = 0;
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c] == piece) count++;
      }
    }
    return count;
  }

  ///
  /// Find the position of the first piece of the given type on the grid.
  ///
  GridPos? _findSinglePiece(List<List<GameTickType>> grid, GameTickType piece) {
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == piece) return (col: col, row: row);
      }
    }
    return null;
  }

  ///
  /// Check if the cell at the given position is empty.
  ///
  bool _isEmpty(List<List<GameTickType>> grid, int col, int row) {
    return grid[row][col] == GameTickType.none;
  }
}
