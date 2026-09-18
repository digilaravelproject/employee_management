import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/utils/logger.dart';

class RolePermissionsRepository {
  final ApiClient apiClient;

  RolePermissionsRepository({required this.apiClient});

  Future<ResponseModel> getPermissions() async {
    try {
      final response = await apiClient.get('/api/admin/permissions');
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to fetch permissions: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
  Future<ResponseModel> createRole(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/admin/roles', data: data);
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to create role: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
  Future<ResponseModel> getRoles() async {
    try {
      final response = await apiClient.get('/api/admin/roles');
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to fetch roles: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
  Future<ResponseModel> getRoleDetails(String id) async {
    try {
      final response = await apiClient.get('/api/admin/roles/$id');
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to fetch role details: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
  Future<ResponseModel> updateRole(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/admin/roles/$id', data: data);
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to update role: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
  Future<ResponseModel> deleteRole(String id) async {
    try {
      final response = await apiClient.delete('/api/admin/roles/$id');
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to delete role: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
  Future<ResponseModel> searchRoles(String query) async {
    try {
      final response = await apiClient.get('/api/admin/roles/search?query=$query');
      return response;
    } catch (e) {
      Logger.e('RolePermissionsRepository => Failed to search roles: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
}
