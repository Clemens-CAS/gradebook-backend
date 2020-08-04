## txConnect API
An Unoffical API for txConnect SCUC.
https://pub.dev/packages/txconnect

## Usage

A simple usage example:

```dart
import 'package:txconnect/txconnect.dart';

void main(List<String> args) async {
  var tx = TxConnect();
  //Switch with your username and password. Returns boolean.
  print(await tx.login('username', 'password'));
  
  //Returns list of student and corresponding IDs
  print(await tx.getStudents());
  
  //Returns current student
  print(await tx.switchStudent('00'));
  
  //Returns list of classes
  print(await tx.getClassrooms());
  
  //Returns list of grades for class ID
  print(await tx.getGrades('02'));
  
  //Returns list of attendance
  print(await tx.getAttendance());
  
  //Returns alerts. Set to true if you want to include read alerts
  print(await tx.getAlerts(true));
  
  //Set alert to read
  await tx.readAlert('13');
}
```

## Features

Basic features including attendance, grades and classes, and alerts.

## Expansion

Post an issue if you would like to expand this project to multiple districts.
