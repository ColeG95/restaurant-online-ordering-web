import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:order_online/models/docRefPath.dart';

enum OrderType {
  pickup,
  delivery,
}

enum Restaurant {
  bennys,
  thai_gourmet,
  vitos,
}

const Color themeColor = Colors.blue;

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> indexedMap<T>(T Function(E element, int index) f) {
    var index = 0;
    return map((e) => f(e, index++));
  }
}

String encryptString(String value) {
  return base64.encode(utf8.encode(value));
}

String decryptString(String value) {
  return utf8.decode(base64.decode(value));
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String deleteNumbersFromString(String str) {
  var nums = str.replaceAll(RegExp(r'[^0-9]'), '');
  return str.replaceAll(nums, '').trimLeft().trimRight();
}

DocRefPath getDocRefFromPath(String path) {
  var newPath = '/$path/';
  int forwardSlashes = '/'.allMatches(newPath).length;
  double layers = (forwardSlashes - 1) / 2;
  List<String> collectionNames = [];
  List<String> documentIds = [];
  for (var i = 0; i < layers; i++) {
    var firstSlashIndex = newPath.indexOf('/', 1);
    var collection = newPath.substring(1, firstSlashIndex);
    collectionNames.add(collection);
    newPath = newPath.replaceFirst('/$collection', '');
    var secondSlashIndex = newPath.indexOf('/', 1);
    var document = newPath.substring(1, secondSlashIndex);
    documentIds.add(document);
    newPath = newPath.replaceFirst('/$document', '');
  }
  return DocRefPath(
    collections: collectionNames,
    documentIds: documentIds,
  );
}

const stripePK =
    'pk_test_51KEeCIBgY0JJ7xyNEwDtIrLSVpmmTPPEqDFGFodtn1BYZRkVy3GtbzSKDF7LGk28B5ZXnGrJzSR7SeMFlM3GkQd700fO7xrieF';
