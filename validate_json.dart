
import 'dart:convert';
import 'dart:io';

void main() {
  // Path to the JSON file
  final file = File('lib/l10n/app_es.arb');
  
  try {
    // Read the file content
    final String content = file.readAsStringSync();
    print('File read successfully.');
    
    try {
      // Try to parse the JSON
      final Map<String, dynamic> parsedJson = jsonDecode(content);
      print('JSON is valid! Found ${parsedJson.length} key-value pairs.');
      
      // Print a few sample entries to verify
      int count = 0;
      parsedJson.forEach((key, value) {
        if (count < 5 && !key.startsWith('@')) {
          print('- $key: $value');
          count++;
        }
      });
      
      print('\nValidation successful! The JSON file is correctly formatted.');
    } catch (e) {
      print('JSON parsing error: $e');
    }
  } catch (e) {
    print('Error reading file: $e');
  }
}
