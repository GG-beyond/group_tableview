import 'package:flutter/material.dart';

///
/// 类型 IndexPath
///
class IndexPath {
  final int section;
  final int row;

  IndexPath(this.section, this.row);
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
typedef Widget ListViewSuperWidgetBuilder(
    BuildContext context, Widget scrollWidget);
///
/// GroupTableView 实现
///
class GroupTableView extends StatefulWidget {
  final ViewStyle style; //listview样式,默认是plain样式
  final int numberOfSections; //section个数 默认1
  final SectionBuilder numberOfRowsInSection; //每个section内有多少个row
  final IndexPathWidgetBuilder itemBuilder; //item builder方法
  final IndexedWidgetBuilder sectionHeaderBuilder; // section header builder 方法
  final IndexedWidgetBuilder sectionFooterBuilder; // section footer builder 方法
  final ListViewSuperWidgetBuilder refreshWidget; //父 刷新组件
  final ScrollController controller; // controller
  final Color backgroundColor; // 背景颜色

  GroupTableView(
      {this.itemBuilder,
      this.style = ViewStyle.plain,
      this.numberOfSections = 1,
      this.numberOfRowsInSection,
      this.sectionHeaderBuilder,
      this.sectionFooterBuilder,
      this.refreshWidget,
      this.controller,
      this.backgroundColor})
      : assert(itemBuilder != null, "itemBuilder 不能为null");

  @override
  _GroupTableViewState createState() => _GroupTableViewState();
}

class _GroupTableViewState extends State<GroupTableView> {
  ScrollController _controller;
  ListView listView;
  List<SectionModel> sectionList = [];
  List<GlobalKey> keyList = [];
  SectionModel currentSectionModel;
  double position = -88; //悬浮位置(相对于设备)
  int currentIndex = -1; //当前是第几个分区悬浮
  double topOffsetY = 0;
  bool floating = true;

  Size _size;

  static int totalCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = widget.controller;
    if (_controller == null) {
      _controller = ScrollController();
    }
    if (widget.style == ViewStyle.group) {
      _controller.addListener(() {
        double offsetY = _controller.offset;
        int _currentIndex = -1;

        if (offsetY < 0.0) {

          floating = false;
          setState(() {

          });
        } else {

          floating = true;
          for (int section = sectionList.length - 1; section >= 0; section--) {
            GlobalKey globalKey = keyList[section];
            if (globalKey.currentContext != null) {
              RenderBox renderBox = globalKey.currentContext.findRenderObject();
              double dy = renderBox.localToGlobal(Offset(0, position)).dy;

              if (dy <= 0) {
                //查找最后一个悬浮的
                _currentIndex = section;
                _size = renderBox.size;
                sectionList[section].headerHeight = _size.height;
                break;
              }
            }
          }

          //加一层复用保护
          if (_currentIndex < 0 && currentIndex >= 0) {
            GlobalKey key = keyList[currentIndex];
            if (key.currentContext == null) {
              _currentIndex = currentIndex;
              _size = Size(_size.width, sectionList[currentIndex].headerHeight);
            } else {
              _currentIndex = currentIndex - 1;
            }
          }

          double _offset = 0;

          if (_currentIndex >= 0) {
            if ((_currentIndex + 1) < sectionList.length) {
              //当前悬浮的
              GlobalKey nextGlobalKey = keyList[_currentIndex + 1];

              if (nextGlobalKey.currentContext != null) {
                RenderBox nextRenderBox =
                    nextGlobalKey.currentContext.findRenderObject();
                double nextDy =
                    nextRenderBox.localToGlobal(Offset(0, position)).dy;

                //取出滚动方向对应的数据
                double offsetAxis = nextDy;
                double sizeAxis = _size.height;

                //计算偏移位置
                if (offsetAxis < sizeAxis) {
                  _offset = offsetAxis - sizeAxis;
                }
              }
            }
          }

          if (_currentIndex != currentIndex || _offset != topOffsetY) {
            currentIndex = _currentIndex;
            currentSectionModel = sectionList[_currentIndex];
            topOffsetY = _offset;
            setState(() {});
          }
        }
      });
    }

    _initData();

  }

  ///根据DataSource 初始化数据
  void _initData() {
    totalCount = 0;
    sectionList.clear();

    for (int section = 0; section < widget.numberOfSections; section++) {
      //遍历section
      int rowCount =
          widget.numberOfRowsInSection(section); //获取每个section(区)有多少个row

      Widget header; //获取header
      if (widget.sectionHeaderBuilder != null) {
        header = widget.sectionHeaderBuilder(context, section);
      }
      Widget footer; //获取footer
      if (widget.sectionFooterBuilder != null) {
        footer = widget.sectionFooterBuilder(context, section);
      }

      bool isHaveHeader = header != null ? true : false; //是否有header
      bool isHaveFooter = footer != null ? true : false; //是否有footer

      SectionModel sectionModel =
          SectionModel(section, rowCount, isHaveHeader, isHaveFooter, header);
      if (section == 0) {
        currentSectionModel = sectionModel;
      }
      sectionList.add(sectionModel);

      totalCount = totalCount +
          rowCount +
          (header != null ? 1 : 0) +
          (footer != null ? 1 : 0); //ListView itemCount总行数

      GlobalKey globalKey = GlobalKey(debugLabel: section.toString());
      keyList.add(globalKey);
    }
    listView = ListView.builder(
      controller: _controller,
      physics: BouncingScrollPhysics(),
      itemBuilder: _itemBuilder,
      itemCount: _calculateItemCount(),
    );
  }

  @override
  Widget build(BuildContext context) {


    Widget child;
    if(widget.refreshWidget!=null&&widget.refreshWidget(context,listView)!=null){

      child = widget.refreshWidget(context,listView);
    }else{
      child = listView;
    }

    if (widget.style == ViewStyle.plain) {
      return Container(
        color: widget.backgroundColor ?? Colors.transparent,
        child: child,
      );
    }
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            color: widget.backgroundColor ?? Colors.transparent,
            child: child,
          ),
          Visibility(
            visible: floating,
            child: Positioned(
                left: 0,
                right: 0,
                top: topOffsetY ?? 0,
                child: currentSectionModel.header ?? Container()),
          ),
        ],
      ),
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
      item = Container(
        key: keyList[sectionHeaderModel.section],
        child: widget.sectionHeaderBuilder(context, sectionHeaderModel.section),
      );
//      item = widget.sectionHeaderBuilder(context, sectionHeaderModel.section);
    } else if (model is SectionFooterModel) {
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
      } else if (index == tempCount + sectionModel.rowCount + passCount &&
          isHaveFooter == true) {
        //这是footer
        return SectionFooterModel(section);
      } else if (index >= passCount &&
          index < tempCount + sectionModel.rowCount + passCount) {
        //这是row
        IndexPath indexPath = IndexPath(section, index - passCount - tempCount);
        return RowModel(indexPath);
      }
      passCount = passCount +
          sectionModel.rowCount +
          tempCount +
          (isHaveFooter ? 1 : 0);
    }
    return null;
  }
}

///
///  ============================ model类 ===============================================
///
class SectionModel {
  final Widget header; //是否有header
  final int section; //当前section
  final int rowCount; //记录当前section下有多少个row
  final bool isHaveHeader; //是否有header
  final bool isHaveFooter; //是否有footer

  SectionModel(this.section, this.rowCount, this.isHaveHeader,
      this.isHaveFooter, this.header);

  double headerHeight;
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
  SectionFooterModel(this.section);
}

///
///记录 row 的model类，
///
class RowModel {
  final IndexPath indexPath; //indexPath 的section和row
  RowModel(this.indexPath);
}
