
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

abstract class GetQuery<T> extends GetxController with StateMixin<T> {

  /// Create a new `GetHttpClient` using the provided getHttpClient function.
  /// If no getHttpClient function is provided, use the default `GetHttpClient`.
  /// Initialize `GetStorage`.
  static Future<void> init([GetHttpClient? getHttpClient]) async {
    Get.lazyPut<GetHttpClient>(() => getHttpClient ?? GetHttpClient());
    await GetStorage.init();
  }


  /// Returns the endpoint that the request will be sent to.
  ///
  /// The endpoint is a URL that specifies the location of a resource
  /// (such as a webpage or a server). This URL can be either relative
  /// (such as "/foo/bar") or absolute (such as "https://example.com/foo/bar").
  ///
  /// If the URL is relative, it will be resolved against the base URL
  /// (which is usually the URL of the webpage that the code is currently
  /// running on).
  String get endpoint;

  /// Returns the parameters that will be sent with the request.
  Map<String, String> get params => {};
  /// Returns the headers that will be sent with the request.
  Map<String, String> get headers => {};
  /// Returns the body that will be sent with the request.
  Map<String, dynamic> get body => {};
  /// Returns the HTTP method that will be used for the request.
  String get method => 'GET';
  /// Returns whether the request will be sent as multipart.
  bool get isMultipart => false;

  /// Returns the `GetHttpClient` that will be used to send the request.
  GetHttpClient? client;

  GetQuery() {
    client ??= Get.find<GetHttpClient>();
  }

  /// As the dart language doesn't support creating a class instence from a
  /// generic function we have to use a decoder function to convert our api data.
  /// This function will be called when the request is successful. The data
  /// returned from the request will be passed to this function.
  /// Example:
  /// ```Dart
  /// class User {
  ///   final String name;
  ///   final String email;
  ///   User({required this.name, required this.email});
  ///   
  ///   factory User.fromJson(Map<String, dynamic> json) {
  ///     return User(
  ///       name: json['name'],
  ///       email: json['email'],
  ///     );
  ///   }
  /// }
  /// class GetUser extends GetQuery<User> {
  ///   @override
  ///   String get endpoint => '/user';
  ///   @override
  ///   User decoder(dynamic data) => User.fromJson(data);
  /// }
  /// ```
  T decoder(dynamic data);

  void onError(String error) {
    log(error, name: 'GetQuery $T');
  }

  /// This method will be called when the request is successful.
  /// The data returned from the request will be passed to this function.
  void onFetch(data) {
    log('Data fetched successfully', name: 'GetQuery $T');
  }

  @override
  void onInit() {
    change(null, status: RxStatus.loading());
    fetch();
    super.onInit();
  }

  void fetch() async {
    try {
      final response = await client!.request(
        endpoint,
        method,
        headers: headers,
        body: body,
        query: params,
      );
      if (response.hasError) {
        onError(response.statusText!);
        change(null, status: RxStatus.error(response.statusText!));
      } else {
        onFetch(response.body);
        change(decoder(response.body as Map<String, dynamic>),
            status: RxStatus.success());
      }
    } catch (e) {
      onError(e.toString());
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}
