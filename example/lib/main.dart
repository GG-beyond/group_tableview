import 'package:example/page1.dart';
import 'package:example/page2.dart';
import 'page3.dart';
import 'page4.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group TableView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Group TableView'),
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
  List<String> _list = ["tableview plain样式","tableview plain样式 带刷新", "tableview group悬停样式","tableview group悬停样式 带刷新"];
  List<Widget> _widgetArr = [Page1(),Page3(),Page2(),Page4()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return _itemBuilder(context, index);
          },
          itemCount: _list.length,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          elevation: 8,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10.0),
            title: Text(
              _list[index],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
      onTap: () {

        Widget page = _widgetArr[index];
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (BuildContext context) {
          return page;
        }));
      },
    );
  }
}
