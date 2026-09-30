import '../models/holiday_calendar_model.dart';

abstract class HolidayCalendarRepositoryInterface {
  Future<HolidayCalendarResponse?> getHolidays({
    required int year,
    String? location,
  });
}
