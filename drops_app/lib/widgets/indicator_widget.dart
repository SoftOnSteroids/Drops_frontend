import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Choose the right progress indicator according to the platform
Widget getIndicatorWidget(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return const CupertinoActivityIndicator();
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
    default:
      return const CircularProgressIndicator();
  }
}