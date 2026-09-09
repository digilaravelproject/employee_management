import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';
import '../storage/token_manger.dart';
import 'api_checker.dart';
import 'multipart.dart';
import 'network_info.dart';
import '../../widgets/no_internet_screen.dart';
import 'response_model.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      validateStatus: (status) => status! < 500,
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String token = await TokenManager.getToken() ?? "";
        // Use hardcoded token if no token is saved
        if (token.isEmpty) {
          token = AppConstants.apiToken;
        }
        options.headers["Authorization"] = "Bearer $token";
        options.headers["Accept"] = "application/json";

        // Detailed request logging
        final requestUrl = options.path.startsWith('http')
            ? options.path
            : '${options.baseUrl}${options.path}';
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|🌐 API REQUEST');
        Logger.d('|📍 URL: $requestUrl');
        Logger.d('|🔧 Method: ${options.method}');
        Logger.d('|🔑 Token: ${token.isNotEmpty ? "${token.substring(0, token.length > 20 ? 20 : token.length)}..." : "No Token"}');
        Logger.d('|📋 Headers: ${options.headers}');
        if (options.queryParameters.isNotEmpty) {
          Logger.d('|🔍 Query Parameters: ${options.queryParameters}');
        }
        if (options.data != null) {
          Logger.d('|📦 Body: ${options.data}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        final responseUrl = response.requestOptions.path.startsWith('http')
            ? response.requestOptions.path
            : '${response.requestOptions.baseUrl}${response.requestOptions.path}';
        // Detailed response logging
        Logger.d('|✅ API RESPONSE');
        Logger.d('|📍 URL: $responseUrl');
        Logger.d('|📊 Status Code: ${response.statusCode}');
        Logger.d('|📨 Response: ${response.data}');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return handler.next(response);
      },
      onError: (error, handler) {
        final errorUrl = error.requestOptions.path.startsWith('http')
            ? error.requestOptions.path
            : '${error.requestOptions.baseUrl}${error.requestOptions.path}';
        // Detailed error logging
        Logger.e('|❌ API ERROR');
        Logger.e('|📍 URL: $errorUrl');
        Logger.e('|🔧 Method: ${error.requestOptions.method}');
        Logger.e('|⚠️ Error Type: ${error.type}');
        Logger.e('|💬 Error Message: ${error.message}');
        if (error.response != null) {
          Logger.e('|📊 Status Code: ${error.response?.statusCode}');
          Logger.e('|📨 Response: ${error.response?.data}');
        }
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return handler.next(error);
      },
    ));
  }

  Future<bool> _checkInternetConnection({bool showDialog = false}) async {
    final isConnected = await NetworkInfo.checkConnectivity();
    if (!isConnected && showDialog) {
      Get.to(() => const NoInternetScreen());
    }
    return isConnected;
  }

  Future<ResponseModel> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
        bool handleError = AppConstants.handleError,
        bool showToaster = AppConstants.showToaster,
        bool showErrorScreen = AppConstants.isHandleErrorScreen,
        bool showInternetScreen = AppConstants.isHandleInternetScreen,
      }) async {

    if (showInternetScreen && !(await _checkInternetConnection(showDialog: showInternetScreen))) {
      return const ResponseModel(isSuccess: false, message: 'No internet connection');
    }

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      if (handleError) {
        final result = ApiChecker.checkResponse(response, showToaster: showToaster);
        return ResponseModel.fromJson(result.data, statusCode: result.statusCode);
      } else {
        return ApiChecker.checkApi(response, showToaster: showToaster);
      }
    } catch (e) {
      return ApiChecker.handleError(e, showErrorScreen: showErrorScreen);
    }
  }

  Future<ResponseModel> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = AppConstants.handleError,
        bool showToaster = AppConstants.showToaster,
        bool showErrorScreen = AppConstants.isHandleErrorScreen,
        bool showInternetScreen = AppConstants.isHandleInternetScreen,
      }) async {
    if (showInternetScreen && !(await _checkInternetConnection(showDialog: showInternetScreen))) {
      return const ResponseModel(isSuccess: false, message: 'No internet connection');
    }

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (handleError) {
        final result = ApiChecker.checkResponse(response, showToaster: showToaster);
        return ResponseModel.fromJson(result.data, statusCode: result.statusCode);
      } else {
        return ApiChecker.checkApi(response, showToaster: showToaster);
      }
    } catch (e) {
      return ApiChecker.handleError(e, showErrorScreen: showErrorScreen);
    }
  }

  Future<ResponseModel> postMultipartData(
      String path,
      Map<String, String> body,
      List<MultipartBody> multipartBody,
      List<MultipartDocument> otherFile, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool fromChat = false,
        bool handleError = AppConstants.handleError,
        bool showToaster = AppConstants.showToaster,
        bool showErrorScreen = AppConstants.isHandleErrorScreen,
        bool showInternetScreen = AppConstants.isHandleInternetScreen,
      }) async {
    if (showInternetScreen && !(await _checkInternetConnection(showDialog: showInternetScreen))) {
      return const ResponseModel(isSuccess: false, message: 'No internet connection');
    }

    try {
      Logger.d('ApiClient() => POST Multipart request: $path');

      Map<String, dynamic> formDataMap = {};
      body.forEach((key, value) => formDataMap[key] = value);

      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          if (kIsWeb) {
            List<int> bytes = await multipart.file!.readAsBytes();
            formDataMap[multipart.key] = MultipartFile.fromBytes(
              bytes,
              filename: basename(multipart.file!.path),
              contentType: MediaType('image', 'jpg'),
            );
          } else {
            formDataMap[multipart.key] = await MultipartFile.fromFile(
              multipart.file!.path,
              filename: basename(multipart.file!.path),
            );
          }
        }
      }

      for (MultipartDocument doc in otherFile) {
        if (doc.file != null) {
          if (kIsWeb) {
            if (fromChat) {
              formDataMap['image[]'] = MultipartFile.fromBytes(doc.file!.bytes!, filename: doc.file!.name);
            } else {
              formDataMap[doc.key] = MultipartFile.fromBytes(doc.file!.bytes!, filename: doc.file!.name);
            }
          } else if (doc.file!.path != null) {
            String fileName = doc.file!.name;
            String extension = fileName.split('.').last.toLowerCase();
            MediaType contentType;
            String uploadPath = doc.file!.path!;
            
            if (extension == 'pdf') {
              contentType = MediaType('application', 'pdf');
            } else if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
              contentType = extension == 'png' ? MediaType('image', 'png') : MediaType('image', 'jpeg');
              
              // Compress image
              try {
                final tempDir = await getTemporaryDirectory();
                final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$extension';
                
                final compressedFile = await FlutterImageCompress.compressAndGetFile(
                  doc.file!.path!,
                  targetPath,
                  quality: 70,
                  format: extension == 'png' ? CompressFormat.png : CompressFormat.jpeg,
                );
                
                if (compressedFile != null) {
                  uploadPath = compressedFile.path;
                  Logger.d('ApiClient() => Image compressed: ${doc.file!.path} -> $uploadPath');
                }
              } catch (e) {
                Logger.e('ApiClient() => Image compression failed: $e');
              }
            } else {
              contentType = MediaType('application', 'octet-stream');
            }

            formDataMap[doc.key] = await MultipartFile.fromFile(
              uploadPath,
              filename: fileName,
              contentType: contentType,
            );
          }
        }
      }

      FormData formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(

        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      Logger.d('ApiClient() => POST Multipart response: ${response.data}');

      if (handleError) {
        final result = ApiChecker.checkResponse(response, showToaster: showToaster);
        return ResponseModel.fromJson(result.data, statusCode: result.statusCode);
      } else {
        return ApiChecker.checkApi(response, showToaster: showToaster);
      }
    } catch (e) {
      Logger.e('ApiClient() => POST Multipart error: $e');
      return ApiChecker.handleError(e, showErrorScreen: showErrorScreen);
    }
  }

  Future<ResponseModel> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = AppConstants.handleError,
        bool showToaster = AppConstants.showToaster,
        bool showErrorScreen = AppConstants.isHandleErrorScreen,
        bool showInternetScreen = AppConstants.isHandleInternetScreen,
      }) async {
    if (showInternetScreen && !(await _checkInternetConnection(showDialog: showInternetScreen))) {
      return const ResponseModel(isSuccess: false, message: 'No internet connection');
    }

    try {
      Logger.d('ApiClient() => PUT request: $path, data: $data');
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      Logger.d('ApiClient() => PUT response: ${response.data}');

      if (handleError) {
        final result = ApiChecker.checkResponse(response, showToaster: showToaster);
        return ResponseModel.fromJson(result.data, statusCode: result.statusCode);
      } else {
        return ApiChecker.checkApi(response, showToaster: showToaster);
      }
    } catch (e) {
      Logger.e('ApiClient() => PUT error: $e');
      return ApiChecker.handleError(e, showErrorScreen: showErrorScreen);
    }
  }

  Future<ResponseModel> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = AppConstants.handleError,
        bool showToaster = AppConstants.showToaster,
        bool showErrorScreen = AppConstants.isHandleErrorScreen,
        bool showInternetScreen = AppConstants.isHandleInternetScreen,
      }) async {
    if (showInternetScreen && !(await _checkInternetConnection(showDialog: showInternetScreen))) {
      return const ResponseModel(isSuccess: false, message: 'No internet connection');
    }

    try {
      Logger.d('ApiClient() => PATCH request: $path, data: $data');
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      Logger.d('ApiClient() => PATCH response: ${response.data}');

      if (handleError) {
        final result = ApiChecker.checkResponse(response, showToaster: showToaster);
        return ResponseModel.fromJson(result.data, statusCode: result.statusCode);
      } else {
        return ApiChecker.checkApi(response, showToaster: showToaster);
      }
    } catch (e) {
      Logger.e('ApiClient() => PATCH error: $e');
      return ApiChecker.handleError(e, showErrorScreen: showErrorScreen);
    }
  }

  Future<ResponseModel> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        bool handleError = AppConstants.handleError,
        bool showToaster = AppConstants.showToaster,
        bool showErrorScreen = AppConstants.isHandleErrorScreen,
        bool showInternetScreen = AppConstants.isHandleInternetScreen,
      }) async {
    if (showInternetScreen && !(await _checkInternetConnection(showDialog: showInternetScreen))) {
      return const ResponseModel(isSuccess: false, message: 'No internet connection');
    }

    try {
      Logger.d('ApiClient() => DELETE request: $path');
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      Logger.d('ApiClient() => DELETE response: ${response.data}');

      if (handleError) {
        final result = ApiChecker.checkResponse(response, showToaster: showToaster);
        return ResponseModel.fromJson(result.data, statusCode: result.statusCode);
      } else {
        return ApiChecker.checkApi(response, showToaster: showToaster);
      }
    } catch (e) {
      Logger.e('ApiClient() => DELETE error: $e');
      return ApiChecker.handleError(e, showErrorScreen: showErrorScreen);
    }
  }
}
