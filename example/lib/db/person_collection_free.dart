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
          'name': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.fieldLength(min: 3),
            ],
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
            defaultValue: false,
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
  Map<String, Object?> toModel(
    Map<String, Object?> document, {
    List<String>? selectedFields,
  }) {
    return super.toModel(document, selectedFields: selectedFields);
  }
}
