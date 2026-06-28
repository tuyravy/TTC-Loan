import 'package:dio/dio.dart';
import 'package:apploan/core/utils/utils.dart';

class ExceptionHandler {
  ExceptionHandler._();

  static void handleException(
    dynamic error, {
    bool alert = true,
    Function(dynamic)? onValue,
  }) {
    if (!alert) {
      return;
    }

    const String title = 'Error';
    String subTitle = 'UnKnown Error';

    if (error is DioException) {
      final res = error.response;
      if (res != null) {
        if (res.data is Map) {
          final message = res.data['message'];
          subTitle =
              (message is String && message.isNotEmpty)
                  ? message
                  : 'Something went wrong (${res.statusCode ?? 'unknown'})';
        } else if (res.data is String &&
            (res.data as String).trim().startsWith('<')) {
          // Server returned an HTML error page (e.g. 404) instead of JSON.
          subTitle =
              'Server error (${res.statusCode ?? 'unknown'}). Please try again later.';
        } else {
          subTitle = res.data?.toString() ?? 'Something went wrong';
        }
      } else {
        subTitle = error.message ?? 'Network error. Please check your connection.';
      }
    } else if (error is String) {
      subTitle = error;
    } else {
      subTitle = 'Something went wrong ($error)';
    }

    DialogManager.showDialog(
      title: title,
      subTitle: subTitle.isEmpty ? 'Something went wrong' : subTitle,
    ).then((value) {
      if (onValue == null) {
        return;
      }
      onValue(value);
    });
  }
}
