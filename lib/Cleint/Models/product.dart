import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel {
  String productId;
  String name;
  DateTime lastSeen;
  String description;
  String foundLocation;
  String uid;
  List<String> urls;
  bool found;
  String age;

  ProductModel(
      {this.productId,
        this.name,
      this.lastSeen,
      this.description,
      this.uid,
      this.foundLocation,
      this.found,
      this.urls,
      this.age});

  ProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    productId= json['product_id'];
    final Timestamp timestamp = json['last_seen'] as Timestamp;
    lastSeen = timestamp.toDate();
    description = json['description'];
    uid = json['uid'];
    foundLocation =
        (json['found_location'] == null) ? "" : json['found_location'];
    urls = json['urls'].cast<String>();
    age = json['age'];
    found = json['found'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id']= this.productId;
    data['name'] = this.name;
    data['last_seen'] = this.lastSeen;
    data['description'] = this.description;
    data['found_location'] = this.foundLocation;
    data['uid'] = this.uid;
    data['urls'] = this.urls;
    data['age'] = this.age;
    data['found'] = this.found;

    return data;
  }

  void update(ProductModel productModel) {
    this.uid = productModel.uid;
    this.productId = productModel.productId;
    this.name = productModel.name;
    this.found = productModel.found;
    this.foundLocation = productModel.foundLocation;
    this.description = productModel.description;
    this.age = productModel.age;
    this.lastSeen = productModel.lastSeen;
    this.urls = productModel.urls;
  }
}
