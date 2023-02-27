import 'package:flutter/material.dart';

class DatabaseService{
  static final DatabaseService _instance = DatabaseService._internal();

  GlobalKey? chatKey;
  GlobalKey? newsKey;
  GlobalKey? transcriptKey;
  GlobalKey? profileKey;



  factory DatabaseService(){
    return _instance;
  }

  DatabaseService._internal();

}