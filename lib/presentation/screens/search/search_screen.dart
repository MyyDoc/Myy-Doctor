import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/services/doctors_list.dart';
import 'package:myydoctor/services/location/doctors_location.dart';
import 'package:myydoctor/services/location/location.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.currentLoc});

  final String currentLoc;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? currentCity;
  bool isLoading = false;
  String? errorMessage;
  String? selectedSpecialization;
  String searchQuery = "";
  bool showSwipes = false;
  Timer? showSwipesin;
  final searchController = TextEditingController();

  final DoctorsList doctorsList = DoctorsList();
  List<Map<String, String>> filteredDoctors = [];
  final DoctorSearchService searchService = DoctorSearchService();

  void _filterDoctors() {
    setState(() {
      filteredDoctors =
          doctorsList.docList.where((doctor) {
            bool matchesSpecialization =
                selectedSpecialization == null ||
                doctor['specializedIn'] == selectedSpecialization;

            bool matchesLocation =
                currentCity == null || doctor['location'] == currentCity;

            bool matchesSearch =
                searchQuery.isEmpty ||
                doctor['name']!.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                doctor['specializedIn']!.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                doctor['location']!.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );

            return matchesSpecialization && matchesLocation && matchesSearch;
          }).toList();
    });
  }

  void _searchDoctors() {
    print("location from prev ${widget.currentLoc}");
    setState(() {
      filteredDoctors = searchService.searchDoctorsByLocation(
        currentLocation: currentCity ?? widget.currentLoc,
        searchQuery: searchQuery,
        specialization: selectedSpecialization,
      );
    });
  }

  void _resetSearch() {
    setState(() {
      selectedSpecialization = null;
      searchQuery = "";
    });
    _searchDoctors();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? city = await LocationService.getCurrentCity();
      setState(() {
        currentCity = city;
        isLoading = false;
      });
      print(city);
      print("cityyyyy");
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get location';
        isLoading = false;
      });
    }
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (selectedSpecialization != null) count++;
    if (currentCity != null) count++;
    return count;
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      selectedSpecialization = null;
      currentCity = null;
      searchQuery = "";
      filteredDoctors = List.from(doctorsList.docList);
    });
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onDeleted,
        backgroundColor: Color(0xFF1F323C),
        labelStyle: TextStyle(color: Colors.white),
        deleteIconColor: Colors.white,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    showSwipesin = Timer(Duration(seconds: 3), () {
      setState(() {
        showSwipes = true;
      });
    });
  }

  @override
  void dispose() {
    if (showSwipesin != null) {
      showSwipesin!.cancel();
      showSwipesin = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: AlertDialog(
                        insetPadding: EdgeInsets.zero,
                        contentPadding: EdgeInsets.zero,
                        content: Container(
                          height: MediaQuery.of(context).size.height,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              "assets/images/searchswipes0.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.format_indent_decrease_rounded,
                color: Colors.amber,
              ),
            ),
          ),
        ],
        backgroundColor: Color(0xFF1F323C),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            _showBottomSheet(context);
          },
          child: Icon(
            Icons.format_list_bulleted_add,
            color: Color(0xFFD4AF37),
            size: 32,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 108, 105, 99),
                  Colors.grey.shade300,
                  Color.fromARGB(255, 108, 105, 99),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                showSwipes = false;
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'SEARCH',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          searchController.text.isNotEmpty
              ? Column(children: [Center(child: Padding(
                padding: const EdgeInsets.only(top:  8.0),
                child: Text('No results'),
              ))])
              : SingleChildScrollView(
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: Image.asset(
                        "assets/images/searchswipes1.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    showSwipes
                        ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Padding(
                              padding: EdgeInsetsGeometry.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.79,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.35,
                                        decoration: BoxDecoration(
                                          color: AppColors.buttonBackground,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                showSwipes = false;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.arrow_drop_down_circle_sharp,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: EdgeInsetsGeometry.symmetric(
                                            horizontal: 15,
                                            vertical: 20,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Dr.Felix, MBBS MD DM Cardiology',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/verified_icon.png',
                                                ),
                                                SizedBox(width: 10),
                                                Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.centerRight,
                                                        width: 140,
                                                        height: 27,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[100],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsGeometry.only(
                                                                right: 10,
                                                              ),
                                                          child: Text(
                                                            'Heart Failure Specialist',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Image.asset(
                                                      'assets/images/golden_coin_icon.png',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey[400],
                                        ),
                
                                        child: Column(
                                          children: [
                                            // Image.asset('assets/images/star.png'),
                                            Text(
                                              '1216',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                              ),
                                            ),
                                            Text(
                                              'Carm',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * 0.1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Image.asset(
                                          'assets/images/x_icon.png',
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Image.asset(
                                          'assets/images/message_icon.png',
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Image.asset(
                                          'assets/images/red_star.png',
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Image.asset(
                                          'assets/images/stethoscope_icon.png',
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Image.asset(
                                          'assets/images/heart_icon.png',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: Container(
            width: double.infinity,
            child: Image.asset(
              "assets/images/searchswipes2.jpg",
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
