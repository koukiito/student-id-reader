import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/view_models/nfc_view_model.dart';

class NFCReaderPage extends ConsumerWidget {
  const NFCReaderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nfcState = ref.watch(nFCViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Reader'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: nfcState.history.isEmpty
                    ? const Center(child: Text('No NFC data yet'))
                    : ListView.builder(
                        itemCount: nfcState.history.length,
                        itemBuilder: (context, index) {
                          final felicaData = nfcState.history[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text('Student ID ${index + 1}'),
                              subtitle: Text(felicaData
                                  .toString()), // Adjust based on your FelicaData structure
                            ),
                          );
                        },
                      ),
              ),
              if (nfcState.message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade100,
                  child: Text(
                    nfcState.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          if (nfcState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement NFC scan action
          ref.read(nFCViewModelProvider.notifier).startNFCReader();
        },
        child: const Icon(Icons.nfc),
      ),
    );
  }
}
