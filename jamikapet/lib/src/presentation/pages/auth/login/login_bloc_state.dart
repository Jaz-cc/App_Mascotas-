abstract class LoginBlocState {}

class LoginInitial extends LoginBlocState {}

class LoginLoading extends LoginBlocState {}

class LoginSuccess extends LoginBlocState {}

class LoginFailure extends LoginBlocState {
  final String errorMessage;

  LoginFailure({required this.errorMessage});
}