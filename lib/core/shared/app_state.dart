sealed class AppState<T> {}

class InitialState<T> extends AppState<T> {}

class LoadingState<T> extends AppState<T> {}

class SuccessState<T> extends AppState<T> {
  final T data;

  SuccessState(this.data);
}

class ErrorState<T> extends AppState<T> {
  final String message;
  final Exception? exception; // Opcional, útil para debugar logs depois

  ErrorState(this.message, {this.exception});
}