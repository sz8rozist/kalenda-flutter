import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A foglalás mentése az eszköz naptárába – szolgáltatás a ViewModel-ek alatt (a rendszer saját naptár-párbeszédével).
class DeviceCalendarGateway {
  /// Igaz, ha az esemény felvétele elindult / sikerült.
  Future<bool> addEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? location,
    String? description,
  }) {
    return Add2Calendar.addEvent2Cal(Event(
      title: title,
      description: description,
      location: location,
      startDate: start,
      endDate: end,
    ));
  }
}

final deviceCalendarGatewayProvider = Provider<DeviceCalendarGateway>((ref) => DeviceCalendarGateway());
