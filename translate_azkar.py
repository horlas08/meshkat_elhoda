import json
import os
import time
import concurrent.futures
from mtranslate import translate

# Global language map
LANG_MAP = {
    'bn': 'bengali',
    'de': 'german',
    'es': 'spanish',
    'fa': 'persian',
    'fr': 'french',
    'id': 'indonesian',
    'ms': 'malay',
    'tr': 'turkish',
    'ur': 'urdu',
    'zh': 'zh-CN'
}

def load_source():
    json_dir = 'assets/json'
    source_path = os.path.join(json_dir, 'azkar_en.json')
    try:
        with open(source_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading source JSON: {e}")
        return None

def safe_translate(text, to_lang, from_lang='auto', retries=3):
    for i in range(retries):
        try:
            return translate(text, to_lang, from_lang)
        except Exception as e:
            if i == retries - 1:
                raise e
            time.sleep(2 * (i + 1)) # Exponential backoff: 2s, 4s, 6s
    return text

def translate_lang(lang_code, source_data):
    lang_name = LANG_MAP[lang_code]
    print(f"Starting threads for {lang_name} ({lang_code})...", flush=True)
    
    target_lang = lang_code if lang_code != 'zh' else 'zh-CN'
    json_dir = 'assets/json'
    target_path = os.path.join(json_dir, f'azkar_{lang_code}.json')

    translated_data = []
    
    # Phase 1: Translate Categories (Fast)
    print(f"[{lang_code}] Translating Categories...", flush=True)
    for category in source_data:
        new_cat = category.copy()
        try:
             new_cat['category'] = safe_translate(category['category'], target_lang, 'auto')
             print(f"[{lang_code}] Translated category: {new_cat['category']}", flush=True)
        except Exception as e:
             # print(f"[{lang_code}] Error translating category: {e}", flush=True)
             pass
        # Empty items for now or copy english
        new_cat['array'] = [item.copy() for item in category.get('array', [])] 
        translated_data.append(new_cat)
    
    # Save after Phase 1
    try:
        with open(target_path, 'w', encoding='utf-8') as f:
            json.dump(translated_data, f, indent=4, ensure_ascii=False)
        print(f"[{lang_code}] Categories saved.", flush=True)
    except Exception as e:
        print(f"[{lang_code}] Error saving categories: {e}", flush=True)

    # Phase 2: Translate Items
    print(f"[{lang_code}] Translating Items...", flush=True)
    total_cats = len(translated_data)
    
    for i, category in enumerate(translated_data):
        items = category['array']
        changed = False
        for item in items:
            if item.get('translation'): 
                try:
                    trans = safe_translate(item['translation'], target_lang, 'en')
                    if trans != item['translation']:
                        item['translation'] = trans
                        changed = True
                except Exception as e:
                    pass
        
        # Save periodically (every 5 categories to be safer)
        if changed and (i + 1) % 5 == 0:
            try:
                with open(target_path, 'w', encoding='utf-8') as f:
                    json.dump(translated_data, f, indent=4, ensure_ascii=False)
                # print(f"[{lang_code}] Progress: {i+1}/{total_cats}", flush=True)
            except:
                pass

    # Final Save
    try:
        with open(target_path, 'w', encoding='utf-8') as f:
            json.dump(translated_data, f, indent=4, ensure_ascii=False)
        print(f"[{lang_code}] Completed.", flush=True)
    except Exception as e:
        print(f"[{lang_code}] Error saving final: {e}", flush=True)

def main():
    source_data = load_source()
    if not source_data:
        return

    # Run all languages in parallel
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
        futures = []
        for lang_code in LANG_MAP.keys():
            futures.append(executor.submit(translate_lang, lang_code, source_data))
        
        for future in concurrent.futures.as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Thread error: {e}")

if __name__ == "__main__":
    main()
