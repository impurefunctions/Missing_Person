import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Cleint/Models/product.dart';
import 'package:ecommerce/Cleint/config/cleint.dart';
import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/Widgets/customAppBar.dart';
import 'package:ecommerce/Widgets/loadingWidget.dart';
import 'package:ecommerce/Widgets/myDrawer.dart';
import 'package:ecommerce/chatApp/Chat/chat.dart';
import 'package:ecommerce/chatApp/Config/config.dart';
import 'package:ecommerce/notifiers/ProductQuantity.dart';

import 'package:http/http.dart' as http;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

class OwnerCard extends StatelessWidget {
  final DocumentSnapshot snapshot;
  OwnerCard(this.snapshot);
  @override
  Widget build(BuildContext context) {
    return snapshot.data[Tswana_Search.userUID] ==
            Tswana_Search.sharedPreferences.getString(Tswana_Search.userUID)
        ? Container(
            child: Text('REPORTED BY YOU'),
          )
        : Container(
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text(snapshot.data[Tswana_Search.userName]),
              accountEmail: Row(
                children: <Widget>[
                  Text(snapshot.data[Tswana_Search.userEmail]),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      List friendList = Tswana_Search.sharedPreferences
                          .getStringList(Tswana_Search.userFriendList);
                      if (!friendList
                          .contains(snapshot.data[ChatApp.userUID])) {
                        friendList.add(snapshot.data[ChatApp.userUID]);

                        Tswana_Search.firestore
                            .collection(Tswana_Search.collectionUser)
                            .document(Tswana_Search.sharedPreferences
                                .getString(ChatApp.userUID))
                            .collection(Tswana_Search.userFriendList)
                            .document(snapshot.data[ChatApp.userUID])
                            .setData({
                          'name': snapshot.data[ChatApp.userName],
                          'url': snapshot.data[Tswana_Search.userAvatarUrl]
                        });
                        Tswana_Search.firestore
                            .collection(Tswana_Search.collectionUser)
                            .document(snapshot.data[ChatApp.userUID])
                            .collection(Tswana_Search.userFriendList)
                            .document(Tswana_Search.sharedPreferences
                                .getString(ChatApp.userUID))
                            .setData({
                          'name': Tswana_Search.sharedPreferences
                              .getString(ChatApp.userName),
                          'url': Tswana_Search.sharedPreferences
                              .getString(Tswana_Search.userAvatarUrl),
                        });
                        Tswana_Search.sharedPreferences.setStringList(
                            Tswana_Search.userFriendList, friendList);
                      }
                      Route route = MaterialPageRoute(
                          builder: (builder) => Chat(
                                // TODO Change peerID with admin ID
                                peerId: snapshot.data[ChatApp.userUID],
                                userID: Tswana_Search.sharedPreferences
                                    .getString(ChatApp.userUID),
                              ));
                      Navigator.push(context, route);
                    },
                    child: Container(
                      color: Colors.white,
                      width: 80,
                      height: 30,
                      child: Center(
                          child: Text(
                        'Chat',
                        style: TextStyle(color: Colors.red),
                      )),
                    ),
                  ),
                ],
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                backgroundImage:
                    NetworkImage(snapshot.data[Tswana_Search.userAvatarUrl]),
              ),
            ),
          );
  }
}

class ProductPage extends StatefulWidget {
  final ProductModel productModel;

  ProductPage({this.productModel});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<NetworkImage> _listOfImages = <NetworkImage>[];

  Position _currentPosition;

  String _currentAddress = "";

  bool isLocationSubmitted = false;

  /*  Location reporterLocation = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;*/

  @override
  Widget build(BuildContext context) {
    print("Product ID: ${widget.productModel.productId}");
    _listOfImages = [];
    for (int i = 0; i < widget.productModel.urls.length; i++) {
      _listOfImages.add(NetworkImage(widget.productModel.urls[i]));
    }
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        drawer: MyDrawer(),
        body: ListView(children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 18.0),
                  child: Text(widget.productModel.name,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Carousel(
                      boxFit: BoxFit.cover,
                      images: _listOfImages,
                      autoplay: false,
                      indicatorBgPadding: 5.0,
                      dotPosition: DotPosition.bottomCenter,
                      animationCurve: Curves.fastOutSlowIn,
                      animationDuration: Duration(milliseconds: 2000)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "DESCRIPTION: ",
                        style: TextStyle(),
                      ),
                      Text(
                        widget.productModel.description.toString(),
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "AGE: ",
                        style: TextStyle(),
                      ),
                      Text(
                        widget.productModel.age.toString(),
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Row(
                    children: <Widget>[
                     if (widget.productModel.found == true)
                      Text(
                       ' Found at: ${widget.productModel.foundLocation}',
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('DETAILS OF REPORTER'),
                ),
                FutureBuilder<DocumentSnapshot>(
                    future: Firestore.instance
                        .collection(AbsaApp.collectionUser)
                        .document(widget.productModel.uid)
                        .get(),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? OwnerCard(snapshot.data)
                          : LoadingWidget();
                    }),
                if (_currentAddress.isNotEmpty)
                  Text("Current Location: $_currentAddress"),
                if(widget.productModel.foundLocation.isEmpty)RaisedButton(
                  onPressed: _currentAddress.isEmpty || isLocationSubmitted
                      ? () => grabLocation()
                      : () => submitLocation(),
                  child: Text(_currentAddress.isEmpty ? 'FOUND' : 'SUBMIT LOCATION'),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  grabLocation() {
    print("grab location pressed");
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  submitLocation() {
    print("submit pressed");

    ProductModel productModel = widget.productModel;
    productModel.foundLocation = "$_currentAddress";
    productModel.found = true;

    print("ID: ${widget.productModel.uid}");
    Firestore.instance
        .collection(AbsaApp.collectionAllBook)
        .document(widget.productModel.productId).updateData(productModel.toJson()).whenComplete(() {
          print('completed Upload');
          setState(() {
            widget.productModel.update(productModel);
            isLocationSubmitted = true;

            print(widget.productModel.foundLocation);

            sendNotification('${widget.productModel.name} found', '${widget.productModel.name} has been found at ${widget.productModel.foundLocation}');
          });

        });



  }


  Future<void> sendNotification(title, subject) async{
    print("Printing test message---------------------->");

    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    String toParams = "/topics/"+'missing-persons';

    final data = {
      "notification": {"body":subject, "title":title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": "yourTopicName",
      },
      "to": "$toParams"};

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=AAAAQihwJ54:APA91bHqsu-P33_mntp9Wt5kP4MV3XA4xwgfBEy-3rpUTJLDVhXYzx5P4a7QfkaSamoG6DjrbfxlHE7lebrTE7JOVWmFAqAa22TmvEGaKvGDSul1UC3tZ84VXYlfNC6oneyC_-EQLDH5'

    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
// on success do
      print("message sent---------------------->");
    } else {
// on failure do
      print("Message failed-------------------------->");
      print(response.body.toString());

    }
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.street},${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}

