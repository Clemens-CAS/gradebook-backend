class Student {
  String studentId;
  String id;
  String name;

  Student(this.studentId, this.id, this.name);

  @override
  String toString() {
    return 'Student{WEB_ID: $studentId, ID: $id, NAME: $name}';
  }
}

class Classroom {
  String classId;
  String period;
  String name;
  String teacher;
  String email;
  String totalAverage;

  Classroom(this.classId, this.period, this.name, this.teacher, this.email,
      this.totalAverage);

  @override
  String toString() {
    return 'Classroom{ID: $classId, PERIOD: $period, NAME: $name, TEACHER: $teacher, EMAIL: $email, TOTAL AVERAGE: $totalAverage}';
  }
}

class Assignment {
  String name;
  String note;
  String grade;
  String date;

  Assignment(this.name, this.note, this.grade, this.date);

  @override
  String toString() {
    return '<Assigment>{ NAME: $name, NOTE: $note, GRADE: $grade, DATE: $date }';
  }
}

class Grades {
  List<Assignment> summative = [];
  List<Assignment> formative = [];
  String summativeAverage;
  String formativeAverage;

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write('Formative ($formativeAverage):');
    for (var assigment in formative) {
      buffer.write('\n\t$assigment');
    }

    buffer.write('\n\nSummative ($summativeAverage):');
    for (var assigment in summative) {
      buffer.write('\n\t$assigment');
    }

    return buffer.toString();
  }
}

class Absence {
  String classId;
  String date;
  String key;

  Absence(this.classId, this.date, this.key);

  @override
  String toString() {
    return '<Absence>{ CLASS_ID: $classId, DATE: $date, KEY:$key }';
  }
}

class Attendance {
  Map<String, String> legend = {};
  List<Absence> absences = [];

  @override
  String toString() {
    var buffer = StringBuffer();

    buffer.write('Legend: ');
    for (var pair in legend.entries) {
      buffer.write('\n\t${pair.key}: ${pair.value}');
    }

    buffer.write('\n\nAbsences: ');
    for (var absence in absences) {
      buffer.write('\n\t$absence');
    }

    return buffer.toString();
  }
}

class Alert {
  String alertId;
  String date;
  String description;
  bool read;

  Alert(this.alertId, this.date, this.description, this.read);

  @override
  String toString() {
    return '<Alert>{ ALERT_ID: $alertId, DATE: $date, DESCIPTION: $description, READ: $read }';
  }
}
