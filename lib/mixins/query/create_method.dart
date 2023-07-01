import 'dart:math';

import 'package:get_query/get_query.dart';

mixin CreateMethod<T> on GetQuery<T> {
  Future<T?> create({required Map<String, dynamic> data})async {
    try {
      final response =await client!.request(
        endpoint,
        'POST',
        headers: headers,
        body: data,
      );
      if (response.hasError) {
        onError(response.statusText!);
        return null;
      } else {
        onFetch(response.body);
        return decoder(response.body);
      }
    } catch (e) {
      onError(e.toString());
      return null;
    }
  }
}