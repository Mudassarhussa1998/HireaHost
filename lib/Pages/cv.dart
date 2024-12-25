// ignore_for_file: use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CVScreen extends StatelessWidget {
  const CVScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final employeeId = args?['employeeId'];

    if (employeeId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No Employee ID provided.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee CV'),
        backgroundColor:  Colors.purple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEmployeeData(employeeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Section
                  _buildProfileSection(data),

                  // Personal Information
                  _buildSection(
                    title: 'Personal Information',
                    content: _buildPersonalInfo(data),
                  ),

                  // Job Titles
                  _buildSection(
                    title: 'Job Titles',
                    content: _buildList(data['jobTitle'] ?? [], 'Job Title'),
                  ),

                  // Introduction
                  _buildSection(
                    title: 'Introduction',
                    content: _buildList(data['introduction'] ?? [], 'Introduction'),
                  ),

                  // Education
                  _buildSection(
                    title: 'Education',
                    content: _buildEducation(data['education'] ?? []),
                  ),

                  // Experience
                  _buildSection(
                    title: 'Experience',
                    content: _buildList(data['experience'] ?? [], 'Experience'),
                  ),

                  // Languages
                  _buildSection(
                    title: 'Languages',
                    content: _buildList(data['languages'] ?? [], 'Language'),
                  ),

                  // Certificates
                  _buildSection(
                    title: 'Certificates',
                    content: _buildList(data['certificates'] ?? [], 'Certificate'),
                  ),

                  // Contact Information
                  _buildSection(
                    title: 'Contact Information',
                    content: _buildContactInfo(data['contact']),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchEmployeeData(String employeeId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('jobApplications')
          .doc(employeeId)
          .get();

      if (!doc.exists) {
        throw Exception('No data found for employee ID: $employeeId');
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch employee data: $e');
    }
  }

  Widget _buildProfileSection(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color:  Colors.purple,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/robot.gif'),
          ),
          const SizedBox(height: 10),
          Text(
            data['name'] ?? 'Unknown',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data['jobTitle']?.join(', ') ?? 'No job title',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconText(Icons.email, data['email'] ?? 'N/A'),
              const SizedBox(width: 20),
              _buildIconText(Icons.phone, data['phone'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(Map<String, dynamic> data) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildListTile('Name', data['name']),
        _buildListTile('Email', data['email']),
        _buildListTile('Phone', data['phone']),
      ],
    );
  }

  Widget _buildEducation(List<dynamic> educationList) {
    return Column(
      children: educationList.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListTile('Institution', entry['institution']),
            _buildListTile('Start Year', entry['startYear']),
            _buildListTile('End Year', entry['endYear']),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo(Map<String, dynamic>? contact) {
    if (contact == null) return const Text('No contact information available');
    return Column(
      children: [
        _buildListTile('WhatsApp', contact['whatsapp']),
        _buildListTile('LinkedIn', contact['linkedin']),
        _buildListTile('GitHub', contact['github']),
        _buildListTile('Facebook', contact['facebook']),
      ],
    );
  }

  Widget _buildList(List<dynamic> items, String label) {
    return Column(
      children: items.map((item) => _buildListTile(label, item)).toList(),
    );
  }

  Widget _buildListTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value ?? 'N/A',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
