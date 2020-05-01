import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final toDoController = TextEditingController();

  List toDoList = [];

  Map<String, dynamic> _lastRemoved; //mapa para remover
  int _lastRemovedPos; //para saber exatamente qual posicao o item foi removido


  @override
  void initState() {
    super.initState();

    _readDAta().then((data) {
      setState(() {
        toDoList = jsonDecode(data);
      });

    });
  }

  void addToDo(){
    setState(() { //setState é usado para atualizar algo na tela
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = toDoController.text;
      toDoController.text = "";
      newToDo["ok"] = false;
      toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds:1));

    setState(() {
      toDoList.sort((a, b){
        if (a["ok"] && !b ["ok"]) return 1;
        else if (!a["ok"] && b["ok"]) return -1;
        else return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded( //Expanded é usado para limitar o tamanho dos objetos
                    child: TextField(
                      controller: toDoController,
                      decoration: InputDecoration(
                          labelText: "Nova tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent)
                      ),
                    )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _refresh,
              child: ListView.builder( // ListView é usado para fazer uma lista
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: toDoList.length, //pegar o tamanho do todolist
                  itemBuilder: buildItem),),
          )
        ],
      ),
    );
  }

  Widget buildItem (BuildContext context, int index){ //widget da lista
    return Dismissible( //widget para deletar o item arrastando para a direita
      key: Key(DateTime.now(). millisecondsSinceEpoch.toString()), //a key é necessaria para saber exatamente qual elemento será deslizado
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(toDoList[index]["title"]),
        value: toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(toDoList[index]["ok"] ?
          Icons.check : Icons.error), ),
        onChanged: (c){
          setState(() {
            toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(toDoList[index]);
          _lastRemovedPos = index;
          toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved ["title"]} removida!"),
            action: SnackBarAction(label: "Desfazer",
                onPressed: (){
                  setState(() {

                  });
                  toDoList.insert(_lastRemoved, _lastRemoved);
                  _saveData();
                }),

            duration: Duration(seconds: 3),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  } //FUNCAO PARA OBTER O ARQUIVO

  Future<File> _saveData() async {
    String data = json.encode(toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  } // FUNCAO PARA SALVAR ALGUM DADO NO ARQUIVO

  Future<String> _readDAta() async {
    try {
      final file = await _getFile();

      return file.readAsStringSync();
    } catch (e) {
      return null;

    }
  } // FUNCAO PARA LER OS DADOS NO ARQUIVO

}

