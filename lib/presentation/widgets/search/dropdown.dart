
import 'package:flutter/material.dart';

class MedicalSpecializationDropdown extends StatefulWidget {
  final Function(String?)? onChanged;
  final String? selectedValue;

  const MedicalSpecializationDropdown({
    Key? key,
    this.onChanged,
    this.selectedValue,
  }) : super(key: key);

  @override
  State<MedicalSpecializationDropdown> createState() => _MedicalSpecializationDropdownState();
}

class _MedicalSpecializationDropdownState extends State<MedicalSpecializationDropdown> {
  String? selectedSpecialization;

  // List of medical specializations from the doctors data
  final List<String> specializations = [
    'Cardiology',
    'Pediatrics',
    'Orthopedics',
    'Gynecology',
    'Neurology',
    'Dermatology',
    'General Surgery',
    'Gastroenterology',
    'Ophthalmology',
    'Psychiatry',
    'ENT Specialist',
    'Pulmonology',
    'Internal Medicine',
    'Urology',
    'Radiology',
    'Anesthesiology',
    'Emergency Medicine',
    'Endocrinology',
    'Oncology',
    'Rheumatology',
  ];

  @override
  void initState() {
    super.initState();
    selectedSpecialization = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedSpecialization,
      hint: const Text('Select Specialization'),
      decoration: const InputDecoration(
        labelText: 'Medical Specialization',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: specializations.map((String specialization) {
        return DropdownMenuItem<String>(
          value: specialization,
          child: Text(specialization),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedSpecialization = newValue;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(newValue);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a specialization';
        }
        return null;
      },
    );
  }
}