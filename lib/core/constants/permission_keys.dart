/// Centralized catalog of all granular permission keys across the app.
/// Organised by module -> submodule -> screen/card/action.
class PermissionKeys {
  // ── 1. Profile & Documents ──
  static const String profileView = 'profile.view';
  static const String profileEdit = 'profile.edit';
  static const String profileChangeAvatar = 'profile.change_avatar';
  static const String profileViewAddress = 'profile.view_address';
  static const String profileViewBankDetails = 'profile.view_bank_details';
  static const String profileEditBankDetails = 'profile.edit_bank_details';
  static const String profileDocumentView = 'profile.document.view';
  static const String profileDocumentUpload = 'profile.document.upload';
  static const String profileDocumentDelete = 'profile.document.delete';
  static const String profileDocumentZoom = 'profile.document.zoom';

  // ── 2. Attendance & Regularization ──
  static const String attendanceView = 'attendance.view';
  static const String attendanceCheckInOut = 'attendance.check_in_out';
  static const String attendanceHistoryView = 'attendance.history.view';
  static const String attendanceRegularizeRequest = 'attendance.regularize.request';
  static const String attendanceRegularizeApprove = 'attendance.regularize.approve';
  static const String attendanceTeamView = 'attendance.team.view';
  static const String attendanceExport = 'attendance.export';

  // ── 3. Leave Management ──
  static const String leaveView = 'leave.view';
  static const String leaveApply = 'leave.apply';
  static const String leaveCancel = 'leave.cancel';
  static const String leaveBalanceView = 'leave.balance.view';
  static const String leaveApproveReject = 'leave.approve_reject';
  static const String leaveAllEmployeeRequests = 'leave.all_employee_requests';
  static const String leavePolicyView = 'leave.policy.view';

  // ── 4. Employee Management ──
  static const String employeeView = 'employee.view';
  static const String employeeAdd = 'employee.add';
  static const String employeeEdit = 'employee.edit';
  static const String employeeDelete = 'employee.delete';
  static const String employeeViewSalary = 'employee.view_salary';
  static const String employeeEditSalary = 'employee.edit_salary';
  static const String employeeViewDocuments = 'employee.view_documents';
  static const String employeeStatusChange = 'employee.status_change';

  // ── 5. Tasks & Projects ──
  static const String tasksView = 'tasks.view';
  static const String tasksCreate = 'tasks.create';
  static const String tasksEdit = 'tasks.edit';
  static const String tasksDelete = 'tasks.delete';
  static const String tasksAssign = 'tasks.assign';
  static const String tasksDailyUpdate = 'tasks.daily_update';
  static const String projectsView = 'projects.view';
  static const String projectsCreate = 'projects.create';
  static const String projectsEdit = 'projects.edit';
  static const String projectsDelete = 'projects.delete';

  // ── 6. Departments & Designations ──
  static const String departmentView = 'department.view';
  static const String departmentAdd = 'department.add';
  static const String departmentEdit = 'department.edit';
  static const String departmentDelete = 'department.delete';
  static const String designationView = 'designation.view';
  static const String designationAdd = 'designation.add';
  static const String designationEdit = 'designation.edit';
  static const String designationDelete = 'designation.delete';

  // ── 7. Payroll & Salary ──
  static const String payrollViewMy = 'payroll.view_my';
  static const String payrollManageAll = 'payroll.manage_all';
  static const String payrollProcess = 'payroll.process';
  static const String payrollDownloadPayslip = 'payroll.download_payslip';

  // ── 8. Assets Management ──
  static const String assetsView = 'assets.view';
  static const String assetsAdd = 'assets.add';
  static const String assetsEdit = 'assets.edit';
  static const String assetsAssign = 'assets.assign';
  static const String assetsReturn = 'assets.return';

  // ── 9. Clients & Leads (CRM) ──
  static const String leadsView = 'leads.view';
  static const String leadsCreate = 'leads.create';
  static const String leadsEdit = 'leads.edit';
  static const String leadsDelete = 'leads.delete';
  static const String leadsAssignTeam = 'leads.assign_team';
  static const String leadsUpdateStatus = 'leads.update_status';
  static const String clientsView = 'clients.view';
  static const String clientsCreate = 'clients.create';
  static const String clientsEdit = 'clients.edit';

  // ── 10. Meetings & Follow-ups ──
  static const String meetingsView = 'meetings.view';
  static const String meetingsCreate = 'meetings.create';
  static const String meetingsEdit = 'meetings.edit';
  static const String meetingsNotes = 'meetings.notes';

  // ── 11. Documents & Folders ──
  static const String documentsView = 'documents.view';
  static const String documentsUpload = 'documents.upload';
  static const String documentsDelete = 'documents.delete';
  static const String documentsAccessControl = 'documents.access_control';

  // ── 12. Company Profile & Policies ──
  static const String companyProfileView = 'company.profile.view';
  static const String companyProfileEdit = 'company.profile.edit';
  static const String compliancePolicyView = 'compliance.policy.view';
  static const String compliancePolicyUpload = 'compliance.policy.upload';

  // ── 13. Roles & Permissions (RBAC) ──
  static const String rolesView = 'roles.view';
  static const String rolesCreate = 'roles.create';
  static const String rolesEdit = 'roles.edit';
  static const String rolesDelete = 'roles.delete';
}
