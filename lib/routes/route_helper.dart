import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../features/auth/bindings/admin_signup_binding.dart';
import '../features/auth/controllers/admin_signup_controller.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/domain/repositories/admin_signup_repository.dart';
import '../features/auth/domain/repositories/admin_signup_repository_interface.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/services/auth_service.dart';
import '../features/auth/domain/usecases/admin_signup_usecase.dart';
import '../features/auth/view/login.dart';
import '../features/auth/view/signup.dart';
import '../features/auth/view/role_selection_screen.dart';
import '../features/auth/view/forgot_password.dart';
import '../features/auth/view/otp_verification.dart';
import '../features/auth/view/reset_password.dart';
import '../features/profile/views/change_password_screen.dart';
import '../features/intro/controllers/intro_controller.dart';
import '../features/intro/views/intro_screen.dart';
import '../features/dashboard/views/dashboard_screen.dart';
import '../features/employee/designation/views/designation_list_screen.dart';
import '../features/employee/designation/views/add_designation_screen.dart';
import '../features/employee/designation/bindings/designation_binding.dart';
import '../features/employee/management/bindings/employee_binding.dart';
import '../features/employee/management/views/employee_list_screen.dart';
import '../features/employee/management/views/add_employee_screen.dart';
import '../features/departments/views/department_list_screen.dart';
import '../features/departments/views/add_department_screen.dart';
import '../features/departments/bindings/department_binding.dart';
import '../features/shift_management/bindings/shift_binding.dart';
import '../features/shift_management/views/shift_management_screen.dart';
import '../features/shift_management/views/create_shift_screen.dart';
import '../features/leave_management/bindings/admin_leave_binding.dart';
import '../features/leave_management/views/leave_requests_screen.dart';
import '../core/services/network/api_client.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;
  static String getLoginRoute() => AppRoutes.login;
  static String getSignupRoute() => AppRoutes.signup;
  static String getRoleSelectionRoute() => AppRoutes.roleSelection;
  static String getOtpRoute() => AppRoutes.otp;
  static String getIntroRoute() => AppRoutes.intro;
  static String getForgotPasswordRoute() => AppRoutes.forgotPassword;
  static String getResetPasswordRoute() => AppRoutes.resetPassword;
  static String getChangePasswordRoute() => AppRoutes.changePassword;
  static String getDashboardRoute() => AppRoutes.dashboard;
  static String getDesignationListRoute() => AppRoutes.designationList;
  static String getAddDesignationRoute() => AppRoutes.addDesignation;
  static String getEmployeeListRoute() => AppRoutes.employeeList;
  static String getDepartmentListRoute() => AppRoutes.departmentList;
  static String getShiftListRoute() => AppRoutes.shiftList;
  static String getCreateShiftRoute() => AppRoutes.createShift;
  static String getAddDepartmentRoute() => AppRoutes.addDepartment;
  static String getLeaveRequestsRoute() => AppRoutes.leaveRequests;
  static String getLeadListRoute() => AppRoutes.leadList;
  static String getLeadSummaryRoute() => AppRoutes.leadSummary;

  /// Shared binding builder for AuthController – reused across login/signup/otp
  static BindingsBuilder _authBinding() => BindingsBuilder(() {
        if (!Get.isRegistered<ApiClient>()) {
          Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
        }
        if (!Get.isRegistered<AuthController>()) {
          final apiClient = Get.find<ApiClient>();
          final authRepo = AuthRepository(apiClient);
          final authService = AuthService(authRepo);

          Get.put(
            AuthController(
              sendOtpUseCase: SendOtpUseCase(authService),
              resendOtpUseCase: ResendOtpUseCase(authService),
              verifyLoginOtpUseCase: VerifyLoginOtpUseCase(authService),
              registerSendOtpUseCase: RegisterSendOtpUseCase(authService),
              loginUseCase: LoginUseCase(authService),
              registerUseCase: RegisterUseCase(authService),
              verifyOtpUseCase: VerifyOtpUseCase(authService),
              logoutUseCase: LogoutUseCase(authService),
              checkLoginStatusUseCase: CheckLoginStatusUseCase(authService),
              getUserInfoUseCase: GetUserInfoUseCase(authService),
            ),
            permanent: false,
          );
        }
        if (!Get.isRegistered<AdminSignupController>()) {
          final apiClient = Get.find<ApiClient>();
          final adminRepo = AdminSignupRepository(apiClient);
          final adminSignupUseCase = AdminSignupUseCase(adminRepo);
          final adminLoginUseCase = AdminLoginUseCase(adminRepo);
          final adminForgotPasswordUseCase = AdminForgotPasswordUseCase(adminRepo);
          final adminResetPasswordUseCase = AdminResetPasswordUseCase(adminRepo);
          final adminUpdatePasswordUseCase = AdminUpdatePasswordUseCase(adminRepo);
          Get.lazyPut<AdminSignupRepositoryInterface>(() => adminRepo, fenix: true);
          Get.lazyPut<AdminSignupUseCase>(() => adminSignupUseCase, fenix: true);
          Get.lazyPut<AdminLoginUseCase>(() => adminLoginUseCase, fenix: true);
          Get.lazyPut<AdminForgotPasswordUseCase>(() => adminForgotPasswordUseCase, fenix: true);
          Get.lazyPut<AdminResetPasswordUseCase>(() => adminResetPasswordUseCase, fenix: true);
          Get.lazyPut<AdminUpdatePasswordUseCase>(() => adminUpdatePasswordUseCase, fenix: true);
          Get.lazyPut<AdminSignupController>(
            () => AdminSignupController(
              adminSignupUseCase: adminSignupUseCase,
              adminLoginUseCase: adminLoginUseCase,
              adminForgotPasswordUseCase: adminForgotPasswordUseCase,
              adminResetPasswordUseCase: adminResetPasswordUseCase,
              adminUpdatePasswordUseCase: adminUpdatePasswordUseCase,
            ),
            fenix: true,
          );
        }
      });

  static final List<GetPage> routes = [
    // ── Intro ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => IntroController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),

    // ── Role Selection ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
      transition: Transition.fadeIn,
    ),

    // ── Login ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AdminSignupBinding(),
      transition: Transition.fadeIn,
    ),

    // ── Signup / Registration ───────────────────────────────────────────────
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: AdminSignupBinding(),
      transition: Transition.rightToLeft,
    ),
    // ── Forgot Password ──────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AdminSignupBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── OTP Verification ─────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerificationScreen(),
      binding: _authBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Reset Password ───────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: AdminSignupBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Change Password ──────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: AdminSignupBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Dashboard ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.designationList,
      page: () => const DesignationListScreen(),
      binding: DesignationBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.addDesignation,
      page: () => const AddDesignationScreen(),
      binding: DesignationBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.employeeList,
      page: () => const EmployeeListScreen(),
      binding: EmployeeBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.addEmployee,
      page: () => const AddEmployeeScreen(),
      binding: EmployeeBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.departmentList,
      page: () => const DepartmentListScreen(),
      binding: DepartmentBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.addDepartment,
      page: () => const AddDepartmentScreen(),
      binding: DepartmentBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.shiftList,
      page: () => const ShiftManagementScreen(),
      binding: ShiftBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.createShift,
      page: () => const CreateShiftScreen(),
      binding: ShiftBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.leaveRequests,
      page: () => const LeaveRequestsScreen(),
      binding: AdminLeaveBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
