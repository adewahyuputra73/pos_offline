import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final storage = await StorageService.init();
  runApp(BorderPoApp(storage: storage));
}

class BorderPoApp extends StatelessWidget {
  final StorageService storage;
  const BorderPoApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(storage),
      child: MaterialApp(
        title: 'Barista POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeDashboardPage(),
      ),
    );
  }
}
