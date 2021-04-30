import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });

    // mqtt test
    final client = MqttServerClient('mqttx.cn', 'flutter233');
    // 打开调试log
    // client.logging(on: true);
    // 发送心跳的间隔
    client.keepAlivePeriod = 5;
    // 连接成功的回调方法
    client.onConnected = onConnected;
    // 断开连接的回调
    client.onDisconnected = onDisconnected;
    // 订阅成功的回调
    client.onSubscribed = onSubscribed;
    // 收到服务端心跳包的回调
    client.pongCallback = onPong;

    try {
      // 连接到mqtt broker
      await client.connect('username', 'password');
    } on Exception catch (e) {
      print('client exception: $e');
    }

    // 订阅主题
    client.subscribe('test/topic', MqttQos.atLeastOnce);
    // 接收服务端发来的消息
    client.updates!.listen((dynamic event) {
      final MqttPublishMessage recMess = event[0].payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      print(pt);
    });

    // 每隔3秒发送一条消息
    Timer.periodic(Duration(seconds: 3), (timer) {
      final builder = MqttClientPayloadBuilder();
      builder.addString('Hello from flutter');
      // 发送消息
      client.publishMessage(
          'test/topic', MqttQos.atLeastOnce, builder.payload!);
    });

    // 取消订阅
    // client.unsubscribe('test/topic');
    // 断开连接
    // client.disconnect();

    // mqtt test
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void onDisconnected() {
    print('client disconnected');
  }

  void onSubscribed(String topic) {
    print('subscribed to topic $topic');
  }

  void onConnected() {
    print('client connected');
  }

  void onPong() {
    print('received pingresp from server');
  }
}
