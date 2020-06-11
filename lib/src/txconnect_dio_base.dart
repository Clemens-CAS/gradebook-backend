import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:html/parser.dart' show parse;

import 'txconnect_models.dart';

class TxConnect {
  Dio _dio;
  CookieJar _cookieJar;

  List<Student> _students;
  Student _currentStudent;
  List<Classroom> _classrooms;
  Attendance _attendance;
  List<Alert> _unreadAlerts;
  List<Alert> _readAlerts;

  Student get currentStudent => _currentStudent;

  TxConnect() {
    _dio = Dio();
    _cookieJar = CookieJar();

    _dio.options.baseUrl = 'https://txconnpa.esc13.net/PACB';
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 3000;
    _dio.options.followRedirects = false;
    _dio.options.validateStatus = (status) {
      return status < 500;
    };

    _dio.options.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36';
    _dio.options.contentType = Headers.formUrlEncodedContentType;

    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<bool> login(String username, String password) async {
    var response = await _dio.get('/Login.aspx');
    var document = parse(response.data);
    var data = FormData.fromMap({
      '__VIEWSTATE': document.getElementById('__VIEWSTATE').attributes['value'],
      '__VIEWSTATEGENERATOR':
          document.getElementById('__VIEWSTATEGENERATOR').attributes['value'],
      'ctl00\$Contentplaceholder\$lgnUserLogin\$UserName': username,
      'ctl00\$Contentplaceholder\$lgnUserLogin\$Password': password,
      'ctl00\$Contentplaceholder\$lgnUserLogin\$LoginButton': 'Log In',
      'ctl00\$Contentplaceholder\$hfMobileDevice': 'false',
    });
    response = await _dio.post('/Login.aspx', data: data);
    _dio.options.baseUrl = 'https://txconnpa.esc13.net/PACB/ParentAccess';
    response = await _dio.get('/Summary.aspx');
    return response.statusCode == 200;
  }

  Future<List<Student>> getStudents() async {
    if (_students != null) return _students;
    var studentList = <Student>[];
    var response = await _dio.get('/Summary.aspx');
    var document = parse(response.data);
    var names = document.querySelectorAll('div[id\$="ctiveStudent"]');
    var ids = document.querySelectorAll('input[id\$="StudentID"]');
    for (var i = 0; i < names.length; i++) {
      studentList.add(Student(
        ids[i]
            .attributes['id']
            .substring(21, ids[i].attributes['id'].lastIndexOf('_')),
        ids[i].attributes['value'],
        names[i].text.trim(),
      ));
    }
    return (_students = studentList);
  }

  Future<Student> switchStudent(String studentId) async {
    if (_currentStudent != null && _currentStudent.studentId == studentId) {
      return _currentStudent;
    }
    var student = _getStudentByWebId(studentId);
    var response = await _dio.get('/Summary.aspx');
    var document = parse(response.data);
    var data = {
      'ctl00\$Scriptmanager1':
          'ctl00\$UpdatePanel2|ctl00\$rptStudents\$ctl${student.studentId}\$lnbStudentName',
      '__EVENTTARGET':
          'ctl00\$rptStudents\$ctl${student.studentId}\$lnbStudentName',
      '__VIEWSTATE': document.getElementById('__VIEWSTATE').attributes['value'],
      '__VIEWSTATEGENERATOR':
          document.getElementById('__VIEWSTATEGENERATOR').attributes['value'],
      '__PREVIOUSPAGE':
          document.getElementById('__PREVIOUSPAGE').attributes['value'],
      '__ASYNCPOST': 'true',
    };
    _students.forEach((element) {
      data['ctl00\$rptStudents\$ctl${element.studentId}\$hdnStudentID'] =
          element.id;
    });
    var parsed = FormData.fromMap(data);
    await _dio.post('/Summary.aspx', data: parsed);
    return (_currentStudent = student);
  }

  Future<List<Classroom>> getClassrooms() async {
    if (_classrooms != null) return _classrooms;
    var classroomList = <Classroom>[];
    var response = await _dio.get('/Grades/Grades.aspx');
    var document = parse(response.data);
    var classroomRows = document
        .querySelectorAll('[summary="Cycle Grades Details"] tr[class=""]');
    for (var i = 0; i < classroomRows.length; i++) {
      var element = classroomRows[i];
      var teacherSpan =
          element.querySelector('span[style="white-space: nowrap"]');
      var email = teacherSpan.querySelector('a') != null
          ? teacherSpan.querySelector('a').attributes['href']
          : '';

      classroomList.add(Classroom(
        i.toString().padLeft(2, '0'),
        element.querySelector('span[id\$=SimplePeriod]').text.trim(),
        element.querySelector('span[id\$=Course]').text.trim(),
        teacherSpan.text.trim(),
        email != '' ? email.substring(7, email.length - 21) : '',
        element.querySelector('td[class~="current_cycle"]') != null
            ? element.querySelector('td[class~="current_cycle"]').text.trim()
            : '',
      ));
    }
    return (_classrooms = classroomList);
  }

  Future<Grades> getGrades(String classId) async {
    var grades = Grades();
    var response = await _dio.get('/Grades/Grades.aspx');
    var document = parse(response.data);
    var currentCycle = (int.parse(document
                .querySelector('th[class="current_cycle"]')
                .text
                .trim()) -
            1)
        .toString()
        .padLeft(2, '0');
    var data = {
      'ctl00\$Scriptmanager1':
          'ctl00\$UpdatePanel1|ctl00\$MainContent\$ctl02\$ctl01\$rptSchedule\$ctl${classId}\$rptCycles\ctl${currentCycle}\$lnbActiveCycleGrade',
      'ctl00\$MainContent\$ctl02\$ctl01\$ucScheduleSelector\$ddlSemester':
          document.querySelector('option[selected="selected"]').text.trim(),
      '__EVENTTARGET':
          'ctl00\$MainContent\$ctl02\$ctl01\$rptSchedule\$ctl${classId}\$rptCycles\$ctl${currentCycle}\$lnbActiveCycleGrade',
      '__VIEWSTATE': document.getElementById('__VIEWSTATE').attributes['value'],
      '__VIEWSTATEGENERATOR':
          document.getElementById('__VIEWSTATEGENERATOR').attributes['value'],
      '__ASYNCPOST': 'true',
    };
    _students.forEach((element) {
      data['ctl00\$rptStudents\$ctl${element.studentId}\$hdnStudentID'] =
          element.id;
    });
    var parsed = FormData.fromMap(data);
    response = await _dio.post('/Grades/Grades.aspx', data: parsed);
    document = parse(response.data);
    var isFormative = true;
    var tableRows = document
        .querySelectorAll('table[summary="Assignment details"] tbody tr');

    for (var i = 2; i < tableRows.length; i++) {
      var element = tableRows[i];
      if (element.querySelector('td[class="total_label"]') != null) {
        if (isFormative) {
          grades.formativeAverage =
              element.querySelector('td[class="value "]').text.trim();
        } else {
          grades.summativeAverage =
              element.querySelector('td[class="value "]').text.trim();
        }
        isFormative = false;
        continue;
      }
      if (element.querySelector('td[class="text assignment"]') == null) {
        continue;
      }
      var array = isFormative ? grades.formative : grades.summative;
      array.add(
        Assignment(
          element
              .querySelector('td[class="text assignment"]')
              .querySelector('div')
              .firstChild
              .text
              .trim(),
          element
              .querySelector('div[class="assignmentNotePopup"]')
              .querySelectorAll('p')[1]
              .text
              .trim(),
          element.querySelector('td[class="grade "]') != null
              ? element.querySelector('td[class="grade "]').text.trim()
              : '',
          element.querySelector('td[class="date_column"]') != null
              ? element.querySelector('td[class="date_column"]').text.trim()
              : '',
        ),
      );
    }
    return grades;
  }

  Future<Attendance> getAttendance() async {
    if (_attendance != null) return _attendance;
    var attendance = Attendance();
    var response = await _dio.get('/Attendance/Attendance.aspx');
    var document = parse(response.data);
    var data = {
      'ctl00\$Scriptmanager1':
          'ctl00\$UpdatePanel1|ctl00\$MainContent\$ctl02\$ctl01\$ucScheduleSelector\$ddlSemester',
      'ctl00\$MainContent\$ctl02\$ctl01\$ucScheduleSelector\$ddlSemester': 1,
      '__EVENTTARGET':
          'ctl00\$MainContent\$ctl02\$ctl01\$ucScheduleSelector\$ddlSemester',
      '__VIEWSTATE': document.getElementById('__VIEWSTATE').attributes['value'],
      '__VIEWSTATEGENERATOR':
          document.getElementById('__VIEWSTATEGENERATOR').attributes['value'],
      '__ASYNCPOST': 'true',
    };
    _students.forEach((element) {
      data['ctl00\$rptStudents\$ctl${element.studentId}\$hdnStudentID'] =
          element.id;
    });

    await _parseAttendance(data, attendance);
    data['ctl00\$MainContent\$ctl02\$ctl01\$ucScheduleSelector\$ddlSemester'] =
        2;
    await _parseAttendance(data, attendance);
    return (_attendance = attendance);
  }

  Future<List<Alert>> getAlerts(bool unread) async {
    if (unread) {
      if (_unreadAlerts != null) return _unreadAlerts;
    } else {
      if (_readAlerts != null) return _readAlerts;
    }

    var alerts = <Alert>[];
    var response = await _dio.get('/Alerts/Alerts.aspx');
    var document = parse(response.data);
    var data = {
      'ctl00\$Scriptmanager1':
          'ctl00\$UpdatePanel1|ctl00\$MainContent\$ctl00\$ctl01\$cbViewRead',
      'ctl00\$MainContent\$ctl00\$ctl01\$cbViewRead': 'on',
      '__EVENTTARGET': 'ctl00\$MainContent\$ctl00\$ctl01\$cbViewRead',
      '__VIEWSTATE': document.getElementById('__VIEWSTATE').attributes['value'],
      '__VIEWSTATEGENERATOR':
          document.getElementById('__VIEWSTATEGENERATOR').attributes['value'],
      '__ASYNCPOST': 'true',
    };
    _students.forEach((element) {
      data['ctl00\$rptStudents\$ctl${element.studentId}\$hdnStudentID'] =
          element.id;
    });
    var parsed = FormData.fromMap(data);
    response = await _dio.post('/Alerts/Alerts.aspx', data: parsed);
    document = parse(response.data);

    var entries = unread
        ? document.querySelectorAll('tr[class="unread"]')
        : document.querySelectorAll('tr[class="read"]');

    for (var entry in entries) {
      var cols = entry.querySelectorAll('td');
      var id = cols[2].querySelector('input').id;
      alerts.add(Alert(
        id.substring(43, id.length - 7),
        cols[0].text.trim(),
        cols[1].text.trim(),
        !unread,
      ));
    }

    if (unread) {
      _unreadAlerts = alerts;
    } else {
      _readAlerts = alerts;
    }

    return alerts;
  }

  Future<void> readAlert(String alertId) async {
    var response = await _dio.get('/Alerts/Alerts.aspx');
    var document = parse(response.data);
    var data = {
      'ctl00\$Scriptmanager1':
          'ctl00\$UpdatePanel1|ctl00\$MainContent\$ctl00\$ctl01\$rptAlerts\$ctl${alertId}\$cbRead',
      'ctl00\$MainContent\$ctl00\$ctl01\$cbViewRead': 'on',
      'ctl00\$MainContent\$ctl00\$ctl01\$rptAlerts\$ctl${alertId}\$cbRead':
          'on',
      '__EVENTTARGET':
          'ctl00\$MainContent\$ctl00\$ctl01\$rptAlerts\$ctl${alertId}\$cbRead',
      '__VIEWSTATE': document.getElementById('__VIEWSTATE').attributes['value'],
      '__VIEWSTATEGENERATOR':
          document.getElementById('__VIEWSTATEGENERATOR').attributes['value'],
      '__ASYNCPOST': 'true',
    };
    _students.forEach((element) {
      data['ctl00\$rptStudents\$ctl${element.studentId}\$hdnStudentID'] =
          element.id;
    });
    var parsed = FormData.fromMap(data);
    response = await _dio.post('/Alerts/Alerts.aspx', data: parsed);
  }

  //HELPER METHODS

  Future<void> _parseAttendance(
      Map<String, dynamic> data, Attendance attendance) async {
    var parsed = FormData.fromMap(data);
    var response = await _dio.post('/Attendance/Attendance.aspx', data: parsed);
    var document = parse(response.data);

    //DID NOT HAVE TO DO THIS ON TS VERSION (VIEWSTATE VARS IN INPUTS)
    var stateHidden = response.data
        .toString()
        .substring(response.data.indexOf('__VIEWSTATE') + 12);
    var genHidden =
        stateHidden.substring(stateHidden.indexOf('__VIEWSTATEGENERATOR') + 22);
    var viewstate = stateHidden.substring(0, stateHidden.indexOf('|'));
    var viewstategenerator = genHidden.substring(0, genHidden.indexOf('|'));

    data['__VIEWSTATE'] = viewstate;
    data['__VIEWSTATEGENERATOR'] = viewstategenerator;

    var entries = document.querySelectorAll('span[class="key_entry"]');
    for (var entry in entries) {
      var split = entry.text.trim().split(':');
      attendance.legend[split[0]] = split[1].trim();
    }

    var tableRows = document.querySelectorAll(
        'table[summary="Attendance  Course Information"] tbody tr');
    var header = document.querySelectorAll('th');
    var dates = <String>[];
    for (var i = 3; i < header.length; i++) {
      dates.add(header[i].text);
    }
    for (var i = 1; i < tableRows.length; i++) {
      var row = tableRows[i].querySelectorAll('td');
      for (var j = 3; j < row.length; j++) {
        var key = row[j].text.trim();
        if (key == '') continue;
        attendance.absences.add(Absence(
          _getClassroomByName(row[1].text.trim()).classId,
          dates[j - 3],
          key,
        ));
      }
    }
  }

  Classroom _getClassroomByName(String name) {
    return _classrooms.firstWhere((element) => element.name == name);
  }

  Student _getStudentByWebId(String webId) {
    return _students.firstWhere((element) => element.studentId == webId);
  }
}
