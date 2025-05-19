import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final Dio dio;
  
  SignupBloc({Dio? dioClient}) 
      : dio = dioClient ?? Dio(BaseOptions(
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
          validateStatus: (status) {
            return status! < 500;
          },
        )),
        super(SignupInitial()) {
    
    on<SignupSubmitEvent>((event, emit) async {
      String? validationError = _validateInputs(
        event.name,
        event.email,
        event.password,
        event.confirmPassword,
      );
      
      if (validationError != null) {
        emit(SignupError(message: validationError));
        return;
      }
      
      emit(SignupLoading());
      
      try {

        Response response = await dio.post(
          'http://10.0.2.2:5042/api/auth/signup',
          data: {
            'name': event.name,
            'email': event.email,
            'gender': event.gender,
            'level': event.level,
            'password': event.password,
            'confirmPassword': event.confirmPassword,
          },
        );
        
        if (response.statusCode == 201) {
          String message = response.data['message'] ?? 'User created successfully';
          emit(SignupSuccess(message: message));
        } else if (response.statusCode == 400) {
          String message = _extractErrorMessage(response.data);
          emit(SignupError(message: message));
        } else {
          emit(SignupError(message: 'Unexpected error: ${response.statusCode}'));
        }
      } catch (e) {
        if (e is DioException) {
          String errorMessage = _handleDioException(e);
          emit(SignupError(message: errorMessage));
        } else {
          emit(SignupError(message: 'Error: ${e.toString()}'));
        }
      }
    });
  }
  
  String? _validateInputs(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    
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
    
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  String _extractErrorMessage(dynamic data) {
    // Case 1: When the data is simply a string error message
    if (data is String) {
      return data;
    }
    
    // Case 2: When the data is in JSON format
    if (data is Map) {
      // Check for specific error message
      if (data['message'] != null) {
        return data['message'].toString();
      }
      
      // Check for ModelState errors (ASP.NET format)
      if (data.containsKey('errors') && data['errors'] is Map) {
        Map<String, dynamic> errors = data['errors'];
        List<String> errorMessages = [];
        
        errors.forEach((field, messages) {
          if (messages is List) {
            for (var message in messages) {
              errorMessages.add('$field: $message');
            }
          } else {
            errorMessages.add('$field: $messages');
          }
        });
        
        if (errorMessages.isNotEmpty) {
          return errorMessages.first;
        }
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
    
    // Case 3: Check if the stringified data contains known error messages
    String dataString = data.toString();
    if (dataString.contains('Email already used before')) {
      return 'Email already used before';
    }
    
    return 'Invalid data provided. Please check your input.';
  }
  
  String _handleDioException(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return _extractErrorMessage(e.response!.data);
        case 401:
          return 'Unauthorized: invalid email or password';
        case 404:
          return 'Server endpoint not found. Please try again later.';
        case 409:
          return 'Email already registered. Please use another email.';
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