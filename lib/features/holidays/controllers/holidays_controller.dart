import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/holiday_model.dart';

class HolidaysController extends GetxController {
  // Reactive list of holidays
  final RxList<Holiday> holidays = <Holiday>[].obs;

  // Filters
  final RxInt filterYear = DateTime.now().year.obs;
  final RxString filterLocation = 'All Locations'.obs;

  // Selected holiday for details or edit mode
  final Rxn<Holiday> selectedHoliday = Rxn<Holiday>();

  // Collapsible Month Expansion States: Month index (1-12) -> isExpanded
  final RxMap<int, bool> expandedMonths = <int, bool>{}.obs;

  // Form Fields & Controllers for Add / Edit Screen
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxString selectedType = 'National Holiday'.obs;
  final RxString selectedLocation = 'All Locations'.obs;
  final RxBool repeatEveryYear = true.obs;

  // Constant list of locations and types for dropdowns
  final List<String> locations = [
    'All Locations',
    'Delhi HQ',
    'Mumbai Office',
    'Bangalore Tech Hub',
    'Remote',
  ];

  final List<String> holidayTypes = [
    'National Holiday',
    'Optional Holiday',
    'Restricted Holiday',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeDummyHolidays();
    // Expand the current month by default
    final currentMonth = DateTime.now().month;
    expandedMonths[currentMonth] = true;
  }

  // Initialize the list with realistic dates matching the current year
  void _initializeDummyHolidays() {
    final currentYear = DateTime.now().year;
    holidays.addAll([
      Holiday(
        id: '1',
        name: 'New Year\'s Day',
        date: DateTime(currentYear, 1, 1),
        type: 'Optional Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'First day of the year on the modern Gregorian calendar.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 1),
      ),
      Holiday(
        id: '2',
        name: 'Republic Day',
        date: DateTime(currentYear, 1, 26),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Honors the date on which the Constitution of India came into effect.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 5),
      ),
      Holiday(
        id: '3',
        name: 'Maha Shivratri',
        date: DateTime(currentYear, 3, 8),
        type: 'Restricted Holiday',
        location: 'Delhi HQ',
        repeatEveryYear: false,
        description: 'A major Hindu festival celebrated annually in honour of the God Shiva.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 2, 10),
      ),
      Holiday(
        id: '4',
        name: 'Holi',
        date: DateTime(currentYear, 3, 25),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: false,
        description: 'The popular ancient Hindu festival of colors, love, and spring.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 2, 12),
      ),
      Holiday(
        id: '5',
        name: 'Good Friday',
        date: DateTime(currentYear, 3, 29),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: false,
        description: 'Christian holiday commemorating the crucifixion of Jesus Christ.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 2, 15),
      ),
      Holiday(
        id: '6',
        name: 'Labour Day',
        date: DateTime(currentYear, 5, 1),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'International Workers\' Day is celebrated to honor the contributions of workers.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
      Holiday(
        id: '7',
        name: 'Buddha Purnima',
        date: DateTime(currentYear, 5, 15),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Festival marks the birth, enlightenment and death of Gautama Buddha.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
      Holiday(
        id: '8',
        name: 'Eid al-Adha',
        date: DateTime(currentYear, 6, 17),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: false,
        description: 'Feast of the Sacrifice, celebrated by Muslims worldwide.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 3, 1),
      ),
      Holiday(
        id: '9',
        name: 'Independence Day',
        date: DateTime(currentYear, 8, 15),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Commemorates the nation\'s independence from the United Kingdom.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
      Holiday(
        id: '10',
        name: 'Raksha Bandhan',
        date: DateTime(currentYear, 8, 19),
        type: 'Optional Holiday',
        location: 'Mumbai Office',
        repeatEveryYear: false,
        description: 'Celebrates the bond between brothers and sisters.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 4, 15),
      ),
      Holiday(
        id: '11',
        name: 'Gandhi Jayanti',
        date: DateTime(currentYear, 10, 2),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Celebrated to mark the occasion of the birthday of Mahatma Gandhi.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
      Holiday(
        id: '12',
        name: 'Dussehra',
        date: DateTime(currentYear, 10, 12),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: false,
        description: 'Major Hindu festival marks the victory of Rama over Ravana.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 4, 20),
      ),
      Holiday(
        id: '13',
        name: 'Diwali / Deepavali',
        date: DateTime(currentYear, 11, 1),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'The festival of lights, representing the triumph of light over darkness.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
      Holiday(
        id: '14',
        name: 'Christmas',
        date: DateTime(currentYear, 12, 25),
        type: 'National Holiday',
        location: 'All Locations',
        repeatEveryYear: true,
        description: 'Annual festival commemorating the birth of Jesus Christ.',
        addedBy: 'Admin',
        addedOn: DateTime(currentYear, 1, 10),
      ),
    ]);
  }

  // Reactive filtered holidays list based on Year and Location
  List<Holiday> get filteredHolidays {
    return holidays.where((h) {
      final matchesYear = h.date.year == filterYear.value;
      final matchesLocation = filterLocation.value == 'All Locations' ||
          h.location == 'All Locations' ||
          h.location == filterLocation.value;
      return matchesYear && matchesLocation;
    }).toList();
  }

  // Group filtered holidays by month index (1 for Jan, 12 for Dec)
  Map<int, List<Holiday>> get holidaysByMonth {
    final Map<int, List<Holiday>> grouped = {};
    for (int i = 1; i <= 12; i++) {
      grouped[i] = [];
    }

    for (var h in filteredHolidays) {
      final month = h.date.month;
      grouped[month]?.add(h);
    }
    return grouped;
  }

  // Toggle Month Collapse state
  void toggleMonth(int monthIndex) {
    if (expandedMonths.containsKey(monthIndex)) {
      expandedMonths[monthIndex] = !expandedMonths[monthIndex]!;
    } else {
      expandedMonths[monthIndex] = true;
    }
    expandedMonths.refresh();
  }

  // Clear Form Fields for Add Mode
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedDate.value = null;
    selectedType.value = 'National Holiday';
    selectedLocation.value = 'All Locations';
    repeatEveryYear.value = true;
  }

  // Populate Form Fields for Edit Mode
  void populateForm(Holiday holiday) {
    nameController.text = holiday.name;
    descriptionController.text = holiday.description;
    selectedDate.value = holiday.date;
    selectedType.value = holiday.type;
    selectedLocation.value = holiday.location;
    repeatEveryYear.value = holiday.repeatEveryYear;
  }

  // Save new holiday (Create)
  void saveHoliday() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Holiday Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newHoliday = Holiday(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      date: selectedDate.value!,
      type: selectedType.value,
      location: selectedLocation.value,
      repeatEveryYear: repeatEveryYear.value,
      description: descriptionController.text.trim(),
      addedBy: 'Admin',
      addedOn: DateTime.now(),
    );

    holidays.add(newHoliday);
    // Expand the month of the newly added holiday so the user sees it immediately
    expandedMonths[newHoliday.date.month] = true;

    clearForm();
    Get.back();
    Get.snackbar(
      'Success',
      'Holiday added successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Update existing holiday (Update)
  void updateHoliday() {
    final current = selectedHoliday.value;
    if (current == null) return;

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Holiday Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final updated = current.copyWith(
      name: nameController.text.trim(),
      date: selectedDate.value!,
      type: selectedType.value,
      location: selectedLocation.value,
      repeatEveryYear: repeatEveryYear.value,
      description: descriptionController.text.trim(),
    );

    final idx = holidays.indexWhere((h) => h.id == current.id);
    if (idx != -1) {
      holidays[idx] = updated;
    }

    selectedHoliday.value = updated;
    clearForm();
    Get.back(); // Go back from Edit screen to Details screen
    Get.snackbar(
      'Updated',
      'Holiday updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
    );
  }

  // Delete holiday (Delete)
  void deleteHoliday(String id) {
    holidays.removeWhere((h) => h.id == id);
    selectedHoliday.value = null;
    Get.back(); // Go back from details to calendar screen
    Get.snackbar(
      'Deleted',
      'Holiday deleted successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
