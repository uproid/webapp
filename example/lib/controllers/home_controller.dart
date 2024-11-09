import 'dart:io';
import 'dart:math';
import '../db/person_collection_free.dart';
import '../configs/setting.dart';
import '../db/example_collections.dart';
import '../models/example_model.dart';
import 'package:webapp/wa_mail.dart';
import 'package:webapp/wa_model.dart';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/wa_tools.dart';
import 'package:webapp/wa_ui.dart';
import '../app.dart';
import '../models/mock_user_model.dart';

class HomeController extends WaController {
  HomeController(super.rq);
  var personCollection = PersonCollectionFree(db: server.db);

  @override
  Future<String> index() async {
    return renderTemplate('index');
  }

  Future<String> exampleForm() async {
    if (rq.method == RequestMethods.POST) {
      var loginForm = FormValidator(
        name: 'loginForm',
        rq: rq,
        fields: {
          'email': [
            FieldValidator.isEmailField(),
            FieldValidator.requiredField(),
            FieldValidator.fieldLength(min: 5, max: 255)
          ],
          'password': [
            (value) {
              return FieldValidateResult(
                success: value.toString().isPassword,
                error: 'error.invalid.password'.tr.write(rq),
              );
            },
            FieldValidator.requiredField(),
            FieldValidator.fieldLength(min: 8, max: 255)
          ],
        },
      );

      var result = await loginForm.validateAndForm();
      var loginResult = false;

      if (result.result) {
        var email = rq.get<String>('email', def: '');
        var password = rq.get<String>('password', def: '');
        if (email == 'example@uproid.com' && password == '@Test123') {
          loginResult = true;
        }
      }

      rq.addParams({
        'loginForm': result.form,
        'loginResult': loginResult,
      });
    }

    return renderTemplate('example/form');
  }

  Future<String> exampleCookie() async {
    return renderTemplate('example/cookie');
  }

  Future<String> exampleAuth() async {
    return renderTemplate('example/auth');
  }

  Future<String> exampleLanguage() async {
    var a = Random().nextInt(10);
    var b = Random().nextInt(10);
    var c = Random().nextInt(10);
    var d = Random().nextInt(10);

    rq.addParams({
      'exampleTString': TString('example.tstring').write(rq),
      'examplePathString': 'example.path'.tr.write(rq),
      'exampleTranslateParams': 'example.params'.tr.write(rq, {
        'name': 'Alexandre',
        'age': Random().nextInt(100),
      }),
      'exampleTranslateDynamic':
          'example.params.dynamic#$a#$b#$c#$d'.tr.write(rq),
    });
    return renderTemplate('example/i18n');
  }

  Future<String> exampleRoute() async {
    var allRoutes = await server.getAllRoutes(rq);

    List<Map> convert(List<WebRoute> routes, String parentPath, hasAuth) {
      var result = <Map>[];

      for (final route in routes) {
        for (var method in route.methods) {
          var map = route.toMap(
            parentPath,
            hasAuth || route.auth != null,
            method,
          );
          result.addAll(map);
        }
        if (route.children.isNotEmpty) {
          result.addAll(
            convert(
              route.children,
              "$parentPath${route.path}",
              hasAuth || route.auth != null,
            ),
          );

          for (var epath in route.extraPath) {
            result.addAll(
              convert(
                route.children,
                "$parentPath$epath",
                hasAuth || route.auth != null,
              ),
            );
          }
        }
      }

      return result;
    }

    var webRoutes = convert(allRoutes, '', false);
    webRoutes.sort(
        (a, b) => a['fullPath'].toString().compareTo(b['fullPath'].toString()));

    rq.addParam('routes', webRoutes);
    return renderTemplate('example/route');
  }

  Future<String> exampleAddCookie() async {
    var name = rq.get<String>('name', def: '');
    var value = rq.get<String>('value', def: '');
    var safe = rq.get<bool>('safe', def: false);
    var action = rq.get<String>('action', def: 'add');

    if (action == 'delete') {
      rq.removeCookie(name);
    } else if (action == 'add' && name.isNotEmpty && value.isNotEmpty) {
      rq.addCookie(name, value, safe: safe);
    }

    return exampleCookie();
  }

  Future<String> exampleSocket() async {
    return renderTemplate('example/socket');
  }

  Future<String> exampleDatabase() async {
    var action = rq.get<String>('action', def: '');
    var page = rq.get<int>('page', def: 0);
    ExampleCollections exampleCollections = ExampleCollections();

    if (rq.method == RequestMethods.POST && action == 'add') {
      var title = rq.get<String>('title', def: '').trim();
      if (title.isNotEmpty) {
        var model = ExampleModel(title: title, slug: title.toSlug());
        await exampleCollections.insertExample(model);
      }
    } else if (action == 'delete') {
      var id = rq.get<String>('id', def: '');
      if (id.isNotEmpty) {
        await exampleCollections.delete(id);
      }
    }

    var countRecords = await exampleCollections.getCount();
    var pagination = UIPaging(
      rq: rq,
      widget: 'template/paging',
      page: page,
      total: countRecords,
      pageSize: 10,
    );

    var allRecords = await exampleCollections.getAllExample(
      start: pagination.start,
      count: pagination.pageSize,
    );
    rq.addParam('allRecords', await DBModel.toListParams(allRecords));
    rq.addParam('pagination', await pagination.render());
    return renderTemplate('example/database');
  }

  Future<String> paginationExample() async {
    var pageA = rq.get<int>('page_a', def: 0);
    var pageB = rq.get<int>('page_b', def: 0);
    var pageC = rq.get<int>('page_c', def: 0);

    var paginationA = UIPaging(
      rq: rq,
      widget: 'template/paging',
      page: pageA,
      total: 1000,
      pageSize: 10,
      profix: 'page_a',
      otherQuery: {
        'page_b': pageB.toString(),
        'page_c': pageC.toString(),
      },
    );

    rq.addParam('paginationA', await paginationA.render());

    var paginationB = UIPaging(
      rq: rq,
      widget: 'template/paging',
      page: pageB,
      total: 500,
      pageSize: 10,
      widthSide: 5,
      profix: 'page_b',
      otherQuery: {
        'page_a': pageA.toString(),
        'page_c': pageC.toString(),
      },
    );

    rq.addParam('paginationB', await paginationB.render());

    var paginationC = UIPaging(
      rq: rq,
      widget: 'template/paging',
      page: pageC,
      total: 1000,
      pageSize: 100,
      profix: 'page_c',
      otherQuery: {
        'page_a': pageA.toString(),
        'page_b': pageB.toString(),
      },
    );

    rq.addParam('paginationC', await paginationC.render());

    return renderTemplate('example/pagination');
  }

  Future<String> exampleEmail() async {
    return renderTemplate('example/email');
  }

  Future<String> exampleEmailSend() async {
    var emailForm = FormValidator(
      name: 'emailForm',
      rq: rq,
      fields: {
        'email': [
          FieldValidator.requiredField(),
          FieldValidator.isEmailField(),
        ],
        'from': [
          FieldValidator.requiredField(),
          FieldValidator.isEmailField(),
        ],
        'subject': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'message': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 1000),
        ],
        'host': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'port': [
          FieldValidator.isNumberField(
            min: 1,
            max: 65535,
            isRequired: true,
          ),
        ],
        'username': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'password': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'fromName': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
      },
    );

    var resEmailForm = await emailForm.validateAndForm();
    if (resEmailForm.result) {
      var resSendEmail = await MailSender.sendEmail(
        from: rq.get('from'),
        to: [rq.get('email')],
        subject: rq.get('subject'),
        text: rq.get('message'),
        html: rq.get('message'),
        host: rq.get('host'),
        port: rq.get('port', def: 465),
        username: rq.get('username'),
        password: rq.get('password'),
        ssl: rq.get('ssl', def: true),
        allowInsecure: rq.get('allowInsecure', def: true),
        fromName: rq.get('fromName'),
      );

      if (resSendEmail) {
        rq.addParam('sendEmailSuccess', 'Email sent successfully');
      } else {
        rq.addParam('sendEmailFeiled', 'Email not sent');
      }
    }

    rq.addParams({
      'emailForm': resEmailForm.form,
    });

    return renderTemplate('example/email');
  }

  Future<String> renderTemplate(String widget) async {
    MockUserModel? user;
    if (rq.session.containsKey('user')) {
      user = MockUserModel();
      ;
    }

    rq.addParam('languages', Setting.languages);

    rq.addParams({
      'title': 'logo.title',
      'year': DateTime.now().year,
      'user': await user?.toParams(),
      'mongoActive': server.db.isConnected,
      'version': 'v${WaServer.info.version}',
    });

    rq.addParam('widget', widget);
    return rq.renderView(path: "template/home");
  }

  Future<String> exampleError() async {
    throw Exception('This is an example error of exceptions');
  }

  Future<String> exampleDump() async {
    var variable = {
      "test": {
        "test1": 'test',
        "test2": 1,
        "test3": false,
        "test4": String,
        "test5": [1, 2, 3],
        "test6": {
          "key": "value",
          "key2": rq.getAssets(),
          "key3": rq.getValidator(),
          "key4": {
            "key": rq.getAllSession(),
            "key2": rq.getAllData(),
            "key3": this,
          },
          "type": rq.getLanguage(),
        },
      },
    };
    return rq.dump(variable);
  }

  Future<String> indexApi() async => rq.renderData(
        data: {
          "message": "Hello World!!!",
          "success": true,
          "time": DateTime.now().toString(),
        },
      );

  Future<String> changeLanguage() async {
    var redirectTo = '/';
    var language = rq.uri.pathSegments.first;

    rq.changeLanguege(language);
    if (rq.uri.pathSegments.length > 1) {
      redirectTo = joinPaths(rq.uri.pathSegments.sublist(1));
    }
    redirectTo =
        rq.uri.replace(path: redirectTo, scheme: null, host: null).toString();

    return rq.redirect("/$redirectTo");
  }

  Future<String> socket() async {
    await socketManager.requestHandel(rq);
    return rq.renderSocket();
  }

  Future<String> info() async {
    Map dbInfo = server.db.isConnected ? await server.db.getBuildInfo() : {};
    var languageCount = [];
    WaServer.appLanguages.forEach((key, value) {
      languageCount.add("$key (${value.length})");
    });

    var collections = server.db.isConnected
        ? await server.db.modernListCollections().toList()
        : [];
    var collectionNames = collections.map((e) => e['name']);

    var headers = <String, List<String>>{};
    rq.headers.forEach((name, values) {
      headers[name] = values;
    });

    var serverInfo = <String, Object>{
      'Address': {
        'URL': rq.url(''),
        'URI': rq.uri.path,
        'Email default': configs.mailDefault,
        'IP': rq.getIP(),
      },
      'Headers': headers,
      'Versions': {
        'Version': configs.version,
        'WebApp version': WaServer.info.version,
        'Dart version': Platform.version,
        'Mongo Version': dbInfo['version'] ?? 'Unknown',
      },
      'System': {
        'Number of processors': Platform.numberOfProcessors,
        'Oprating System':
            "${Platform.operatingSystem.toUpperCase()} ${Platform.operatingSystemVersion}",
      },
      'Database': {
        'DB name': configs.dbConfig.dbName,
        'Collections': collectionNames.join(', '),
      },
      'Date & Time': {
        'Idle Timeout': server.server!.idleTimeout,
        'Time': DateTime.now(),
        'Time stamp': DateTime.now().millisecondsSinceEpoch,
        'Time Zone Name': DateTime.now().timeZoneName,
      },
      'Language': {
        'Current language': rq.getLanguage(),
        'Languages Strings': languageCount.join(' , ').toUpperCase(),
      },
      'Server Info': {
        'Server Header': server.server!.serverHeader ?? 'Unknown',
        'Connection Count': server.server!.connectionsInfo().total,
        'Connection Active': server.server!.connectionsInfo().active,
        'Connection Closing': server.server!.connectionsInfo().closing,
        'Connection Idle': server.server!.connectionsInfo().idle,
      },
      'Cron Job': {
        'Cron count': server.crons.length,
        'Active Cron': server.crons
            .where((element) => element.status == CronStatus.running)
            .length,
        'Stoped Cron': server.crons
            .where((element) => element.status == CronStatus.stoped)
            .length,
        'Not started Cron': server.crons
            .where((element) => element.status == CronStatus.notStarted)
            .length,
      },
      'Socker IO Server': {
        'Socket Runing': server.hasSocket,
        'Socket online sessions': server.socketManager?.countClients ?? 0,
        'Socket online users': server.socketManager?.countUsers ?? 0,
      },
    };

    rq.addParam('server', serverInfo);
    if (rq.isApiEndpoint) {
      return rq.renderDataParam();
    }

    return renderTemplate('example/info');
  }

  Future<String> addNewPerson() async {
    final res = await personCollection.insert(rq.getAllData());
    if (res.success) {
      rq.addParam('data', res.formValues);
    } else {
      rq.addParam('form', res.toJson());
    }
    return _renderPerson(data: {
      'success': res.success,
    });
  }

  Future<String> replacePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final res = await personCollection.replaceOne(id, rq.getAllData());

    if (res == null) {
      return _renderPerson(
        data: {'success': false},
        status: 404,
      );
    }

    if (res.success) {
      rq.addParam('data', res.formValues);
    } else {
      rq.addParam('form', res.toJson());
    }
    return _renderPerson(data: {
      'success': res.success,
    });
  }

  Future<String> allPerson() async {
    final countAll = await personCollection.getCount();
    final pageSize = rq.get<int>('pageSize', def: 20);
    final orderBy = rq.get<String>('orderBy', def: '_id');
    final orderReverse = rq.get<bool>('orderReverse', def: true);

    UIPaging paging = UIPaging(
      rq: rq,
      total: countAll,
      pageSize: pageSize,
      widget: '',
      page: rq.get<int>('page', def: 1),
    );

    final res = await personCollection.getAll(
      limit: paging.pageSize,
      skip: paging.start,
      sort: DQ.order(orderBy, orderReverse),
    );

    return _renderPerson(data: {
      'success': res.isNotEmpty,
      'data': res,
      'paging': await paging.renderData(),
    });
  }

  Future<String> onePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final res = await personCollection.getById(id);
    return _renderPerson(data: {
      'success': res != null,
      'data': res,
    });
  }

  Future<String> updateOrDeletePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final action = rq.get<String>('action', def: '');
    if (action == 'DELETE') {
      return deletePerson();
    }

    final email = rq.get<String>('email', def: '');
    final res = await personCollection.updateField(id, 'email', email);
    if (res == null) {
      return _renderPerson(
        data: {'success': false},
        status: 404,
      );
    }
    if (res.success) {
      return _renderPerson(data: {
        'success': res.success,
        'data': res.formValues,
      });
    }
    return _renderPerson(data: {
      'success': res.success,
      'form': res.toJson(),
    });
  }

  Future<String> deletePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final res = await personCollection.delete(id);
    return _renderPerson(data: {
      'success': res,
    });
  }

  Future<String> _renderPerson({
    required Map<String, Object?> data,
    status = 200,
  }) async {
    if (rq.isApiEndpoint) {
      return rq.renderDataParam(
        data: data,
        status: status,
      );
    }

    final countAll = await personCollection.getCount();
    final pageSize = rq.get<int>('pageSize', def: 10);
    final orderBy = rq.get<String>('orderBy', def: '_id');
    final orderReverse = rq.get<bool>('orderReverse', def: true);

    UIPaging paging = UIPaging(
      rq: rq,
      total: countAll,
      pageSize: pageSize,
      widget: 'template/paging',
      page: rq.get<int>('page', def: 1),
    );

    final res = await personCollection.getAll(
      limit: paging.pageSize,
      skip: paging.start,
      sort: DQ.order(orderBy, orderReverse),
    );

    data = {
      ...data,
      'success': res.isNotEmpty,
      'allPerson': res,
      'paging': await paging.render(),
    };
    rq.addParams(data);
    return renderTemplate('example/person');
  }
}
