import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/admin_leads_hub_controller.dart';
import '../domain/usecases/assign_lead_usecase.dart';
import '../domain/usecases/create_admin_lead_usecase.dart';
import '../domain/usecases/get_admin_lead_detail_usecase.dart';
import '../domain/usecases/get_admin_leads_usecase.dart';
import '../domain/usecases/get_sales_employees_usecase.dart';
import '../repositories/admin_leads_repository.dart';
import '../repositories/admin_leads_repository_interface.dart';

import '../controllers/lead_integrations_controller.dart';
import '../domain/usecases/get_facebook_authorization_url_usecase.dart';
import '../repositories/lead_integrations_repository.dart';
import '../repositories/lead_integrations_repository_interface.dart';

class AdminLeadsHubBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }

    Get.lazyPut<AdminLeadsRepositoryInterface>(
      () => AdminLeadsRepository(apiClient: Get.find<ApiClient>()),
    );

    Get.lazyPut<GetAdminLeadsUseCase>(
      () => GetAdminLeadsUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<GetAdminLeadDetailUseCase>(
      () => GetAdminLeadDetailUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<GetSalesEmployeesUseCase>(
      () => GetSalesEmployeesUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<CreateAdminLeadUseCase>(
      () => CreateAdminLeadUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<AssignLeadUseCase>(
      () => AssignLeadUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<AdminLeadsHubController>(
      () => AdminLeadsHubController(
        getAdminLeadsUseCase: Get.find<GetAdminLeadsUseCase>(),
        getAdminLeadDetailUseCase: Get.find<GetAdminLeadDetailUseCase>(),
        getSalesEmployeesUseCase: Get.find<GetSalesEmployeesUseCase>(),
        createAdminLeadUseCase: Get.find<CreateAdminLeadUseCase>(),
        assignLeadUseCase: Get.find<AssignLeadUseCase>(),
      ),
    );

    Get.lazyPut<LeadIntegrationsRepositoryInterface>(
      () => LeadIntegrationsRepository(apiClient: Get.find<ApiClient>()),
    );

    Get.lazyPut<GetFacebookAuthorizationUrlUseCase>(
      () => GetFacebookAuthorizationUrlUseCase(Get.find<LeadIntegrationsRepositoryInterface>()),
    );

    Get.lazyPut<LeadIntegrationsController>(
      () => LeadIntegrationsController(
        getFacebookAuthorizationUrlUseCase: Get.find<GetFacebookAuthorizationUrlUseCase>(),
      ),
    );
  }
}
