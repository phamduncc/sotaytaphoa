import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/database/database_helper.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/sales/pos_screen.dart';
import 'screens/sales/invoices_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/purchases/purchases_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await DatabaseHelper.instance.database;
  runApp(const SoTayTapHoaApp());
}

class SoTayTapHoaApp extends StatelessWidget {
  const SoTayTapHoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (_, themeProvider, localeProvider, __) {
          return MaterialApp(
            title: 'Sổ Tay Tạp Hóa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (_) => const MainScaffold(),
              '/products': (_) => const ProductsScreen(),
              '/categories': (_) => const CategoriesScreen(),
              '/purchases': (_) => const PurchasesScreen(),
              '/invoices': (_) => const InvoicesScreen(),
              '/transactions': (_) => const TransactionsScreen(),
              '/suppliers': (_) => const SuppliersScreen(),
              '/reports': (_) => const ReportsScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PosScreen(),
    ProductsScreen(),
    ReportsScreen(),
    _MoreScreen(),
  ];

  static MainScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScaffoldState>();
  }

  void setTab(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
      context.read<CategoryProvider>().loadAll();
      context.read<SupplierProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saleProvider = context.watch<SaleProvider>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: !saleProvider.cartEmpty,
              label: Text('${saleProvider.cartItemCount}'),
              child: const Icon(Icons.point_of_sale_outlined),
            ),
            selectedIcon: const Icon(Icons.point_of_sale_rounded),
            label: l10n.navSales,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2_rounded),
            label: l10n.navProducts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: l10n.navReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz_rounded),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final items = [
      _MoreItem(
        icon: Icons.receipt_long_rounded,
        label: l10n.navInvoices,
        color: const Color(0xFF1565C0),
        route: '/invoices',
      ),
      _MoreItem(
        icon: Icons.local_shipping_rounded,
        label: l10n.navPurchases,
        color: const Color(0xFF2E7D32),
        route: '/purchases',
      ),
      _MoreItem(
        icon: Icons.account_balance_wallet_rounded,
        label: l10n.navTransactions,
        color: const Color(0xFF6A1B9A),
        route: '/transactions',
      ),
      _MoreItem(
        icon: Icons.people_rounded,
        label: l10n.navSuppliers,
        color: const Color(0xFFE65100),
        route: '/suppliers',
      ),
      _MoreItem(
        icon: Icons.category_rounded,
        label: l10n.navCategories,
        color: const Color(0xFF00838F),
        route: '/categories',
      ),
      _MoreItem(
        icon: Icons.settings_rounded,
        label: l10n.navSettings,
        color: const Color(0xFF455A64),
        route: '/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, item.route),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
