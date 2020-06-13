import 'package:html/parser.dart';
import 'package:txconnect/src/txconnect_models.dart';

Map<String, dynamic> parse(Alert alert) {
  String simpleTitle;
  String simpleMessage;
  var simpleDate = alert.date.replaceAll('/', '.');

  //Class Average
  if (alert.description.startsWith('Student\'s current average')) {
    var message =
        alert.description.substring(alert.description.indexOf('in') + 2);
    simpleTitle = message.substring(0, message.indexOf('fell')).trim();
    simpleMessage = 'average ' +
        message.substring(message.indexOf('fell'), message.indexOf('.')).trim();
  } else if (alert.description.startsWith(RegExp(r'Student received a \d+'))) {
    var message =
        alert.description.substring(alert.description.indexOf('a') + 1);
    simpleTitle = message
        .substring(message.indexOf('in') + 2, message.indexOf('.'))
        .trim();
    simpleMessage =
        message.substring(0, message.indexOf('on')).trim() + ' on assignment';
  } else if (alert.description.contains('in period')) {
    var message = alert.description
        .substring(alert.description.indexOf(RegExp(r'an?')) + 2)
        .trim();
    simpleTitle =
        message.substring(0, message.indexOf(' ')).trim().toUpperCase();
    simpleMessage =
        message.substring(0, message.indexOf('.')).trim().toLowerCase();
  }

  return {
    'alert': alert,
    'simpleTitle': simpleTitle,
    'simpleMessage': simpleMessage,
    'simpleDate': simpleDate,
  };
}
