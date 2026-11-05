/// A foglalás utáni értékelés oldala (`GET /public/reviews/{token}`).
class ReviewInfo {
  const ReviewInfo({
    required this.businessName,
    required this.serviceName,
    required this.alreadySubmitted,
    this.appointmentDate,
    this.rating,
    this.googleReviewUrl,
  });

  final String businessName;
  final String serviceName;
  final String? appointmentDate;
  final bool alreadySubmitted;

  /// A már leadott értékelés (1–5).
  final int? rating;

  /// Ha a vállalkozásnak van Google-értékelő linkje, a jó értékelés után ide lehet irányítani.
  final String? googleReviewUrl;

  factory ReviewInfo.fromJson(Map<String, dynamic> j) => ReviewInfo(
        businessName: j['business_name'] as String? ?? '',
        serviceName: j['service_name'] as String? ?? '',
        appointmentDate: j['appointment_date'] as String?,
        alreadySubmitted: j['already_submitted'] as bool? ?? false,
        rating: (j['rating'] as num?)?.toInt(),
        googleReviewUrl: j['google_review_url'] as String?,
      );
}
