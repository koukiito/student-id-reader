import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/felica_data.dart';

part 'nfc_state.freezed.dart';

@freezed
class NFCState with _$NFCState {
  const factory NFCState({
    @Default([]) List<FelicaData> history,
    @Default('') String message,
    @Default(false) bool isLoading,
  }) = _NFCState;
}
