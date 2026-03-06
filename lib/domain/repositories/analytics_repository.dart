abstract class AnalyticsRepository {
  Future<void> logAuthEvent({
    required String eventName,
    required String method,
    String? errorType,
  });
}
