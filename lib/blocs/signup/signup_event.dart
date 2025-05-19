abstract class SignupEvent {}
class SignupSubmitEvent extends SignupEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool? gender; 
  final int? level;

  SignupSubmitEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.gender,
    this.level,
  });
}