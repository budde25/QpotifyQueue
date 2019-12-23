import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'search.dart';
import 'platform.dart';

import 'firebase.dart' as fs;

String queueId;
List songs = new List();

class Queue extends StatefulWidget {
  @override
  _QueueState createState() => _QueueState();

  Queue(String id) {
    if (id != null) {
      queueId = id;
    } else {
      queueId = fs.generateRoom(6);
    }
  }
}

class _QueueState extends State<Queue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Song Queue'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => _buildDialog(context),
                );
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Search())),
          child: Icon(Icons.add),
          tooltip: 'search',
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection(queueId).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Text('Retriving Queue');
                        default:
                          return ListView(
                            children: songs = snapshot.data.documents.map((DocumentSnapshot document) {
                              return ListTile (
                                title: Text(document['name']),
                                subtitle: Text(document['artist']),
                                onTap: () {play(document['track']);},
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => fs.removeSong(queueId, document.documentID),
                                ),
                              );
                            }).toList(),
                      );
                      }
                    }
                )
              )
            ],
          ),
        )
    );
  }

  Widget _buildDialog(BuildContext context) {
    TextEditingController code = new TextEditingController();
    return new AlertDialog(
      title: const Text('Room Code'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(queueId)
        ],
      ),
      actions: <Widget>[

      ],
    );
  }
}