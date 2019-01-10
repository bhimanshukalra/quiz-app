import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/quiz.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quiz quiz;
  List<Results> results;

  Future<void> fetchQuestions() async {
    var response = await http.get("https://opentdb.com/api.php?amount=20");
    var decodedResponse = jsonDecode(response.body);
    print(decodedResponse);
    quiz = Quiz.fromJson(decodedResponse);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz app"),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("Press button to start.");
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
//                if (snapshot.hasError) return Text("Snapshot has error");
                if (snapshot.hasError) return errorData(snapshot);
//              print("Question List");
                return questionList();
              case ConnectionState.active:
                return Text("Connection is active");
            }
            return null;
          },
          future: fetchQuestions(),
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Error: ${snapshot.error}"),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
            child: Text("Try again"),
          )
        ],
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemBuilder: (context, index) => Card(
            color: Colors.white,
            elevation: 0.0,
            child: ExpansionTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    results[index].question,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RawChip(label: Text(results[index].category,style: TextStyle(fontSize: 10.0),),),
                      SizedBox(
                        width: 10.0,
                      ),
                      RawChip(label: Text(results[index].difficulty,style: TextStyle(fontSize: 10.0))),
                    ],
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(results[index].type == "multiple" ? "M" : "B"),
              ),
              children: results[index].allAnswers.map((str) {
                return AnswerWidget(results, index, str);
              }).toList(),
            ),
          ),
      itemCount: results.length,
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String str;

  AnswerWidget(this.results, this.index, this.str);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color customColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.str,
        textAlign: TextAlign.center,
        style: TextStyle(color: customColor, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        setState(() {
          if (widget.str == widget.results[widget.index].correctAnswer)
            customColor = Colors.green;
          else
            customColor = Colors.red;
        });
      },
    );
  }
}
