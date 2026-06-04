import 'package:cloud_functions/cloud_functions.dart';

class TrackingStatusService {
  final FirebaseFunctions _functions;

  TrackingStatusService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  Future<void> reportStatus({required String status, String? message}) async {
    try {
      await _functions.httpsCallable('reportTrackingStatus').call({
        'status': status,
        'message': message ?? '',
      });
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'permission-denied') return;
      rethrow;
    }
  }
}
