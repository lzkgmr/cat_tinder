import 'package:cat_tinder/data/analytics/firebase_analytics_service.dart';
import 'package:cat_tinder/domain/repositories/analytics_repository.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseAnalyticsService _service;

  FirebaseAnalyticsRepository(this._service);

  @override
  Future<void> logAuthEvent({
    required String eventName,
    required String method,
    String? errorType,
  }) async {
    final params = <String, Object>{'method': method};
    if (errorType != null) {
      params['error_type'] = errorType;
    }

    await _service.logEvent(name: eventName, parameters: params);
  }
}
