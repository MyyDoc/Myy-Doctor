import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/widgets/search/dropdown.dart';
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (context) => Padding(
                padding: const EdgeInsets.all(30.0),
                child: AlertDialog(
                  insetPadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset("assets/images/searchswipes0.jpg", fit: BoxFit.cover,))),
                ),
              ),);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(Icons.format_indent_decrease_rounded, color: Colors.amber,),
            ),
          )
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Image.asset(
          "assets/images/searchswipes1.png",
          fit: BoxFit.cover
        ),
      )
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
