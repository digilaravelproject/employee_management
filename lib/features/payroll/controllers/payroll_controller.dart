import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/payroll_record_model.dart';

class PayrollController extends GetxController {
  // Symmetrical reactive list of payroll records
  final payrollRecords = <PayrollRecord>[].obs;
  
  // Selected period
  final selectedMonth = 'May 2024'.obs;
  final availableMonths = ['May 2024', 'April 2024', 'March 2024'];
  
  // Filter variables
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs; // 'All', 'Created', 'Pending'
  
  // Selected single record
  final selectedRecord = Rxn<PayrollRecord>();
  
  // Create Salary Form Elements
  late TextEditingController bankNameController;
  late TextEditingController accountController;
  late TextEditingController remarksController;
  
  final paymentDate = Rxn<DateTime>();
  final selectedPaymentMode = Rxn<String>();
  final confirmReviewed = false.obs;
  
  final List<String> paymentModes = ['Bank Transfer', 'Cash', 'Cheque', 'UPI'];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _seedMockPayrollData();
  }

  void _initializeControllers() {
    bankNameController = TextEditingController();
    accountController = TextEditingController();
    remarksController = TextEditingController();
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  // Pre-seed mock payroll records matching the reference mockups
  void _seedMockPayrollData() {
    payrollRecords.assignAll([
      PayrollRecord(
        id: 'PR001',
        employeeId: 'EMP001',
        employeeName: 'Rahul Sharma',
        designation: 'Sales Executive',
        department: 'Sales Department',
        profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        salaryMonth: 'May 2024',
        status: 'Pending',
        totalWorkingDays: 26,
        presentDays: 22,
        absentDays: 2,
        paidLeaves: 1,
        unpaidLeaves: 1,
        halfDays: 0,
        lateComingDays: 2,
        overtimeHours: 5.5,
        basicSalary: 20000.00,
        hra: 5000.00,
        conveyance: 2000.00,
        specialAllowance: 2500.00,
        incentive: 2000.00,
        bonus: 1500.00,
        overtimeAmount: 1500.00,
        leaveDeduction: 1000.00,
        lateDeduction: 500.00,
        pf: 2400.00,
        esi: 200.00,
        loanAdvance: 250.00,
        otherDeduction: 0.0,
      ),
      PayrollRecord(
        id: 'PR002',
        employeeId: 'EMP002',
        employeeName: 'Priya Verma',
        designation: 'HR Manager',
        department: 'HR Department',
        profilePic: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
        salaryMonth: 'May 2024',
        status: 'Created',
        totalWorkingDays: 26,
        presentDays: 25,
        absentDays: 0,
        paidLeaves: 1,
        unpaidLeaves: 0,
        halfDays: 0,
        lateComingDays: 0,
        overtimeHours: 0.0,
        basicSalary: 23000.00,
        hra: 6000.00,
        conveyance: 2000.00,
        specialAllowance: 3000.00,
        incentive: 1500.00,
        bonus: 1000.00,
        overtimeAmount: 0.0,
        leaveDeduction: 0.0,
        lateDeduction: 0.0,
        pf: 2760.00,
        esi: 230.00,
        loanAdvance: 0.0,
        otherDeduction: 0.0,
        paymentDate: '31 May 2024',
        paymentMode: 'Bank Transfer',
        bankName: 'HDFC Bank',
        accountIfsc: 'XXXX XXXX XXXX 1234',
        remarks: 'Salary processed successfully',
      ),
      PayrollRecord(
        id: 'PR003',
        employeeId: 'EMP003',
        employeeName: 'Amit Kumar',
        designation: 'IT Engineer',
        department: 'IT Department',
        profilePic: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
        salaryMonth: 'May 2024',
        status: 'Pending',
        totalWorkingDays: 26,
        presentDays: 23,
        absentDays: 1,
        paidLeaves: 2,
        unpaidLeaves: 0,
        halfDays: 0,
        lateComingDays: 1,
        overtimeHours: 3.0,
        basicSalary: 21000.00,
        hra: 5500.00,
        conveyance: 2000.00,
        specialAllowance: 2500.00,
        incentive: 1000.00,
        bonus: 1200.00,
        overtimeAmount: 800.00,
        leaveDeduction: 500.00,
        lateDeduction: 200.00,
        pf: 2520.00,
        esi: 200.00,
        loanAdvance: 800.00,
        otherDeduction: 0.0,
      ),
      PayrollRecord(
        id: 'PR004',
        employeeId: 'EMP004',
        employeeName: 'Neha Singh',
        designation: 'Marketing Executive',
        department: 'Marketing Department',
        profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
        salaryMonth: 'May 2024',
        status: 'Pending',
        totalWorkingDays: 26,
        presentDays: 21,
        absentDays: 3,
        paidLeaves: 1,
        unpaidLeaves: 1,
        halfDays: 0,
        lateComingDays: 4,
        overtimeHours: 0.0,
        basicSalary: 18500.00,
        hra: 4500.00,
        conveyance: 1800.00,
        specialAllowance: 2000.00,
        incentive: 1000.00,
        bonus: 500.00,
        overtimeAmount: 0.0,
        leaveDeduction: 1200.00,
        lateDeduction: 800.00,
        pf: 2220.00,
        esi: 180.00,
        loanAdvance: 0.0,
        otherDeduction: 0.0,
      ),
      PayrollRecord(
        id: 'PR005',
        employeeId: 'EMP005',
        employeeName: 'Vikash Yadav',
        designation: 'Operations Specialist',
        department: 'Operations',
        profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80',
        salaryMonth: 'May 2024',
        status: 'Created',
        totalWorkingDays: 26,
        presentDays: 24,
        absentDays: 0,
        paidLeaves: 2,
        unpaidLeaves: 0,
        halfDays: 0,
        lateComingDays: 0,
        overtimeHours: 2.0,
        basicSalary: 17000.00,
        hra: 4000.00,
        conveyance: 1500.00,
        specialAllowance: 1500.00,
        incentive: 800.00,
        bonus: 1000.00,
        overtimeAmount: 500.00,
        leaveDeduction: 0.0,
        lateDeduction: 0.0,
        pf: 2040.00,
        esi: 160.00,
        loanAdvance: 600.00,
        otherDeduction: 0.0,
        paymentDate: '30 May 2024',
        paymentMode: 'UPI',
        bankName: 'SBI Bank',
        accountIfsc: 'vikash@ybl',
        remarks: 'Salary paid via UPI Transfer',
      ),
      PayrollRecord(
        id: 'PR006',
        employeeId: 'EMP006',
        employeeName: 'Sanjay Patel',
        designation: 'Accountant',
        department: 'Accounts',
        profilePic: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&auto=format&fit=crop&q=80',
        salaryMonth: 'May 2024',
        status: 'Pending',
        totalWorkingDays: 26,
        presentDays: 22,
        absentDays: 2,
        paidLeaves: 2,
        unpaidLeaves: 0,
        halfDays: 0,
        lateComingDays: 2,
        overtimeHours: 0.0,
        basicSalary: 20000.00,
        hra: 5000.00,
        conveyance: 2000.00,
        specialAllowance: 2500.00,
        incentive: 1000.00,
        bonus: 800.00,
        overtimeAmount: 0.0,
        leaveDeduction: 1200.00,
        lateDeduction: 400.00,
        pf: 2400.00,
        esi: 200.00,
        loanAdvance: 250.00,
        otherDeduction: 0.0,
      ),
    ]);
  }

  // Active statistics counts
  int get totalEmployeesCount => payrollRecords.length;
  int get createdCount => payrollRecords.where((r) => r.status == 'Created').length;
  int get pendingCount => payrollRecords.where((r) => r.status == 'Pending').length;

  // Filtered list based on search queries and tabs
  List<PayrollRecord> get filteredPayrollRecords {
    List<PayrollRecord> temp = List.from(payrollRecords);
    
    // Apply selected tab filter
    if (selectedFilter.value != 'All') {
      temp = temp.where((r) => r.status == selectedFilter.value).toList();
    }
    
    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      temp = temp.where((r) =>
        r.employeeName.toLowerCase().contains(query) ||
        r.employeeId.toLowerCase().contains(query) ||
        r.designation.toLowerCase().contains(query) ||
        r.department.toLowerCase().contains(query)
      ).toList();
    }
    
    return temp;
  }

  // Clear payment form values
  void clearForm() {
    bankNameController.clear();
    accountController.clear();
    remarksController.clear();
    paymentDate.value = DateTime.now();
    selectedPaymentMode.value = 'Bank Transfer';
    confirmReviewed.value = false;
  }

  // Set values to selected record for paying
  void initializePaymentForm(PayrollRecord record) {
    clearForm();
    selectedRecord.value = record;
  }

  // Commit salary creation transaction
  void processCreateSalary() {
    if (selectedRecord.value == null) return;
    
    final record = selectedRecord.value!;
    final index = payrollRecords.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      final formattedDate = paymentDate.value != null 
          ? "${paymentDate.value!.day} ${_getMonthName(paymentDate.value!.month)} ${paymentDate.value!.year}"
          : "31 May 2024";

      final updated = record.copyWith(
        status: 'Created',
        paymentDate: formattedDate,
        paymentMode: selectedPaymentMode.value ?? 'Bank Transfer',
        bankName: bankNameController.text.trim().isNotEmpty ? bankNameController.text.trim() : 'Standard Bank',
        accountIfsc: accountController.text.trim().isNotEmpty ? accountController.text.trim() : 'XXXX XXXX XXXX 5678',
        remarks: remarksController.text.trim().isNotEmpty ? remarksController.text.trim() : 'Salary Paid Successfully',
      );
      
      payrollRecords[index] = updated;
      selectedRecord.value = updated;
      
      // Trigger dynamic SaaS snackbar notification
      Get.snackbar(
        'Salary Processed Successfully 🎉',
        'Payslip generated and recorded for ${record.employeeName}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981), // success green
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        borderRadius: 16,
        boxShadows: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      );
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return 'May';
  }
}
