import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:untitled/Firebase/auth.dart';
import 'package:untitled/Pages/ThemeManager.dart';
import 'package:untitled/Pages/welcome.dart';
 // Import your ChatBot screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Handles user sign-out
  Future<void> signOut(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.signout(); // Attempt to sign out the user
      if (kDebugMode) {
        print('User signed out successfully');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } catch (e) {
      // Handle errors, such as network issues or sign-out failures
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      // Optionally, show a Snackbar or AlertDialog to notify the user about the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  // Displays the current user's email or a default text
  Widget _userid() {
    return Text(
      FirebaseAuth.instance.currentUser?.email ?? 'Hire Host',
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
    );
  }

  // Builds the Home Page with job listings
  Widget _buildHomePage(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('CompanyApplications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No applications found'));
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final jobTitle = item['jobTitle'] ?? 'N/A';
            final jobType = item['jobType'] ?? 'N/A';
            final location = item['location'] ?? 'N/A';

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context, '/details', arguments: {'companyId': item['id']},                       
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeManager.isDarkMode
                          ? [Color.fromARGB(255, 91, 89, 92), Colors.transparent]
                          : [Colors.transparent, Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/photo2.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeManager.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.work, size: 20, color: themeManager.isDarkMode ? Colors.white70 : Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              'Type: $jobType',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeManager.isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 20, color: themeManager.isDarkMode ? Colors.white70 : Colors.black54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Location: $location',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeManager.isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Placeholder for Search Page content
  Widget _buildSearchPage() {
    return Center(child: Text('Search Content', style: TextStyle(fontSize: 20)));
  }

  // Placeholder for Profile Page content
  Widget _buildProfilePage() {
    return Center(child: Text('Profile Content', style: TextStyle(fontSize: 20)));
  }

  // Placeholder for Settings Page content
  Widget _buildSettingsPage() {
    return Center(child: Text('Settings Content', style: TextStyle(fontSize: 20)));
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    final List<Widget> _pages = [
      _buildHomePage(context), // Firebase data fetching page
      _buildSearchPage(),
      _buildProfilePage(),
      _buildSettingsPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: themeManager.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Image.asset(
            'assets/robot.gif', // Replace with your logo
            height: 40,
            width: 40,
          ),
        ),
        title: Text(
          'Hire Host',
          style: TextStyle(
            color: themeManager.isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // Open the drawer when the menu button is pressed.
            },
            icon: Icon(
              Icons.menu,
              color: themeManager.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      drawer: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.7, // Set to 0.7 for 70% of screen width
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeManager.isDarkMode
                    ?  [Color.fromARGB(255, 119, 73, 184), const Color.fromARGB(255, 77, 12, 176)]
                    : [Color.fromARGB(255, 247, 245, 245), const Color.fromARGB(255, 255, 255, 255)]
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/robot.gif'), // Replace with your logo or user image
                        ),
                        const SizedBox(height: 12),
                        _userid(),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: themeManager.isDarkMode ? Colors.white : Colors.black),
                    title: const Text("Hire a Host"),
                    onTap: () {
                      Navigator.pushNamed(context, '/page2'); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.post_add, color: themeManager.isDarkMode ? Colors.white : Colors.black),
                    title: const Text("Apply for Job"),
                    onTap: () {
                      Navigator.pushNamed(context, '/'); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.help, color: themeManager.isDarkMode ? Colors.white : Colors.black),
                    title: const Text("Help & Support"),
                    onTap: () {
                      Navigator.pushNamed(context, '/help'); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.brightness_6, color: themeManager.isDarkMode ? Colors.white : Colors.black),
                    title: const Text("Dark Mode"),
                    trailing: Switch(
                      value: themeManager.isDarkMode,
                      onChanged: (bool value) {
                        themeManager.toggleTheme();
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: themeManager.isDarkMode ? Colors.white : Colors.black),
                    title: const Text("Sign Out"),
                    onTap: () {
                      signOut(context);
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: null,
      body: Padding(
        padding: const EdgeInsets.only(top: 120.0), // Adjust the top padding as needed
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeManager.isDarkMode
                  ?  [Color.fromARGB(255, 0, 0, 0), const Color.fromARGB(255, 0, 0, 0)]
                  : [Color.fromARGB(255, 247, 245, 245), const Color.fromARGB(255, 255, 255, 255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = 0; // Update the active tab index
          });
          if (index == 0) {
            // Home page already selected
          } else if (index == 1) {
            Navigator.pushNamed(context, '/search');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/page2');
          } else if (index == 4) {
            // Open the ChatBot screen
            Navigator.pushNamed(
              context,
               '/chatbot',
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Create CV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Hire a Host',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ChatBot',
          ),
        ],
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: themeManager.isDarkMode ? Colors.transparent : Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
