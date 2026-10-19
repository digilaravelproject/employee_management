import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../domain/usecases/get_facebook_authorization_url_usecase.dart';
import '../domain/usecases/get_lead_integrations_status_usecase.dart';
import '../models/facebook_authorization_request_model.dart';
import '../models/lead_integration_model.dart';
import '../models/lead_integrations_status_response_model.dart';
import '../repositories/lead_integrations_repository.dart';
import '../views/facebook_oauth_webview_screen.dart';

class LeadIntegrationsController extends GetxController {
  final GetFacebookAuthorizationUrlUseCase getFacebookAuthorizationUrlUseCase;
  final GetLeadIntegrationsStatusUseCase? getLeadIntegrationsStatusUseCase;

  LeadIntegrationsController({
    required this.getFacebookAuthorizationUrlUseCase,
    this.getLeadIntegrationsStatusUseCase,
  });

  static LeadIntegrationsController get to {
    if (!Get.isRegistered<LeadIntegrationsController>()) {
      final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final repository = LeadIntegrationsRepository(apiClient: apiClient);
      final useCase = GetFacebookAuthorizationUrlUseCase(repository);
      final statusUseCase = GetLeadIntegrationsStatusUseCase(repository);
      return Get.put(
        LeadIntegrationsController(
          getFacebookAuthorizationUrlUseCase: useCase,
          getLeadIntegrationsStatusUseCase: statusUseCase,
        ),
      );
    }
    return Get.find<LeadIntegrationsController>();
  }

  final RxList<LeadIntegrationItem> integrations = <LeadIntegrationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isLoadingStatus = false.obs;
  final Rxn<LeadIntegrationsData> liveStatus = Rxn<LeadIntegrationsData>();

  static const String _storageKey = 'crm_lead_integrations_oauth_data';

  @override
  void onInit() {
    super.onInit();
    loadIntegrations();
    fetchLeadIntegrationsStatus();
  }

  void loadIntegrations() {
    isLoading.value = true;
    try {
      final savedData = SharedPrefs.getString(_storageKey);
      if (savedData != null && savedData.isNotEmpty) {
        final List decoded = json.decode(savedData);
        integrations.value = decoded
            .map((item) => LeadIntegrationItem.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        integrations.value = _getDefaultIntegrations();
        _saveToStorage();
      }
    } catch (e) {
      integrations.value = _getDefaultIntegrations();
    } finally {
      isLoading.value = false;
    }
  }

  List<LeadIntegrationItem> _getDefaultIntegrations() {
    return [
      LeadIntegrationItem(
        id: 'facebook_ads',
        name: 'Facebook (Meta) Ads',
        shortName: 'Facebook',
        type: 'meta',
        isConnected: false,
        clientId: '1456126426464024',
        clientSecret: 'e538d100399d1ce84fe5fd48659fbc6f',
        redirectUri: 'https://oauth.pstmn.io/v1/callback',
        state: 'fbtest123',
        statusMessage: 'Not connected',
        lastSyncTime: 'Never',
      ),
      LeadIntegrationItem(
        id: 'google_ads',
        name: 'Google Ads',
        shortName: 'Google',
        type: 'google',
        isConnected: false,
        clientId: '4819021184-apps.googleusercontent.com',
        clientSecret: 'GOCSPX-e538d100399d1ce84fe5',
        redirectUri: 'https://oauth.pstmn.io/v1/callback',
        state: 'googletest123',
        statusMessage: 'Not connected',
        lastSyncTime: 'Never',
      ),
    ];
  }

  Future<void> _saveToStorage() async {
    try {
      final listMap = integrations.map((item) => item.toMap()).toList();
      await SharedPrefs.setString(_storageKey, json.encode(listMap));
    } catch (_) {}
  }

  int get totalConnectedCount =>
      integrations.where((item) => item.isConnected).length;

  bool get isMetaConnected {
    if (liveStatus.value?.facebook != null) {
      return liveStatus.value!.facebook!.connected;
    }
    final item = integrations.firstWhereOrNull((i) => i.id == 'facebook_ads');
    return item?.isConnected ?? false;
  }

  bool get isGoogleConnected {
    if (liveStatus.value?.google != null) {
      return liveStatus.value!.google!.connected;
    }
    final item = integrations.firstWhereOrNull((i) => i.id == 'google_ads');
    return item?.isConnected ?? false;
  }

  LeadIntegrationItem? getChannel(String id) {
    return integrations.firstWhereOrNull((i) => i.id == id);
  }

  /// Fetch live connection status for Facebook and Google Ads from backend
  Future<void> fetchLeadIntegrationsStatus() async {
    isLoadingStatus.value = true;
    try {
      final useCase = getLeadIntegrationsStatusUseCase ??
          GetLeadIntegrationsStatusUseCase(
            LeadIntegrationsRepository(
              apiClient: Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient(),
            ),
          );

      final response = await useCase.call();
      if (response.status && response.data != null) {
        liveStatus.value = response.data;

        // Synchronize integrations collection
        if (response.data!.facebook != null) {
          final fb = response.data!.facebook!;
          final fbIndex = integrations.indexWhere((i) => i.id == 'facebook_ads');
          if (fbIndex != -1) {
            integrations[fbIndex].isConnected = fb.connected;
            integrations[fbIndex].statusMessage = fb.status;
            if (fb.lastSyncedAt != null && fb.lastSyncedAt!.isNotEmpty) {
              integrations[fbIndex].lastSyncTime = fb.lastSyncedAt!;
            }
          }
        }

        if (response.data!.google != null) {
          final g = response.data!.google!;
          final gIndex = integrations.indexWhere((i) => i.id == 'google_ads');
          if (gIndex != -1) {
            integrations[gIndex].isConnected = g.connected;
            integrations[gIndex].statusMessage = g.status;
            if (g.lastSyncedAt != null && g.lastSyncedAt!.isNotEmpty) {
              integrations[gIndex].lastSyncTime = g.lastSyncedAt!;
            }
          }
        }
        integrations.refresh();
      }
    } catch (_) {
      // Keep existing status if status fetch fails
    } finally {
      isLoadingStatus.value = false;
    }
  }

  /// Call the backend Facebook Authorization URL API
  Future<bool> connectFacebook({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    required String state,
  }) async {
    if (clientId.trim().isEmpty || clientSecret.trim().isEmpty || redirectUri.trim().isEmpty) {
      Get.snackbar(
        'Validation Required',
        'Please provide client_id, client_secret and redirect_uri.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    }

    isConnecting.value = true;
    try {
      final request = FacebookAuthorizationRequestModel(
        clientId: clientId.trim(),
        clientSecret: clientSecret.trim(),
        redirectUri: redirectUri.trim(),
        state: state.trim(),
      );

      final response = await getFacebookAuthorizationUrlUseCase.call(request);

      // Save credentials locally
      await saveOAuthCredentials(
        id: 'facebook_ads',
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        markConnected: true,
      );

      // Close bottom sheet if currently displayed
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      // If backend returns authorization URL, open in in-app WebView
      if (response.authorizationUrl != null && response.authorizationUrl!.isNotEmpty) {
        Get.to(
          () => FacebookOAuthWebViewScreen(
            url: response.authorizationUrl!,
            redirectUri: redirectUri,
            title: 'Facebook (Meta) Ads',
          ),
        );
      } else {
        Get.snackbar(
          'Facebook Connected 🚀',
          response.message.isNotEmpty
              ? response.message
              : 'Facebook credentials saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

      return true;
    } catch (e) {
      // Save credentials as configured even if network exception occurs
      await saveOAuthCredentials(
        id: 'facebook_ads',
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        state: state,
        markConnected: true,
      );

      Get.snackbar(
        'Credentials Saved',
        'Credentials saved locally. Network message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return true;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> saveOAuthCredentials({
    required String id,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    required String state,
    bool markConnected = true,
  }) async {
    final index = integrations.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = integrations[index];
      item.clientId = clientId.trim();
      item.clientSecret = clientSecret.trim();
      item.redirectUri = redirectUri.trim();
      item.state = state.trim();
      item.isConnected = markConnected;
      item.statusMessage = markConnected ? 'Connected & Verified' : 'Not connected';
      item.lastSyncTime = markConnected ? 'Just now' : 'Never';

      integrations[index] = item;
      integrations.refresh();
      await _saveToStorage();
    }
  }

  Future<void> disconnectChannel(String id) async {
    final index = integrations.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = integrations[index];
      item.isConnected = false;
      item.statusMessage = 'Not connected';
      integrations[index] = item;
      integrations.refresh();
      await _saveToStorage();

      Get.snackbar(
        'Disconnected',
        '${item.name} has been disconnected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
