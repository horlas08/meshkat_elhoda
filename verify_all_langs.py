
import re
import json
import os

def get_dart_keys(file_path):
    keys = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            matches = re.findall(r'String\s+get\s+(\w+)', content)
            matches += re.findall(r'String\s+(\w+)\(', content)
            keys.update(matches)
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    return keys

def get_arb_keys(file_path):
    keys = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            keys.update(k for k in data.keys() if not k.startswith('@'))
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON in {file_path}: {e}")
    return keys

def verify_language(lang_code, base_path):
    dart_path = os.path.join(base_path, f'app_localizations_{lang_code}.dart')
    arb_path = os.path.join(base_path, f'app_{lang_code}.arb')
    
    # print(f"Checking {lang_code}...")
    
    dart_keys = get_dart_keys(dart_path)
    arb_keys = get_arb_keys(arb_path)
    
    in_dart_not_arb = dart_keys - arb_keys
    in_arb_not_dart = arb_keys - dart_keys
    
    if in_dart_not_arb:
        print(f"❌ {lang_code.upper()} mismatch: {len(in_dart_not_arb)} keys in Dart but NOT in ARB.")
        # for k in in_dart_not_arb: print(f"  + Dart only: {k}")
            
    if in_arb_not_dart:
        print(f"❌ {lang_code.upper()} mismatch: {len(in_arb_not_dart)} keys in ARB but NOT in Dart.")
        # for k in in_arb_not_dart: print(f"  + ARB only: {k}")
            
    if not in_dart_not_arb and not in_arb_not_dart:
        print(f"✅ {lang_code.upper()} synced.")
    return len(in_dart_not_arb) + len(in_arb_not_dart)

def main():
    base_path = 'lib/l10n'
    languages = ['ar', 'bn', 'de', 'en', 'es', 'fa', 'fr', 'id', 'ms', 'tr', 'ur', 'zh']
    
    total_errors = 0
    print("--- Verification Report ---")
    for lang in languages:
        total_errors += verify_language(lang, base_path)
        
    if total_errors == 0:
        print("\n🎉 All 12 languages are perfectly synced!")
    else:
        print(f"\n⚠️ Found issues in {total_errors} places.")

if __name__ == '__main__':
    main()
