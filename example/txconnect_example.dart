import 'package:txconnect/txconnect.dart';

void main(List<String> args) async {
  var tx = TxConnect();
  //Switch with your username and password
  print(await tx.login('username', 'password'));
  print(await tx.getStudents());
  print(await tx.switchStudent('00'));
  print(await tx.getClassrooms());
  print(await tx.getGrades('02'));
  print(await tx.getAttendance());
  print(await tx.getAlerts(true));
  // await tx.readAlert('13');
}
