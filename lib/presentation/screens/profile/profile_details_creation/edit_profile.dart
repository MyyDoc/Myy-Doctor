import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/loader/loader.dart';
import '../../../../data/user/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? initialUser;

  const EditProfileScreen({
    super.key,
    this.initialUser,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialityController = TextEditingController();

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController latCtrl;
  late TextEditingController longCtrl;

  late List<String> _specialities;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.initialUser?.fullName ?? '');
    emailCtrl = TextEditingController(text: widget.initialUser?.email ?? '');

    _specialities = List.from(widget.initialUser?.speciality ?? []);

    // Location
    if (widget.initialUser?.lat != null && widget.initialUser?.lng != null) {
      latCtrl = TextEditingController(text: widget.initialUser!.lat!);
      longCtrl = TextEditingController(text: widget.initialUser!.lng!);
    } else {
      latCtrl = TextEditingController();
      longCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    _specialityController.dispose();
    latCtrl.dispose();
    longCtrl.dispose();
    super.dispose();
  }

  void _addSpeciality() {
    final text = _specialityController.text.trim();
    if (text.isNotEmpty && !_specialities.contains(text)) {
      setState(() {
        _specialities.add(text);
        _specialityController.clear();
      });
    }
  }

  void _removeSpeciality(String speciality) {
    setState(() {
      _specialities.remove(speciality);
    });
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions permanently denied")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        latCtrl.text = position.latitude.toStringAsFixed(6);
        longCtrl.text = position.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No user logged in");

      final updatedData = {
        'fullName': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'specialities': _specialities, // ← List<String>
        'lat': latCtrl.text.trim().isNotEmpty ? latCtrl.text.trim() : null,
        'lng': longCtrl.text.trim().isNotEmpty ? longCtrl.text.trim() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Clean up null/empty values if you prefer
      updatedData.removeWhere((key, value) =>
      value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Edit Profile"),
      ),
      body: isLoading
          ? const Center(child: MyyDocLoader())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return "Required";
                  final emailRegex = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');
                  if (!emailRegex.hasMatch(v!)) return "Invalid email";
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Specialities Chips + Input ──
              const Text(
                "Specialities",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._specialities.map((spec) => Chip(
                    label: Text(spec),
                    backgroundColor: Colors.blue.shade50,
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSpeciality(spec),
                  )),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _specialityController,
                      decoration: const InputDecoration(
                        labelText: "Add speciality",
                        hintText: "e.g. Pediatrician",
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _addSpeciality(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _addSpeciality,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Location Section ──
              const Text(
                "Location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: latCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Latitude"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: longCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Longitude"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Get Current Location"),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text("Save Profile", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}