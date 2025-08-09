import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mysql_client/mysql_client.dart';
import 'package:webapp/src/tools/console.dart';
import 'package:webapp/src/tools/path.dart';
import 'package:webapp/wa_mysql.dart';

class MysqlMigration {
  MySQLConnection db;
  MysqlMigration(this.db);

  MTable migrationTable = MTable(
    name: 'wa_migration',
    fields: [
      MFieldVarchar(
        name: 'file',
        isNullable: false,
        isPrimaryKey: true,
        comment: 'Name of the migration SQL file',
        length: 255,
      ),
      MFieldTimestamp(
        name: 'created_at',
        isPrimaryKey: false,
        isAutoIncrement: false,
        isNullable: false,
        defaultValue: 'CURRENT_TIMESTAMP',
        comment: 'Time when the record was created',
      ),
      MFieldVarchar(
        name: 'sort',
        isNullable: false,
        defaultValue: '',
        length: 255,
      ),
    ],
  );

  Future<void> _createTable() async {
    if (!await migrationTable.existsTable(db)) {
      await migrationTable.createTable(db);
      Console.i('\nMigration table created: OK!');
    }
  }

  Future<String> migrateInit() async {
    await _createTable();
    var files = await getMigrationFiles();
    var executedFiles = [];
    for (var file in files) {
      var filename = path.basename(file.path);
      var exists = await checkExcutedMigration(filename);
      if (exists) continue;

      var sqlContent = await file.readAsString();
      sqlContent = sqlContent.split('-- ## ROLL BACK:')[0];
      if (sqlContent.isEmpty) continue;
      await db.execute(sqlContent);
      executedFiles.add(filename);
      await migrationTable.insert(db, {
        'file': QVar(filename),
        'sort': QVar(DateTime.now().millisecondsSinceEpoch.toString()),
      });
    }

    if (executedFiles.isEmpty) {
      return 'No migrations to execute.';
    }
    return 'Migration completed successfully:\n\n${executedFiles.join('\n')}';
  }

  Future<String> migrateRollback(int deep) async {
    List<String> successRollbackFiles = [];
    var resMigrations = await migrationTable.select(
      db,
      Sqler()
        ..addSelect(QSelect('file'))
        ..from(QField(migrationTable.name))
        ..orderBy(QOrder('sort', desc: true)),
    );

    var migrations = <String>[];
    for (var row in resMigrations.rows) {
      if (migrations.length >= deep) break;
      var filename = row.colByName('file');
      if (filename == null || filename.isEmpty) continue;
      migrations.add(filename);
    }

    for (var migration in migrations) {
      var filename = migration;
      if (filename.isEmpty) continue;
      var file = File(path.join(pathTo('./migrations'), filename));
      if (!file.existsSync()) continue;
      var sqlContent = await file.readAsString();
      if (!sqlContent.contains('-- ## ROLL BACK:')) continue;
      var rollbackContent = sqlContent.split('-- ## ROLL BACK:')[1];
      if (rollbackContent.isEmpty) continue;

      await db.execute(rollbackContent);
      await migrationTable.delete(
        db,
        Sqler()
          ..delete()
          ..from(QField(migrationTable.name))
          ..where(
            WhereOne(QField('file'), QO.EQ, QParam('file')),
          )
          ..addParam('file', QVar(filename)),
      );
      successRollbackFiles.add(file.path);
    }

    return 'Rollback completed successfully for: \n${successRollbackFiles.join('\n')}';
  }

  Future<String> migrateCreate() async {
    File file = File(
      path.join(
        pathTo('./migrations'),
        '${DateTime.now().millisecondsSinceEpoch}_migration.sql',
      ),
    );

    file.createSync(recursive: true);
    file.writeAsString(
      '-- ${DateTime.now()} \n'
      '-- ## NEW VERSION:\n\n\n\n'
      '-- ## ROLL BACK:\n\n\n\n',
    );
    Console.i('Migration file created: ${file.path}');
    return 'Create migration file command executed successfully.';
  }

  Future<bool> checkExcutedMigration(String filename) async {
    var query = Sqler()
      ..from(QField(migrationTable.name))
      ..addSelect(SQL.count(QField('file', as: 'count_records')))
      ..where(
        WhereOne(QField('file'), QO.EQ, QParam('file')),
      )
      ..addParam('file', QVar(filename));
    var res = await migrationTable.select(
      db,
      query,
    );

    return res.countRecords > 0;
  }

  Future<List<File>> getMigrationFiles() async {
    // Get all migration files from the migrations directory
    var dir = Directory(pathTo("./migrations"));
    if (!dir.existsSync()) {
      return [];
    }
    var files = dir.listSync().whereType<File>().toList();
    var res = <File>[];
    for (var file in files) {
      if (file.path.endsWith('.sql')) {
        res.add(file);
      }
    }
    res.sort((a, b) => a.path.compareTo(b.path));
    return res;
  }
}
