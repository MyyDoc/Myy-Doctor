class NearDoctorSearchResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  NearDoctorSearchResult.success(this.data)
      : error = null,
        isSuccess = true;

  NearDoctorSearchResult.failure(this.error)
      : data = null,
        isSuccess = false;
}
