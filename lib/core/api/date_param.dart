/// Dátum az API paraméterezéséhez: `ÉÉÉÉ-HH-NN`.
String dateParam(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Napok tartománya (a naptár lekérdezéseihez).
typedef DateRange = ({DateTime from, DateTime to});
