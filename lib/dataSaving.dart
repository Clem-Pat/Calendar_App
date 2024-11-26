import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class CardStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cards.json');
  }

  Future<void> writeCards(List<Map<String, dynamic>> cards) async {
    final file = await _localFile;
    String jsonCards = jsonEncode(cards);
    await file.writeAsString(jsonCards);
  }

  Future<List<Map<String, dynamic>>> readCards() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonCards = jsonDecode(contents);
        return jsonCards.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}