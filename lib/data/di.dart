import 'package:get_it/get_it.dart';
import 'table_data.dart';

final sl = GetIt.I;

void setupDI() {
  sl.registerSingleton<TableData>(TableData());
}
