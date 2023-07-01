import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_query/get_query.dart';

abstract class GetQueryList<T> extends GetQuery<List<T>> {
  @override
  List<T> decoder(dynamic data);

  @override
  void onFetch(data) {
    log('Data fetched successfully', name: 'GetQuery $T');
  }

  @override
  void onError(String error) {
    log(error, name: 'GetQuery $T');
  }

  @override
  void onInit() {
    change([], status: RxStatus.loading());
    fetch();
    super.onInit();
  }

  @override
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
        change([], status: RxStatus.error(response.statusText!));
      } else {
        onFetch(response.body);
        List<T> data = [];
        data = decoder(response.body);
        if (data.isEmpty) {
          change([], status: RxStatus.empty());
          return;
        }
        change(data, status: RxStatus.success());
      }
    } catch (e) {
      onError(e.toString());
      change([], status: RxStatus.error(e.toString()));
    }
  }
}
