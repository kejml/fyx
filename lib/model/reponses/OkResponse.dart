class OkResponse {
  bool _isOk = false;

  OkResponse();

  OkResponse.fromJson(Map<String, dynamic> json) {
    _isOk = json.isEmpty;
  }

  bool get isOk => _isOk;
}
