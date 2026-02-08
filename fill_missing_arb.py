
import json
import os
import glob

def load_arb(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return {}

def save_arb(file_path, data):
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write('\n') # Add trailing newline
        print(f"Updated {os.path.basename(file_path)}")
    except Exception as e:
        print(f"Error writing {file_path}: {e}")

def main():
    base_path = 'lib/l10n'
    en_path = os.path.join(base_path, 'app_en.arb')
    
    if not os.path.exists(en_path):
        print(f"Base English file not found at {en_path}")
        return

    en_data = load_arb(en_path)
    en_keys = set(k for k in en_data.keys() if not k.startswith('@'))
    print(f"Base English Keys Count: {len(en_keys)}")

    arb_files = glob.glob(os.path.join(base_path, 'app_*.arb'))
    
    for arb_file in arb_files:
        if arb_file.endswith('app_en.arb'):
            continue
            
        lang_data = load_arb(arb_file)
        lang_keys = set(k for k in lang_data.keys() if not k.startswith('@'))
        
        missing_keys = en_keys - lang_keys
        
        if missing_keys:
            print(f"Fixing {os.path.basename(arb_file)}: Adding {len(missing_keys)} missing keys.")
            for key in missing_keys:
                # Add the missing key with English value
                lang_data[key] = en_data[key]
                # maintain metadata if exists in english (optional, but good for context)
                if f"@{key}" in en_data:
                     lang_data[f"@{key}"] = en_data[f"@{key}"]

            # Sort keys to match English order or alphabetic for consistency (optional)
            # Python dictionaries preserve insertion order in 3.7+, but json.dump might not match exactly.
            # Best effort to keep it clean.
            
            save_arb(arb_file, lang_data)
        else:
            print(f"Skipping {os.path.basename(arb_file)}: Up to date.")

if __name__ == '__main__':
    main()
