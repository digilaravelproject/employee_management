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
import '../domain/usecases/get_lead_integrations_status_usecase.dart';
import '../repositories/lead_integrations_repository.dart';
import '../repositories/lead_integrations_repository_interface.dart';

import '../controllers/admin_lead_statuses_controller.dart';
import '../domain/usecases/create_lead_status_usecase.dart';
import '../domain/usecases/delete_lead_status_usecase.dart';
import '../domain/usecases/get_lead_status_detail_usecase.dart';
import '../domain/usecases/get_lead_statuses_usecase.dart';
import '../domain/usecases/update_lead_status_usecase.dart';

import '../controllers/admin_lead_sources_controller.dart';
import '../domain/usecases/create_lead_source_usecase.dart';
import '../domain/usecases/get_lead_sources_usecase.dart';
import '../domain/usecases/get_lead_source_detail_usecase.dart';
import '../domain/usecases/update_lead_source_usecase.dart';

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
        repository: Get.find<AdminLeadsRepositoryInterface>(),
      ),
    );

    Get.lazyPut<LeadIntegrationsRepositoryInterface>(
      () => LeadIntegrationsRepository(apiClient: Get.find<ApiClient>()),
    );

    Get.lazyPut<GetFacebookAuthorizationUrlUseCase>(
      () => GetFacebookAuthorizationUrlUseCase(Get.find<LeadIntegrationsRepositoryInterface>()),
    );

    Get.lazyPut<GetLeadIntegrationsStatusUseCase>(
      () => GetLeadIntegrationsStatusUseCase(Get.find<LeadIntegrationsRepositoryInterface>()),
    );

    Get.lazyPut<LeadIntegrationsController>(
      () => LeadIntegrationsController(
        getFacebookAuthorizationUrlUseCase: Get.find<GetFacebookAuthorizationUrlUseCase>(),
        getLeadIntegrationsStatusUseCase: Get.find<GetLeadIntegrationsStatusUseCase>(),
      ),
    );

    Get.lazyPut<GetLeadStatusesUseCase>(
      () => GetLeadStatusesUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<CreateLeadStatusUseCase>(
      () => CreateLeadStatusUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<DeleteLeadStatusUseCase>(
      () => DeleteLeadStatusUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<GetLeadStatusDetailUseCase>(
      () => GetLeadStatusDetailUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<UpdateLeadStatusUseCase>(
      () => UpdateLeadStatusUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<AdminLeadStatusesController>(
      () => AdminLeadStatusesController(
        getLeadStatusesUseCase: Get.find<GetLeadStatusesUseCase>(),
        createLeadStatusUseCase: Get.find<CreateLeadStatusUseCase>(),
        deleteLeadStatusUseCase: Get.find<DeleteLeadStatusUseCase>(),
        getLeadStatusDetailUseCase: Get.find<GetLeadStatusDetailUseCase>(),
        updateLeadStatusUseCase: Get.find<UpdateLeadStatusUseCase>(),
      ),
    );

    Get.lazyPut<GetLeadSourcesUseCase>(
      () => GetLeadSourcesUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<GetLeadSourceDetailUseCase>(
      () => GetLeadSourceDetailUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<UpdateLeadSourceUseCase>(
      () => UpdateLeadSourceUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<CreateLeadSourceUseCase>(
      () => CreateLeadSourceUseCase(Get.find<AdminLeadsRepositoryInterface>()),
    );

    Get.lazyPut<AdminLeadSourcesController>(
      () => AdminLeadSourcesController(
        getLeadSourcesUseCase: Get.find<GetLeadSourcesUseCase>(),
        getLeadSourceDetailUseCase: Get.find<GetLeadSourceDetailUseCase>(),
        updateLeadSourceUseCase: Get.find<UpdateLeadSourceUseCase>(),
        createLeadSourceUseCase: Get.find<CreateLeadSourceUseCase>(),
      ),
    );
  }
}
