import 'package:flutter/material.dart';

///
/// 类型 IndexPath
///
class IndexPath {
  final int _section;
  final int _row;

  //mark get  方法
  int get section => _section;

  int get row => _row;

  IndexPath(this._section, this._row);
}

///
/// 类型 模仿iOS tableview样式，默认是plain
///
enum ViewStyle {
  plain, //regular table view
  group //sections are grouped together
}

///
/// 定义方法
///
typedef IndexPathWidgetBuilder = Widget Function(
    BuildContext context, IndexPath indexPath);
typedef SectionBuilder = int Function(int section);

///
/// GroupListView 实现
///
class GroupListView extends StatefulWidget {
  final ViewStyle style; //listview样式,默认是plain样式
  final int numberOfSections; //section个数 默认1
  final SectionBuilder numberOfRowsInSection; //每个section内有多少个row
  final IndexPathWidgetBuilder itemBuilder; //item builder方法
  final IndexedWidgetBuilder sectionHeaderBuilder; // section header builder 方法
  final IndexedWidgetBuilder sectionFooterBuilder; // section footer builder 方法

  GroupListView(
      {this.itemBuilder,
      this.style = ViewStyle.plain,
      this.numberOfSections = 1,
      this.numberOfRowsInSection,
      this.sectionHeaderBuilder,
      this.sectionFooterBuilder})
      : assert(itemBuilder != null);

  @override
  _GroupListViewState createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  ScrollController controller;
  List<SectionModel> sectionList = [];

  static int totalCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = ScrollController();
    controller.addListener(() {
//      setState(() {});
    });
  }

  ///根据DataSource 初始化数据
  void _initData() {
    totalCount = 0;
    for (int section = 0; section < widget.numberOfSections; section++) {
      //遍历section

      int rowCount =
      widget.numberOfRowsInSection(section); //获取每个section(区)有多少个row

      Widget header; //获取header
      if(widget.sectionHeaderBuilder!=null){
        header = widget.sectionHeaderBuilder(context, section);
      }
      Widget footer; //获取footer
      if(widget.sectionFooterBuilder!=null){
        footer = widget.sectionFooterBuilder(context, section);
      }

      bool isHaveHeader = header != null ? true : false;//是否有header
      bool isHaveFooter = footer != null ? true : false;//是否有footer

      sectionList.add(SectionModel(isHaveHeader, section, rowCount,isHaveFooter));
      totalCount = totalCount + rowCount + (header != null ? 1 : 0) + (footer != null ? 1 : 0);//ListView itemCount总行数
    }
  }

  @override
  Widget build(BuildContext context) {
    _initData();

    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: _calculateItemCount(),
    );
  }

  int _calculateItemCount() {
    return totalCount; //row+section = 总行数
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Widget item;
    Object model = _getItemRowModel(index);

    if (model is SectionHeaderModel) {
      SectionHeaderModel sectionHeaderModel = model;
      item = widget.sectionHeaderBuilder(context, sectionHeaderModel.section);
    }else if(model is SectionFooterModel){
      SectionFooterModel sectionFooterModel = model;
      item = widget.sectionFooterBuilder(context, sectionFooterModel.section);
    } else {
      RowModel rowModel = model;
      item = widget.itemBuilder(context, rowModel.indexPath);
    }
    return item;
  }

  Object _getItemRowModel(int index) {

    int passCount = 0;
    //遍历整个分区 ，去查找index在哪个分区section的哪个下标row
    for (int section = 0; section < sectionList.length; section++) {

      SectionModel sectionModel = this.sectionList[section];

      bool isHaveHeader = sectionModel.isHaveHeader;
      bool isHaveFooter = sectionModel.isHaveFooter;

      int tempCount = 0;
      if (isHaveHeader == true) {
        //有header
        tempCount = tempCount + 1;
      }

      if (index == passCount && isHaveHeader == true) {
        //这是header
        return SectionHeaderModel(section);
      }else if(index == tempCount + sectionModel.rowCount + passCount && isHaveFooter == true){
        //这是footer
        return SectionFooterModel(section);
      } else if (index >= passCount &&
          index < tempCount + sectionModel.rowCount+passCount) {
        //这是row
        IndexPath indexPath = IndexPath(section, index - passCount - tempCount);
        return RowModel(indexPath);
      }
      passCount = passCount + sectionModel.rowCount + tempCount +(isHaveFooter?1:0);
    }
    return null;
  }
}

///
///  ============================ model类 ===============================================
///
class SectionModel {
  final bool isHaveHeader; //是否有header
  final int section; //当前section
  final int rowCount; //记录当前section下有多少个row
  final bool isHaveFooter; //是否有footer

  SectionModel(this.isHaveHeader, this.section, this.rowCount,this.isHaveFooter);
}

///
/// 记录section header 的类 包含区域
///
class SectionHeaderModel {

  final int section; //当前section
  SectionHeaderModel(this.section);
}

///
/// 记录section footer 的类 包含区域
///
class SectionFooterModel {

  final int section; //当前section
  SectionFooterModel( this.section);
}

///
///记录 row 的model类，
///
class RowModel {

  final IndexPath indexPath; //row 所在的section和下标
  RowModel(this.indexPath);
}
