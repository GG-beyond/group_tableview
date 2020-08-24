import 'package:flutter/material.dart';
import 'package:group_tableview/group_tableview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  RefreshController _refreshController;
  ScrollController _controller = ScrollController();

  List<Map> _list = [
    {
      "group": "A",
      "list": ["Apple", "安琪拉", "A-桔子🍊🍊🍊", "艾菲尔"]
    },
    {
      "group": "B",
      "list": ["拜仁", "白起", "Boy", "宝丁"]
    },
    {
      "group": "C",
      "list": ["城主", "Channel", "长安城管", "Charles", "长江"]
    },
    {
      "group": "D",
      "list": ["东南西北"]
    },
  ];

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget _refreshWidget(BuildContext context, Widget listView) {
      return SmartRefresher(
        scrollController: _controller,
        physics: BouncingScrollPhysics(),
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手,加载更多!");
            } else {
              body = Text("没有更多数据了!");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: listView,
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text("TableView Group"),
      ),
      body: Container(
        child: GroupTableView(
          controller: _controller,
          style: ViewStyle.group,
          itemBuilder: _itemBuilder,
          numberOfSections: _list.length,
          numberOfRowsInSection: (int section) {
            return _list[section]["list"].length;
          },
          sectionFooterBuilder: (context, section) {
            Color bgColor = section % 2 == 0 ? Colors.red : Colors.green;
            return Container(
              color: bgColor,
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Text(
                    "              这是一个footer -> section = ${section.toString()}"),
              ),
            );
          },
          sectionHeaderBuilder: (BuildContext context, int section) {
            Color bgColor = section % 2 == 0 ? Colors.red : Colors.green;
            String title = _list[section]["group"];
            double height = section % 2 == 0 ? 40 : 60;
            return Container(
              height: height,
              color: bgColor,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Text(
                  "$title             这是一个header -> section = ${section.toString()}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
          refreshWidget: _refreshWidget,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, IndexPath indexPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 8,
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 10.0),
          title: Text(
            _list[indexPath.section]["list"][indexPath.row],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          subtitle: Text(
              "section = ${indexPath.section.toString()},row = ${indexPath.row.toString()}"),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
