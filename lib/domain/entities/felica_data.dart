import 'package:freezed_annotation/freezed_annotation.dart';

part 'felica_data.freezed.dart';

@freezed
class FelicaData with _$FelicaData {
  const factory FelicaData({
    required String idm,
    required String studentId,
  }) = _FelicaData;
}
