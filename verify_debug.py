
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
    
    dart_keys = get_dart_keys(dart_path)
    arb_keys = get_arb_keys(arb_path)
    
    in_dart_not_arb = dart_keys - arb_keys
    in_arb_not_dart = arb_keys - dart_keys
    
    if in_dart_not_arb:
        print(f"❌ {lang_code.upper()} mismatch: {len(in_dart_not_arb)} keys in Dart but NOT in ARB.")
        print(f"   Sample: {list(in_dart_not_arb)[:5]}")
            
    if in_arb_not_dart:
        print(f"❌ {lang_code.upper()} mismatch: {len(in_arb_not_dart)} keys in ARB but NOT in Dart.")
        print(f"   Sample: {list(in_arb_not_dart)[:5]}")
            
    if not in_dart_not_arb and not in_arb_not_dart:
        print(f"✅ {lang_code.upper()} synced.")
    return len(in_dart_not_arb) + len(in_arb_not_dart)

def main():
    base_path = 'lib/l10n'
    verify_language('fr', base_path)
    verify_language('zh', base_path)

if __name__ == '__main__':
    main()
