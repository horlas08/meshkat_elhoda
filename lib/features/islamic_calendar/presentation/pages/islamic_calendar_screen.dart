
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/islamic_calendar/core/utils/islamic_event_utils.dart';
import 'package:meshkat_elhoda/features/islamic_calendar/domain/entities/islamic_event.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HijriCalendar _selectedHijriDate;
  late DateTime _selectedGregorianDate;
  late int _currentViewingHijriYear;
  
  // Events for the current year
  List<IslamicEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedHijriDate = HijriCalendar.now();
    _selectedGregorianDate = DateTime.now();
    _currentViewingHijriYear = _selectedHijriDate.hYear;
    _updateEvents();
  }

  void _updateEvents() {
    setState(() {
      _events = IslamicEventUtils.getEventsForHijriYear(_currentViewingHijriYear);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xff0a2f45) : AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.islamicCalendar,
          style: TextStyle(
            fontFamily: AppFonts.tajawal,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.goldenColor,
          unselectedLabelColor: isDark ? Colors.grey : Colors.black54,
          indicatorColor: AppColors.goldenColor,
          labelStyle: TextStyle(
            fontFamily: AppFonts.tajawal,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.hijriCalendar),
            Tab(text: AppLocalizations.of(context)!.gregorianCalendar),
          ],
        ),
      ),
      body: Column(
        children: [
          // Calendar View
          Expanded(
            flex: 3,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHijriCalendar(isDark),
                _buildGregorianCalendar(isDark),
              ],
            ),
          ),
          
          // Events List
          Expanded(
            flex: 2,
            child: _buildEventsList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHijriCalendar(bool isDark) {
    // Placeholder for Hijri Calendar View
    // We can use a PageView.builder to navigate months
    return _HijriMonthView(
      initialYear: _selectedHijriDate.hYear,
      initialMonth: _selectedHijriDate.hMonth,
      onMonthChanged: (year, month) {
        setState(() {
          _currentViewingHijriYear = year;
          _updateEvents();
        });
      },
      selectedDate: _selectedHijriDate,
      onDateSelected: (date) {
        setState(() {
          _selectedHijriDate = date;
           // Sync Gregorian
           _selectedGregorianDate = date.hijriToGregorian(date.hYear, date.hMonth, date.hDay);
        });
      },
      isDark: isDark,
    );
  }

  Widget _buildGregorianCalendar(bool isDark) {
    // Placeholder for Gregorian Calendar View
    return _GregorianMonthView(
      initialDate: _selectedGregorianDate,
      onMonthChanged: (date) {
        // Sync Hijri year for events list? 
        // We probably want to find the Hijri year of the 15th of this gregorian month
        final hDate = HijriCalendar.fromDate(DateTime(date.year, date.month, 15));
        if (hDate.hYear != _currentViewingHijriYear) {
          setState(() {
            _currentViewingHijriYear = hDate.hYear;
            _updateEvents();
          });
        }
      },
      selectedDate: _selectedGregorianDate,
      onDateSelected: (date) {
        setState(() {
          _selectedGregorianDate = date;
          // Sync Hijri
          _selectedHijriDate = HijriCalendar.fromDate(date);
        });
      },
      isDark: isDark,
    );
  }

  Widget _buildEventsList(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${AppLocalizations.of(context)!.islamicEvents} ($_currentViewingHijriYear)",
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              itemCount: _events.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.3)),
              itemBuilder: (context, index) {
                final event = _events[index];
                return InkWell(
                  onTap: () {
                    // Navigate calendar to this date
                    setState(() {
                      _selectedHijriDate = HijriCalendar()
                        ..hYear = _currentViewingHijriYear // Keep current view year or event year? Utils uses current view year.
                        ..hMonth = event.hMonth
                        ..hDay = event.hDay;
                      _selectedGregorianDate = event.gregorianDate;
                      
                      // TODO: instruct calendar View to jump. 
                      // For now, setting selected date triggers update, but PageView needs controller jump.
                      // Since we don't have controllers exposed easily here without more code, we just update state.
                      // The CalendarViews should listen to selectedDate updates if they can.
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.getTitle(context),
                                style: TextStyle(
                                  fontFamily: AppFonts.tajawal,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.goldenColor,
                                ),
                              ),
                              Text(
                                "${event.hDay}/${event.hMonth}/${_currentViewingHijriYear}", // Assuming events are for current year
                                style: TextStyle(
                                  fontFamily: AppFonts.tajawal,
                                  fontSize: 14.sp,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${event.gregorianDate.day}/${event.gregorianDate.month}/${event.gregorianDate.year}",
                           style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal implementations for Helper Widgets to make it compile and work
// These should ideally be full calendar implementations.

class _HijriMonthView extends StatelessWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int, int) onMonthChanged;
  final HijriCalendar selectedDate;
  final Function(HijriCalendar) onDateSelected;
  final bool isDark;

  const _HijriMonthView({
    required this.initialYear,
    required this.initialMonth,
    required this.onMonthChanged,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Basic PageView implementation
    final controller = PageController(initialPage: (initialYear - 1300) * 12 + initialMonth - 1);
    
    return PageView.builder(
      controller: controller,
      onPageChanged: (index) {
        final year = 1300 + (index ~/ 12);
        final month = (index % 12) + 1;
        onMonthChanged(year, month);
      },
      itemBuilder: (context, index) {
        final year = 1300 + (index ~/ 12);
        final month = (index % 12) + 1;
        return _buildMonthGrid(context, year, month);
      },
    );
  }

  Widget _buildMonthGrid(BuildContext context, int year, int month) {
    final hDate = HijriCalendar();
    hDate.hYear = year;
    hDate.hMonth = month;
    hDate.hDay = 1;
    
    // Days in month
    final daysInMonth = hDate.getDaysInMonth(year, month);
    // Weekday of 1st day? Hijri package might default to today if not set fully?
    // HijriCalendar doesn't easily give weekday of explicit hDate unless we convert to gregorian
    final gDate = hDate.hijriToGregorian(year, month, 1);
    final weekdayOffset = gDate.weekday % 7; // Mon=1..Sun=7. We want Sun=0 or Mon=0 based on locale?
    // Usually calendars start on Sunday or Monday. Let's assume Saturday/Sunday start for Islamic?
    // Let's use standard grid. Mon=0..Sun=6 index?
    
    // We will use a standard GridView
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "${hDate.toFormat("MMMM")} $year", // Requires locale settings on HijriCalendar
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
          ),
        ),
        // Days Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ["S", "M", "T", "W", "T", "F", "S"].map((d) => Text(d, style: TextStyle(color: Colors.grey))).toList(),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + (gDate.weekday % 7), // Offset
            itemBuilder: (context, i) {
              final offset = gDate.weekday % 7;
              if (i < offset) return SizedBox();
              
              final day = i - offset + 1;
              final isSelected = selectedDate.hYear == year && selectedDate.hMonth == month && selectedDate.hDay == day;
              
              return InkWell(
                 onTap: () {
                   final newDate = HijriCalendar();
                   newDate.hYear = year;
                   newDate.hMonth = month;
                   newDate.hDay = day;
                   onDateSelected(newDate);
                 },
                 child: Container(
                   alignment: Alignment.center,
                   decoration: isSelected ? BoxDecoration(color: AppColors.goldenColor, shape: BoxShape.circle) : null,
                   child: Text(
                     "$day",
                     style: TextStyle(
                       color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                     ),
                   ),
                 ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class _GregorianMonthView extends StatelessWidget {
  final DateTime initialDate;
  final Function(DateTime) onMonthChanged;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isDark;

  const _GregorianMonthView({
    required this.initialDate,
    required this.onMonthChanged,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      onDateChanged: onDateSelected,
      currentDate: DateTime.now(),
      // Styling is limited here, but sufficient for MVp
    );
  }
}
