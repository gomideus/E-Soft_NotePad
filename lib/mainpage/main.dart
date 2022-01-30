import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'E-Soft Notepad'),
    );
  }
}

/* 
- Classe que armazena os dados do NotePad.
- ID fixo,
- Titulo, mensagem podem ser alterador atraves do metodo SET
- Booleana done serve para marcacao de tarefas concluidas ( ou nao ),
  e pode ser alterada com medo SET
*/
class Address {
  Address({
    required this.id,
    required this.title,
    required this.message,
    required this.done,
  });

  final int id;
  String title;
  String message;
  bool done;

  Address.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        message = map['message'],
        done = map['done'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'done': done,
    };
  }

  @override
  String toString() {
    return '{id: $id, title: $title message: $message, done: $done  }';
  }

  // Metodos GET

  String getTitle() {
    return title;
  }

  String getMessage() {
    return message;
  }

  bool getCheck() {
    return this.done;
  }

  int getId() {
    return this.id;
  }

  // Metodos SET

  void setCheck() {
    this.done = !this.done;
  }

  void setMessage(String message) {
    this.message = message;
  }

  void setTitle(String title) {
    this.title = title;
  }

}

// Para manter a lista ordenada por ID
int mySortComparison(Address a, Address b) {
  final propertyA = a.getId();
  final propertyB = b.getId();
  if (propertyA < propertyB) {
    return -1;
  } else if (propertyA > propertyB) {
    return 1;
  } else {
    return 0;
  }
}

// Funcao para validar tamanho do titulo. MAX = 15
bool verifyTitle( String title ){
  bool check = true;
  if( title.length > 15 || title.length <= 0 ){
    check = false;
  }
  return check;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static File? _file;
  static final _fileName = 'notesDataBase.txt';

  Future<File> get file async {
    if (_file != null) return _file!;

    _file = await _initFile();
    return _file!;
  }

  Future<File> _initFile() async {
    final _directory = await getApplicationDocumentsDirectory();
    final _path = _directory.path;
    return File('$_path/$_fileName');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notesDataBase.txt');
  }

  // Para excluir arquivo, caso necessario
  Future<int> deleteFile() async {
    try {
      final file = await _localFile;
      await file.delete();
    } catch (e) {
      return 0;
    }
    return 0;
  }

  // Funcoes do CRUD (Create, read, Update, Delete)

  static Set<Address> _noteSet = {};
  Future<void> writeNote(Address notes) async {
    final File fl = await _localFile;
    _noteSet.add(notes);
    final _noteListMap = _noteSet.map((e) => e.toJson()).toList();
    await fl.writeAsString(jsonEncode(_noteListMap));
  }

  int id = 1;
  Future<List<Address>> readNote() async {
    final File fl = await _localFile;
    final _content = await fl.readAsString();

    final List<dynamic> _jsonData = jsonDecode(_content);
    final List<Address> _notes = _jsonData
        .map(
          (e) => Address.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    item = _notes.length;

    if (_notes.length > 0) {
      int lengthAux = _notes.length;
      int controller = 0;
      int highestID = -1;
      // Encontrando o maior ID existente da database, para inncrementa-lo em novos adds
      while( controller < lengthAux ){
        if( _notes[controller].getId() > highestID  ){
          highestID = _notes[controller].getId();
        }
        controller++;
      }
      id = highestID +
          1; // Pegar ultimo ID e incrementar para o proximo
    }
    //print(_notes); // Mostrar a lista de notes (caso necessario para verificacoes)
    return _notes;
  }

  Future<void> updateNote({
    required int id,
    required Address updatedNote,
  }) async {
    _noteSet.removeWhere((e) => e.id == updatedNote.id);
    await writeNote(updatedNote);
  }

  Future<void> deleteNote(int actualId) async {
    final File fl = await _localFile;
    _noteSet.removeWhere((e) => e.id == actualId);
    final _noteListMap = _noteSet.map((e) => e.toJson()).toList();
    await fl.writeAsString(jsonEncode(_noteListMap));
  }
  // FIM FUNCOES DO CRUD

  // Variaveis
  TextEditingController titleController = TextEditingController();
  TextEditingController changeTitleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  bool _checkbox = false;
  int item = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                readNote();
              });
            },
          )
        ],
        backgroundColor: Colors.purple,
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 150),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('Título da anotação:'),
                      content: Container(
                        height: 100,
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (value) {},
                              controller: titleController,
                              decoration:
                                  InputDecoration(hintText: "Insira um título"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (verifyTitle(titleController.text)) {
                                      Address notes = new Address(
                                          id: id,
                                          title: titleController.text,
                                          message: "",
                                          done: false);
                                      setState(() {
                                        writeNote(notes);
                                      });
                                      titleController.clear();
                                      Navigator.pop(context);
                                    }else{
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            content: Text("O título deve possuir entre 1 e 15 caracteres."),
                                            actions: [
                                              ElevatedButton(onPressed: (){
                                                Navigator.pop(context);
                                              },
                                                  child: Text(
                                                    "OK"
                                                  )
                                              )
                                            ],
                                          )
                                      );
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.purple),
                                  ),
                                  child: Text(
                                    'criar',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ));
          },
          backgroundColor: Colors.purple,
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder(
            future: readNote(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Container(
                    child: ListView.builder(
                        itemCount: item,
                        itemBuilder: (BuildContext context, int index) {
                          var myList = snapshot.data! as List<Address>;
                          myList.sort(mySortComparison);
                          Address actual = myList[index];
                          _checkbox = actual.getCheck();

                          return InkWell(
                            onTap: () {
                              messageController.text = actual.getMessage();
                              //deleteFile(); // deletar arquivo ao clicar nos containers ( apenas para testes )
                              setState(() {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      content: Container(
                                        color: Colors.purple.withOpacity(0.3),
                                        height: 180,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: messageController,
                                            style: TextStyle(
                                                color: Colors.black,
                                            ),
                                            maxLines: 8,
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(color: Colors.purple),
                                              contentPadding: EdgeInsets.all(20.0),
                                              labelText: "Tarefa: ${actual.getTitle()}",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        Container(
                                          height: 50,
                                          width: 70,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.8)),
                                            ),
                                            onPressed: (){
                                              Navigator.pop(context);
                                              messageController.clear();
                                              showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    content: Text(
                                                      "Insira o novo título para: ${actual.getTitle()}"
                                                    ),
                                                    actions: [
                                                      TextField(
                                                        controller: changeTitleController,
                                                      ),
                                                      Row(
                                                        children: [ ElevatedButton(
                                                            onPressed: (){
                                                              Navigator.pop(context);
                                                              changeTitleController.clear();
                                                            },
                                                            child: Text("Cancelar"),
                                                        ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: ElevatedButton(
                                                              onPressed: (){
                                                                if(verifyTitle(changeTitleController.text)) {
                                                                  actual
                                                                      .setTitle(
                                                                      changeTitleController
                                                                          .text);
                                                                  setState(() {
                                                                    updateNote(
                                                                        id: actual
                                                                            .getId(),
                                                                        updatedNote: actual);
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                  changeTitleController.clear();
                                                                }else{
                                                                  showDialog(
                                                                      context: context,
                                                                      builder: (_) => AlertDialog(
                                                                        content: Text("O título deve possuir entre 1 e 15 caracteres."),
                                                                        actions: [
                                                                          ElevatedButton(
                                                                              onPressed: (){
                                                                                Navigator.pop(
                                                                                    context);
                                                                                changeTitleController.clear();
                                                                              },
                                                                              child: Text("OK")),
                                                                        ],
                                                                      ));
                                                                }
                                                              },
                                                              child: Text("Salvar"),
                                                            ),
                                                          )
                                                        ]
                                                      ),
                                                    ],
                                                  )
                                              );
                                            },
                                            child: Text('Editar Título'),
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: (){
                                              Navigator.pop(context);
                                              messageController.clear();
                                            },
                                            child: Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: (){
                                            actual.setMessage(messageController.text);
                                            setState(() {
                                              updateNote(
                                                  id: actual.getId(),
                                                  updatedNote: actual,
                                              );
                                            });
                                            messageController.clear();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Salvar'),
                                        ),
                                      ],
                                    ),
                                );
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, bottom: 4.0, left: 5, right: 5),
                              child: Container(
                                height: 55,
                                color: (index % 2 == 0)
                                    ? Colors.grey.withOpacity(0.7)
                                    : Colors.purple.withOpacity(1),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, left: 40),
                                  child: Row(children: [
                                    Checkbox(
                                      shape: CircleBorder(),
                                      value: _checkbox,
                                      onChanged: (value) {
                                        setState(() {
                                          actual.setCheck();
                                          updateNote(
                                              id: actual.getId(),
                                              updatedNote: actual);
                                        });
                                      },
                                    ),
                                    Text(
                                      actual.getTitle(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: actual.getCheck()
                                            ? Colors.black.withOpacity(0.4)
                                            : Colors.black,
                                        decoration: actual.getCheck()
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  content: Container(
                                                      height: 80,
                                                      child: Column(children: [
                                                        Text(
                                                            "Tem certeza que deseja excluir a tarefa '${myList[index].getTitle()}' ? ",
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                            ),
                                                        ),
                                                      ])),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Não')),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            deleteNote(actual.getId());
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text('Sim')),
                                                  ],
                                                ));
                                      },
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                );
              } else if ( snapshot.connectionState == ConnectionState.none ) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }else{
                return Center(
                  child: Text(
                      "Clique no '+' para adicionar a sua primeira tarefa!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
