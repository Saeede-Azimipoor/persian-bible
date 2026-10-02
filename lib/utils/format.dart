import 'package:flutter/material.dart';

/// تبدیل ارقام لاتین به فارسی — 123 -> ۱۲۳
String toFaDigits(Object value) {
  const english = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value.toString();
  for (var i = 0; i < 10; i++) {
    result = result.replaceAll(english[i], persian[i]);
  }
  return result;
}

/// عدد به رقم مناسب ترجمه: فارسی ۱۲۳، انگلیسی 123
String trNum(Object value, {required bool rtl}) =>
    rtl ? toFaDigits(value) : value.toString();

/// جهت متن ترجمه
TextDirection dirOf(bool rtl) =>
    rtl ? TextDirection.rtl : TextDirection.ltr;
