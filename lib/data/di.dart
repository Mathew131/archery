import 'package:get_it/get_it.dart';
import 'data.dart';

final sl = GetIt.I;

void setupDI() {
  sl.registerSingleton<Data>(Data());
}
