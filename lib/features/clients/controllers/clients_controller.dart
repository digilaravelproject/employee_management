import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/client_model.dart';

class ClientsController extends GetxController {
  // Reactive list of clients
  final clients = <Client>[].obs;

  // Selected client for details
  final selectedClient = Rxn<Client>();

  // Filter and search states
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'All'.obs; // All, Active, Inactive

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
    _initializeFormControllers();
    _seedDummyClients();
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

  // Seed Dummy Clients Matching Mockups Exactly
  void _seedDummyClients() {
    clients.assignAll([
      Client(
        id: 'C001',
        name: 'R K Enterprises',
        email: 'info@rkenterprises.com',
        mobile: '+91 98765 43210',
        website: 'www.rkenterprises.com',
        address: '123, Business Park, Andheri West, Mumbai - 400053, Maharashtra, India',
        status: 'Active',
        notes: 'Important client. Handle with priority.',
        createdOn: DateTime(2024, 1, 1),
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
        id: 'C002',
        name: 'Tech Solutions Pvt Ltd',
        email: 'contact@techsolutions.com',
        mobile: '+91 87654 32109',
        website: 'www.techsolutions.com',
        address: '45, Technology Hub, Sector 62, Noida, NCR, India',
        status: 'Active',
        notes: 'Monthly billing client. Retainer contract.',
        createdOn: DateTime(2024, 2, 10),
        keyContacts: const [
          KeyContact(
            name: 'Aman Verma',
            designation: 'CTO',
            mobile: '+91 87654 32109',
            email: 'aman@techsolutions.com',
          ),
        ],
        projects: [],
        communications: [],
      ),
      Client(
        id: 'C003',
        name: 'Digital India Pvt Ltd',
        email: 'hello@digitalindia.com',
        mobile: '+91 76543 21098',
        website: 'www.digitalindia.com',
        address: '56, Connaught Place, New Delhi - 110001, India',
        status: 'Active',
        notes: 'Government contractor. Extended delivery timeline.',
        createdOn: DateTime(2024, 3, 1),
        keyContacts: const [],
        projects: [],
        communications: [],
      ),
      Client(
        id: 'C004',
        name: 'Future Soft',
        email: 'support@futuresoft.com',
        mobile: '+91 65432 10987',
        website: 'www.futuresoft.com',
        address: '89, IT Park, Hinjewadi, Pune - 411057, Maharashtra, India',
        status: 'Inactive',
        notes: 'Account suspended due to payment delinquency.',
        createdOn: DateTime(2024, 1, 15),
        keyContacts: const [],
        projects: [],
        communications: [],
      ),
      Client(
        id: 'C005',
        name: 'Bright Marketing',
        email: 'info@brightmarketing.com',
        mobile: '+91 54321 09876',
        website: 'www.brightmarketing.com',
        address: '12, MG Road, Bengaluru - 560001, Karnataka, India',
        status: 'Active',
        notes: 'New referral client. High potential.',
        createdOn: DateTime(2024, 4, 20),
        keyContacts: const [],
        projects: [],
        communications: [],
      ),
      Client(
        id: 'C006',
        name: 'Webcraft Solutions',
        email: 'sales@webcraft.com',
        mobile: '+91 67890 12345',
        website: 'www.webcraft.com',
        address: '234, Infocity, Gandhinagar - 382007, Gujarat, India',
        status: 'Active',
        notes: 'E-commerce platform development.',
        createdOn: DateTime(2024, 5, 1),
        keyContacts: const [],
        projects: [],
        communications: [],
      ),
    ]);
  }

  // Active / Inactive Filtering Calculations
  int get totalClientsCount => clients.length;
  int get activeClientsCount => clients.where((c) => c.status == 'Active').length;
  int get inactiveClientsCount => clients.where((c) => c.status == 'Inactive').length;

  List<Client> get filteredClients {
    List<Client> temp = List.from(clients);

    if (selectedStatusFilter.value != 'All') {
      temp = temp.where((c) => c.status == selectedStatusFilter.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      temp = temp.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q) ||
        c.mobile.toLowerCase().contains(q)
      ).toList();
    }

    temp.sort((a, b) => b.createdOn.compareTo(a.createdOn));
    return temp;
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
    nameController.text = client.name;
    emailController.text = client.email;
    mobileController.text = client.mobile;
    websiteController.text = client.website;
    addressController.text = client.address;
    notesController.text = client.notes;
    formSelectedStatus.value = client.status;
  }

  void saveClient({String? id}) {
    if (id == null) {
      // Create new client
      final newClient = Client(
        id: 'C00${clients.length + 1}',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        website: websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : 'www.client.com',
        address: addressController.text.trim(),
        status: formSelectedStatus.value ?? 'Active',
        notes: notesController.text.trim(),
        keyContacts: [],
        projects: [],
        communications: [],
        createdOn: DateTime.now(),
      );
      clients.add(newClient);
      _showSnackbar('Success 🎉', 'Client added successfully', const Color(0xFF10B981));
    } else {
      // Edit existing
      final idx = clients.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final existing = clients[idx];
        final updated = existing.copyWith(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobileController.text.trim(),
          website: websiteController.text.trim(),
          address: addressController.text.trim(),
          status: formSelectedStatus.value ?? existing.status,
          notes: notesController.text.trim(),
        );
        clients[idx] = updated;
        if (selectedClient.value?.id == id) {
          selectedClient.value = updated;
        }
        _showSnackbar('Success 🎉', 'Client details updated', const Color(0xFF3B82F6));
      }
    }
  }

  void deleteClient(String id) {
    clients.removeWhere((c) => c.id == id);
    if (selectedClient.value?.id == id) {
      selectedClient.value = null;
    }
    _showSnackbar('Deleted 🗑️', 'Client removed from database', const Color(0xFFEF4444));
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
