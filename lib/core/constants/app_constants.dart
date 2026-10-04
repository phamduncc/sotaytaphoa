class AppConstants {
  AppConstants._();

  static const String appName = 'Sổ Tay Tạp Hóa';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyPin = 'app_pin';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyLowStockThreshold = 'low_stock_threshold';
  static const String keyFirstRun = 'first_run';

  // Database
  static const String dbName = 'sotaytaphoa.db';
  static const int dbVersion = 2;

  // Default values
  static const int defaultLowStockThreshold = 5;
  static const int defaultExpiryWarningDays = 30;

  // Payment methods
  static const String paymentCash = 'cash';
  static const String paymentTransfer = 'transfer';

  // Transaction types
  static const String transactionIncome = 'income';
  static const String transactionExpense = 'expense';

  // Units
  static const List<String> productUnits = [
    'cái',
    'chai',
    'gói',
    'thùng',
    'hộp',
    'túi',
    'kg',
    'g',
    'lít',
    'ml',
    'bao',
    'cuộn',
    'đôi',
    'bộ',
  ];

  // Category icons (Material icon names map)
  static const List<String> defaultCategories = [
    'Nước giải khát',
    'Bánh kẹo',
    'Mì gói',
    'Gia vị',
    'Sữa',
    'Đồ hộp',
    'Đồ gia dụng',
    'Thực phẩm tươi',
    'Rau củ quả',
    'Khác',
  ];
}
