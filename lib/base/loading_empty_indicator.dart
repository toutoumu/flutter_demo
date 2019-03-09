import 'package:flutter/material.dart';
import 'package:flutter_demo/base/loading_more_base.dart';

/// 加载更多 没有数据时, 用于显示当前的状态
class LoadingEmptyIndicator extends StatelessWidget {
  final DataLoadMoreBase dataLoader;

  /// [dataLoader] 类型为[DataLoadMoreBase]
  const LoadingEmptyIndicator({Key key, this.dataLoader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dataLoader != null && !dataLoader.hasData) {
      if (dataLoader.pageState == PageState.Loading) {
        return Container(
          child: Center(child: new Text('Loading...')),
        );
      }

      if (dataLoader.pageState == PageState.LoadingException) {
        return Material(
          child: InkWell(
            onTap: () => dataLoader.obtainData(false),
            child: Center(child: new Text('网络异常...')),
          ),
        );
      }

      if (dataLoader.pageState == PageState.LoadingError) {
        return Material(
          child: InkWell(
            onTap: () => dataLoader.obtainData(false),
            child: Center(child: new Text('业务逻辑错误...')),
          ),
        );
      }

      return Material(
        child: InkWell(
          onTap: () => dataLoader.obtainData(false),
          child: Center(child: new Text('暂无数据...')),
        ),
      );
    }
    return Container(
      child: Center(child: new Text('欢迎光临...')),
    );
  }
}
