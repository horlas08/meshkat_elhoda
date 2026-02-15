import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final supportedLanguages = ['bn', 'de', 'es', 'fa', 'fr', 'id', 'ms', 'tr', 'ur', 'zh'];
  
  // Get absolute path to assets/json
  // Assuming script is run from project root
  final currentDir = Directory.current.path;
  final jsonDir = '$currentDir/assets/json';
  
  print('Json Directory: $jsonDir');

  final husnEnFile = File('$jsonDir/husn_en.json');
  if (!husnEnFile.existsSync()) {
    print('Error: husn_en.json not found at ${husnEnFile.path}');
    return;
  }

  // Read Template (English)
  final husnEnContent = await husnEnFile.readAsString();
  final husnEnJson = jsonDecode(husnEnContent) as Map<String, dynamic>;
  final templateKey = husnEnJson.keys.first; 
  final templateList = husnEnJson[templateKey] as List;

  print('Loaded Template with ${templateList.length} chapters.');

  // Helper to normalize Arabic text
  String normalize(String text) {
    return text.trim();
  }

  // 1. Process Supported Languages
  for (final lang in supportedLanguages) {
    print('\nProcessing Language: $lang');
    final azkarFile = File('$jsonDir/azkar_$lang.json');
    final outFile = File('$jsonDir/husn_$lang.json');

    if (!azkarFile.existsSync()) {
      print('Warning: azkar_$lang.json not found. Skipping.');
      continue;
    }

    // Build Map from Azkar
    final azkarContent = await azkarFile.readAsString();
    final azkarList = jsonDecode(azkarContent) as List;
    
    final Map<String, String> translationMap = {};
    final Map<String, String> categoryMap = {}; // Arabic Text -> Category Name

    int azkarItems = 0;
    for (final category in azkarList) {
      final catName = category['category'] as String? ?? '';
      final array = category['array'] as List? ?? [];
      for (final item in array) {
        final text = item['text'] as String? ?? '';
        final trans = item['translation'] as String? ?? '';
        if (text.isNotEmpty) {
          final key = normalize(text);
          if (trans.isNotEmpty) {
            translationMap[key] = trans;
            if (catName.isNotEmpty) {
              categoryMap[key] = catName;
            }
          }
        }
        azkarItems++;
      }
    }
    print('  Loaded ${translationMap.length} translations from $azkarItems items in azkar_$lang.json');

    // Migrate
    final newHusnList = [];
    int matches = 0;
    int totalDhikrs = 0;

    for (final chapter in templateList) {
      final newChapter = Map<String, dynamic>.from(chapter);
      final textList = (newChapter['TEXT'] as List);
      final newTextList = <Map<String, dynamic>>[];
      
      final categoryVotes = <String, int>{};

      for (final item in textList) {
        final dhikr = item as Map<String, dynamic>;
        totalDhikrs++;
        final arabic = dhikr['ARABIC_TEXT'] as String? ?? '';
        final key = normalize(arabic);

        final newDhikr = Map<String, dynamic>.from(dhikr);
        
        if (translationMap.containsKey(key)) {
          newDhikr['TRANSLATED_TEXT'] = translationMap[key];
          matches++;
          
          if (categoryMap.containsKey(key)) {
            final cat = categoryMap[key]!;
            categoryVotes[cat] = (categoryVotes[cat] ?? 0) + 1;
          }
        }
        
        newTextList.add(newDhikr);
      }
      
      newChapter['TEXT'] = newTextList;

      if (categoryVotes.isNotEmpty) {
        var bestCat = '';
        var maxVotes = 0;
        categoryVotes.forEach((k, v) {
          if (v > maxVotes) {
            maxVotes = v;
            bestCat = k;
          }
        });
        if (bestCat.isNotEmpty) {
           newChapter['TITLE'] = bestCat;
        }
      }

      newHusnList.add(newChapter);
    }

    final outJson = {lang: newHusnList};
    await outFile.writeAsString(jsonEncode(outJson));
    print('  Saved husn_$lang.json. Match Rate: $matches / $totalDhikrs (${(matches/totalDhikrs*100).toStringAsFixed(1)}%)');
  }

  // 2. Process Arabic (husn_ar.json)
  print('\nProcessing Language: ar');
  final outFile = File('$jsonDir/husn_ar.json');
  final azkarFile = File('$jsonDir/azkar.json');
  
  Map<String, String> categoryMapAr = {};

  if (azkarFile.existsSync()) {
      final azkarContent = await azkarFile.readAsString();
      final azkarList = jsonDecode(azkarContent) as List;
      for (final category in azkarList) {
          final catName = category['category'] as String? ?? '';
          final array = category['array'] as List? ?? [];
          for (final item in array) {
             final text = item['text'] as String? ?? '';
             // Use text as key to identify category
             if (text.isNotEmpty && catName.isNotEmpty) {
               categoryMapAr[normalize(text)] = catName;
             }
          }
      }
      print('  Loaded Arabic categories from azkar.json');
  } else {
      print('  Warning: azkar.json not found. Retaining English titles.');
  }

  final newHusnListAr = [];
  int totalDhikrsAr = 0;
  
  for (final chapter in templateList) {
    final newChapter = Map<String, dynamic>.from(chapter);
    final textList = (newChapter['TEXT'] as List);
    final newTextList = <Map<String, dynamic>>[];
    
    final categoryVotes = <String, int>{};

    for (final item in textList) {
      final dhikr = item as Map<String, dynamic>;
      totalDhikrsAr++;
      final arabic = dhikr['ARABIC_TEXT'] as String? ?? '';
      final key = normalize(arabic);

      final newDhikr = Map<String, dynamic>.from(dhikr);
      
      // Clear Translated Text for Arabic mode
      newDhikr['TRANSLATED_TEXT'] = ""; 
      
      if (categoryMapAr.containsKey(key)) {
            final cat = categoryMapAr[key]!;
            categoryVotes[cat] = (categoryVotes[cat] ?? 0) + 1;
      }
      
      newTextList.add(newDhikr);
    }
    
    newChapter['TEXT'] = newTextList;
    
    // Update Title to Arabic
    if (categoryVotes.isNotEmpty) {
        var bestCat = '';
        var maxVotes = 0;
        categoryVotes.forEach((k, v) {
            if (v > maxVotes) {
            maxVotes = v;
            bestCat = k;
            }
        });
        if (bestCat.isNotEmpty) {
            newChapter['TITLE'] = bestCat;
        }
    }

    newHusnListAr.add(newChapter);
  }

  final outJsonAr = {'ar': newHusnListAr};
  await outFile.writeAsString(jsonEncode(outJsonAr));
  print('  Saved husn_ar.json with cleared translations and mapped titles.');
  print('\nMigration Complete.');
}
