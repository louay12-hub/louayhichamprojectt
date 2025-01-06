import 'package:flutter/material.dart';

class PassedPage extends StatelessWidget {
  final List<dynamic> grades;
  final String username;

  const PassedPage({Key? key, required this.grades, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter grades for the given username
    final filteredGrades =
        grades.where((grade) => grade['username'] == username).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Grades for $username"),
      ),
      body: filteredGrades.isNotEmpty
          ? ListView.builder(
              itemCount: filteredGrades.length,
              itemBuilder: (context, index) {
                final grade = filteredGrades[index];
                return ListTile(
                  title: Text(
                      "${grade['course']} (${grade['year']})"),
                  subtitle: Text(
                      "Grade: ${grade['grade']}, Section: ${grade['section']}"),
                );
              },
            )
          : const Center(
              child: Text("No grades available for this user."),
            ),
    );
  }
}
