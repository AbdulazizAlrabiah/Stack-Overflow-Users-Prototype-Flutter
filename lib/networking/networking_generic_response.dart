class NetworkingGenericResponse<T> {
  Status status;

  T? data;

  String? message;

  NetworkingGenericResponse.normal() : status = Status.normal;

  NetworkingGenericResponse.loading() : status = Status.loading;

  NetworkingGenericResponse.completed(this.data) : status = Status.completed;

  NetworkingGenericResponse.error(this.message) : status = Status.error;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status {
  loading,
  completed,
  error,
  normal,
}
