import '../app.dart';
import '../db/job_collection_free.dart';
import 'package:webapp/wa_model_less.dart';
import 'package:webapp/wa_ui.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PersonCollectionFree extends DBCollectionFree {
  PersonCollectionFree({required super.db})
      : super(
          name: 'person',
          form: formPerson,
        );

  static DBFormFree get formPerson => DBFormFree(
        fields: {
          '_id': DBFieldFree<ObjectId>(
            readonly: true,
            hideJson: true,
          ),
          'job_id': DBFieldFree<ObjectId?>(
            defaultValue: null,
            validators: [
              FieldValidator.hasRelation(
                collectionModel: JobCollectionFree(db: server.db),
                relationField: '_id',
                isRequired: true,
              ),
            ],
          ),
          'name': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.fieldLength(min: 3),
            ],
          ),
          'password': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.isPasswordField(),
            ],
          ),
          'color': DBFieldFree<String?>(
            validators: [
              FieldValidator.isColorField(),
            ],
            defaultValue: () => "#FF0055",
          ),
          'gender': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.isSelectField(['male', 'female', 'other', 'none']),
            ],
            defaultValue: () => "none",
          ),
          'age': DBFieldFree<int?>(validators: [
            FieldValidator.requiredField(),
            FieldValidator.isNumberField(
              min: 1,
              max: 120,
              isRequired: true,
            ),
          ]),
          'email': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.isEmailField(),
            ],
          ),
          'birthday': DBFieldFree<DateTime?>(
            validators: [
              FieldValidator.requiredField(),
            ],
          ),
          'married': DBFieldFree<bool?>(
            defaultValue: () => false,
          ),
          'height': DBFieldFree<double?>(
            validators: [
              FieldValidator.isNumberDoubleField(
                min: 0.5,
                max: 2.5,
                isRequired: true,
              ),
            ],
          ),
        },
      );

  @override
  Future<Map<String, Object?>> toModel(
    Map<String, Object?> document, {
    List<String>? selectedFields,
  }) async {
    var model = await super.toModel(document, selectedFields: selectedFields);
    return model;
  }

  Future<List<Map<String, Object?>>> getAllWithJob({
    SelectorBuilder? selector,
    Map<String, Object?>? filter,
    FindOptions? findOptions,
    String? hint,
    int? skip,
    Map<String, Object>? sort,
    int? limit,
    Map<String, Object>? hintDocument,
    Map<String, Object>? projection,
    Map<String, Object>? rawOptions,
  }) async {
    var res = await super.getAll(
      selector: selector,
      filter: filter,
      findOptions: findOptions,
      hint: hint,
      skip: skip,
      sort: sort,
      limit: limit,
      hintDocument: hintDocument,
      projection: projection,
      rawOptions: rawOptions,
    );

    for (var person in res) {
      var jobId = person['job_id'];
      if (jobId != null && jobId is ObjectId) {
        person['job'] = await JobCollectionFree(db: db).getByOid(jobId);
      } else {
        person['job'] = null;
      }
    }

    return res;
  }
}
