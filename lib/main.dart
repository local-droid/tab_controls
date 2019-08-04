import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tab_controls/service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Flutter Demo',
      android: (_) => MaterialAppData(color: Colors.blue),
      ios: (_) => CupertinoAppData(color: CupertinoColors.activeBlue),
      home: ChangeNotifierProvider<TabDisplayState>(
        builder: (_) => TabDisplayState(),
        child: MyHomePage(title: 'Tab Control Demo'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _loadResults(context);
    return DefaultTabController(
        length: 3,
        child: PlatformScaffold(
          appBar: PlatformAppBar(
            android: (_) => MaterialAppBarData(
                backgroundColor: Colors.white,
                title: Center(
                    child: PlatformText(
                  "Material Tab Bar",
                  style: TextStyle(color: Colors.black),
                )),
                bottom: TabBar(
                  indicatorColor: Colors.black,
                  tabs: _tabs(),
                  onTap: (value) {
                    _onMaterialTabTapped(context, value);
                  },
                )),
            ios: (_) => CupertinoNavigationBarData(
                title: PlatformText("iOS Segmented Control")),
          ),
          body: SafeArea(
              child: Padding(
                  padding: EdgeInsets.all(8), child: _showTabView(context))),
          // ),
        ));
  }

  dynamic _showTabView(BuildContext context) {
    if (Platform.isIOS) {
      var currentState = Provider.of<TabDisplayState>(context).currentState;
      currentState = currentState != null ? currentState : ResultType.TYPE_A;
      return Column(children: <Widget>[
        CupertinoSegmentedControl(
            borderColor: CupertinoColors.black,
            groupValue: currentState,
            selectedColor: CupertinoColors.black,
            children: _cupertinoTabs(),
            onValueChanged: (value) =>
                Provider.of<TabDisplayState>(context).setCurrentState(value)),
        _divider(context),
        _tabList()
      ]);
    } else {
      //material
      return _tabList();
    }

    // return _makeChildren();
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: CupertinoColors.black,
        child: Center(
            child: SizedBox(
          height: 10,
          width: MediaQuery.of(context).size.width - 12,
        )),
      ),
    );
  }

  Widget _tabList() {
    return Column(children: <Widget>[
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<TabDisplayState>(
              builder: (context, display, _) => _tabPage(display)),
        ),
      )
    ]);
  }

  Widget _tabPage(TabDisplayState display) {
    var displayList;

    if (display != null &&
        display.displayData != null &&
        display.currentState != null) {
      displayList = display.displayData[display.currentState];
    }
    return TabPage(display.currentState, displayList);
  }

  // dynamic _makeChildren() {
  //   dynamic tabViews;

  //   if (Platform.isIOS) {
  //     return TabBarView(children: <Widget>[]);
  //   }
  // }

  dynamic _cupertinoTabs() {
    return {
      ResultType.TYPE_A: _tabs()[0],
      ResultType.TYPE_B: _tabs()[1],
      ResultType.TYPE_C: _tabs()[2]
    };
  }

  List<Widget> _tabs() {
    TextStyle style = TextStyle(
        fontSize: 24,
        color: Platform.isIOS == true ? CupertinoColors.black : Colors.black);

    var tabA = PlatformText("Type A", style: style);
    var tabB = PlatformText("Type B", style: style);
    var tabC = PlatformText("Type C", style: style);

    final double inset = 12.0;
    List<Widget> iosTabs = [
      Padding(padding: EdgeInsets.all(inset), child: tabA),
      Padding(padding: EdgeInsets.all(inset), child: tabB),
      Padding(padding: EdgeInsets.all(inset), child: tabC),
    ];
    List<Tab> materialTabs = [
      Tab(child: tabA),
      Tab(child: tabB),
      Tab(child: tabC)
    ];

    return Platform.isIOS == true ? iosTabs : materialTabs;
  }

  void _loadResults(BuildContext context) {
    var state = Provider.of<TabDisplayState>(context);
    var results = state.displayData;
    var currentState = state.currentState;

    if (results == null) {
      Service.getResults().then((results) {
        if (currentState == null) {
          state.setCurrentState(ResultType.TYPE_A);
        }
        state.setDisplayData(results);
      });
    }
  }

  _onMaterialTabTapped(BuildContext context, int value) {
    var rType = Provider.of<TabDisplayState>(context).currentState;

    switch (value) {
      case 0:
        rType = ResultType.TYPE_A;
        break;
      case 1:
        rType = ResultType.TYPE_B;
        break;
      case 2:
        rType = ResultType.TYPE_C;
        break;
      default:
        rType = ResultType.TYPE_A;
    }

    Provider.of<TabDisplayState>(context).setCurrentState(rType);
  }
}

class TabPage extends StatelessWidget {
  final ResultType currentState;

  final List<Result> results;

  TabPage(this.currentState, this.results);

  @override
  Widget build(BuildContext context) {
    return this.results == null || this.currentState == null
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              TextStyle style = TextStyle(
                fontSize: 24,
              );
              return PlatformText(results[index].resultData, style: style);
            },
            shrinkWrap: true,
          );
  }
}

class TabDisplayState with ChangeNotifier {
  ResultType currentState;
  Map<ResultType, List<Result>> displayData;

  void setDisplayData(Map<ResultType, List<Result>> data) {
    displayData = data;
    notifyListeners();
  }

  void setCurrentState(ResultType rType) {
    currentState = rType;
    notifyListeners();
  }
}
