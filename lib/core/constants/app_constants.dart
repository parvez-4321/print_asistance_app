/// App-wide string and numeric constants.
class AppConstants {
  AppConstants._();

  static const appName = 'PrintAssist';
  static const version = '1.0.0';

  // Bluetooth
  static const btScanTimeout = Duration(seconds: 30);
  static const btConnectTimeout = Duration(seconds: 10);

  // Wi-Fi / IPP
  static const ippPort = 631;
  static const rawPort = 9100;
  static const lprPort = 515;
  static const discoveryTimeout = Duration(seconds: 10);

  // Scan
  static const maxScanDpi = 2400;
  static const defaultDocDpi = 300;
  static const defaultPhotoDpi = 600;

  // Job history
  static const historyRetentionDays = 90;

  // Print
  static const maxCopies = 99;
  static const minScale = 10;
  static const maxScale = 400;

  // Paper sizes (mm)
  static const paperSizes = {
    'A3':     [297.0, 420.0],
    'A4':     [210.0, 297.0],
    'A5':     [148.0, 210.0],
    'A6':     [105.0, 148.0],
    'B4':     [250.0, 353.0],
    'B5':     [176.0, 250.0],
    'Letter': [215.9, 279.4],
    'Legal':  [215.9, 355.6],
    'Tabloid':[279.4, 431.8],
    '4x6':    [101.6, 152.4],
    '5x7':    [127.0, 177.8],
    '8x10':   [203.2, 254.0],
  };
}

