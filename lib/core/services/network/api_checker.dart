import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../../routes/route_helper.dart';
import '../../constants/app_constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/logger.dart';
import '../storage/shared_prefs.dart';
import '../storage/token_manger.dart';
import 'response_model.dart';
import '../../widgets/error_screen.dart';

class ApiChecker {
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    final str = error.toString().toLowerCase();
    if (str.contains('socket') ||
        str.contains('failed host lookup') ||
        str.contains('network') ||
        str.contains('connection') ||
        str.contains('timed out') ||
        str.contains('timeout') ||
        str.contains('clientexception') ||
        str.contains('handshake') ||
        str.contains('offline') ||
        str.contains('no internet') ||
        str.contains('unreachable')) {
      return true;
    }
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return true;
      }
      if (error.error != null && isNetworkError(error.error)) {
        return true;
      }
    }
    return false;
  }
  static Response checkResponse(Response response, {bool showToaster = false}) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        if (response.data is Map && response.data['res'] == 'error') {
          if (showToaster) _showErrorMessage(response);
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: response.data['msg'] ?? 'Unable to complete request. Please try again.',
          );
        }
        return response;
      case 401:
        final path = response.requestOptions.path;
        final isAuthRoute = path.contains('login') || path.contains('signup') || path.contains('admin');
        if (!isAuthRoute) {
          _showErrorMessage(response, 'Unauthorized');
          _logout();
        }
        final errorMsg = response.data is Map
            ? (response.data['message'] ?? response.data['msg'] ?? 'Unauthorized')
            : 'Unauthorized';
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: errorMsg,
        );
      case 403:
        _showErrorMessage(response, 'Forbidden');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Forbidden',
        );
      case 404:
        _showErrorMessage(response, 'Not Found');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Not Found',
        );
      case 422:
        _showValidationErrors(response);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Validation Error',
        );
      case 500:
        _showErrorMessage(response, 'Server Error');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Server Error',
        );
      default:
        _showErrorMessage(response);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unable to complete request. Please try again.',
        );
    }
  }

  static ResponseModel handleError(dynamic error, {bool showErrorScreen = false}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Connection Timeout',
              message: 'Connection timed out. Please check your internet connection and try again.',
            );
          } else {
            CustomSnackbar.showError(
              'Connection timed out. Please check your internet connection and try again.',
              title: 'No Internet Connection',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Connection timed out. Please check your internet connection and try again.',
            statusCode: 408,
          );

        case DioExceptionType.badCertificate:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Security Error',
              message: 'There was a security certificate error. Please try again.',
            );
          } else {
            CustomSnackbar.showError('Bad certificate');
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Bad certificate',
            statusCode: 495,
          );

        case DioExceptionType.badResponse:
          final path = error.requestOptions.path;
          final isAuthRoute = path.contains('login') || path.contains('signup') || path.contains('admin');
          if (error.response?.statusCode == 401 && !isAuthRoute) {
            CustomSnackbar.showError('Session expired. Please login again.');
            _logout();
            return const ResponseModel(
              isSuccess: false,
              message: 'Unauthorized',
              statusCode: 401,
            );
          }

          if (error.response?.data != null) {
            try {
              final responseModel = ResponseModel.fromJson(
                error.response!.data,
                statusCode: error.response!.statusCode,
              );

              if (showErrorScreen) {
                _showErrorScreen(
                  title: 'Error',
                  message: responseModel.errors != null && responseModel.errors!.isNotEmpty
                      ? responseModel.errors!.first.message ?? responseModel.message
                      : responseModel.message,
                );
              } else {
                if (responseModel.errors != null && responseModel.errors!.isNotEmpty) {
                  CustomSnackbar.showError(
                    responseModel.errors!.first.message ?? 'Something went wrong',
                  );
                } else {
                  CustomSnackbar.showError(responseModel.message);
                }
              }

              return responseModel;
            } catch (e) {
              if (showErrorScreen) {
                _showErrorScreen(
                  title: 'Error',
                  message: 'Something went wrong. Please try again.',
                );
              } else {
                CustomSnackbar.showError('Something went wrong');
              }
              return ResponseModel(
                isSuccess: false,
                message: 'Something went wrong',
                statusCode: error.response?.statusCode,
              );
            }
          } else {
            if (showErrorScreen) {
              _showErrorScreen(
                title: 'Bad Response',
                message: 'Received an invalid response from server.',
              );
            } else {
              CustomSnackbar.showError('Bad response');
            }
            return ResponseModel(
              isSuccess: false,
              message: 'Bad response',
              statusCode: error.response?.statusCode,
            );
          }

        case DioExceptionType.cancel:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Request Cancelled',
              message: 'The request was cancelled.',
            );
          } else {
            CustomSnackbar.showError('Request cancelled');
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Request cancelled',
            statusCode: 499,
          );

        case DioExceptionType.connectionError:
          CustomSnackbar.showError(
            'Please check your internet connection and turn on Wi-Fi or Mobile Data.',
            title: 'No Internet Connection',
          );
          return const ResponseModel(
            isSuccess: false,
            message: 'No internet connection. Please turn on your Wi-Fi or Mobile Data.',
            statusCode: 408,
          );

        case DioExceptionType.unknown:
          final isNet = isNetworkError(error);
          final title = isNet ? 'No Internet Connection' : 'Connection Error';
          final msg = isNet
              ? 'Please check your internet connection and turn on Wi-Fi or Mobile Data.'
              : 'Unable to connect to server. Please check your internet connection and try again.';

          if (showErrorScreen) {
            _showErrorScreen(
              title: title,
              message: msg,
            );
          } else {
            CustomSnackbar.showError(msg, title: title);
          }
          return ResponseModel(
            isSuccess: false,
            message: msg,
            statusCode: 500,
          );
      }

      Logger.e('DioError: ${error.message}');
    } else {
      Logger.e('Error: $error');
      final isNet = isNetworkError(error);
      final title = isNet ? 'No Internet Connection' : 'Connection Error';
      final msg = isNet
          ? 'Please check your internet connection and turn on Wi-Fi or Mobile Data.'
          : 'Unable to load data. Please check your internet connection and try again.';

      if (showErrorScreen) {
        _showErrorScreen(
          title: title,
          message: msg,
        );
      } else {
        CustomSnackbar.showError(msg, title: title);
      }
      return ResponseModel(
        isSuccess: false,
        message: msg,
        statusCode: 500,
      );
    }

    return const ResponseModel(
      isSuccess: false,
      message: 'Unable to connect to server. Please check your internet connection and try again.',
      statusCode: 500,
    );
  }

  static ResponseModel checkApi(Response response, {bool showToaster = false}) {
    final statusCode = response.statusCode ?? 500;
    final path = response.requestOptions.path;
    final isAuthRoute = path.contains('login') || path.contains('signup') || path.contains('admin');

    if (statusCode == 401 && !isAuthRoute) {
      if (showToaster) {
        CustomSnackbar.showError('Session expired. Please login again.');
      }
      _logout();
      return const ResponseModel(
        isSuccess: false,
        message: 'Unauthorized',
        statusCode: 401,
      );
    }

    if (statusCode != 200 && statusCode != 201) {
      if (response.data != null) {
        try {
          final responseModel = ResponseModel.fromJson(response.data, statusCode: statusCode);

          if (showToaster) {
            if (responseModel.errors != null && responseModel.errors!.isNotEmpty) {
              CustomSnackbar.showError(
                responseModel.errors!.first.message ?? 'Unable to complete request. Please try again.',
              );
            } else {
              CustomSnackbar.showError(responseModel.message);
            }
          }

          return responseModel;
        } catch (e) {
          if (showToaster) {
            CustomSnackbar.showError('Unable to process response. Please try again.');
          }
          return ResponseModel(
            isSuccess: false,
            message: 'Unable to process response. Please try again.',
            statusCode: statusCode,
          );
        }
      } else {
        if (showToaster) {
          CustomSnackbar.showError('Unable to connect to server. Please try again.');
        }
        return ResponseModel(
          isSuccess: false,
          message: 'Unable to connect to server. Please try again.',
          statusCode: statusCode,
        );
      }
    }

    // Check for success in multiple ways (res or success field)
    if (response.data is Map) {
      final res = response.data['res']?.toString().toLowerCase();
      final successValue = response.data['success'];
      
      bool isSuccess = false;
      if (res == 'success') {
        isSuccess = true;
      } else if (successValue is bool) {
        isSuccess = successValue;
      } else if (successValue != null) {
        isSuccess = successValue.toString().toLowerCase() == 'true';
      }
      
      // If not successful, return error
      if (!isSuccess && res != null) {
        final message = response.data['msg']?.toString() ?? 
                       response.data['message']?.toString() ?? 
                       'Unable to process request. Please try again.';
        if (showToaster) CustomSnackbar.showError(message);

        return ResponseModel(
          isSuccess: false,
          message: message,
          body: response.data['data'],
          statusCode: statusCode,
        );
      }
    }

    return ResponseModel.fromJson(response.data, statusCode: statusCode);
  }

  static void _showErrorMessage(Response response, [String? defaultMessage]) {
    final message = response.data['msg'] ?? defaultMessage ?? 'Unable to process request. Please try again.';
    CustomSnackbar.showError(message);
  }

  static void _showValidationErrors(Response response) {
    if (response.data != null) {
      try {
        final responseModel = ResponseModel.fromJson(response.data, statusCode: response.statusCode);
        if (responseModel.errors != null && responseModel.errors!.isNotEmpty) {
          CustomSnackbar.showError(responseModel.errors!.first.message ?? 'Validation Error');
        } else if (response.data['msg'] != null) {
          CustomSnackbar.showError(response.data['msg']);
        } else {
          CustomSnackbar.showError('Validation Error');
        }
      } catch (e) {
        if (response.data['msg'] != null) {
          CustomSnackbar.showError(response.data['msg']);
        } else {
          CustomSnackbar.showError('Validation Error');
        }
      }
    } else {
      CustomSnackbar.showError('Validation Error');
    }
  }

  static void _showErrorScreen({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    getx.Get.to(
          () => ErrorScreen(
        title: title,
        message: message,
        onRetry: onRetry ?? () => getx.Get.back(),
        showBackButton: true,
      ),
    );
  }

  static void _logout() {
    SharedPrefs.remove(AppConstants.userData);
    SharedPrefs.setBool(AppConstants.isLoggedIn, false);
    TokenManager.clearToken();
    getx.Get.offAllNamed(RouteHelper.getLoginRoute());
  }
}