import 'dart:io';
import 'dart:math';
import '../db/mysql/mysql_books.dart';
import '../db/mysql/mysql_categories.dart';
import 'package:webapp/wa_mysql.dart';
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

  @override
  Future<String> index() async {
    return renderTemplate('template/home');
  }

  Future<String> sseExample() async {
    Stream<SSE> streamer = Stream.periodic(Duration(seconds: 1), (count) {
      return SSE(
        data: 'This is an SSE message $count',
        event: 'message',
      );
    }).take(10);

    return rq.renderSSE(streamer);
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
            (value) async {
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

  Future<String> renderTemplate(String widget, {bool toData = false}) async {
    MockUserModel? user;
    if (rq.session.containsKey('user')) {
      user = MockUserModel();
    }

    rq.addParam('languages', Setting.languages);

    rq.addParams({
      'title': 'logo.title',
      'year': DateTime.now().year,
      'user': await user?.toParams(),
      'mongoActive': server.db.isConnected,
      'mysqlActive': server.mysqlDb.connected,
      'version': 'v${WaServer.info.version}',
    });

    return rq.renderView(path: widget, toData: toData);
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
            "key2": rq.getAll(),
            "key3": this,
          },
          "type": rq.getLanguage(),
        },
      },
    };

    rq.addParam('variable', variable);
    return renderTemplate('example/dump');
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
        'MongoDB connected': server.db.isConnected,
        if (configs.isLocalDebug)
          'MongoDB Host': "${configs.dbConfig.host}:${configs.dbConfig.port}",
        'MongoDB DB name': configs.dbConfig.dbName,
        'MongoDB Collections': collectionNames.join(', '),
        'MySQL connected': server.mysqlDb.connected,
        if (configs.isLocalDebug)
          'MySQL Host':
              "${configs.mysqlConfig.host}:${configs.mysqlConfig.port}",
        'MySQL DB name': configs.mysqlConfig.databaseName,
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
    final res = await personCollectionFree.insert(rq.getAll());
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
    final res = await personCollectionFree.replaceOne(id, rq.getAll());

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
    final countAll = await personCollectionFree.getCount();
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

    final res = await personCollectionFree.getAll(
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
    final action = rq.get<String>('action', def: '');
    final res = await personCollectionFree.getById(id);
    if (res != null) {
      if (action == 'EDIT') {
        var res = await personCollectionFree.mergeOne(id, rq.getAll());
        if (res != null && res.success) {
          return rq.redirect('/example/person');
        } else {
          rq.addParam('form', res?.toJson());
        }
      } else {
        var personForm = await personCollectionFree.validate(res);
        rq.addParam('form', personForm.toJson());
      }
    }
    return _renderPerson(data: {
      'success': res != null,
      'data': res,
    });
  }

  Future<String> deletePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final res = await personCollectionFree.delete(id);
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

    final countAll = await personCollectionFree.getCount();
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

    final res = await personCollectionFree.getAllWithJob(
      limit: paging.pageSize,
      skip: paging.start,
      sort: DQ.order(orderBy, orderReverse),
    );

    final jobs = await jobCollectionFree.getAll();

    data = {
      ...data,
      'success': res.isNotEmpty,
      'allPerson': res,
      'paging': await paging.render(),
      'jobs': jobs
    };
    rq.addParams(data);
    return renderTemplate('example/person');
  }

  Future<String> exampleMysql() async {
    MysqlBooks tableBooks = MysqlBooks(server.mysqlDb);
    MysqlCategories tableCategories = MysqlCategories(server.mysqlDb);
    final action = rq.get<String>('action', def: '');
    rq.addParam('action', action);

    if (action == 'add_category') {
      final title = rq.get<String>('title', def: '');
      if (title.isNotEmpty) {
        var res = await tableCategories.addNewCategory(title: title);
        if (res.success) {
          addFlash('Category added successfully');
        } else {
          addFlash(
            'Error adding category: ${res.errorMsg}',
            type: FlashType.ERROR,
          );
        }
      } else {
        addFlash('Category title is required', type: FlashType.ERROR);
      }
    } else if (action == 'delete_category') {
      final id = rq.get<String>('id', def: '');
      await tableCategories.deleteCategory(id);
      addFlash('Category deleted successfully');
    } else if (action == 'delete') {
      final id = rq.get<String>('id', def: '');
      await tableBooks.deleteBook(id);

      addFlash('Book deleted successfully', type: FlashType.ERROR);
    } else if (action == 'delete_all') {
      var ids = rq.get<String>('selected_books', def: '').split(',');
      await tableBooks.deleteAllBooks(ids);
    } else if (action == 'add' || action == 'edit' || action == 'update') {
      Map<String, dynamic>? book;
      var bookId = rq.get<String>('id', def: '');

      rq.addParam('id', bookId);

      if (action == 'edit' || action == 'update') {
        book = await tableBooks.getBookById(bookId);
      }

      var data = <String, dynamic>{};
      switch (action) {
        case 'edit':
          data = book ?? {};
          break;
        default:
          data = rq.getAll();
      }

      var validate = await tableBooks.table.formValidateUI(data);
      if ((action == "update" || action == "add") && validate.result) {
        final title = rq.get<String>('title', def: '');
        final author = rq.get<String>('author', def: '');
        final publishedDate = rq.get<String>('published_date', def: '');
        final categoryId = rq.get<String>('category_id', def: '');
        MySqlResult res;

        if (action == "update" && book != null) {
          res = await tableBooks.updateBook(
            id: bookId,
            title: title,
            author: author,
            publishedDate: publishedDate,
            categoryId: categoryId,
          );
        } else if (action == "add") {
          res = await tableBooks.addNewBook(
            title: title,
            author: author,
            publishedDate: publishedDate,
            categoryId: categoryId,
          );
        } else {
          return rq.redirect('/example/mysql/overview');
        }

        if (res.success) {
          addFlash('Book added successfully');
        } else {
          addFlash(
            'Error adding book: ${res.errorMsg}',
            type: FlashType.ERROR,
          );
        }
      } else {
        rq.addParam('form', validate.form);
      }
    }

    var sort = rq.get<String>('sort', def: 'b.id');
    var order = rq.get<String>('order', def: 'asc');

    var formFilter = FormValidator(
      rq: rq,
      fields: {
        'filter_b.id': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_published_date': [
          FieldValidator.isDateField(isRequired: false),
        ],
        'filter_category_id': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_count': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_title': [],
        'filter_author': [],
      },
      name: 'filter_books',
    );
    var filter = await formFilter.validateAndForm();
    rq.addParam('filter_books', filter.form);
    var page = rq.get<int>('page', def: 1);
    var pageSize = rq.get<int>('pageSize', def: 10);

    var paging = UIPaging(
      rq: rq,
      widget: 'template/paging',
      page: page,
      total: 10,
      pageSize: pageSize,
      otherQuery: {
        ...FormValidator.extractString(filter.form),
        'pageSize': pageSize.toString(),
        'sort': sort,
        'order': order,
      },
    );

    var books = await tableBooks.getAllBooks(
      sort,
      order,
      filters: filter.result ? FormValidator.extractValues(filter.form) : {},
      limit: paging.pageSize,
      offset: paging.offset,
    );
    paging.total = books.count;
    var categories = await tableCategories.getAllCategories(
      'id',
      'ASC',
    );
    rq.addParam('books', books.rows.assoc);
    rq.addParam('categories', categories.rows.assoc);
    rq.addParam('count_total', books.count);
    rq.addParam('paging', await paging.render(toData: rq.isApiEndpoint));

    if (rq.isApiEndpoint) {
      return rq.renderDataParam();
    }

    return renderTemplate('example/mysql/overview');
  }

  void addFlash(String text, {final type = FlashType.SUCCESS}) {
    var flashs = rq.get<List>('flashs', def: []);
    flashs.add({
      'text': text,
      'type': type.toString(),
    });
    rq.addParam('flashs', flashs);
  }
}

enum FlashType {
  SUCCESS,
  ERROR,
  DANGER,
  INFO,
  WARNING;

  @override
  String toString() {
    switch (this) {
      case FlashType.SUCCESS:
        return 'success';
      case FlashType.ERROR:
      case FlashType.DANGER:
        return 'danger';
      case FlashType.INFO:
        return 'info';
      case FlashType.WARNING:
        return 'warning';
    }
  }
}
