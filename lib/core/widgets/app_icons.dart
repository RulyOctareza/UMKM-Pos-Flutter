import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Single source of truth untuk icon wrapper sesuai DESIGN_SYSTEM.md §8
class AppIcons {
  AppIcons._();

  // Navigation icons
  static const IconData pos = PhosphorIconsRegular.shoppingCart;
  static const IconData posActive = PhosphorIconsFill.shoppingCart;
  static const IconData products = PhosphorIconsRegular.package;
  static const IconData productsActive = PhosphorIconsFill.package;
  static const IconData history = PhosphorIconsRegular.receipt;
  static const IconData historyActive = PhosphorIconsFill.receipt;
  static const IconData dashboard = PhosphorIconsRegular.chartLineUp;
  static const IconData dashboardActive = PhosphorIconsFill.chartLineUp;
  static const IconData settings = PhosphorIconsRegular.gearSix;
  static const IconData settingsActive = PhosphorIconsFill.gearSix;

  // Action icons
  static const IconData add = PhosphorIconsRegular.plus;
  static const IconData subtract = PhosphorIconsRegular.minus;
  static const IconData delete = PhosphorIconsRegular.trash;
  static const IconData edit = PhosphorIconsRegular.pencilSimple;
  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData filter = PhosphorIconsRegular.funnel;
  static const IconData check = PhosphorIconsRegular.checkCircle;
  static const IconData close = PhosphorIconsRegular.x;
  static const IconData back = PhosphorIconsRegular.arrowLeft;
  static const IconData camera = PhosphorIconsRegular.camera;
  static const IconData image = PhosphorIconsRegular.image;
  static const IconData share = PhosphorIconsRegular.shareNetwork;
  static const IconData print = PhosphorIconsRegular.printer;
  static const IconData sync = PhosphorIconsRegular.arrowsClockwise;
  static const IconData cloud = PhosphorIconsRegular.cloudCheck;
  static const IconData cloudOffline = PhosphorIconsRegular.cloudSlash;
  static const IconData store = PhosphorIconsRegular.storefront;
  static const IconData cash = PhosphorIconsRegular.money;
  static const IconData qris = PhosphorIconsRegular.qrCode;
  static const IconData warning = PhosphorIconsRegular.warning;
  static const IconData info = PhosphorIconsRegular.info;
  static const IconData lock = PhosphorIconsRegular.lockKey;
  static const IconData calendar = PhosphorIconsRegular.calendarBlank;
  static const IconData phone = PhosphorIconsRegular.phone;
  static const IconData location = PhosphorIconsRegular.mapPin;
}
