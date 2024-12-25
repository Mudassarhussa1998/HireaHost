import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const JobVacancyApp());
}

class JobVacancyApp extends StatelessWidget {
  const JobVacancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Vacancy Form',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF6F8FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const JobVacancyScreen(),
    );
  }
}

class JobVacancyScreen extends StatefulWidget {
  const JobVacancyScreen({super.key});

  @override
  _JobVacancyScreenState createState() => _JobVacancyScreenState();
}

class _JobVacancyScreenState extends State<JobVacancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  String _locationDetails = "";
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  final _applicationDeadlineController = TextEditingController();
  String _jobType = "Full-time";

  final List<TextEditingController> _skillsControllers = [];
  final List<TextEditingController> _educationControllers = [];
  final List<TextEditingController> _qualificationsControllers = [];

  final List<String> _jobTypes = ["Full-time", "Part-time", "Contract", "Internship", "Freelance"];

  final String _openCageApiKey = "061789803bcf4cddb2323fd10060d891";

  Future<void> _selectLocationFromMap() async {
    LatLng? selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(),
      ),
    );

    if (selectedPosition != null) {
      final url =
          "https://api.opencagedata.com/geocode/v1/json?q=${selectedPosition.latitude}+${selectedPosition.longitude}&key=$_openCageApiKey";

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final formattedAddress = data['results'][0]['formatted'];
          setState(() {
            _locationDetails = formattedAddress;
          });
          _locationController.text = formattedAddress;
        } else {
          throw Exception('Failed to fetch location');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
    }
  }

  void _addDynamicField(List<TextEditingController> controllers) {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeDynamicField(int index, List<TextEditingController> controllers) {
    setState(() {
      controllers.removeAt(index);
    });
  }

  Future<void> _submitJobVacancy() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('CompanyApplications').add({
          'jobTitle': _jobTitleController.text,
          'jobDescription': _jobDescriptionController.text,
          'experience': _experienceController.text,
          'salary': _salaryController.text,
          'location': _locationController.text,
          'benefits': _benefitsController.text,
          'companyName': _companyNameController.text,
          'companyWebsite': _companyWebsiteController.text,
          'applicationDeadline': _applicationDeadlineController.text,
          'jobType': _jobType,
          'skills': _skillsControllers.map((controller) => controller.text).toList(),
          'education': _educationControllers.map((controller) => controller.text).toList(),
          'qualifications': _qualificationsControllers.map((controller) => controller.text).toList(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job vacancy posted successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _jobType = "Full-time";
          _skillsControllers.clear();
          _educationControllers.clear();
          _qualificationsControllers.clear();
          Navigator.pushNamed(context, '/home');
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting job vacancy: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job Vacancy'),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildTextFormField(_jobTitleController, 'Job Title', 'Please enter a job title'),
                _buildTextFormField(_jobDescriptionController, 'Job Description', 'Please enter a job description', maxLines: 3),
                _buildTextFormField(_experienceController, 'Experience Requirements', 'Please enter the required experience'),
                _buildTextFormField(_salaryController, 'Salary (Optional)', null, keyboardType: TextInputType.number),
                Row(
                 children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on, color: Colors.indigo),
                            onPressed: () async {
                              await _selectLocationFromMap();
                            },
                          ),
                        ),
                        readOnly: true, // Prevent manual editing, only allow selection
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter the job location' : null,
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _jobType,
                  decoration: const InputDecoration(labelText: 'Job Type'),
                  items: _jobTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _jobType = value!),
                ),
                ..._dynamicFieldSection('Skills', _skillsControllers),
                ..._dynamicFieldSection('Education', _educationControllers),
                ..._dynamicFieldSection('Qualifications', _qualificationsControllers),
                _buildTextFormField(_benefitsController, 'Benefits (Optional)', null),
                _buildTextFormField(_companyNameController, 'Company Name', 'Please enter the company name'),
                _buildTextFormField(_companyWebsiteController, 'Company Website (Optional)', null),
                _buildTextFormField(
                  _applicationDeadlineController,
                  'Application Deadline (YYYY-MM-DD)',
                  'Please enter the application deadline',
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitJobVacancy,
                    child: const Text('Post Job Vacancy', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, String? validationMessage,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validationMessage != null
            ? (value) => value == null || value.isEmpty ? validationMessage : null
            : null,
      ),
    );
  }

  List<Widget> _dynamicFieldSection(String title, List<TextEditingController> controllers) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.indigo),
            onPressed: () => _addDynamicField(controllers),
          ),
        ],
      ),
      for (int i = 0; i < controllers.length; i++)
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(controllers[i], '$title ${i + 1}', 'Please enter $title'),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeDynamicField(i, controllers),
            ),
          ],
        ),
    ];
  }
}
class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _openCageApiKey = "061789803bcf4cddb2323fd10060d891";
  List<Map<String, dynamic>> _searchResults = [];

  void _searchLocation(String query) async {
    if (query.isEmpty) return;

    final url = "https://api.opencagedata.com/geocode/v1/json?q=$query&key=$_openCageApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = (data['results'] as List)
              .map((result) => {
                    'formatted': result['formatted'],
                    'lat': result['geometry']['lat'],
                    'lng': result['geometry']['lng'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching search results: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(37.7749, -122.4194),
                minZoom: 13.0,
                onTap: (tapPosition, point) {
                  Navigator.pop(context, point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                      ),
              ],
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result['formatted']),
                    onTap: () {
                      final point = LatLng(result['lat'], result['lng']);
                      Navigator.pop(context, point);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
