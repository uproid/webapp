import 'dart:async';
import '../render/web_request.dart';

class RequestContext {
  static const String _requestKey = 'wa_request_context';

  static WebRequest get rq {
    final context = Zone.current[_requestKey];
    if (context == null) {
      throw StateError('No WebRequest found in current zone. '
          'This method can only be called within a request context.');
    }
    return context as WebRequest;
  }

  static bool get hasCurrent {
    return Zone.current[_requestKey] != null;
  }

  static T run<T>(WebRequest request, T Function() body) {
    return runZoned(
      body,
      zoneValues: {
        _requestKey: request,
      },
    );
  }

  static void runVoid(WebRequest request, void Function() body) {
    runZoned(
      body,
      zoneValues: {
        _requestKey: request,
      },
    );
  }
}
