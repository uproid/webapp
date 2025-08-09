import 'package:mysql_client/mysql_client.dart';
import 'package:mysql_client/mysql_protocol.dart';
import 'package:webapp/src/forms/form_validator.dart';
import 'package:webapp/src/tools/convertor/string_validator.dart';
import 'package:webapp/wa_mysql.dart';

extension MySqlTable on MTable {
  List<QSelectField> getFieldsAs(String from, String as) {
    return this.fields.map((field) {
      return QSelectCustom(
          QMath('${from.isEmpty ? field.name : "$from.${field.name}"}'),
          as: as.isEmpty ? field.name : '$as.${field.name}');
    }).toList();
  }

  Future<MySqlResult> execute(
    MySQLConnection conn,
    String sql,
  ) async {
    try {
      var resultSet = await conn.execute(sql);
      return MySqlResult(resultSet);
    } catch (e) {
      return MySqlResult(
        EmptyResultSet(
            okPacket: MySQLPacketOK(
          header: 0,
          affectedRows: BigInt.zero,
          lastInsertID: BigInt.zero,
        )),
        errorMsg: e.toString(),
      );
    }
  }

  Future<bool> existsTable(MySQLConnection conn) async {
    Sqler sqler = Sqler()
      ..from(QField('information_schema.tables'))
      ..selects([
        QSelect('table_name'),
        SQL.count(QField('table_name', as: 'count')),
      ])
      ..where(WhereOne(
        QField('table_name'),
        QO.EQ,
        QVar(name),
      ));
    ;
    var result = await execute(conn, sqler.toSQL());
    var count = result.rows.first.colByName('count')?.toInt(def: 0);
    return (count ?? 0) > 0;
  }

  Future<MySqlResult> createTable(MySQLConnection conn) async {
    String sql = toSQL();
    return execute(conn, sql);
  }

  Future<MySqlResult> dropTable(MySQLConnection conn) async {
    String sql = 'DROP TABLE IF EXISTS `$name`;';
    return execute(conn, sql);
  }

  Future<MySqlResult?> createForeignKeys(MySQLConnection conn) async {
    if (foreignKeys.isEmpty) {
      return null;
    }
    String sql = 'ALTER TABLE `$name`\n';
    for (var i = 1; i <= foreignKeys.length; i++) {
      var fk = foreignKeys[i - 1];
      sql +=
          'ADD CONSTRAINT fk_${name}_${fk.name}_${DateTime.now().microsecondsSinceEpoch} ' +
              fk.toSQL() +
              (i == foreignKeys.length ? ';\n' : ',\n');
    }
    return execute(conn, sql);
  }

  Future<MySqlResult> insertMany(
    MySQLConnection conn,
    List<Map<String, QVar>> data,
  ) async {
    String sql = Sqler().insert(QField(this.name), data).toSQL();
    return execute(conn, sql);
  }

  Future<MySqlResult> insert(
    MySQLConnection conn,
    Map<String, QVar> data,
  ) async {
    return this.insertMany(conn, [data]);
  }

  Future<MySqlResult> select(MySQLConnection conn, Sqler query) async {
    String sql = query.toSQL();
    return execute(conn, sql);
  }

  Future<MySqlResult> delete(MySQLConnection conn, Sqler query) async {
    String sql = query.toSQL();

    if (!sql.contains('DELETE')) {
      throw Exception(
          'Use delete method instead of select for deleting records.');
    }

    return execute(conn, sql);
  }

  Future<FormResult> formValidateUI(
    Map<String, Object?> data,
  ) async {
    Map<String, List<Future<FieldValidateResult> Function(dynamic)>> fields =
        {};

    var exteraData = <String, Object?>{};
    for (final field in this.fields) {
      fields[field.name] = field.validators.map((validator) {
        return (value) async {
          var result = await validator(value);
          return FieldValidateResult(
            error: result,
            success: result.isEmpty,
          );
        };
      }).toList();
      exteraData[field.name] = data[field.name];
    }

    FormValidator formValidator = FormValidator(
      fields: fields,
      name: '${this.name}_form',
      extraData: exteraData,
    );
    var res = await formValidator.validateAndForm();

    return FormResult(
      form: res.form,
      result: res.result,
    );
  }
}

class MySqlResult {
  static const String _countRecordsField = 'count_records';
  final IResultSet resultSet;

  String errorMsg;
  MySqlResult(this.resultSet, {this.errorMsg = ''});

  bool get success => errorMsg.isEmpty;
  bool get error => !success;

  Iterable<ResultSetRow> get rows => resultSet.rows;
  BigInt get affectedRows => resultSet.affectedRows;
  BigInt get insertId => resultSet.lastInsertID;
  int get numFields => resultSet.numOfColumns;
  int get numRows => resultSet.numOfRows;

  List<Map<String, dynamic>> get assoc =>
      rows.map((row) => row.assoc()).toList();

  Map<String, dynamic>? get assocFirst {
    if (rows.isEmpty) {
      return null;
    }
    return rows.first.assoc();
  }

  /// This method returns the count of records from results
  /// with from this filed = `count_records`.
  int get countRecords {
    return int.tryParse((assocFirst?[_countRecordsField] ?? 0).toString()) ?? 0;
  }
}
