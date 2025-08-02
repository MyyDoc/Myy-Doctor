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

  final DoctorsList doctorsList = DoctorsList();
  List<Map<String, String>> filteredDoctors = [];
  final DoctorSearchService searchService = DoctorSearchService();

 

   void _filterDoctors() {
    setState(() {
      filteredDoctors = doctorsList.docList.where((doctor) {
        bool matchesSpecialization = selectedSpecialization == null || 
            doctor['specializedIn'] == selectedSpecialization;
        
        bool matchesLocation = currentCity == null || 
            doctor['location'] == currentCity;
        
        bool matchesSearch = searchQuery.isEmpty ||
            doctor['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            doctor['specializedIn']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            doctor['location']!.toLowerCase().contains(searchQuery.toLowerCase());

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

  Widget _buildFilterChip({required String label, required VoidCallback onDeleted}) {
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
          // Filter count badge
          if (selectedSpecialization != null || currentCity != null)
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${_getActiveFiltersCount()}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
        backgroundColor: Color(0xFF1F323C),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            _showBottomSheet(context);
          },
          child: Icon(Icons.format_list_bulleted_add, color:  Color(0xFFD4AF37), size: 32)),
        title: Container(
          alignment: Alignment.center,
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: Center(
              child: TextField(
                onChanged: (value) {
                searchQuery = value;
               _searchDoctors(); 
               
              },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search',
                  hintStyle: textTheme.bodyMedium!.copyWith(color: Colors.grey)
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (selectedSpecialization != null || currentCity != null)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (selectedSpecialization != null)
                      _buildFilterChip(
                        label: selectedSpecialization!,
                        onDeleted: () {
                          setState(() {
                            selectedSpecialization = null;
                          });
                          _searchDoctors(); 
                        },
                      ),
                    if (currentCity != null)
                      _buildFilterChip(
                        label: currentCity!,
                        onDeleted: () {
                          setState(() {
                            currentCity = null;
                          });
                          _searchDoctors(); 
                        },
                      ),
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: Icon(Icons.clear_all, size: 18),
                      label: Text('Clear All'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Text(
                  '${filteredDoctors.length} doctor${filteredDoctors.length == 1 ? '' : 's'} found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _resetFilters,
                          child: Text('Reset Filters'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF1F323C),
                            child: Text(
                              doctor['name']![4], // Gets first letter after "Dr. "
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            doctor['name']!,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor['specializedIn']!),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(doctor['location']!, style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(),));
                          },
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        color: Color.fromARGB(255, 221, 220, 220),
                      ),
                      itemCount: filteredDoctors.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        // Use StatefulBuilder to manage state within the bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Specialization Dropdown
                    MedicalSpecializationDropdown(
                      selectedValue: selectedSpecialization,
                      onChanged: (String? value) {
                        // Update both the parent state and modal state
                        setState(() {
                          selectedSpecialization = value;
                        });
                        setModalState(() {
                          selectedSpecialization = value;
                        });
                        print('Selected: $value');
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Location Section
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Your current location:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Refresh button
                        IconButton(
                          onPressed: () async {
                            setModalState(() {
                              isLoading = true;
                            });
                            await _getCurrentLocation();
                            setModalState(() {
                              isLoading = false;
                            });
                          },
                          icon: Icon(Icons.refresh),
                          tooltip: 'Refresh location',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Location Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Text('Getting location...'),
                              ],
                            )
                          : Text(
                              currentCity ?? "Location not available",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: currentCity != null ? Colors.black : Colors.grey,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset filters
                              setState(() {
                                selectedSpecialization = null;
                              });
                              setModalState(() {
                                selectedSpecialization = null;
                              });
                            },
                            child: Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _filterDoctors();
                            Navigator.pop(context);
                              print('Applying filters:');
                              print('Specialization: $selectedSpecialization');
                              print('Location: $currentCity');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1F323C),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}