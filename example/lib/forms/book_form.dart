import '../app.dart';
import '../db/mysql/mysql_categories.dart';
import 'package:webapp/wa_tools.dart';
import 'package:webapp/wa_ui.dart';

class BookForm extends AdvancedForm {
  @override
  String get widget => 'example/mysql/_form_edit.j2.html';

  @override
  String get name => 'form_book';
  BookForm({super.initData = const {}});

  @override
  List<Field> fields() {
    return [
      csrf(),
      Field(
        'title',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 3, max: 255),
        ],
      ),
      Field(
        'author',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 3, max: 255),
        ],
      ),
      Field(
        'published_date',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.isDateField(isRequired: true),
        ],
        initValue: DateTime.now().format('yyyy-MM-dd'),
      ),
      Field(
        'category_id',
        validators: [
          FieldValidator.hasSqlRelation(
            isRequired: false,
            db: server.mysqlDb,
            table: 'categories',
            field: 'id',
          )
        ],
        initValue: '',
        initOptions: (field) async {
          var categories =
              await MysqlCategories(server.mysqlDb).getAllCategories(
            'title',
            'desc',
          );
          return categories.rows.assoc;
        },
      ),
    ];
  }
}
