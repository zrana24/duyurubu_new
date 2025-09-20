import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../language.dart'; // LanguageProvider'ı import et

class BluetoothProvider with ChangeNotifier {
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;

  BluetoothConnection? get connection => _connection;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnecting => _isConnecting;

  void setConnection(BluetoothConnection? connection, BluetoothDevice? device) {
    _connection = connection;
    _connectedDevice = device;
    _isConnecting = false;
    notifyListeners();
  }

  void setConnecting(bool connecting) {
    _isConnecting = connecting;
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (e) {
      print('Bağlantı kesme hatası: $e');
    } finally {
      _connection = null;
      _connectedDevice = null;
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> sendJsonData(Map<String, dynamic> data, BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (_connection == null || !_connection!.isConnected) {
      print('Bağlantı yok, veri gönderilemedi');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(languageProvider.getTranslation('connection_failed')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      String jsonString = jsonEncode(data);
      List<int> bytes = utf8.encode(jsonString + '\n');
      _connection!.output.add(Uint8List.fromList(bytes));
      await _connection!.output.allSent;
      print('JSON veri gönderildi: $jsonString');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(languageProvider.getTranslation('data_sent_success')),
        backgroundColor: Colors.green,
      ));
    }
    catch (e) {
      print('Veri gönderme hatası: $e');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(languageProvider.getTranslation('data_send_failed')),
        backgroundColor: Colors.red,
      ));

      disconnect();
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}