class AuthUIState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthUIState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthUIState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthUIState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
