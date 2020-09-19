import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class PacManScreen extends StatefulWidget {
  @override
  _PacManScreenState createState() => _PacManScreenState();
}

const row = 18;
const column = 11;
const originalMap = [
  1,1,1,1,1,1,1,1,1,1,1,
  1,0,0,0,0,0,0,0,0,0,1,
  1,0,1,0,1,0,1,0,1,0,1,
  1,0,1,0,1,1,1,0,1,0,1,
  1,0,1,0,0,0,0,0,1,0,1,
  1,0,1,0,1,0,1,0,1,0,1,
  1,0,0,0,1,0,1,0,0,0,1,
  1,1,1,1,1,0,1,1,1,1,1,
  0,0,0,0,0,0,0,0,0,0,0,
  1,1,1,1,1,0,1,1,1,1,1,
  1,0,0,0,1,0,1,0,0,0,1,
  1,0,1,0,1,0,1,0,1,0,1,
  1,0,1,0,0,0,0,0,1,0,1,
  1,0,1,0,1,1,1,0,1,0,1,
  1,0,1,0,1,0,1,0,1,0,1,
  1,0,0,0,0,0,0,0,0,0,1,
  1,1,1,1,1,1,1,1,1,1,1,
];

class Character {
  Character(this.x, this.y, this.turn, this.isPacMan);

  int x;
  int y;
  int turn;
  final int isPacMan;

  bool at(int x, int y) => this.x == x && this.y == y;
}

class _PacManScreenState extends State<PacManScreen> {
  final directions = [
    Icons.arrow_back,
    Icons.arrow_upward,
    Icons.arrow_downward,
    Icons.arrow_forward,
  ];

  Character pacman;
  List<Character> ghosts;
  List<int> currentMap;
  Timer timer;

  void restart() {
    setState(() {
      timer?.cancel();
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        ghosts.forEach((it) {
          while (!tryMove(it, directions[Random().nextInt(3)]));
        });
      });
      pacman = Character(1,1,0,1);
      ghosts = [
        Character(7,1,0,0),
        Character(1,15,0,0),
      ];
      currentMap = List<int>.from(originalMap);
    });
  }

  @override
  void initState() {
    super.initState();
    restart();
  }

  @override
  Widget build(BuildContext context) {
    ///    小精靈圖檔
    ///    Image.asset("images/pacman.png")
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => Column(
          children: [
            Expanded(
              child: Container(
                  color: Colors.black,
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: column,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 1.1,
                    children: currentMap.asMap().entries.map((entry) {
                      final index = entry.key;
                      final isBarrier = entry.value;
                      final x = index % column;
                      final y = index ~/ column;
                      if (pacman.at(x, y)) {
                        if (ghosts.any((it) => it.at(x, y))) {
                          gameOver(context);
                        }
                        if (isBarrier == 0) {
                          currentMap[index] = -1;
                        }
                        return RotatedBox(
                            quarterTurns: pacman.turn,
                            child: Image.asset("images/pacman.png"),
                        );
                      } else if (ghosts.any((it) => it.at(x, y))){
                        return Image.asset("images/ghost.png");
                      } else if (isBarrier == 1) {
                        return Container(
                          color: Colors.blue,
                        );
                      } else if (isBarrier == 0){
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }).toList(),
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  child: Text("START"),
                  onPressed: () => restart(),
                  color: Colors.green,
                ),
                Text("SCORE: ${currentMap.where((it) => it == -1).length}"),
              ],

            ),
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: directions.map(buildKey).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildKey(IconData iconData) => GestureDetector(
    onTap: () {
      tryMove(pacman, iconData);
    },
    child: Padding(
      child: Icon(iconData),
      padding: EdgeInsets.all(8),
    ),
  );

  bool tryMove(Character char, IconData iconData) {
    int x = char.x;
    int y = char.y;
    int turn = char.turn;
    if (iconData == Icons.arrow_back) {
      x = max(0, x-1);
      turn = 2;
    } else if (iconData == Icons.arrow_forward) {
      x = min(column, x+1);
      turn = 0;
    } else if (iconData == Icons.arrow_upward) {
      y = max(0, y-1);
      turn = 3;
    } else {
      y = min(row, y+1);
      turn = 1;
    }
    if (char.isPacMan == 0) turn = 0;
    if (currentMap[x+y*column] == 1) return false;
    setState(() {
      char.x = x;
      char.y = y;
      char.turn = turn;
    });
    return true;
  }

  void gameOver(BuildContext context) {
    timer?.cancel();
    Future.delayed(Duration(milliseconds: 500), () {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("GAME OVER!"),));
    });
  }
}
