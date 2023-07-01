
import 'package:get_query/get_query.dart';

abstract class GetQueryWithCache<T> extends GetQuery<T> with CacheQuery {
  GetQueryWithCache() : super();
}
