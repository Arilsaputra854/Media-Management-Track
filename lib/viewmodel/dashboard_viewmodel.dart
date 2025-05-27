import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/user.dart';

class DashboardViewmodel extends ChangeNotifier{
  User? _currentUser = null;
  User? get currentUser => _currentUser;
  BuildContext context;

  DashboardViewmodel(this.context);
  void init(){

    if(_currentUser == null){
        context.go('/login');
    } 
  }

}