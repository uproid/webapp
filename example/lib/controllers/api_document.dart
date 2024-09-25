import '../app.dart';
import '../models/mock_user_model.dart';
import 'package:webapp/wa_route.dart';

class ApiDocuments {
  static final r_403 = [
    ApiResponse<int>('timestamp_start', def: 0),
    ApiResponse<String>('message', def: 'Please login'),
    ApiResponse<bool>('success', def: false),
    ApiResponse<int>('status', def: 403),
  ];

  static final r_404 = [
    ApiResponse<int>('timestamp_start', def: 0),
    ApiResponse<String>('message', def: 'Not found'),
    ApiResponse<bool>('success', def: false),
    ApiResponse<int>('status', def: 404),
  ];

  static final _pagging = [
    ApiParameter<String>('orderBy'),
    ApiParameter<bool>('orderReverse', def: true),
    ApiParameter<int>('pageSize', def: 0),
    ApiParameter<int>('page', def: 0),
  ];

  static Future<ApiDoc> info() async {
    return ApiDoc(
      response: {
        '200': [
          ApiResponse<int>('timestamp_start', def: 0),
          ApiResponse<Map<String, String>>('server', def: {}),
          ApiResponse<MockUserModel>(
            'users',
            def: [
              await MockUserModel().toParams(db: server.db),
              await MockUserModel().toParams(db: server.db),
            ],
          ),
          ApiResponse<Map>('usersPaging', def: {}),
          ApiResponse<Map<String, List<Map<String, String>>>>('server', def: {
            'Headers': [
              {'Content-Type': 'application/json'},
              {'Access-Control-Allow-Origin': '*'},
            ],
          }),
        ],
        '403': r_403,
        '404': r_404,
      },
      description: "Get all informations about server details.",
      parameters: _pagging,
    );
  }
}
