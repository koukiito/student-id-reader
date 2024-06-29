// application/view_models/nfc_view_model.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_id_reader/application/view_models/nfc_state.dart';
import '../../domain/repositories/nfc_repository.dart';

part 'nfc_view_model.g.dart';

@riverpod
class NFCViewModel extends _$NFCViewModel {
  @override
  NFCState build() {
    return const NFCState();
  }

  Future<void> startNFCReader() async {
    state = state.copyWith(isLoading: true);

    final nfcRepository = ref.read(nfcRepositoryProvider);
    bool isAvailable = await nfcRepository.isNfcAvailable();

    if (!isAvailable) {
      state = state.copyWith(
        message: 'NFC is not available on this device',
        isLoading: false,
      );
      return;
    }

    nfcRepository.startNfcSession().listen(
      (felicaData) {
        if (felicaData != null) {
          state = state.copyWith(
            history: [...state.history, felicaData],
            message: felicaData.studentId,
            isLoading: false,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          message: 'Error: $error',
          isLoading: false,
        );
      },
      onDone: () {
        // The session is automatically stopped after a tag is discovered
      },
    );
  }
}
