import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soccer/data/Game.dart';
import 'package:soccer/data/Player.dart';
import 'package:soccer/nav/args/PositionSelectArgs.dart';
import 'package:soccer/pages/main/FieldPlayer.dart';
import 'package:soccer/pages/main/GameQuarter.dart';
import 'package:soccer/pages/main/PositionSelector.dart';
import 'package:soccer/service/StorageService.dart';
import 'package:soccer/service/serviceLocator.dart';

import '../../data/Position.dart';

class GameField extends StatefulWidget {
  final Game game;

  const GameField({Key? key, required this.game}) : super(key: key);

  @override
  _GameFieldState createState() => _GameFieldState();
}

class _GameFieldState extends State<GameField> {
  StorageService storage = locator<StorageService>();

  _GameFieldState();

  @override
  Widget build(BuildContext context) {
    var fieldItems = <Widget>[
      const Image(
        image: AssetImage("assets/graphics/field.png"),
      ),
    ];
    for(var position in widget.game.positions) {
      Player? player;
      bool duplicate = false;
      for(var pp in widget.game.byQuarter[widget.game.currentQuarter]!) {
        if(pp.position.id == position.id) {
          if(player != null) {
            duplicate = true;
          }
          player = pp.player;
        }
      }
      if(player == null) {
        throw Exception("No player found!");
      }
      var item = FieldPlayer(
        position: position,
        player: player,
        duplicate: duplicate,
        onPressed: () {
          Navigator.pushNamed(
              context, PositionSelector.route,
              arguments: PositionSelectArgs(widget.game.currentQuarter, player!, widget.game)).then((obj) async {
            if(obj != null) {
              if(obj == "bench") {
                //  We can't change it! position = null;
                widget.game.setPosition(player!, widget.game.currentQuarter, null);
              } else {
                widget.game.setPosition(player!, widget.game.currentQuarter, obj as Position);
                // We can't change it! position = obj;
              }
              storage.saveGame(widget.game);
              setState(() {

              });
            }
          });

        },
      );
      fieldItems.add(item);
    }

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          GameQuarter(game: widget.game, onChanged: () {
            setState(() {});
          },),
          Flexible(
            child: InteractiveViewer(
                child: Stack(
              children: fieldItems,
            )),
          ),
        ],
      ),
    );
  }
}
