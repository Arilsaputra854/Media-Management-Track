import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget LoadingWidget(String text) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.stretchedDots(color: Colors.black, size: 100),
          Text(text, style: TextStyle(color: Colors.black)),
        ],
      ),
    ),
  );
}
