import 'package:flutter/material.dart';

/// App ngân hàng để mở nhanh sau khi lưu mã QR.
/// [scheme] là URL scheme của app (mở bằng "scheme://").
/// Scheme lấy từ registry deeplink chính thức của VietQR/Napas (dl.vietqr.io).
class BankApp {
  final String name;
  final String short; // nhãn ngắn hiển thị trên icon
  final String scheme;
  final Color color;
  const BankApp(this.name, this.short, this.scheme, this.color);
}

const kBankApps = <BankApp>[
  BankApp('MB Bank', 'MB', 'mbbank', Color(0xFF1F4E9C)),
  BankApp('Vietcombank', 'VCB', 'vietcombankmobile', Color(0xFF00913A)),
  BankApp('VietinBank', 'CTG', 'vietinbankipay', Color(0xFF0072BC)),
  BankApp('BIDV', 'BIDV', 'bidv.smartbanking.partner', Color(0xFF006B68)),
  BankApp('Agribank', 'AGR', 'agribankmobile', Color(0xFF9A1B1F)),
  BankApp('Techcombank', 'TCB', 'tcb', Color(0xFFEC1C24)),
  BankApp('ACB', 'ACB', 'acbone', Color(0xFF00559F)),
  BankApp('VPBank', 'VPB', 'vpbankneo', Color(0xFF00A651)),
  BankApp('TPBank', 'TPB', 'hydro', Color(0xFF582C83)),
  BankApp('VIB', 'VIB', 'myvib2', Color(0xFF0A2C5E)),
  BankApp('SHB', 'SHB', 'shbmobile', Color(0xFF005BAC)),
  BankApp('HDBank', 'HDB', 'hdbankmobile', Color(0xFFE30613)),
  BankApp('OCB', 'OCB', 'newomni-app', Color(0xFF008C44)),
  BankApp('SCB', 'SCB', 'scbmobilebanking', Color(0xFF1B3A6B)),
  BankApp('Eximbank', 'EIB', 'eximbankmobile', Color(0xFF003399)),
];
