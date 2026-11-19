import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dgm360/core/theme/app_colors.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/client_model.dart';
import '../models/client_detail_model.dart';
import '../models/clients_response_model.dart';
import '../repositories/clients_repository.dart';
import '../repositories/clients_repository_interface.dart';

class ClientsController extends GetxController {
  final ClientsRepositoryInterface repository;

  ClientsController({ClientsRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<ClientsRepositoryInterface>()
                ? Get.find<ClientsRepositoryInterface>()
                : ClientsRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : ApiClient(),
                  ));

  // Reactive list of clients
  final clients = <Client>[].obs;

  // Selected client for details
  final selectedClient = Rxn<Client>();

  // Full detailed client data from GET /api/admin/clients/{id}
  final clientDetailData = Rxn<ClientDetailData>();
  final isDetailLoading = false.obs;
  final detailErrorMessage = ''.obs;

  // API State
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSearching = false.obs;
  final isSavingClient = false.obs;
  final isDeletingClient = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Pagination State
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final hasMorePages = false.obs;
  final totalClients = 2.obs;

  // API Counts
  final countsAll = 2.obs;
  final countsActive = 2.obs;
  final countsInactive = 0.obs;

  // Filter and search states
  late TextEditingController searchFieldController;
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'All'.obs; // All, Active, Inactive
  Worker? _searchWorker;

  // Dropdown lists
  final List<String> clientStatuses = ['Active', 'Inactive'];
  final List<String> projectStatuses = ['Active', 'In Progress', 'Completed', 'On Hold'];
  final List<String> communicationTypes = ['Email', 'Call', 'Meeting', 'Note'];

  // Project Managers list (Dynamically mapped from employees)
  List<AppUser> get projectManagers {
    if (Get.isRegistered<EmployeeController>()) {
      final empCtrl = Get.find<EmployeeController>();
      if (empCtrl.employees.isNotEmpty) {
        return empCtrl.employees
            .where((e) => e.name.isNotEmpty)
            .map((e) => AppUser(
                  id: int.tryParse(e.id),
                  name: e.name,
                  email: e.email,
                  avatarUrl: e.profilePic ?? '',
                ))
            .toList();
      }
    }
    return [];
  }

  // Forms Text Editing Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController websiteController;
  late TextEditingController addressController;
  late TextEditingController notesController;

  // Selected status in Form
  final formSelectedStatus = Rxn<String>();

  // Project form controllers
  late TextEditingController projectNameController;
  late TextEditingController projectDescController;
  late TextEditingController projectValueController;
  final projectSelectedCategory = Rxn<String>();
  final projectSelectedManager = Rxn<AppUser>();
  final projectSelectedStatus = Rxn<String>();
  final projectStartDate = Rxn<DateTime>();
  final projectDueDate = Rxn<DateTime>();
  final isSubmittingProject = false.obs;
  final List<String> projectCategories = [
    'Custom ERP / CRM',
    'Web Development',
    'Mobile App Development',
    'E-Commerce',
    'UI/UX Design',
    'Cloud & DevOps',
    'Software Maintenance',
    'Digital Marketing',
    'Other',
  ];

  // Live Client Projects
  final clientProjects = <ClientDetailProject>[].obs;
  final clientProjectsCounts = Rxn<ClientProjectsCounts>();
  final clientProjectsClientInfo = Rxn<ClientProjectsClientInfo>();
  final isLoadingClientProjects = false.obs;
  final clientProjectsCurrentStatus = 'all'.obs;

  // Communication form controllers
  final commSelectedType = Rxn<String>();
  late TextEditingController commSubjectController;
  late TextEditingController commToController;
  late TextEditingController commDescController;
  final commDateTime = Rxn<DateTime>();
  final commAttachmentName = Rxn<String>();
  final commAttachmentPath = Rxn<String>();
  final commAttachmentSize = Rxn<int>();
  final isSubmittingComm = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchFieldController = TextEditingController();
    _initializeFormControllers();
    fetchClientsFromApi(page: 1, resetPagination: true);

    // Debounce search input to call search API automatically
    _searchWorker = debounce(searchQuery, (query) {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        fetchClientsFromApi(page: 1, resetPagination: true);
      } else {
        searchClientsFromApi(query: trimmed, page: 1, resetPagination: true);
      }
    }, time: const Duration(milliseconds: 400));
  }

  void _initializeFormControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    mobileController = TextEditingController();
    websiteController = TextEditingController();
    addressController = TextEditingController();
    notesController = TextEditingController();

    projectNameController = TextEditingController();
    projectDescController = TextEditingController();
    projectValueController = TextEditingController();

    commSubjectController = TextEditingController();
    commToController = TextEditingController();
    commDescController = TextEditingController();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchFieldController.dispose();
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    websiteController.dispose();
    addressController.dispose();
    notesController.dispose();

    projectNameController.dispose();
    projectDescController.dispose();
    projectValueController.dispose();

    commSubjectController.dispose();
    commToController.dispose();
    commDescController.dispose();
    super.onClose();
  }

  /// Fetch clients live from the API: /api/admin/clients?status=all&per_page=15&page=1
  Future<void> fetchClientsFromApi({
    String? status,
    int page = 1,
    bool isLoadMore = false,
    bool resetPagination = false,
  }) async {
    try {
      if (isLoadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';

      if (resetPagination) {
        currentPage.value = 1;
        hasMorePages.value = false;
      }

      final filterStatus = status ?? (selectedStatusFilter.value == 'All' ? 'all' : selectedStatusFilter.value.toLowerCase());
      final ClientsResponseModel response = await repository.getClients(
        status: filterStatus,
        page: page,
        perPage: 15,
      );

      if (response.status) {
        if (isLoadMore) {
          clients.addAll(response.data);
        } else {
          clients.assignAll(response.data);
        }

        if (response.pagination != null) {
          currentPage.value = response.pagination!.currentPage;
          lastPage.value = response.pagination!.lastPage;
          hasMorePages.value = response.pagination!.hasMore;
          totalClients.value = response.pagination!.total;
        } else {
          currentPage.value = page;
          lastPage.value = 1;
          hasMorePages.value = false;
          totalClients.value = clients.length;
        }

        if (response.counts != null) {
          countsAll.value = response.counts!.all;
          countsActive.value = response.counts!.active;
          countsInactive.value = response.counts!.inactive;
        } else {
          countsAll.value = totalClients.value;
          countsActive.value = clients.where((c) => c.status.toLowerCase() == 'active').length;
          countsInactive.value = clients.where((c) => c.status.toLowerCase() == 'inactive').length;
        }
      } else {
        if (!isLoadMore) {
          hasError.value = true;
          errorMessage.value = response.message;
        }
      }
    } catch (e) {
      if (!isLoadMore) {
        hasError.value = true;
        errorMessage.value = e.toString();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Search clients live from API: /api/admin/clients/search?query=...&status=...&per_page=15&page=...
  Future<void> searchClientsFromApi({
    required String query,
    String? status,
    int page = 1,
    bool isLoadMore = false,
    bool resetPagination = false,
  }) async {
    try {
      if (isLoadMore) {
        isLoadingMore.value = true;
      } else {
        isSearching.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';

      if (resetPagination) {
        currentPage.value = 1;
        hasMorePages.value = false;
      }

      final filterStatus = status ?? (selectedStatusFilter.value == 'All' ? 'all' : selectedStatusFilter.value.toLowerCase());
      final ClientsResponseModel response = await repository.searchClients(
        query: query,
        status: filterStatus,
        page: page,
        perPage: 15,
      );

      if (response.status) {
        if (isLoadMore) {
          clients.addAll(response.data);
        } else {
          clients.assignAll(response.data);
        }

        if (response.pagination != null) {
          currentPage.value = response.pagination!.currentPage;
          lastPage.value = response.pagination!.lastPage;
          hasMorePages.value = response.pagination!.hasMore;
          totalClients.value = response.pagination!.total;
        } else {
          currentPage.value = page;
          lastPage.value = 1;
          hasMorePages.value = false;
          totalClients.value = clients.length;
        }

        if (response.counts != null) {
          countsAll.value = response.counts!.all;
          countsActive.value = response.counts!.active;
          countsInactive.value = response.counts!.inactive;
        }
      } else {
        if (!isLoadMore) {
          hasError.value = true;
          errorMessage.value = response.message;
        }
      }
    } catch (e) {
      if (!isLoadMore) {
        hasError.value = true;
        errorMessage.value = e.toString();
      }
    } finally {
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Triggers pagination when user scrolls near the bottom of the list
  void loadMoreClients() {
    if (!hasMorePages.value || isLoadingMore.value || isLoading.value || isSearching.value) {
      return;
    }
    final nextPage = currentPage.value + 1;
    if (searchQuery.value.trim().isNotEmpty) {
      searchClientsFromApi(
        query: searchQuery.value.trim(),
        page: nextPage,
        isLoadMore: true,
      );
    } else {
      fetchClientsFromApi(
        page: nextPage,
        isLoadMore: true,
      );
    }
  }

  void onSearchTextChanged(String text) {
    searchQuery.value = text;
  }

  void clearSearch() {
    searchFieldController.clear();
    searchQuery.value = '';
    fetchClientsFromApi(page: 1, resetPagination: true);
  }

  void onStatusFilterChanged(String status) {
    selectedStatusFilter.value = status;
    final filterStatus = status == 'All' ? 'all' : status.toLowerCase();
    if (searchQuery.value.trim().isNotEmpty) {
      searchClientsFromApi(
        query: searchQuery.value.trim(),
        status: filterStatus,
        page: 1,
        resetPagination: true,
      );
    } else {
      fetchClientsFromApi(
        status: filterStatus,
        page: 1,
        resetPagination: true,
      );
    }
  }

  /// Fetch client details live from API: /api/admin/clients/{id}
  Future<void> fetchClientDetail(dynamic id) async {
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';

      final response = await repository.getClientDetail(id);

      if (response.status && response.data != null) {
        clientDetailData.value = response.data;
        final d = response.data!;
        selectedClient.value = Client(
          id: d.id.toString(),
          name: d.name,
          email: d.email,
          mobile: d.mobileNumber,
          website: d.website,
          address: d.address,
          status: d.status,
          notes: d.notes,
          leadId: d.leadId,
          projectsCount: d.projectsCount,
          communicationsCount: d.communicationsCount,
          keyContacts: selectedClient.value?.keyContacts ?? const [],
          projects: d.projects.map((p) => ClientProject(
            id: p.id.toString(),
            name: p.name,
            description: p.description,
            startDate: DateTime.tryParse(p.startDate) ?? DateTime.now(),
            dueDate: DateTime.tryParse(p.endDate) ?? DateTime.now(),
            projectManager: AppUser(
              name: p.projectManager?.name ?? 'Assigned Manager',
              email: p.projectManager?.email ?? '',
              avatarUrl: p.projectManager?.avatar ?? '',
            ),
            estimatedValue: p.estimatedValue,
            status: p.status,
          )).toList(),
          communications: d.communications.map((c) => ClientCommunication(
            id: c.id.toString(),
            type: c.type,
            subject: c.subject,
            dateTime: c.communicatedAt ?? DateTime.now(),
            to: c.recipient,
            description: c.description,
            attachmentName: c.attachmentName,
            attachmentUrl: c.attachmentUrl,
          )).toList(),
          createdOn: d.createdAt ?? DateTime.now(),
          updatedAt: d.updatedAt,
        );
      } else if (response.message.isNotEmpty) {
        detailErrorMessage.value = response.message;
      }
    } catch (e) {
      detailErrorMessage.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }

  // Active / Inactive Filtering Calculations
  int get totalClientsCount => countsAll.value > 0 ? countsAll.value : clients.length;
  int get activeClientsCount => countsActive.value > 0 ? countsActive.value : clients.where((c) => c.status.toLowerCase() == 'active').length;
  int get inactiveClientsCount => countsInactive.value > 0 ? countsInactive.value : clients.where((c) => c.status.toLowerCase() == 'inactive').length;

  List<Client> get filteredClients {
    if (hasError.value) {
      List<Client> temp = List.from(clients);
      if (selectedStatusFilter.value != 'All') {
        temp = temp.where((c) => c.status.toLowerCase() == selectedStatusFilter.value.toLowerCase()).toList();
      }
      if (searchQuery.value.trim().isNotEmpty) {
        final q = searchQuery.value.trim().toLowerCase();
        temp = temp.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.mobile.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q) ||
          c.website.toLowerCase().contains(q) ||
          c.notes.toLowerCase().contains(q) ||
          (c.leadId != null && c.leadId.toString().contains(q))
        ).toList();
      }
      temp.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return temp;
    }
    return clients;
  }

  // Form Operations
  void clearForm() {
    nameController.clear();
    emailController.clear();
    mobileController.clear();
    websiteController.clear();
    addressController.clear();
    notesController.clear();
    formSelectedStatus.value = 'Active';
  }

  void initializeEditing(Client client) {
    final detail = clientDetailData.value;
    final isSameClient = detail != null && detail.id.toString() == client.id.toString();

    nameController.text = (isSameClient && detail.name.isNotEmpty) ? detail.name : client.name;
    emailController.text = (isSameClient && detail.email.isNotEmpty) ? detail.email : client.email;
    mobileController.text = (isSameClient && detail.mobileNumber.isNotEmpty) ? detail.mobileNumber : client.mobile;
    websiteController.text = (isSameClient && detail.website.isNotEmpty) ? detail.website : client.website;
    addressController.text = (isSameClient && detail.address.isNotEmpty) ? detail.address : client.address;
    notesController.text = (isSameClient && detail.notes.isNotEmpty) ? detail.notes : client.notes;
    formSelectedStatus.value = (isSameClient && detail.status.isNotEmpty) ? detail.status : client.status;
  }

  Future<bool> saveClient({String? id}) async {
    if (id == null) {
      // Create new client via API
      try {
        isSavingClient.value = true;
        final payload = <String, dynamic>{
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'mobile_number': mobileController.text.trim(),
          'website': websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : null,
          'address': addressController.text.trim(),
          'status': formSelectedStatus.value ?? 'Active',
          'notes': notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        };

        final CreateClientResponse response = await repository.createClient(payload);

        if (response.status && response.data != null) {
          final createdClient = response.data!;
          clients.insert(0, createdClient);
          countsAll.value++;
          if (createdClient.status.toLowerCase() == 'active') {
            countsActive.value++;
          } else {
            countsInactive.value++;
          }
          totalClients.value++;

          clearForm();
          _showSnackbar(
            'Success 🎉',
            response.message.isNotEmpty ? response.message : 'Client created successfully.',
            const Color(0xFF10B981),
          );

          // Refresh list in background to sync with server pagination
          fetchClientsFromApi(resetPagination: true);

          return true;
        } else {
          _showSnackbar(
            'Error ⚠️',
            response.message.isNotEmpty ? response.message : 'Failed to create client.',
            const Color(0xFFEF4444),
          );
          return false;
        }
      } catch (e) {
        _showSnackbar('Error ⚠️', e.toString(), const Color(0xFFEF4444));
        return false;
      } finally {
        isSavingClient.value = false;
      }
    } else {
      // Edit / Update existing client via PATCH API
      try {
        isSavingClient.value = true;
        final payload = <String, dynamic>{
          'name': nameController.text.trim(),
          'website': websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : null,
          'status': formSelectedStatus.value ?? 'Active',
          'notes': notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        };

        if (emailController.text.trim().isNotEmpty) {
          payload['email'] = emailController.text.trim();
        }
        if (mobileController.text.trim().isNotEmpty) {
          payload['mobile_number'] = mobileController.text.trim();
        }
        if (addressController.text.trim().isNotEmpty) {
          payload['address'] = addressController.text.trim();
        }

        final UpdateClientResponse response = await repository.updateClient(id, payload);

        if (response.status) {
          final idx = clients.indexWhere((c) => c.id == id.toString());
          final existing = idx != -1 ? clients[idx] : null;

          final updatedClient = response.data ??
              (existing != null
                  ? existing.copyWith(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      mobile: mobileController.text.trim(),
                      website: websiteController.text.trim(),
                      address: addressController.text.trim(),
                      status: formSelectedStatus.value ?? existing.status,
                      notes: notesController.text.trim(),
                    )
                  : Client(
                      id: id.toString(),
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      mobile: mobileController.text.trim(),
                      website: websiteController.text.trim(),
                      address: addressController.text.trim(),
                      status: formSelectedStatus.value ?? 'Active',
                      notes: notesController.text.trim(),
                      keyContacts: const [],
                      projects: const [],
                      communications: const [],
                      createdOn: DateTime.now(),
                    ));

          final mergedClient = existing != null
              ? updatedClient.copyWith(
                  keyContacts: updatedClient.keyContacts.isNotEmpty ? updatedClient.keyContacts : existing.keyContacts,
                  projects: updatedClient.projects.isNotEmpty ? updatedClient.projects : existing.projects,
                  communications: updatedClient.communications.isNotEmpty ? updatedClient.communications : existing.communications,
                  projectsCount: updatedClient.projectsCount > 0 ? updatedClient.projectsCount : existing.projectsCount,
                  communicationsCount: updatedClient.communicationsCount > 0 ? updatedClient.communicationsCount : existing.communicationsCount,
                )
              : updatedClient;

          if (idx != -1) {
            clients[idx] = mergedClient;
          } else {
            clients.insert(0, mergedClient);
          }
          clients.refresh();

          if (selectedClient.value?.id == id.toString()) {
            selectedClient.value = mergedClient;
          }

          if (response.detailData != null) {
            clientDetailData.value = response.detailData;
          }

          _showSnackbar(
            'Success 🎉',
            response.message.isNotEmpty ? response.message : 'Client updated successfully.',
            AppColors.primaryColor,
          );

          // Refresh list in background to sync server counts & pagination
          fetchClientsFromApi(resetPagination: true);

          return true;
        } else {
          _showSnackbar(
            'Error ⚠️',
            response.message.isNotEmpty ? response.message : 'Failed to update client.',
            const Color(0xFFEF4444),
          );
          return false;
        }
      } catch (e) {
        _showSnackbar('Error ⚠️', e.toString(), const Color(0xFFEF4444));
        return false;
      } finally {
        isSavingClient.value = false;
      }
    }
  }

  Future<bool> deleteClient(dynamic id) async {
    try {
      isDeletingClient.value = true;
      final DeleteClientResponse response = await repository.deleteClient(id);

      if (response.status) {
        clients.removeWhere((c) => c.id.toString() == id.toString());
        if (selectedClient.value?.id.toString() == id.toString()) {
          selectedClient.value = null;
        }
        totalClients.value = clients.length;
        countsAll.value = clients.length;
        countsActive.value = clients.where((c) => c.status.toLowerCase() == 'active').length;
        countsInactive.value = clients.where((c) => c.status.toLowerCase() == 'inactive').length;

        // Refresh list in background to sync with server pagination
        fetchClientsFromApi(resetPagination: true);

        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Client deleted successfully.',
        );
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to delete client.',
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
      return false;
    } finally {
      isDeletingClient.value = false;
    }
  }

  // Symmetrical Projects Management
  void clearProjectForm() {
    projectNameController.clear();
    projectDescController.clear();
    projectValueController.clear();
    projectSelectedCategory.value = projectCategories[0];
    projectSelectedManager.value = projectManagers.isNotEmpty ? projectManagers[0] : null;
    projectSelectedStatus.value = 'Active';
    projectStartDate.value = DateTime.now();
    projectDueDate.value = DateTime.now().add(const Duration(days: 90));
  }

  Future<bool> saveProject(dynamic clientId) async {
    isSubmittingProject.value = true;
    try {
      final name = projectNameController.text.trim();
      final desc = projectDescController.text.trim();
      final category = projectSelectedCategory.value ?? 'Custom ERP / CRM';
      final startDate = projectStartDate.value ?? DateTime.now();
      final dueDate = projectDueDate.value ?? DateTime.now().add(const Duration(days: 90));
      final valStr = projectValueController.text.replaceAll(',', '').replaceAll(' ', '').trim();
      final estVal = double.tryParse(valStr) ?? 0.0;
      final status = projectSelectedStatus.value ?? 'Active';

      final Map<String, dynamic> data = {
        'name': name,
        'description': desc.isNotEmpty ? desc : 'Custom project requirement.',
        'category': category,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(dueDate),
        'estimated_value': estVal,
        'status': status,
      };

      final response = await repository.addClientProject(
        clientId: clientId,
        data: data,
      );

      if (response.status) {
        if (response.data != null) {
          final p = response.data!;
          final newClientProject = ClientProject(
            id: p.id.toString(),
            name: p.name,
            description: p.description,
            startDate: DateTime.tryParse(p.startDate) ?? startDate,
            dueDate: DateTime.tryParse(p.endDate) ?? dueDate,
            projectManager: AppUser(
              name: p.projectManager?.name ?? 'Assigned Manager',
              email: p.projectManager?.email ?? '',
              avatarUrl: p.projectManager?.avatar ?? '',
            ),
            estimatedValue: p.estimatedValue,
            status: p.status,
          );

          if (selectedClient.value != null &&
              (selectedClient.value!.id == clientId.toString() || selectedClient.value!.id == clientId)) {
            final updatedProjects = List<ClientProject>.from(selectedClient.value!.projects)
              ..insert(0, newClientProject);
            selectedClient.value = selectedClient.value!.copyWith(
              projects: updatedProjects,
              projectsCount: selectedClient.value!.projectsCount + 1,
            );
          }

          final clientIdx = clients.indexWhere((c) => c.id == clientId.toString() || c.id == clientId);
          if (clientIdx != -1) {
            final client = clients[clientIdx];
            final updatedProjects = List<ClientProject>.from(client.projects)
              ..insert(0, newClientProject);
            clients[clientIdx] = client.copyWith(
              projects: updatedProjects,
              projectsCount: client.projectsCount + 1,
            );
          }
        }

        fetchClientDetail(clientId);
        fetchClientProjects(clientId, status: clientProjectsCurrentStatus.value);

        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Project added to client successfully.',
        );
        clearProjectForm();
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to add project to client.',
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error adding project: $e');
      return false;
    } finally {
      isSubmittingProject.value = false;
    }
  }

  Future<void> fetchClientProjects(dynamic clientId, {String status = 'all'}) async {
    isLoadingClientProjects.value = true;
    clientProjectsCurrentStatus.value = status;
    try {
      final response = await repository.getClientProjects(
        clientId: clientId,
        status: status,
      );

      if (response.status) {
        clientProjects.assignAll(response.data);
        clientProjectsCounts.value = response.counts;
        if (response.client != null) {
          clientProjectsClientInfo.value = response.client;
        }

        if (selectedClient.value != null &&
            (selectedClient.value!.id == clientId.toString() || selectedClient.value!.id == clientId)) {
          selectedClient.value = selectedClient.value!.copyWith(
            projectsCount: response.counts.all > 0 ? response.counts.all : response.total,
          );
        }
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to retrieve client projects.',
        );
      }
    } catch (e) {
      CustomSnackbar.showError('Error loading projects: $e');
    } finally {
      isLoadingClientProjects.value = false;
    }
  }

  // Symmetrical Communications Management
  void clearCommForm() {
    commSelectedType.value = 'Email';
    commSubjectController.clear();
    commToController.clear();
    commDescController.clear();
    commDateTime.value = DateTime.now();
    commAttachmentName.value = null;
    commAttachmentPath.value = null;
    commAttachmentSize.value = null;
  }

  Future<bool> saveCommunication(dynamic clientId) async {
    final subject = commSubjectController.text.trim();
    final recipient = commToController.text.trim();
    final description = commDescController.text.trim();
    final type = commSelectedType.value ?? 'Email';
    final commDate = commDateTime.value ?? DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(commDate);

    if (subject.isEmpty || recipient.isEmpty || description.isEmpty) {
      _showSnackbar('Required Fields', 'Please fill in all required fields.', AppColors.errorColor);
      return false;
    }

    isSubmittingComm.value = true;
    try {
      final Map<String, dynamic> formMap = {
        'type': type,
        'subject': subject,
        'communicated_at': formattedDate,
        'recipient': recipient,
        'description': description,
      };

      if (commAttachmentPath.value != null && commAttachmentPath.value!.isNotEmpty) {
        formMap['attachment'] = await MultipartFile.fromFile(
          commAttachmentPath.value!,
          filename: commAttachmentName.value ?? 'attachment',
        );
      }

      final formData = FormData.fromMap(formMap);
      final response = await repository.addCommunication(
        clientId: clientId,
        formData: formData,
      );

      if (response.status) {
        final newCommData = response.data;
        final newComm = ClientCommunication(
          id: (newCommData?.id ?? DateTime.now().millisecondsSinceEpoch).toString(),
          type: newCommData?.type ?? type,
          subject: newCommData?.subject ?? subject,
          dateTime: newCommData?.communicatedAt ?? commDate,
          to: newCommData?.recipient ?? recipient,
          description: newCommData?.description ?? description,
          attachmentName: newCommData?.attachmentName ?? commAttachmentName.value,
          attachmentUrl: newCommData?.attachmentUrl,
        );

        if (selectedClient.value != null &&
            (selectedClient.value!.id == clientId.toString() || selectedClient.value!.id == clientId)) {
          final updatedComms = List<ClientCommunication>.from(selectedClient.value!.communications)..insert(0, newComm);
          selectedClient.value = selectedClient.value!.copyWith(
            communications: updatedComms,
            communicationsCount: selectedClient.value!.communicationsCount + 1,
          );
        }

        final idx = clients.indexWhere((c) => c.id == clientId.toString() || c.id == clientId);
        if (idx != -1) {
          final client = clients[idx];
          final updatedComms = List<ClientCommunication>.from(client.communications)..insert(0, newComm);
          clients[idx] = client.copyWith(
            communications: updatedComms,
            communicationsCount: client.communicationsCount + 1,
          );
        }

        // Fetch fresh client detail from backend
        fetchClientDetail(clientId);

        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Client communication added successfully.',
        );
        clearCommForm();
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to add communication.',
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to add communication: $e');
      return false;
    } finally {
      isSubmittingComm.value = false;
    }
  }

  Future<ClientDetailCommunication?> fetchCommunicationDetail({
    required dynamic clientId,
    required dynamic communicationId,
  }) async {
    try {
      final response = await repository.getCommunicationDetail(
        clientId: clientId,
        communicationId: communicationId,
      );
      if (response.status && response.data != null) {
        return response.data;
      }
      if (response.message.isNotEmpty) {
        CustomSnackbar.showError(response.message);
      }
      return null;
    } catch (e) {
      CustomSnackbar.showError('Error fetching communication: $e');
      return null;
    }
  }

  Future<bool> updateCommunication({
    required dynamic clientId,
    required dynamic communicationId,
    required Map<String, dynamic> data,
  }) async {
    isSubmittingComm.value = true;
    try {
      final response = await repository.updateCommunication(
        clientId: clientId,
        communicationId: communicationId,
        data: data,
      );

      if (response.status) {
        final updatedData = response.data;
        if (updatedData != null) {
          final updatedComm = ClientCommunication(
            id: updatedData.id.toString(),
            type: updatedData.type,
            subject: updatedData.subject,
            dateTime: updatedData.communicatedAt ?? DateTime.now(),
            to: updatedData.recipient,
            description: updatedData.description,
            attachmentName: updatedData.attachmentName,
            attachmentUrl: updatedData.attachmentUrl,
          );

          if (selectedClient.value != null &&
              (selectedClient.value!.id == clientId.toString() || selectedClient.value!.id == clientId)) {
            final comms = List<ClientCommunication>.from(selectedClient.value!.communications);
            final idx = comms.indexWhere((c) => c.id == communicationId.toString() || c.id == communicationId);
            if (idx != -1) {
              comms[idx] = updatedComm;
              selectedClient.value = selectedClient.value!.copyWith(communications: comms);
            }
          }

          final clientIdx = clients.indexWhere((c) => c.id == clientId.toString() || c.id == clientId);
          if (clientIdx != -1) {
            final client = clients[clientIdx];
            final comms = List<ClientCommunication>.from(client.communications);
            final idx = comms.indexWhere((c) => c.id == communicationId.toString() || c.id == communicationId);
            if (idx != -1) {
              comms[idx] = updatedComm;
              clients[clientIdx] = client.copyWith(communications: comms);
            }
          }
        }

        fetchClientDetail(clientId);

        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Client communication updated successfully.',
        );
        clearCommForm();
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to update communication.',
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to update communication: $e');
      return false;
    } finally {
      isSubmittingComm.value = false;
    }
  }

  Future<bool> deleteCommunication({
    required dynamic clientId,
    required dynamic communicationId,
  }) async {
    try {
      final DeleteClientResponse response = await repository.deleteCommunication(
        clientId: clientId,
        communicationId: communicationId,
      );

      if (response.status) {
        if (selectedClient.value != null &&
            (selectedClient.value!.id == clientId.toString() || selectedClient.value!.id == clientId)) {
          final comms = List<ClientCommunication>.from(selectedClient.value!.communications);
          comms.removeWhere((c) => c.id.toString() == communicationId.toString());
          final newCount = (selectedClient.value!.communicationsCount > 0)
              ? selectedClient.value!.communicationsCount - 1
              : comms.length;
          selectedClient.value = selectedClient.value!.copyWith(
            communications: comms,
            communicationsCount: newCount,
          );
        }

        final clientIdx = clients.indexWhere((c) => c.id == clientId.toString() || c.id == clientId);
        if (clientIdx != -1) {
          final client = clients[clientIdx];
          final comms = List<ClientCommunication>.from(client.communications);
          comms.removeWhere((c) => c.id.toString() == communicationId.toString());
          final newCount = (client.communicationsCount > 0)
              ? client.communicationsCount - 1
              : comms.length;
          clients[clientIdx] = client.copyWith(
            communications: comms,
            communicationsCount: newCount,
          );
        }

        fetchClientDetail(clientId);

        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Client communication deleted successfully.',
        );
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to delete communication.',
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to delete communication: $e');
      return false;
    }
  }

  void _showSnackbar(String title, String message, Color bgColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }
}
