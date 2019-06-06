import 'package:flutter/material.dart';
import 'package:gesture_password/gesture_password.dart';
import 'package:gesture_password/mini_gesture_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(
        title: 'Flutter Demo Home Page',
        createNewPassWorld: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.createNewPassWorld}) : super(key: key);

  final String title;
  final bool createNewPassWorld;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<MiniGesturePasswordState> miniGesturePassword =
      new GlobalKey<MiniGesturePasswordState>();

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey<ScaffoldState>();

  int count = 0;

  //临时存储的密码
  var _storageStringValue;

  String _notifyMsg = "";

  final _textStyle = new TextStyle(
      color: Colors.red, fontSize: 14, fontWeight: FontWeight.w200);

  final STORAGE_KEY = "NCF_UNLOCK_KEY";

  Future saveString(_storageString) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(STORAGE_KEY, _storageString);
    setState(() {
      _storageStringValue = _storageString;
    });
  }

  Future getString() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _storageStringValue = sharedPreferences.get(STORAGE_KEY);
    });
  }

  List<Widget> _buildBody() {
    var _bodyList = new List<Widget>();
    if (this.widget.createNewPassWorld) {
      _bodyList.add(_buildMiniGesturePassword());
    }
    _bodyList.add(_buildNofityMsg());
    _bodyList.add(_buildPassworldBody());
    return _bodyList;
  }

  Widget _buildMiniGesturePassword() {
    return new Container(
      child:
          new Center(child: new MiniGesturePassword(key: miniGesturePassword)),
      margin: const EdgeInsets.only(top: 50),
    );
  }

  Widget _buildNofityMsg() {
    return new Container(
      margin: EdgeInsets.only(top: this.widget.createNewPassWorld ? 10 : 120),
      child: new SizedBox(
        child: new Center(
            child: new Text(
          _notifyMsg,
          style: _textStyle,
        )),
        height: 20,
      ),
    );
  }

  _createNewGestureCode(str) {
    if (this.count == 0) {
      setState(() {
        _storageStringValue = str;
        _notifyMsg = "请再次确认手势密码";
        ++count;
      });
    } else if (_storageStringValue != str) {
      setState(() {
        _storageStringValue = null;
        _notifyMsg = "两次手势密码不一致，请重新设置";
        count = 0;
      });
    } else {
      saveString(str);
    }
  }

  _validateGestturCode(str) {
    getString();
    print("已保存的?密码是：" + _storageStringValue);
    if (str != _storageStringValue) {
      setState(() {
        _notifyMsg = "手势密码不正确";
      });
    }
  }

  Widget _buildPassworldBody() {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return new Container(
          color: Colors.white,
          margin:
              EdgeInsets.only(top: this.widget.createNewPassWorld ? 25 : 10),
          child: new GesturePassword(
            successCallback: (s) {
              if (this.widget.createNewPassWorld) {
                _createNewGestureCode(s);
              } else {
                _validateGestturCode(s);
              }
            },
            failCallback: () {
              setState(() {
                _notifyMsg = this.widget.createNewPassWorld ? "无效的手势" : "解锁失败";
              });
            },
            selectedCallback: (str) {
              if(_notifyMsg!=null&&_notifyMsg!=""){
                setState(() {
                  _notifyMsg = "";
                });
              }
              miniGesturePassword.currentState?.setSelected(str);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: scaffoldState,
        appBar: new AppBar(
          title: new Text('你财富创新项目组'),
        ),
        body: new Column(
          children: _buildBody(),
        ),
      ),
    );
  }
}
