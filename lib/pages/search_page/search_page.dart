import 'package:demo/dao/search_dao.dart';
import 'package:demo/model/search_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchModel _searchModel;
  IconData _searchBarIcon = Icons.mic;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Column(
            children: <Widget>[
              _searchBar(),
              Expanded(
                child: _searchResultList(),
              )
            ],
          ),
        ));
  }

  Widget _searchBar() {
    return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: BorderDirectional(
                bottom: BorderSide(color: Color.fromARGB(255, 237, 237, 237)))),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 237, 237, 237),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  height: 34,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 200, 200, 200),
                          size: 22,
                        ),
                        Expanded(
                            child: TextField(
                          controller: _textEditingController,
                          onChanged: _onInputChanged,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              border: InputBorder.none,
                              hintText: '杭州攻略',
                              hintStyle: TextStyle(fontSize: 14)),
                        )),
                        _wrapTap(
                            Icon(
                              _searchBarIcon,
                              color: Color.fromARGB(255, 169, 169, 169),
                              size: 22,
                            ), () {
                          if (_searchBarIcon.codePoint == 0xe029) {
                          } else {
                            _textEditingController.clear();
                            _onInputChanged('');
                          }
                        })
                      ],
                    ),
                  )),
            ),
            Container(
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 144, 254),
                    borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                width: 50,
                height: 30,
                child: Text(
                  '搜索',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ))
          ],
        ));
  }

  Widget _searchResultList() {
    return ListView.builder(
        itemCount: _searchModel?.data?.length ?? 0,
        itemBuilder: (BuildContext context, int position) {
          return _listItem(position);
        });
  }

  void _onInputChanged(String text) {
    _changeIcon(text);
    if (text != '') {
      _sendSearch(text);
    }
  }

  void _changeIcon(String text) {
    if (text.length > 0) {
      setState(() {
        _searchBarIcon = Icons.clear;
      });
    } else {
      setState(() {
        _searchBarIcon = Icons.mic;
      });
    }
  }

  void _sendSearch(String text) async {
    try {
      SearchModel model = await SearchDao.fetch(text);
      setState(() {
        _searchModel = model;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _wrapTap(Widget child, void Function() callback) {
    return GestureDetector(
      onTap: () {
        if (callback != null) callback();
      },
      child: child,
    );
  }

  Widget _listItem(int position) {
    if (_searchModel == null || _searchModel.data == null) return null;
    SearchItem item = _searchModel.data[position];
    String text = item.word;
    text = text.length >= 23 ? text.substring(0, 20) + '...' : text;
    TextStyle normalStyle = TextStyle(color: Colors.black);
    TextStyle highlightStyle = TextStyle(color: Color.fromARGB(255, 140, 210, 239));
    List<Text> textList = [];
    List<TextSpan> spanList = [];
    // text.
    for(int i=0;i<text.length;i++) {
      if(text[i] == _searchModel.keyword) {
        textList.add(Text(text[i], style: highlightStyle));
      } else {
        textList.add(Text(text[i], style: normalStyle));
      }
    }
    return GestureDetector(
        onTapUp: (_) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return WebviewScaffold(
              url: item.url,
              hidden: true,
              appBar: AppBar(
                title: Text(item.word ?? '详情'),
              ),
            );
          }));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                color: Color.fromARGB(255, 140, 210, 239),
              ),
              Expanded(
                child: Row(
                  children: textList,
                )
              ),
              Icon(Icons.keyboard_arrow_right,
                  color: Color.fromARGB(255, 162, 162, 162))
            ],
          ),
        ));
  }
}
