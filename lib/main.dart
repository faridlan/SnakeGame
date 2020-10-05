import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  var totalRow = 10;
  var totalCol = 20;
  var food = [0, 4];
  var direction = 'down';
  var isPlaying = false;
  var snake = [
    [0, 1],
    [0, 0]
  ];

  createFood() {
    food = [Random().nextInt(totalRow), Random().nextInt(totalCol)];
  }

  moveSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snake.first[1] > totalCol) {
            snake.insert(0, [snake.first[0], snake.first[1] - 21]);
          } else {
            snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          }

          break;
        case 'up':
          if (snake.first[1] < 0) {
            snake.insert(0, [snake.first[0], snake.first[1] + 21]);
          } else {
            snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          }

          break;
        case 'right':
          if (snake.first[0] > totalRow) {
            snake.insert(0, [snake.first[0] - 11, snake.first[1]]);
          } else {
            snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          }

          break;
        case 'left':
          if (snake.first[0] < 0) {
            snake.insert(0, [snake.first[0] + totalRow, snake.first[1]]);
          } else {
            snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          }

          break;
      }

      if (snake.first.toString() == food.toString()) {
        createFood();
      } else {
        snake.removeLast();
      }
    });
  }

  checkGameOver() {
    // if (snake.first[0] < 0 ||
    //     snake.first[0] >= totalRow ||
    //     snake.first[1] < 0 ||
    //     snake.first[1] >= totalCol) {
    //   isPlaying = false;
    // }

    for (var i = 1; i < snake.length; i++) {
      if (snake[i].toString() == snake.first.toString()) {
        isPlaying = false;
      }
    }
  }

  gameOver() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Your Score Is ${snake.length - 2}'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      food = [0, 4];
                      direction = 'down';
                      snake = [
                        [0, 1],
                        [0, 0]
                      ];
                    });
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  startGame() {
    isPlaying = true;
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      checkGameOver();
      if (isPlaying) {
        moveSnake();
      } else {
        timer.cancel();
        gameOver();
      }
    });
  }

  Future<bool> onPressedBack() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Want To Exit?'),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('YES'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('NO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onPressedBack,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (detail) {
                    if (direction != 'left' && detail.delta.dx > 0) {
                      direction = 'right';
                    } else if (direction != 'right' && detail.delta.dx < 0) {
                      direction = 'left';
                    }
                  },
                  onVerticalDragUpdate: (detail) {
                    if (direction != 'up' && detail.delta.dy > 0) {
                      direction = 'down';
                    } else if (direction != 'down' && detail.delta.dy < 0) {
                      direction = 'up';
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: totalRow / totalCol,
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: totalRow,
                        ),
                        itemCount: totalRow * totalCol,
                        itemBuilder: (context, index) {
                          var x = index % totalRow;
                          var y = (index / totalRow).floor();
                          var color;
                          var isBody = false;

                          for (var item in snake) {
                            if (item[0] == x && item[1] == y) {
                              isBody = true;
                            }
                          }

                          if (food[0] == x && food[1] == y) {
                            color = Colors.red;
                          } else if (snake.first[0] == x &&
                              snake.first[1] == y) {
                            color = Colors.green;
                          } else if (isBody) {
                            color = Colors.green[200];
                          } else {
                            color = Colors.grey[200];
                          }
                          return Container(
                            // child: Text('$x, $y'),
                            margin: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.rectangle,
                            ),
                          );
                        }),
                  ),
                ),
              ),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                    onPressed: isPlaying
                        ? null
                        : () {
                            startGame();
                          },
                    color: Colors.red,
                    child: Text('Start'),
                  ),
                  Text('Score : ${snake.length - 2}')
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
