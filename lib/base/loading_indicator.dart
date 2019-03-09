import 'package:flutter/material.dart';
import 'package:flutter_demo/base/loading_more_base.dart';

/// 加载更多 列表的最后一项, 用于显示当前的状态
class LoadingIndicator extends StatelessWidget {
  final DataLoadMoreBase dataLoader;

  /// [dataLoader] 类型为[DataLoadMoreBase]
  const LoadingIndicator({Key key, this.dataLoader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _indicator;
    if (dataLoader.isLoading) {
      _indicator = Text("正在加载中...");
    } else if (dataLoader.hasException) {
      // 网络异常
      _indicator = Text("网络异常...");
    } else if (dataLoader.hasError) {
      // 出错了
      _indicator = Text("出错了...");
    } else if (!dataLoader.hasMore()) {
      // 没有更多
      _indicator = Text("没有更多...");
    } else if (dataLoader.hasMore()) {
      // 还有更多
      _indicator = Text("还有更多...");
    } else {
      _indicator = Text("...");
    }
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: _indicator,
    );
  }
}
