import '../../leave_management/models/holiday_calendar_model.dart';
import '../models/add_holiday_model.dart';
import '../models/holiday_details_model.dart';

abstract class HolidaysRepositoryInterface {
  Future<HolidayCalendarResponse?> getHolidays({
    required int year,
    String? location,
  });

  Future<AddHolidayResponseModel?> addHoliday(AddHolidayRequestModel request);

  Future<AddHolidayResponseModel?> updateHoliday(
    String id,
    AddHolidayRequestModel request,
  );

  Future<HolidayDetailsResponseModel?> getHolidayDetails(String id);

  Future<bool> deleteHoliday(String id);
}
