import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/sudoku_model.dart';
import '../../providers/sudoku_provider.dart';


class SudokuGrid extends ConsumerWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sudokuBoard = ref.watch(sudokuProvider);
    final sudokuNotifier = ref.read(sudokuProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        double gridSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        double cellSize = gridSize / 9;

        return GestureDetector(
          onTapDown: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPosition = box.globalToLocal(details.globalPosition);

            int row = (localPosition.dy ~/ cellSize).clamp(0, 8);
            int col = (localPosition.dx ~/ cellSize).clamp(0, 8);

            sudokuNotifier.selectCell(row, col);
          },
          child: CustomPaint(
            size: Size(gridSize, gridSize),
            painter: SudokuPainter(sudokuBoard),
          ),
        );
      },
    );
  }
}

class SudokuPainter extends CustomPainter {
  final SudokuBoard board;

  SudokuPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = size.width < size.height ? size.width : size.height;
    double cellSize = gridSize / 9;

    // Paints
    Paint gridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    Paint boldGridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    Paint selectedCellPaint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.5);

    Paint sameNumberCellPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.5);

    // flag to check if a cell is selected
    bool hasSelection = board.selectedRow >= 0 && board.selectedCol >= 0;

    for (var row in board.cells) {
      for (var cell in row) {
        double x = cell.col * cellSize;
        double y = cell.row * cellSize;

        if (cell.isSelected) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            selectedCellPaint,
          );
        } else if (hasSelection &&
            cell.value != 0 &&
            board.cells[board.selectedRow][board.selectedCol].value ==
                cell.value &&
            !(board.selectedRow == cell.row && board.selectedCol == cell.col)) {
          // Highlight cells with the same number
          canvas.drawRect(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            sameNumberCellPaint,
          );
        } else if (hasSelection &&
            (cell.row == board.selectedRow || cell.col == board.selectedCol)) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            selectedCellPaint,
          );
        }
      }
    }

    for (int i = 0; i <= 9; i++) {
      Paint paint = (i % 3 == 0) ? boldGridPaint : gridPaint;

      double x = i * cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, cellSize * 9),
        paint,
      );

      double y = i * cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(cellSize * 9, y),
        paint,
      );
    }

    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (var row in board.cells) {
      for (var cell in row) {
        if (cell.value != 0) {
          final textSpan = TextSpan(
            text: cell.value.toString(),
            style: TextStyle(
              color: cell.isInitial ? Colors.black : Colors.blue,
              fontSize: cellSize * 0.6,
              fontWeight:
              cell.isInitial ? FontWeight.bold : FontWeight.normal,
            ),
          );
          textPainter.text = textSpan;
          textPainter.layout(
            minWidth: cellSize,
            maxWidth: cellSize,
          );
          double xPos = cell.col * cellSize;
          double yPos = cell.row * cellSize;
          textPainter.paint(
            canvas,
            Offset(
              xPos + (cellSize - textPainter.width) / 2,
              yPos + (cellSize - textPainter.height) / 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SudokuPainter oldDelegate) {
    return true;
  }
}
