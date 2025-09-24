import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

//import 'package:share_plus/share_plus.dart';
import 'nfcData/nfcData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NFCReaderScreen(),
    );
  }
}

class NFCReaderScreen extends StatefulWidget {
  @override
  _NFCReaderScreenState createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  TextEditingController _nfcData = TextEditingController();
  bool _isScanning = false;
  bool _useId = false;

  Uint8List stringToUnit8List(String str) {
    return Uint8List.fromList(
        str.split(',').map((e) => int.parse(e.trim())).toList());
  }

  void processNfcData(Map<String, dynamic> data) {
    if (data.containsKey('nfcf')) {
      final nfcfData = data['nfcf'] as Map<String, dynamic>;

      // Extract individual fields
      List<int> identifier = List<int>.from(nfcfData['identifier']);
      List<int> manufacturer = List<int>.from(nfcfData['manufacturer']);
      int maxTransceiveLength = nfcfData['maxTransceiveLength'];
      List<int> systemCode = List<int>.from(nfcfData['systemCode']);
      int timeout = nfcfData['timeout'];

      // Print or use the extracted data
      print('Identifier: $identifier');
      print('Manufacturer: $manufacturer');
      print('Max Transceive Length: $maxTransceiveLength');
      print('System Code: $systemCode');
      print('Timeout: $timeout');
    } else {
      print('No NFCF data found.');
    }
  }

  void _startNFCReading() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _nfcData.text += 'NFC is not available on this device.\n';
      });
      return;
    }

    // Prevent multiple session starts
    if (_isScanning) {
      _nfcData.text += ("NFC session is already active.\n");
      return;
    }

    setState(() {
      _isScanning = true; // Mark scanning as active
    });

    NfcManager.instance.startSession(
      onError: (error) async {
        _nfcData.text += ("NFC Error: $error");
        setState(() {
          _nfcData.text = "Error: ${error.message}";
          _isScanning = false; // Reset scanning status
        });
      },
      onDiscovered: (NfcTag tag) async {
        try {
          final nfcTag = NfcF.from(tag);
          if (nfcTag != null) {
            final response = await nfcTag!.transceive(data: NFCData.generateReadCommand(nfcTag.identifier)),
            response2 = await nfcTag!.transceive(data: NFCData.generateReadCommand(nfcTag.identifier,startBlockNumber: 10));
            setState(() {
                  if(response.isEmpty) {
                    _nfcData.text += "didn't got any response \n";
                  }
                  if(response2.isEmpty) {
                    _nfcData.text += "didn't got any response 2\n";
                  }
                  if(response.isNotEmpty) {
                    _nfcData.text += "Got response1: ${response.toString()}\n";
                  }
                  if(response2.isNotEmpty) {
                    _nfcData.text += "Got response2: ${response2.toString()}\n";
                  }
            });
          }
        } catch (e) {
          setState(() {
            _nfcData.text += "Error processing tag: $e";
          });
        } finally {
          // Stop the session and reset scanning status
          NfcManager.instance.stopSession();
          setState(() {
            _isScanning = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              minLines: 1,
              maxLines: 10,
              controller: _nfcData,
            ),
            const SizedBox(height:20),
            ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: _nfcData.text));
                    },
                    child: const Icon(Icons.copy)),
            //ElevatedButton(onPressed: () => _nfcData.clear(), child: const Icon(Icons.clear)),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: _nfcData.text));
                    },
                    child: const Icon(Icons.copy)),
                const SizedBox(width: 10,),
                ElevatedButton(
                    onPressed: () async {
                      final result = await Share.share(_nfcData.text);
                    },
                    child: const Icon(Icons.share)),
              ],
            ),*/
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startNFCReading,
              child: const Text('Start NFC Reader'),
            ),
          ],
        ),
      ),
    );
  }
}
