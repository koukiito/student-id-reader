// data/repositories/nfc_repository_impl.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import '../../domain/repositories/nfc_repository.dart';
import '../../domain/entities/felica_data.dart';

class NFCRepositoryImpl implements NFCRepository {
  static const systemCode = [0xFE, 0x00];
  static const serviceCode = [0x1A, 0x8B];

  @override
  Future<bool> isNfcAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  @override
  Stream<FelicaData?> startNfcSession() {
    final controller = StreamController<FelicaData?>();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        NfcF? nfcf = NfcF.from(tag); // NfcF is a Android FeliCa tag
        FeliCa? felica = FeliCa.from(tag); // FeliCa is a iOS FeliCa tag

        if ((null == nfcf) && (null == felica)) {
          controller.add(null);
          return;
        }

        // if Android
        if (null != nfcf) {
          //Polling to Switch the System Code
          final polling = [
            0x00,
            0x00,
            systemCode[0],
            systemCode[1],
            0x01,
            0x0f
          ];
          polling[0] = polling.length; // Set the length of the polling command
          final pollingRes =
              await nfcf.transceive(data: Uint8List.fromList(polling));

          final idm = pollingRes.sublist(2, 10);

          //Request Service
          final requestService = [
            0x00,
            0x02,
            ...idm,
            0x01,
            serviceCode[1],
            serviceCode[0]
          ];
          requestService[0] = requestService
              .length; // Set the length of the request service command

          // Send the command and get the response
          final requestServiceRes =
              await nfcf.transceive(data: Uint8List.fromList(requestService));

          if ([0xff, 0xff] == requestServiceRes.sublist(11)) {
            //Service not available
            return;
          }

          //Polling
          final readWithoutEncryption = [
            0x00,
            0x06,
            ...idm,
            0x01,
            serviceCode[1],
            serviceCode[0]
          ];
          const size = 0x01;
          readWithoutEncryption.add(size); // Block count
          for (var i = 0; i < size; i++) {
            readWithoutEncryption.add(0x80); // Block element upper byte
            readWithoutEncryption.add(i); // Block number
          }

          readWithoutEncryption[0] = readWithoutEncryption
              .length; // Set the length of the read without encryption command

          final readRes = await nfcf.transceive(
              data: Uint8List.fromList(readWithoutEncryption));

          //Extract Student ID
          final data = readRes
              .sublist(15, 22)
              .map((e) => String.fromCharCode(e))
              .join('');

          final idmHex = idm.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');

          // Set the IDm and Student ID to the stream
          controller.add(FelicaData(
            idm: idmHex,
            studentId: data,
          ));
          return;
        }

        // if iOS
        if (null != felica) {
          //TODO: Implement the iOS FeliCa tag reading logic
          throw UnimplementedError();
        }

        // Stop the session after a tag is discovered
        await NfcManager.instance.stopSession();
      },
    ).catchError((error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  @override
  Future<void> stopNfcSession() async {
    await NfcManager.instance.stopSession();
  }
}
