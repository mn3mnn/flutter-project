import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:project_flutter/blocs/login/login_event.dart';
import 'package:project_flutter/blocs/login/login_state.dart';
import 'package:project_flutter/services/auth_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Dio dio;
  
  LoginBloc({Dio? dioClient}) 
      : dio = dioClient ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) {
            return status! < 500;
          },
        )),
        super(LoginInitial()) {
          
    on<LoginSubmitEvent>((event, emit) async {
      String? validationError = _validateInputs(
        event.email,
        event.password,
      );
      
      if (validationError != null) {
        emit(LoginError(message: validationError));
        return;
      }
      
      emit(LoginLoading());
      
      try {
        Response response = await dio.post(
          'http://10.0.2.2:5042/api/auth/login',
          data: {
            'email': event.email,
            'password': event.password,
          },
        );
        
        if (response.statusCode == 200) {
          String message = 'Login successful';
          String? token;
          
          if (response.data is Map) {
            if (response.data['token'] != null) {
              token = response.data['token'].toString();
            } else if (response.data['access_token'] != null) {
              token = response.data['access_token'].toString();
            } else if (response.data['data'] is Map && response.data['data']['token'] != null) {
              token = response.data['data']['token'].toString();
            }
            
            if (response.data['message'] != null) {
              message = response.data['message'].toString();
            }
          } else if (response.data is String) {
            message = response.data;
            if (response.headers.map.containsKey('authorization')) {
              token = response.headers.value('authorization');
            }
          }
          
          if (token != null) {
            await AuthService.saveToken(token);
          }
          
          emit(LoginSuccess(message: message, token: token));
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          String message = _extractErrorMessage(response.data);
          emit(LoginError(message: message));
        } else {
          emit(LoginError(message: 'Unexpected error: ${response.statusCode}'));
        }
      } catch (e) {
        if (e is DioException) {
          String errorMessage = _handleDioException(e);
          emit(LoginError(message: errorMessage));
        } else {
          emit(LoginError(message: 'Error: ${e.toString()}'));
        }
      }
    });
  }
  
  String? _validateInputs(
    String email,
    String password,
  ) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    if (password.isEmpty) {
      return 'Password is required';
    }
    
    return null;
  }
  
  String _extractErrorMessage(dynamic data) {
    // Case 1: When the data is simply a string error message
    if (data is String) {
      return data;
    }
    
    // Case 2: When the error is in JSON format
    if (data is Map) {
      // Check for specific error message
      if (data['message'] != null) {
        return data['message'].toString();
      }
      
      // Check for direct error properties in the response
      for (var key in data.keys) {
        if (key != 'type' && key != 'title' && key != 'status' && key != 'traceId') {
          var value = data[key];
          if (value is String) {
            return value;
          } else if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }
    }
    
    // Default error message if we couldn't extract a specific one
    return 'Invalid email or password';
  }
  
  String _handleDioException(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return _extractErrorMessage(e.response!.data);
        case 401:
          return 'Invalid email or password';
        case 404:
          return 'Server endpoint not found. Please try again later.';
        default:
          return 'Server error: ${e.response!.statusCode}';
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection and try again.';
        case DioExceptionType.badCertificate:
          return 'Security error. Invalid certificate.';
        case DioExceptionType.connectionError:
          return 'Connection error. Please check your internet connection.';
        case DioExceptionType.unknown:
          if (e.message != null && 
              (e.message!.contains('SocketException') || 
              e.message!.contains('Connection refused'))) {
            return 'Server unreachable. Please check your connection or try again later.';
          }
          return 'Unknown error occurred: ${e.message}';
        default:
          return 'Network error: ${e.message}';
      }
    }
  }
}