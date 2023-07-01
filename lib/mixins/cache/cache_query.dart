
import 'package:get/get.dart';
import 'package:get_query/get_query.dart';
import 'package:get_storage/get_storage.dart';

mixin CacheQuery<T> on GetQuery<T> {
  String get cacheKey => endpoint + params.toString();
  bool get cacheEnabled => true;

  @override
  void fetch() async {
    if (cacheEnabled) {
      final data = GetStorage().read(cacheKey);
      if (data != null) {
        change(decoder(data as Map<String, dynamic>),
            status: RxStatus.success());
        return;
      }
    }
    super.fetch();
  }

  @override
  void onFetch(data) {
    if (cacheEnabled) {
      GetStorage().write(cacheKey, data);
    }
    super.onFetch(data);
  }

/// This method clears the cache
/// cacheKey is the key used to store the data
/// ```Dart
/// yourController.clearCache();
/// ```

void clearCache() {
    GetStorage().remove(cacheKey);
  }
}
