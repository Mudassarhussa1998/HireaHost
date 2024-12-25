import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {

  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely extracting arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Check if the arguments are valid and contain the 'companyId'
    final companyId = args?['companyId'];

    if (kDebugMode) {
      print('Company ID: $companyId');
    }

    if (companyId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No Company ID provided.')),
      );
    }

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Company Details'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
       
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchCompanyDetails(companyId), // Fetch data using companyId
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
                  // Company Profile Section
                  _buildCompanyProfile(data),

                  // Company Details Section
                  _buildSection(
                    title: 'Company Details',
                    content: _buildCompanyDetails(data),
                  ),

                  // Jobs Section
                  _buildSection(
                    title: 'Job Details',
                    content: _buildJobDetails(data),
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

  // Fetch company details from Firestore
  Future<Map<String, dynamic>> fetchCompanyDetails(String companyId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('CompanyApplications') // Correct collection name
          .doc(companyId) // Fetch by companyId
          .get();

      if (!doc.exists) {
        throw Exception('No data found for company ID: $companyId');
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch company details: $e');
    }
  }

  // Build the company profile UI
  Widget _buildCompanyProfile(Map<String, dynamic> data) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/photo1.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Text(
            data['companyName'] ?? 'Unknown Company',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail, color: Colors.white70),
              Text(
                data['companyWebsite'] ?? 'email',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['location'] ?? 'email',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Create a reusable section with title and content
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

  // Build company details list
  Widget _buildCompanyDetails(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildListTile('Company Name', data['companyName']),
        _buildListTile('Company Website', data['companyWebsite']),
        _buildListTile('Location', data['location']),
        _buildListTile('Industry', data['industry']),
        _buildListTile('Founded', data['founded']),
      ],
    );
  }

  // Build job details section
  Widget _buildJobDetails(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildListTile('Job Title', data['jobTitle']),
        _buildListTile('Job Description', data['jobDescription']),
        _buildListTile('Experience Required', data['experience']),
        _buildListTile('Salary', data['salary']),
        _buildListTile('Location', data['location']),
        _buildListTile('Benefits', data['benefits']),
        _buildListTile('Application Deadline', data['applicationDeadline']),
        _buildListTile('Job Type', data['jobType']),
        _buildListTile('Skills', data['skills']?.join(', ') ?? 'N/A'),
        _buildListTile('Education', data['education']?.join(', ') ?? 'N/A'),
        _buildListTile('Qualifications', data['qualifications']?.join(', ') ?? 'N/A'),
      ],
    );
  }

  // Build a single list tile with title and subtitle
  Widget _buildListTile(String label, dynamic value) {
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
          value?.toString() ?? 'N/A',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
