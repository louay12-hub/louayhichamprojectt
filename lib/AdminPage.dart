import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PassedPage.dart';

class AdminPage extends StatefulWidget {
  final String username;
  const AdminPage({super.key, required this.username});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? selectedStudent;
  String? selectedGrade;
  String? selectedCourse;
  String? selectedYear;
  String? selectedSection;

  List<String> usernames = [];
  List<dynamic> gradesData = [];
  final List<String> grades = ["A", "B", "C", "D", "F"];
  final List<String> courses = ["Math", "Science", "History", "English"];
  final List<String> years = ["2023", "2024", "2025"];
  final List<String> sections = ["A", "B", "C", "D"];

  @override
  void initState() {
    super.initState();
    fetchUsernames();
    fetchGrades();
  }

  Future<void> fetchUsernames() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.15.98/Hisham/username.php'));
      if (response.statusCode == 200) {
        setState(() {
          usernames = List<String>.from(json.decode(response.body))
              .where((username) => username != "admin")
              .toSet()
              .toList(); // Ensure uniqueness by converting to a Set
        });
      } else {
        print("Failed to fetch usernames.");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> fetchGrades() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.15.98/Hisham/fetchgrade.php'));
      if (response.statusCode == 200) {
        setState(() {
          gradesData = json.decode(response.body);
        });
      } else {
        print("Failed to fetch grades.");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  int calculateGradePoint(String grade) {
    switch (grade) {
      case "A":
        return 4;
      case "B":
        return 3;
      case "C":
        return 2;
      case "D":
        return 1;
      case "F":
        return 0;
      default:
        return 0;
    }
  }

  Future<void> addGrade() async {
    if (selectedStudent != null &&
        selectedGrade != null &&
        selectedCourse != null &&
        selectedYear != null &&
        selectedSection != null) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.15.98/Hisham/addgrade.php'),
          body: {
            'student': selectedStudent!,
            'grade': selectedGrade!,
            'course': selectedCourse!,
            'year': selectedYear!,
            'section': selectedSection!,
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            print("Grade added successfully.");
            fetchGrades();
          } else {
            print("Failed to add grade: ${responseData['message']}");
          }
        } else {
          print("Error connecting to the server.");
        }
      } catch (e) {
        print("An error occurred: $e");
      }
    } else {
      print("Please fill in all fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Welcome, ${widget.username}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedStudent,
                hint: const Text("Select Username"),
                items: usernames.map((username) {
                  return DropdownMenuItem(
                    value: username,
                    child: Text(username),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStudent = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                hint: const Text("Select Grade"),
                items: grades.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGrade = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCourse,
                hint: const Text("Select Course"),
                items: courses.map((course) {
                  return DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourse = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedYear,
                hint: const Text("Select Year"),
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedSection,
                hint: const Text("Select Section"),
                items: sections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSection = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addGrade,
                child: const Text("Add Grade"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: gradesData.length,
                  itemBuilder: (context, index) {
                    final item = gradesData[index];
                    final gradePoint = calculateGradePoint(item['grade']);
                    return ListTile(
                      title: Text(
                          "${item['username']} - ${item['course']} (${item['year']})"),
                      subtitle: Text(
                          "Grade: ${item['grade']} (Points: $gradePoint), Section: ${item['section']}"),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassedPage(username: "",grades: gradesData),
                    ),
                  );
                },
                child: const Text("Go to PassedPage"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
