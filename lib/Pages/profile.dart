import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dynamic CV Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _CVFormState createState() => _CVFormState();
}

class _CVFormState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  // Basic Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Dynamic fields
  final _jobTitleControllers = [TextEditingController()];
  final _introductionControllers = [TextEditingController()];
  final _experienceControllers = [TextEditingController()];
  final _languageControllers = [TextEditingController()];
  final _certificateControllers = [TextEditingController()];

  // Education Section
  final List<Map<String, dynamic>> _educationEntries = [
    {
      'institution': TextEditingController(),
      'startYear': TextEditingController(),
      'endYear': TextEditingController(),
      'isOngoing': false,
    }
  ];

  // Contact Me
  final _whatsappController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _facebookController = TextEditingController();

  // Add a new education entry
  void _addEducationEntry() {
    setState(() {
      _educationEntries.add({
        'institution': TextEditingController(),
        'startYear': TextEditingController(),
        'endYear': TextEditingController(),
        'isOngoing': false,
      });
    });
  }

  // Remove an education entry
  void _removeEducationEntry(int index) {
    setState(() {
      if (_educationEntries.length > 1) {
        _educationEntries.removeAt(index);
      }
    });
  }

  // Submit data to Firestore
  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('jobApplications').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'jobTitle': _jobTitleControllers.map((c) => c.text).toList(),
          'introduction': _introductionControllers.map((c) => c.text).toList(),
          'education': _educationEntries.map((entry) {
            return {
              'institution': entry['institution'].text,
              'startYear': entry['startYear'].text,
              'endYear': entry['isOngoing']
                  ? 'Expected ${entry['endYear'].text}'
                  : entry['endYear'].text,
            };
          }).toList(),
          'experience': _experienceControllers.map((c) => c.text).toList(),
          'languages': _languageControllers.map((c) => c.text).toList(),
          'certificates': _certificateControllers.map((c) => c.text).toList(),
          'contact': {
            'whatsapp': _whatsappController.text,
            'linkedin': _linkedinController.text,
            'github': _githubController.text,
            'facebook': _facebookController.text,
          },
          'timestamp': FieldValue.serverTimestamp(),
          
        });
        

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV submitted successfully!')),
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _jobTitleControllers.clear();
          _introductionControllers.clear();
          _experienceControllers.clear();
          _languageControllers.clear();
          _certificateControllers.clear();
          _educationEntries.clear();

          _jobTitleControllers.add(TextEditingController());
          _introductionControllers.add(TextEditingController());
          _experienceControllers.add(TextEditingController());
          _languageControllers.add(TextEditingController());
          _certificateControllers.add(TextEditingController());
          _educationEntries.add({
            'institution': TextEditingController(),
            'startYear': TextEditingController(),
            'endYear': TextEditingController(),
            'isOngoing': false,
          });

          Navigator.pushReplacementNamed(context, '/home'); 
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting CV: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Your CV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Basic Info
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value == null || value.isEmpty ? 'Enter your phone number' : null,
              ),

              _buildDynamicSection('Job Title/Designation', _jobTitleControllers),
              _buildDynamicSection('Introduction Paragraph', _introductionControllers),
              _buildEducationSection(),
              _buildDynamicSection('Experience', _experienceControllers),
              _buildDynamicSection('Languages', _languageControllers),
              _buildDynamicSection('Certificates', _certificateControllers),

              // Contact Me
              const Text('Contact Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'WhatsApp'),
                validator: (value) => value == null || value.isEmpty ? 'Enter WhatsApp contact' : null,
              ),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn'),
                validator: (value) => value == null || value.isEmpty ? 'Enter LinkedIn profile' : null,
              ),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(labelText: 'GitHub'),
                validator: (value) => value == null || value.isEmpty ? 'Enter GitHub profile' : null,
              ),
              TextFormField(
                controller: _facebookController,
                decoration: const InputDecoration(labelText: 'Facebook'),
                validator: (value) => value == null || value.isEmpty ? 'Enter Facebook profile' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Submit CV'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build dynamic sections
  Widget _buildDynamicSection(String title, List<TextEditingController> controllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(labelText: '$title ${index + 1}'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter $title ${index + 1}' : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => setState(() => controllers.removeAt(index)),
              ),
            ],
          );
        }),
        TextButton(
          onPressed: () => setState(() => controllers.add(TextEditingController())),

          child: Text('Add More $title'),

        ),
      ],
    );
  }

  // Build dynamic education section
  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._educationEntries.asMap().entries.map((entry) {
          int index = entry.key;
          var education = entry.value;

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: education['institution'],
                      decoration: InputDecoration(labelText: 'Institution ${index + 1}'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter institution' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeEducationEntry(index),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: education['startYear'],
                      decoration: const InputDecoration(labelText: 'Start Year'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter start year' : null,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: education['endYear'],
                      decoration: InputDecoration(
                        labelText: education['isOngoing']
                            ? 'Expected Completion Year'
                            : 'End Year',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter year' : null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: education['isOngoing'],
                    onChanged: (value) {
                      setState(() {
                        education['isOngoing'] = value ?? false;
                      });
                    },
                  ),
                  const Text('Currently Studying'),
                ],
              ),
            ],
          );
        }),
        TextButton(
          onPressed: _addEducationEntry,
          
          child: const Text('Add More Education'),
        ),
      ],
    );
  }
}