import 'package:flutter/material.dart';
import 'package:dgm360/core/theme/app_colors.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
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
  final List<String> projectStatuses = ['Active', 'Completed', 'On Hold'];
  final List<String> communicationTypes = ['Email', 'Call', 'Meeting', 'Note'];

  // Project Managers list (Symmetrical with role reps)
  final List<AppUser> projectManagers = [
    const AppUser(
      name: 'Vikash Yadav',
      email: 'vikash.yadav@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Rahul Sharma',
      email: 'rahul.sharma@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    ),
    const AppUser(
      name: 'Neha Verma',
      email: 'neha.verma@company.com',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
  ];

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
  final projectSelectedManager = Rxn<AppUser>();
  final projectSelectedStatus = Rxn<String>();
  final projectStartDate = Rxn<DateTime>();
  final projectDueDate = Rxn<DateTime>();

  // Communication form controllers
  final commSelectedType = Rxn<String>();
  late TextEditingController commSubjectController;
  late TextEditingController commToController;
  late TextEditingController commDescController;
  final commDateTime = Rxn<DateTime>();
  final commAttachmentName = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    searchFieldController = TextEditingController();
    _initializeFormControllers();
    _seedClientsFromApiResponse();
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

  // Seed Clients from the provided live API response
  void _seedClientsFromApiResponse() {
    clients.assignAll([
      Client(
        id: '2',
        name: '2R K Enterprises Pvt Ltd',
        email: 'info@rkenterprises.com',
        mobile: '+91 98765 43210',
        website: 'https://www.rkenterprises.com',
        address: 'Suite 12, Tech Tower, Mumbai',
        status: 'Active',
        notes: 'Updated client notes',
        leadId: null,
        projectsCount: 1,
        communicationsCount: 1,
        createdOn: DateTime.parse('2026-10-23T06:23:07.000000Z'),
        updatedAt: DateTime.parse('2026-10-23T06:24:14.000000Z'),
        keyContacts: const [
          KeyContact(
            name: 'Rahul Kumar',
            designation: 'Managing Director',
            mobile: '+91 98765 43210',
            email: 'rahul@rkenterprises.com',
          ),
          KeyContact(
            name: 'Neha Sharma',
            designation: 'Project Manager',
            mobile: '+91 87654 32109',
            email: 'neha@rkenterprises.com',
          ),
        ],
        projects: [
          ClientProject(
            id: 'P001',
            name: 'Website Development',
            description: 'Develop a custom WordPress website reflecting new enterprise standards.',
            startDate: DateTime(2024, 1, 1),
            dueDate: DateTime(2024, 6, 30),
            projectManager: projectManagers[0], // Vikash Yadav
            estimatedValue: 500000.0,
            status: 'Active',
          ),
          ClientProject(
            id: 'P002',
            name: 'Mobile App Development',
            description: 'Develop iOS and Android applications for employee attendance tracking.',
            startDate: DateTime(2024, 2, 15),
            dueDate: DateTime(2024, 8, 15),
            projectManager: projectManagers[1], // Rahul Sharma
            estimatedValue: 800000.0,
            status: 'Active',
          ),
          ClientProject(
            id: 'P003',
            name: 'ERP System',
            description: 'Deploy inventory tracking ERP system across regional offices.',
            startDate: DateTime(2023, 10, 10),
            dueDate: DateTime(2023, 12, 30),
            projectManager: projectManagers[2], // Neha Verma
            estimatedValue: 575000.0,
            status: 'Completed',
          ),
        ],
        communications: [
          ClientCommunication(
            id: 'CM001',
            type: 'Email',
            subject: 'Project requirement discussion',
            dateTime: DateTime(2024, 5, 20, 11, 30),
            to: 'info@rkenterprises.com',
            description: 'Sent proposal details outlining initial phase modules and timelines.',
            attachmentName: 'Design_Document.pdf',
          ),
          ClientCommunication(
            id: 'CM002',
            type: 'Call',
            subject: 'Discussed about timeline',
            dateTime: DateTime(2024, 5, 20, 10, 15),
            to: 'Rahul Kumar',
            description: 'Quick call to address timeline concerns. Client agreed on milestone payouts.',
          ),
          ClientCommunication(
            id: 'CM003',
            type: 'Meeting',
            subject: 'Kick-off meeting',
            dateTime: DateTime(2024, 5, 19, 15, 00),
            to: 'Rahul Kumar, Neha Sharma',
            description: 'Conducted a physical kick-off meeting to align engineering deliverables.',
          ),
          ClientCommunication(
            id: 'CM004',
            type: 'Note',
            subject: 'Client interested in extra module',
            dateTime: DateTime(2024, 5, 18, 16, 20),
            to: 'Internal',
            description: 'Client expressed interest in adding a shift roster module in Phase 2.',
          ),
          ClientCommunication(
            id: 'CM005',
            type: 'Email',
            subject: 'Proposal sent',
            dateTime: DateTime(2024, 5, 18, 11, 45),
            to: 'info@rkenterprises.com',
            description: 'Emailed estimated budget and scope document to Neha Sharma.',
          ),
        ],
      ),
      Client(
        id: '1',
        name: 'Greaves td',
        email: 'jdmessaging@gmail.com',
        mobile: '9930190653',
        website: '',
        address: 'Ghatkopar West, Mumbai, Apollo Bunder',
        status: 'Active',
        notes: '',
        leadId: 218,
        projectsCount: 1,
        communicationsCount: 0,
        createdOn: DateTime.parse('2026-10-23T06:16:26.000000Z'),
        updatedAt: DateTime.parse('2026-10-23T06:16:26.000000Z'),
        keyContacts: const [
          KeyContact(
            name: 'Gaurav Jadhav',
            designation: 'Commercial Lead',
            mobile: '9930190653',
            email: 'jdmessaging@gmail.com',
          ),
        ],
        projects: [
          ClientProject(
            id: 'P002',
            name: 'Supply Chain Tracker',
            description: 'Logistics and delivery tracking integration.',
            startDate: DateTime(2026, 10, 23),
            dueDate: DateTime(2027, 1, 15),
            projectManager: projectManagers[1],
            estimatedValue: 450000.0,
            status: 'Active',
          ),
        ],
        communications: const [],
      ),
    ]);
    countsAll.value = 2;
    countsActive.value = 2;
    countsInactive.value = 0;
    totalClients.value = 2;
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

      if (id.toString() == '2' && clientDetailData.value == null) {
        _seedDetailForClient2();
      }

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

  void _seedDetailForClient2() {
    clientDetailData.value = ClientDetailData(
      id: 2,
      name: "2R K Enterprises Pvt Ltd",
      email: "info@rkenterprises.com",
      mobileNumber: "+91 98765 43210",
      website: "https://www.rkenterprises.com",
      address: "Suite 12, Tech Tower, Mumbai",
      status: "Active",
      notes: "Updated client notes",
      leadId: null,
      projectsCount: 1,
      communicationsCount: 1,
      createdAt: DateTime.parse("2026-10-23T06:23:07.000000Z"),
      updatedAt: DateTime.parse("2026-10-23T06:24:14.000000Z"),
      createdBy: ClientCreatedBy(
        id: 19,
        name: "Rahul Sharma",
        email: "darshankondekar01+15@gmail.com",
      ),
      projects: [
        ClientDetailProject(
          id: 5,
          clientId: 2,
          name: "CRM Software Development",
          description: "Develop a custom CRM software as per the client business process.",
          category: "Custom ERP / CRM",
          priority: "Standard",
          startDate: "2026-10-23",
          endDate: "2027-01-21",
          workingDays: 70,
          estimatedValue: 550000.0,
          status: "In Progress",
          progress: 0,
          projectManager: ProjectManagerSummary(
            id: 7,
            name: "Rahul Sharma",
            email: "rahul@example.com",
            phone: "9876543210",
            designation: "Lead Flutter Developer",
            employeeId: "EMP-2026-007",
            department: "Engineering",
          ),
          team: [
            ProjectTeamMember(
              id: 7,
              employeeId: "EMP-2026-007",
              name: "Rahul Sharma",
              email: "rahul@example.com",
              designation: "Lead Flutter Developer",
            ),
            ProjectTeamMember(
              id: 19,
              employeeId: "EMP-2026-017",
              name: "Rahul Sharma",
              email: "darshankondekar01+15@gmail.com",
              designation: "Lead Flutter Developer",
            ),
          ],
        ),
      ],
      communications: [
        ClientDetailCommunication(
          id: 1,
          clientId: 2,
          type: "Meeting",
          subject: "Updated project review meeting remind",
          communicatedAt: DateTime.parse("2026-10-24T15:30:00+05:30"),
          recipient: "info@client.com",
          description: "Reviewed milestones and agreed on the next delivery.",
          attachmentName: "proflect-logo-cover 2.png",
          attachmentUrl: "https://attendance.digiemperor.com/storage/client-communications/dyM0ZlqGIVDaKTUmP6PMlw5R14JFNxy17j2xFXU3.png",
          createdBy: ClientCreatedBy(
            id: 19,
            name: "Rahul Sharma",
            email: "darshankondekar01+15@gmail.com",
            designation: "Lead Flutter Developer",
          ),
          createdAt: DateTime.parse("2026-10-23T06:29:46.000000Z"),
          updatedAt: DateTime.parse("2026-10-23T06:32:30.000000Z"),
        ),
      ],
    );
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
    projectSelectedManager.value = projectManagers[0];
    projectSelectedStatus.value = 'Active';
    projectStartDate.value = DateTime.now();
    projectDueDate.value = DateTime.now().add(const Duration(days: 90));
  }

  void saveProject(String clientId) {
    final idx = clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final client = clients[idx];
      final newProj = ClientProject(
        id: 'P00${client.projects.length + 10}',
        name: projectNameController.text.trim(),
        description: projectDescController.text.trim().isNotEmpty 
            ? projectDescController.text.trim() 
            : 'Custom project solution.',
        startDate: projectStartDate.value ?? DateTime.now(),
        dueDate: projectDueDate.value ?? DateTime.now().add(const Duration(days: 90)),
        projectManager: projectSelectedManager.value ?? projectManagers[0],
        estimatedValue: double.tryParse(projectValueController.text.trim()) ?? 50000.0,
        status: projectSelectedStatus.value ?? 'Active',
      );

      final updatedProjects = List<ClientProject>.from(client.projects)..add(newProj);
      final updatedClient = client.copyWith(projects: updatedProjects);

      clients[idx] = updatedClient;
      if (selectedClient.value?.id == clientId) {
        selectedClient.value = updatedClient;
      }
      _showSnackbar('Success 🎉', 'Project assigned to client', const Color(0xFF10B981));
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
  }

  void saveCommunication(String clientId) {
    final idx = clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final client = clients[idx];
      final newComm = ClientCommunication(
        id: 'CM00${client.communications.length + 10}',
        type: commSelectedType.value ?? 'Email',
        subject: commSubjectController.text.trim(),
        dateTime: commDateTime.value ?? DateTime.now(),
        to: commToController.text.trim().isNotEmpty ? commToController.text.trim() : 'info@client.com',
        description: commDescController.text.trim(),
        attachmentName: commAttachmentName.value,
      );

      final updatedComms = List<ClientCommunication>.from(client.communications)..insert(0, newComm);
      final updatedClient = client.copyWith(communications: updatedComms);

      clients[idx] = updatedClient;
      if (selectedClient.value?.id == clientId) {
        selectedClient.value = updatedClient;
      }
      _showSnackbar('Success 🎉', 'Communication entry logged', const Color(0xFF10B981));
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
