import 'package:flutter/material.dart';

class AnimationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnimationPageState();
  }
}

class AnimationPageState extends State<AnimationPage> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _color;

  bool forward = true;

  @override
  void initState() {
    _controller = new AnimationController(vsync: this, duration: Duration(seconds: 5));
    _color = ColorTween(begin: Colors.blue[300], end: Colors.red[900]).animate(_controller);
    /*_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
      print(status);
    });*/
    /*_controller.addListener(() {
      setState(() {});
    });*/

    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("动画"),
      ),
      body: Center(
        child: Container(
            alignment: Alignment.center,
            width: 200,
            height: 200,
            child: RotationTransition(
              alignment: Alignment.center,
              turns: ReverseTween<double>(Tween<double>(end: 100, begin: 90)).animate(_controller),
              child: InkWell(
                onTap: () => _controller.repeat(),
                child: Container(color: Colors.red),
              ),
            )
            /*child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return Material(
                  color: _color.value,
                  child: InkWell(
                    child: Padding(
                      child: Text("adf"),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    onTap: () {
                      if (forward)
                        _controller.forward(); //向前播放动画
                      else
                        _controller.reverse(); //向后播放动画
                      forward = !forward;
                    },
                  ));
            },
          ),*/
            ),
      ),
    );
  }
}
