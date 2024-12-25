// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final TextEditingController searchController;
  final String query; // The query passed from the other page
  const SearchPage({super.key, required this.searchController, required this.query});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isEmployeeSelected = true;
  List<Map<String, dynamic>> allEmployees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  List<Map<String, dynamic>> allCompanies = [];
  List<Map<String, dynamic>> filteredCompanies = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize the search text field with the passed query
    widget.searchController.text = widget.query;
    widget.searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), filterResults);
    });
    fetchInitialData();
    filterResults(); // Call this to filter results based on the passed query
  }

  // Fetch initial data from Firestore
  void fetchInitialData() async {
    try {
      var employeeSnapshot = await FirebaseFirestore.instance.collection('jobApplications').get();
      var employeeList = employeeSnapshot.docs.map((doc) {
        return {
          "id": doc.id, // Include the document ID
          "name": doc['name'],
          "location": doc['contact']?['location'] ?? "N/A",
          "phone": doc['phone'],
          "email": doc['email'],
          "jobTitle": doc['jobTitle'] ?? [],
        };
      }).toList();

      await Future.delayed(const Duration(seconds: 0));

      var companySnapshot = await FirebaseFirestore.instance.collection('CompanyApplications').get();
      var companyList = companySnapshot.docs.map((doc) {
        return {
          "id": doc.id, // Include the document ID
          "companyName": doc['companyName'],
          "location": doc['location'],
        };
      }).toList();

      setState(() {
        allEmployees = employeeList;
        filteredEmployees = List.from(allEmployees);
        allCompanies = companyList;
        filteredCompanies = List.from(allCompanies);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    }
  }

  // Filter results based on search query
  void filterResults() {
    String query = widget.searchController.text.toLowerCase();

    setState(() {
      if (isEmployeeSelected) {
        filteredEmployees = allEmployees.where((employee) {
          return employee['name']!.toLowerCase().contains(query) ||
                 employee['location']!.toLowerCase().contains(query);
        }).toList();
      } else {
        filteredCompanies = allCompanies.where((company) {
          return company['companyName']!.toLowerCase().contains(query) ||
                 company['location']!.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          "Search",
          style: TextStyle(
            fontSize: 24,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: widget.searchController, // Use the passed controller
                        decoration: InputDecoration(
                          hintText: isEmployeeSelected ? "Search Employees" : "Search Companies",
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Toggle between Employee and Company
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isEmployeeSelected = true;
                        filterResults();
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isEmployeeSelected
                            ? Colors.purple
                            : isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Employee",
                        style: TextStyle(
                          color: isEmployeeSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isEmployeeSelected = false;
                        filterResults();
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: !isEmployeeSelected
                            ?  Colors.purple
                            : isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Company",
                        style: TextStyle(
                          color: !isEmployeeSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular ${isEmployeeSelected ? 'Employees' : 'Companies'}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add "View all" functionality here
                  },
                  child: const Text(
                    "Filter",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            ),
            Expanded(
              child: filteredEmployees.isEmpty && isEmployeeSelected ||
                      filteredCompanies.isEmpty && !isEmployeeSelected
                  ? Center(
                      child: Text(
                        "No ${isEmployeeSelected ? 'employees' : 'companies'} found.",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: isEmployeeSelected
                          ? filteredEmployees.length
                          : filteredCompanies.length,
                      itemBuilder: (context, index) {
                        var item = isEmployeeSelected
                            ? filteredEmployees[index]
                            : filteredCompanies[index];
                        return GestureDetector(
                          onTap: () {
                            if (isEmployeeSelected) {
                              if (kDebugMode) {
                                print('Employee ID: ${item['id']}');
                              }
                              Navigator.pushNamed(
                                context,
                                '/cv',
                                arguments: {'employeeId': item['id']},
                              );
                            } else {
                              // Navigate to Company Details page and pass company ID
                              if (kDebugMode) {
                                print('companyid: ${item['id']}');
                              }
                              Navigator.pushNamed(
                                context,
                                '/details',
                                arguments: {'companyId': item['id']},
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEmployeeSelected
                                        ? item['name']!
                                        : item['companyName']!,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isEmployeeSelected
                                        ? item['email']!
                                        : item['location']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                    
                                  ),
                                  
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      
      
    );
  }
}
