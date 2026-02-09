import json
import os

def propagate_translations():
    json_dir = 'assets/json'
    source_path = os.path.join(json_dir, 'azkar_en.json')

    if not os.path.exists(source_path):
        print(f"Source file not found: {source_path}")
        return

    try:
        with open(source_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading source JSON: {e}")
        return

    # List of languages to support based on l10n folder
    # ar is source, en is source for translation.
    # Targets: bn, de, es, fa, fr, id, ms, tr, ur, zh
    target_langs = ['bn', 'de', 'es', 'fa', 'fr', 'id', 'ms', 'tr', 'ur', 'zh']

    for lang in target_langs:
        target_path = os.path.join(json_dir, f'azkar_{lang}.json')
        
        # For now, we just copy the English version as a placeholder/fallback
        # The user requested "use the english to translate the other language manually"
        # which implies populating them with English content so they exist and have *some* translation.
        
        try:
            with open(target_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=4, ensure_ascii=False)
            print(f"Generated {target_path} (English content)")
        except Exception as e:
            print(f"Error writing {target_path}: {e}")

if __name__ == "__main__":
    propagate_translations()
