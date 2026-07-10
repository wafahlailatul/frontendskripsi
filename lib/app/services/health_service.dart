import 'package:health/health.dart';

class HealthService {
  final Health health = Health();

  Future<bool> requestPermission() async {
    try {
      bool available =
          await health.isHealthConnectAvailable();

      if (!available) {
        return false;
      }

      final types = [
        HealthDataType.HEART_RATE,
        HealthDataType.STEPS,
      ];

      final permissions = [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      bool granted =
          await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      return granted;
    } catch (e) {
      return false;
    }
  }

  Future<double?> getLatestHeartRate() async {
    try {
      final now = DateTime.now();
      final yesterday =
          now.subtract(const Duration(days: 1));

      final data =
          await health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [
          HealthDataType.HEART_RATE,
        ],
      );

      if (data.isEmpty) {
        return null;
      }

      data.sort(
        (a, b) =>
            b.dateFrom.compareTo(a.dateFrom),
      );

      return double.tryParse(
        data.first.value.toString(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<int> getSteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final steps =
          await health.getTotalStepsInInterval(
        midnight,
        now,
      );

      return steps ?? 0;
    } catch (e) {
      return 0;
    }
  }
}