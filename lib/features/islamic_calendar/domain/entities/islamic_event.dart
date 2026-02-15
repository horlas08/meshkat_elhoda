
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class IslamicEvent {
  final String titleKey; // Key to look up in AppLocalizations
  final int hMonth;
  final int hDay;
  final DateTime gregorianDate;

  IslamicEvent({
    required this.titleKey,
    required this.hMonth,
    required this.hDay,
    required this.gregorianDate,
  });

  String getTitle(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (titleKey) {
      case 'eventRamadanStart':
        return localizations.eventRamadanStart;
      case 'eventLaylatAlQadr':
        return localizations.eventLaylatAlQadr;
      case 'eventEidAlFitr':
        return localizations.eventEidAlFitr;
      case 'eventHajj':
        return localizations.eventHajj;
      case 'eventEidAlAdha':
        return localizations.eventEidAlAdha;
      case 'eventAlHijra':
        return localizations.eventAlHijra;
      case 'eventAshura':
        return localizations.eventAshura;
      case 'eventMawlidAlNabi':
        return localizations.eventMawlidAlNabi;
      case 'eventLaylatAlMiraj':
        return localizations.eventLaylatAlMiraj;
      case 'eventLaylatAlBaraat':
        return localizations.eventLaylatAlBaraat;
      default:
        return titleKey;
    }
  }
}
