import 'package:flutter/material.dart';
import 'strings_vi.dart';
import 'strings_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  Map<String, String> get _strings => locale.languageCode == 'vi' ? stringsVi : stringsEn;

  String translate(String key) => _strings[key] ?? key;

  String get appName => translate('app_name');

  // Common
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get confirm => translate('confirm');
  String get loading => translate('loading');
  String get noData => translate('no_data');
  String get error => translate('error');
  String get success => translate('success');
  String get requiredField => translate('required_field');
  String get total => translate('total');
  String get date => translate('date');
  String get note => translate('note');
  String get amount => translate('amount');
  String get quantity => translate('quantity');
  String get price => translate('price');
  String get name => translate('name');
  String get phone => translate('phone');
  String get address => translate('address');
  String get email => translate('email');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get close => translate('close');
  String get back => translate('back');
  String get done => translate('done');
  String get print => translate('print');
  String get exportPdf => translate('export_pdf');
  String get all => translate('all');
  String get filter => translate('filter');
  String get select => translate('select');
  String get optional => translate('optional');
  String get deleteConfirm => translate('delete_confirm');
  String get deleteConfirmDetail => translate('delete_confirm_detail');
  String get actionSuccess => translate('action_success');
  String get actionError => translate('action_error');
  String get noResults => translate('no_results');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get thisWeek => translate('this_week');
  String get thisMonth => translate('this_month');
  String get selectDate => translate('select_date');
  String get fromDate => translate('from_date');
  String get toDate => translate('to_date');
  String get scan => translate('scan');
  String get clear => translate('clear');
  String get refresh => translate('refresh');
  String get details => translate('details');
  String get viewAll => translate('view_all');

  // Navigation
  String get navDashboard => translate('nav_dashboard');
  String get navSales => translate('nav_sales');
  String get navProducts => translate('nav_products');
  String get navReports => translate('nav_reports');
  String get navMore => translate('nav_more');
  String get navPurchases => translate('nav_purchases');
  String get navInvoices => translate('nav_invoices');
  String get navTransactions => translate('nav_transactions');
  String get navSuppliers => translate('nav_suppliers');
  String get navCategories => translate('nav_categories');
  String get navSettings => translate('nav_settings');

  // Dashboard
  String get dashboardTitle => translate('dashboard_title');
  String get dashboardTodayRevenue => translate('dashboard_today_revenue');
  String get dashboardTodayProfit => translate('dashboard_today_profit');
  String get dashboardTodayInvoices => translate('dashboard_today_invoices');
  String get dashboardLowStock => translate('dashboard_low_stock');
  String get dashboardRecentTransactions => translate('dashboard_recent_transactions');
  String get dashboardQuickActions => translate('dashboard_quick_actions');
  String get dashboardAlerts => translate('dashboard_alerts');
  String get dashboardOutOfStock => translate('dashboard_out_of_stock');
  String get dashboardExpiringSoon => translate('dashboard_expiring_soon');
  String get dashboardNoAlerts => translate('dashboard_no_alerts');
  String get dashboardTotalProducts => translate('dashboard_total_products');
  String get dashboardWelcome => translate('dashboard_welcome');
  String get dashboardGreeting => translate('dashboard_greeting');

  // Products
  String get productTitle => translate('product_title');
  String get productAdd => translate('product_add');
  String get productEdit => translate('product_edit');
  String get productName => translate('product_name');
  String get productBarcode => translate('product_barcode');
  String get productCategory => translate('product_category');
  String get productCostPrice => translate('product_cost_price');
  String get productSalePrice => translate('product_sale_price');
  String get productStock => translate('product_stock');
  String get productUnit => translate('product_unit');
  String get productExpiryDate => translate('product_expiry_date');
  String get productSupplier => translate('product_supplier');
  String get productLowStockWarning => translate('product_low_stock_warning');
  String get productOutOfStock => translate('product_out_of_stock');
  String get productScanBarcode => translate('product_scan_barcode');
  String get productDeleteConfirm => translate('product_delete_confirm');
  String get productSaved => translate('product_saved');
  String get productDeleted => translate('product_deleted');
  String get productSelect => translate('product_select');
  String get productNoCategory => translate('product_no_category');
  String get productNoSupplier => translate('product_no_supplier');

  // Categories
  String get categoryTitle => translate('category_title');
  String get categoryAdd => translate('category_add');
  String get categoryEdit => translate('category_edit');
  String get categoryName => translate('category_name');
  String get categoryDeleteConfirm => translate('category_delete_confirm');
  String get categorySaved => translate('category_saved');
  String get categoryDeleted => translate('category_deleted');

  // POS / Sales
  String get posTitle => translate('pos_title');
  String get posSearchProduct => translate('pos_search_product');
  String get posCartEmpty => translate('pos_cart_empty');
  String get posCartEmptyHint => translate('pos_cart_empty_hint');
  String get posSubtotal => translate('pos_subtotal');
  String get posPayment => translate('pos_payment');
  String get posPaymentMethod => translate('pos_payment_method');
  String get posCash => translate('pos_cash');
  String get posTransfer => translate('pos_transfer');
  String get posCustomerPayment => translate('pos_customer_payment');
  String get posChange => translate('pos_change');
  String get posCompleteSale => translate('pos_complete_sale');
  String get posInvoiceCreated => translate('pos_invoice_created');
  String get posClearCart => translate('pos_clear_cart');
  String get posInsufficientStock => translate('pos_insufficient_stock');
  String get posNewSale => translate('pos_new_sale');

  // Purchases
  String get purchaseTitle => translate('purchase_title');
  String get purchaseAdd => translate('purchase_add');
  String get purchaseDetail => translate('purchase_detail');
  String get purchaseSupplier => translate('purchase_supplier');
  String get purchaseDate => translate('purchase_date');
  String get purchaseItems => translate('purchase_items');
  String get purchaseAddItem => translate('purchase_add_item');
  String get purchaseTotal => translate('purchase_total');
  String get purchaseComplete => translate('purchase_complete');
  String get purchaseSaved => translate('purchase_saved');
  String get purchaseNoItems => translate('purchase_no_items');
  String get purchaseSelectSupplier => translate('purchase_select_supplier');

  // Invoices
  String get invoiceTitle => translate('invoice_title');
  String get invoiceDetail => translate('invoice_detail');
  String get invoiceCode => translate('invoice_code');
  String get invoiceDate => translate('invoice_date');
  String get invoiceItems => translate('invoice_items');
  String get invoiceTotal => translate('invoice_total');
  String get invoicePaymentMethod => translate('invoice_payment_method');
  String get invoicePrint => translate('invoice_print');
  String get invoiceExportPdf => translate('invoice_export_pdf');

  // Transactions
  String get transactionTitle => translate('transaction_title');
  String get transactionAdd => translate('transaction_add');
  String get transactionIncome => translate('transaction_income');
  String get transactionExpense => translate('transaction_expense');
  String get transactionTotalIncome => translate('transaction_total_income');
  String get transactionTotalExpense => translate('transaction_total_expense');
  String get transactionProfit => translate('transaction_profit');
  String get transactionDescription => translate('transaction_description');
  String get transactionType => translate('transaction_type');
  String get transactionSaved => translate('transaction_saved');
  String get transactionDeleted => translate('transaction_deleted');
  String get transactionDeleteConfirm => translate('transaction_delete_confirm');

  // Suppliers
  String get supplierTitle => translate('supplier_title');
  String get supplierAdd => translate('supplier_add');
  String get supplierEdit => translate('supplier_edit');
  String get supplierName => translate('supplier_name');
  String get supplierPhone => translate('supplier_phone');
  String get supplierAddress => translate('supplier_address');
  String get supplierEmail => translate('supplier_email');
  String get supplierNote => translate('supplier_note');
  String get supplierDeleteConfirm => translate('supplier_delete_confirm');
  String get supplierSaved => translate('supplier_saved');
  String get supplierDeleted => translate('supplier_deleted');
  String get supplierCall => translate('supplier_call');
  String get supplierSendEmail => translate('supplier_send_email');

  // Reports
  String get reportTitle => translate('report_title');
  String get reportToday => translate('report_today');
  String get reportThisWeek => translate('report_this_week');
  String get reportThisMonth => translate('report_this_month');
  String get reportRevenue => translate('report_revenue');
  String get reportProfit => translate('report_profit');
  String get reportExpense => translate('report_expense');
  String get reportBestSelling => translate('report_best_selling');
  String get reportLowStock => translate('report_low_stock');
  String get reportInvoicesCount => translate('report_invoices_count');
  String get reportOverview => translate('report_overview');
  String get reportProducts => translate('report_products');
  String get reportChartRevenue => translate('report_chart_revenue');
  String get reportSoldQuantity => translate('report_sold_quantity');

  // Settings
  String get settingsTitle => translate('settings_title');
  String get settingsLanguage => translate('settings_language');
  String get settingsVietnamese => translate('settings_vietnamese');
  String get settingsEnglish => translate('settings_english');
  String get settingsTheme => translate('settings_theme');
  String get settingsLightMode => translate('settings_light_mode');
  String get settingsDarkMode => translate('settings_dark_mode');
  String get settingsSystemMode => translate('settings_system_mode');
  String get settingsPinLock => translate('settings_pin_lock');
  String get settingsPinSetup => translate('settings_pin_setup');
  String get settingsBackup => translate('settings_backup');
  String get settingsRestore => translate('settings_restore');
  String get settingsAbout => translate('settings_about');
  String get settingsVersion => translate('settings_version');
  String get settingsLowStockThreshold => translate('settings_low_stock_threshold');
  String get settingsGeneral => translate('settings_general');
  String get settingsData => translate('settings_data');
  String get settingsSecurity => translate('settings_security');
  String get settingsDisplay => translate('settings_display');
  String get settingsPinEnter => translate('settings_pin_enter');
  String get settingsPinConfirm => translate('settings_pin_confirm');
  String get settingsPinWrong => translate('settings_pin_wrong');
  String get settingsPinMismatch => translate('settings_pin_mismatch');
  String get settingsPinSaved => translate('settings_pin_saved');

  // More
  String get moreTitle => translate('more_title');
  String get moreManagement => translate('more_management');
  String get moreFinance => translate('more_finance');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
