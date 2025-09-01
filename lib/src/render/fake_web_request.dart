import 'dart:io';

import 'package:webapp/wa_route.dart';

class FakeHttpRequest implements HttpRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Uri get requestedUri => Uri.parse('http://localhost');
  @override
  Uri get uri => Uri.parse('http://localhost');
}

class FakeWebRequest extends WebRequest {
  FakeWebRequest() : super(FakeHttpRequest());
}
