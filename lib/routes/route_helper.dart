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
import '../features/intro/controllers/intro_controller.dart';
import '../features/intro/views/intro_screen.dart';
import '../features/dashboard/views/dashboard_screen.dart';
import '../features/employee/designation/views/designation_list_screen.dart';
import '../features/employee/designation/views/add_designation_screen.dart';
import '../features/employee/management/views/employee_list_screen.dart';
import '../features/employee/management/views/add_employee_screen.dart';
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
  static String getDashboardRoute() => AppRoutes.dashboard;
  static String getDesignationListRoute() => AppRoutes.designationList;
  static String getAddDesignationRoute() => AppRoutes.addDesignation;
  static String getEmployeeListRoute() => AppRoutes.employeeList;
  static String getAddEmployeeRoute() => AppRoutes.addEmployee;
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
          Get.lazyPut<AdminSignupRepositoryInterface>(() => adminRepo, fenix: true);
          Get.lazyPut<AdminSignupUseCase>(() => adminSignupUseCase, fenix: true);
          Get.lazyPut<AdminLoginUseCase>(() => adminLoginUseCase, fenix: true);
          Get.lazyPut<AdminForgotPasswordUseCase>(() => adminForgotPasswordUseCase, fenix: true);
          Get.lazyPut<AdminResetPasswordUseCase>(() => adminResetPasswordUseCase, fenix: true);
          Get.lazyPut<AdminSignupController>(
            () => AdminSignupController(
              adminSignupUseCase: adminSignupUseCase,
              adminLoginUseCase: adminLoginUseCase,
              adminForgotPasswordUseCase: adminForgotPasswordUseCase,
              adminResetPasswordUseCase: adminResetPasswordUseCase,
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

    // ── Dashboard ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.designationList,
      page: () => const DesignationListScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.addDesignation,
      page: () => const AddDesignationScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.employeeList,
      page: () => const EmployeeListScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.addEmployee,
      page: () => const AddEmployeeScreen(),
      transition: Transition.rightToLeft,
    ),
  ];

}
