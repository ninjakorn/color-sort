// lib/features/game/ui/game_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/color_sort_game.dart';
import '../logic/level_manager.dart';
import 'draggable_tube_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<ColorSortGame>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Color Sort - Level ${game.currentLevel}'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: game.resetLevel,
            tooltip: 'Reset Level',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Level info and moves counter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Moves: ${game.moveCount}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Difficulty: ${LevelManager.getDifficultyLabel(game.currentLevel)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Game board
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate tubes per row based on screen width
                    int tubesPerRow = (constraints.maxWidth / 70).floor();
                    tubesPerRow =
                        tubesPerRow > game.tubes.length
                            ? game.tubes.length
                            : tubesPerRow;

                    return game.isGameComplete
                        ? _buildLevelCompleteView(context, game)
                        : _buildGameBoard(context, game, tubesPerRow);
                  },
                ),
              ),
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: game.moveCount > 0 ? game.undoMove : null,
                  icon: Icon(Icons.undo),
                  label: Text('Undo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: game.resetLevel,
                  icon: Icon(Icons.refresh),
                  label: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    ColorSortGame game,
    int tubesPerRow,
  ) {
    // Calculate number of rows needed
    int numRows = (game.tubes.length / tubesPerRow).ceil();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numRows, (rowIndex) {
        int startIndex = rowIndex * tubesPerRow;
        int endIndex = (rowIndex + 1) * tubesPerRow;
        endIndex = endIndex > game.tubes.length ? game.tubes.length : endIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(endIndex - startIndex, (index) {
              int tubeIndex = startIndex + index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: DraggableTubeWidget(
                  tube: game.tubes[tubeIndex],
                  tubeIndex: tubeIndex,
                  isSelected: game.selectedTubeIndex == tubeIndex,
                  onTap: game.selectTube,
                  onMove: game.moveColor,
                  isAnimating: game.isAnimating,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildLevelCompleteView(BuildContext context, ColorSortGame game) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level ${game.currentLevel} Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'You completed this level in ${game.moveCount} moves.',
            style: TextStyle(fontSize: 18, color: Colors.blue[700]),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: game.resetLevel,
                icon: Icon(Icons.refresh),
                label: Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed:
                    game.currentLevel < LevelManager.totalLevels
                        ? game.nextLevel
                        : null,
                icon: Icon(Icons.arrow_forward),
                label: Text('Next Level'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
