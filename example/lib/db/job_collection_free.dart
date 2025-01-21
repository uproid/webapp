import 'package:webapp/wa_model_less.dart';
import 'package:webapp/wa_ui.dart';
import 'package:mongo_dart/mongo_dart.dart';

class JobCollectionFree extends DBCollectionFree {
  JobCollectionFree({required super.db})
      : super(
          name: 'job',
          form: formPerson,
        );

  static DBFormFree get formPerson => DBFormFree(
        fields: {
          '_id': DBFieldFree<ObjectId>(
            readonly: true,
            hideJson: true,
          ),
          'title': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.fieldLength(min: 3),
            ],
          ),
        },
      );
}
