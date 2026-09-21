class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String roleSelection = '/roleSelection';
  static const String otp = '/otp';
  static const String intro = '/intro';
  static const String forgotPassword = '/forgotPassword';
  static const String resetPassword = '/resetPassword';
  static const String dashboard = '/dashboard';
  static const String leadList = '/leadList';
  static const String createLead = '/createLead';
  static const String leadDetails = '/leadDetails';
  static const String editLead = '/editLead';
  static const String leadNotes = '/leadNotes';
  static const String followUp = '/followUp';
  static const String followUpList = '/followUpList';
  static const String quotationPreview = '/quotationPreview';
  static String getPdfViewerRoute() => AppRoutes.pdfViewer;
  static String getDocumentPreviewRoute() => AppRoutes.documentPreview;
  static const String pdfViewer = '/pdfViewer';
  static const String tripList = '/trip-list';
  static const String createTrip = '/create-trip';
  static const String tripDetails = '/trip-details';
  static const String assignVehicle = '/assign-vehicle';
  static const String assignDriver = '/assign-driver';
  static const String tripTracking = '/trip-tracking';
  static const String tripExpenseEntry = '/trip-expense-entry';
  static const String tripExpenseList = '/trip-expense-list';
  static const String tripInvoice = '/trip-invoice';
  static const String dutySheetUpload = '/duty-sheet-upload';
  static const String dutySheetList = '/duty-sheet-list';
  static const String tripStatusUpdate = '/trip-status-update';
  static const String leadSummary = '/leadSummary';
  static const String tripSummary = '/trip-summary';
  static const String vehicleList = '/vehicle-list';
  static const String addVehicle = '/add-vehicle';
  static const String vehicleDetails = '/vehicle-details';
  static const String editVehicle = '/edit-vehicle';
  static const String vehicleDocuments = '/vehicle-documents';
  static const String fuelEntry = '/fuel-entry';
  static const String fuelHistory = '/fuel-history';
  static const String serviceEntry = '/service-entry';
  static const String serviceHistory = '/service-history';
  static const String repairEntry = '/repair-entry';
  static const String maintenanceHistory = '/maintenance-history';
  static const String documentUpload = '/document-upload';
  static const String servicePaymentHistory = '/service-payment-history';

  // Staff
  static const String staffList = '/staff-list';
  static const String addStaff = '/add-staff';
  static const String staffDetails = '/staff-details';
  static const String editStaff = '/edit-staff';
  static const String attendance = '/attendance';
  static const String attendanceHistory = '/attendance-history';
  static const String dutyHours = '/duty-hours';
  static const String addDutyRecord = '/add-duty-record';
  static const String salaryManagement = '/salary-management';
  static const String salaryPaymentEntry = '/salary-payment-entry';
  static const String salaryHistory = '/salary-history';
  static const String advancePaymentEntry = '/advance-payment-entry';
  static const String advanceHistory = '/advance-history';
  static const String staffDocuments = '/staff-documents';
  static const String driverLicenseTracker = '/driver-license-tracker';
  static const String staffPerformance = '/staff-performance';

  // Corporate
  static const String companyList = '/company-list';
  static const String createCorporateContract = '/create-corporate-contract';
  static const String contractDetails = '/contract-details';
  static const String assignVehicleToContract = '/assign-vehicle-to-contract';
  static const String corporateDutyTracking = '/corporate-duty-tracking';
  static const String corporateInvoice = '/corporate-invoice';
  static const String assignDriverToContract = '/assign_vehical';

  // Finance
  static const String cashbookDashboard = '/cashbook-dashboard';
  static const String cashInEntry = '/cash-in-entry';
  static const String cashOutEntry = '/cash-out-entry';
  static const String paymentHistory = '/payment-history';
  static const String paymentDetails = '/payment-details';

  // Inventory
  static const String inventoryList = '/inventory-list';
  static const String addInventoryItem = '/add-inventory-item';
  static const String inventoryDetails = '/inventory-details';
  static const String stockIn = '/stock-in';
  static const String stockOut = '/stock-out';
  static const String stockHistory = '/stock-history';

  // Shifts
  static const String shiftList = '/shift-list';
  static const String createShift = '/create-shift';
  static const String assignDriverToShift = '/assign-driver-to-shift';
  static const String shiftDetails = '/shift-details';

  // Routes Management
  static const String routeList = '/route-list';
  static const String createRoute = '/create-route';
  static const String routeDetails = '/route-details';
  static const String assignRouteDriver = '/assign-route-driver';
  static const String assignRoute = '/assign-route';

  // Reports
  static const String reportsDashboard = '/reports-dashboard';
  static const String tripReports = '/trip-reports';
  static const String financialReports = '/financial-reports';
  static const String vehicleReports = '/vehicle-reports';
  static const String staffReports = '/staff-reports';
  static const String complianceReports = '/compliance-reports';
  static const String profitLossReport = '/profit-loss-report';
  static const String allReports = '/all-reports';
  static const String repairHistory = '/repair-history';

  // Settings & Profile
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String subscription = '/subscription';
  static const String help = '/help';

  // Phase 11 Modules
  static const String templateList = '/template-list';
  static const String addTemplate = '/add-template';
  static const String editTemplate = '/edit-template';
  static const String templateDetails = '/template-details';
  static const String templateView = '/template-view';
  static const String roleList = '/role-list';
  static const String addRole = '/add-role';
  static const String editRole = '/edit-role';
  static const String roleDetails = '/role-details';
  static const String membership = '/membership';
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notification-details';
  static const String search = '/search';
  static const String documentPreview = '/document-preview';
  static const String vehicleTypeList = '/vehicle-type-list';
  static const String addVehicleType = '/add-vehicle-type';
  static const String editVehicleType = '/edit-vehicle-type';
  static const String designationList = '/designation-list';
  static const String addDesignation = '/add-designation';
  static const String employeeList = '/employee-list';
  static const String addEmployee = '/add-employee';
  static const String departmentList = '/department-list';
  static const String addDepartment = '/add-department';
  static const String leaveRequests = '/leave-requests';
}
