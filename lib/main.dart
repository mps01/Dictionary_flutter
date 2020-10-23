import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "a3c1945ef6700fa7b6ed023e2477ec4d6f0589f8";

  TextEditingController _controller = TextEditingController();

  StreamController _streamController;
  Stream _stream;
  Timer _debounce;
  _search() async {
    if (_controller.text.length == 0) {
      _streamController.add(null);
      return;
    }

    _streamController.add("waiting");
    Response response = await get(url + _controller.text.trim(),
        headers: {"Authorization": "Token " + token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    var buildContext = BuildContext;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Wordifyne"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        _search();
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                )),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _search();
                  },
                )
              ],
            ),
          ),
        ),
        body: Container(
            margin: const EdgeInsets.all(8.0),
            child: StreamBuilder(
                stream: _stream,
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Text("Enter a word to search"),
                    );
                  }

                  if (snapshot.data == "waiting") {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data["definitions"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListBody(
                          children: <Widget>[
                            Container(
                              color: Colors.grey[300],
                              child: ListTile(
                                leading: snapshot.data["definitions"][index]
                                            ["image_url"] ==
                                        null
                                    ? null
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            snapshot.data["definitions"][index]
                                                ["image_url"]),
                                      ),
                                title: Text(_controller.text.trim() +
                                    "(" +
                                    snapshot.data["definitions"][index]
                                        ["type"] +
                                    ")"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(snapshot.data["definitions"][index]
                                  ["definition"]),
                            )
                          ],
                        );
                      });
                })));
  }
}
