import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/felica_data.dart';
import 'nfc_repository_impl.dart';

part 'nfc_repository.g.dart';

abstract class NFCRepository {
  Future<bool> isNfcAvailable();
  Stream<FelicaData?> startNfcSession();
  Future<void> stopNfcSession();
}

@riverpod
NFCRepository nfcRepository(NfcRepositoryRef ref) {
  return NFCRepositoryImpl();
}
