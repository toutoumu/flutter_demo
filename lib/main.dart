import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_demo/Model.dart';
import 'package:flutter_demo/base/loading_empty_indicator.dart';
import 'package:flutter_demo/base/loading_indicator.dart';
import 'package:flutter_demo/base/loading_more_base.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoaderMoreDemo(1),
    );
  }
}

class LoaderMoreDemo extends StatefulWidget {
  final int _id;

  const LoaderMoreDemo(this._id, {Key key}) : super(key: key);

  @override
  _LoaderMoreDemoState createState() => _LoaderMoreDemoState();
}

class _LoaderMoreDemoState extends State<LoaderMoreDemo> with AutomaticKeepAliveClientMixin {
  /// 数据加载类
  _DataLoader _loader;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _loader = _DataLoader(widget._id);
    _loader.obtainData(false);
    super.initState();
  }

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('加载更多示例'),
      ),
      body: StreamBuilder<DataLoadMoreBase<Article, Model>>(
          stream: _loader.stream,
          builder: (context, snapshot) {
            /// 监听滑动结束广播
            return NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  if (notification.depth != 0) return false;
                  if (notification.metrics.axisDirection != AxisDirection.down) return false;
                  if (notification.metrics.pixels < notification.metrics.maxScrollExtent) return false;

                  /// 如果没有更多, 服务返回错误信息, 网络异常,那么不允许上拉加载更多
                  if (snapshot.data == null ||
                      !snapshot.data.hasMore() ||
                      snapshot.data.hasError ||
                      snapshot.data.hasException) return false;

                  // 加载更多
                  _loader.obtainData(false);
                  return false;
                },

                /// 下拉刷新
                child: RefreshIndicator(
                  child: _buildList(snapshot.data),
                  onRefresh: () => _loader.obtainData(true),
                ));
          }),
    );
  }

  Widget _buildList(DataLoadMoreBase<Article, Model> dataLoader) {
    /// 初始化时显示的View
    if (dataLoader == null) {
      return Container(
        child: Center(child: new Text('欢迎光临...')),
      );
    }

    /// 没有数据时候显示的View构建
    if (!dataLoader.hasData) {
      return LoadingEmptyIndicator(dataLoader: dataLoader);
    }

    /// 渲染数据 ,这里数据+1 1表示最后一项,用于显示加载状态
    return ListView.separated(
      itemCount: dataLoader.length + 1,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (content, index) {
        return new Container(height: 0.5, color: Colors.grey);
      },
      itemBuilder: (context, index) {
        if (index == dataLoader.length) {
          return LoadingIndicator(dataLoader: dataLoader);
        } else {
          return Material(
            color: Colors.white,
            child: new InkWell(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(dataLoader[index].title),
              ),
              onTap: () {},
            ),
          );
        }
      },
    );
  }
}

/// 数据业务逻辑处理
class _DataLoader extends DataLoadMoreBase<Article, Model> {
  bool _hasMore = true;

  int _id; // 请求时的参数

  _DataLoader(this._id);

  @override
  Future<Model> getRequest(bool isRefresh, int currentPage, int pageSize) async {
    // 这里模拟网络请求
    var list = List();
    for (var i = 0; i < 10; i++) {
      var article = Article(title: "Article$currentPage $_id $i");
      list.add(article);
    }
    await Future.delayed(Duration(seconds: 2));

    return Model(data: list, message: "加载成功", code: 0);
  }

  @override
  Future<bool> handlerData(Model model, bool isRefresh) async {
    // 1. 判断是否有业务错误,
    // 2. 将数据存入列表, 如果是刷新清空数据
    // 3. 判断是否有更多数据
    if (model == null || model.isError()) {
      return false;
    }

    if (isRefresh) clear();

    // todo 实际使用时这里需要修改
    addAll((model.data as List<dynamic>).map((d) {
      return d as Article;
    }));

    _hasMore = length < 100;

    return true;
  }

  @override
  bool hasMore() => _hasMore;
}
