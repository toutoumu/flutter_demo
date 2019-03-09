import 'dart:async';

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

enum PageState {
  None, // 现在什么也没做(网络请求前,网络请求完成)
  Loading, // 加载中
  LoadingError, // 加载失败(业务逻辑错误)
  LoadingException, // 网络异常
}

/// [DATA] 列表中的数据的数据类型
/// [MODEL] 服务返回的数据结构对应的数据类
abstract class DataLoadBase<DATA, MODEL> extends _DataLoadBloc<DataLoadBase<DATA, MODEL>> {
  DATA mData;

  /// 是否有业务错误
  bool get hasError => _pageState == PageState.LoadingError;

  /// 是否有网络异常
  bool get hasException => _pageState == PageState.LoadingException;

  /// 是否加载中
  bool get isLoading => _pageState == PageState.Loading;

  /// 页面状态
  PageState get pageState => _pageState;

  /// 页面状态
  PageState _pageState = PageState.None;

  bool get hasData {
    if (mData == null) {
      return false;
    }
    if (mData is List) {
      return (mData as List).length > 0;
    }
    return true;
  }

  @mustCallSuper
  Future<bool> obtainData([bool isRefresh = false]) async {
    if (isLoading) return true;
    _pageState = PageState.Loading;
    onStateChanged(this);

    var success = false;
    try {
      success = await _loadData(isRefresh);
      if (success) {
        // 加载数据成功
        _pageState = PageState.None;
      } else {
        // 加载数据业务逻辑错误
        _pageState = PageState.LoadingError;
      }
    } catch (e) {
      // 网络异常
      _pageState = PageState.LoadingException;
    }

    onStateChanged(this);
    return success;
  }

  /// 加载数据
  Future<bool> _loadData([bool isRefresh = false]) async {
    MODEL model = await getRequest(isRefresh);
    bool success = await handlerData(model, isRefresh);
    return success;
  }

  @protected
  Future<MODEL> getRequest(bool isRefresh);

  /// 重载这个方法,必须在这个方法将数据添加到列表中
  /// [model] 本次请求回来的数据
  /// [isRefresh] 是否清空原来的数据
  @protected
  Future<bool> handlerData(MODEL model, bool isRefresh);
}

/// [DATA] 列表中的数据的数据类型
/// [MODEL] 服务返回的数据结构对应的数据类
abstract class DataLoadMoreBase<DATA, MODEL> extends ListBase<DATA> {
  /// 使用 BehaviorSubject 会保留最后一次的值,所有监听是会受到回调
  final _streamController = new BehaviorSubject<DataLoadMoreBase<DATA, MODEL>>();

  /// 页面通过监听stream变化更新界面
  Stream<DataLoadMoreBase<DATA, MODEL>> get stream => _streamController.stream;

  void onStateChanged(DataLoadMoreBase<DATA, MODEL> source) {
    if (!_streamController.isClosed) _streamController.add(source);
  }

  void dispose() {
    _streamController.close();
  }

  final _mData = <DATA>[];

  @override
  DATA operator [](int index) {
    return _mData[index];
  }

  @override
  void operator []=(int index, DATA value) {
    _mData[index] = value;
  }

  @override
  int get length => _mData.length;

  @override
  set length(int newLength) => _mData.length = newLength;

  final _pageSize = 20;

  int _currentPage = 1;

  /// 页面状态
  PageState _pageState = PageState.None;

  /// 是否有数据
  bool get hasData => this.length > 0;

  /// 是否有业务错误
  bool get hasError => _pageState == PageState.LoadingError;

  /// 是否有网络异常
  bool get hasException => _pageState == PageState.LoadingException;

  /// 是否加载中
  bool get isLoading => _pageState == PageState.Loading;

  /// 页面状态
  PageState get pageState => _pageState;

  /// 拉取数据
  /// [isRefresh] 是否清空原来的数据
  @mustCallSuper
  Future<bool> obtainData([bool isRefresh = false]) async {
    if (isLoading) return true;

    _pageState = PageState.Loading;
    onStateChanged(this);

    var success = false;
    try {
      success = await _loadData(isRefresh);
      if (success) {
        // 加载数据成功
        _pageState = PageState.None;
      } else {
        // 加载数据业务逻辑错误
        _pageState = PageState.LoadingError;
      }
    } catch (e) {
      // 网络异常
      _pageState = PageState.LoadingException;
    }

    onStateChanged(this);
    return success;
  }

  /// 加载数据
  /// [isRefresh] 是否清空原来的数据
  Future<bool> _loadData([bool isRefresh = false]) async {
    int currentPage = isRefresh ? 1 : _currentPage + 1;
    MODEL model = await getRequest(isRefresh, currentPage, _pageSize);
    bool success = await handlerData(model, isRefresh);
    if (success) _currentPage = currentPage;
    return success;
  }

  /// 是否还有更多数据
  @protected
  bool hasMore();

  /// 构造请求
  /// [isRefresh] 是否清空原来的数据
  /// [currentPage] 将要请求的页码
  /// [pageSize] 每页多少数据
  @protected
  Future<MODEL> getRequest(bool isRefresh, int currentPage, int pageSize);

  /// 重载这个方法,必须在这个方法将数据添加到列表中
  /// [model] 本次请求回来的数据
  /// [isRefresh] 是否清空原来的数据
  @protected
  Future<bool> handlerData(MODEL model, bool isRefresh);
}

/// 数据加载Bloc
class _DataLoadBloc<T> {
  /// 使用 BehaviorSubject 会保留最后一次的值,所有监听是会受到回调
  final _streamController = new BehaviorSubject<T>();

  // final _streamController = new StreamController<LoadingMoreBase<DATA, MODEL>>.broadcast();

  Stream<T> get stream => _streamController.stream;

  void onStateChanged(T source) {
    if (!_streamController.isClosed) _streamController.add(source);
  }

  void dispose() {
    _streamController.close();
  }
}
