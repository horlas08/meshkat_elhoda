import json
import os

def normalize(text):
    return text.strip()

def main():
    supported_languages = ['bn', 'de', 'es', 'fa', 'fr', 'id', 'ms', 'tr', 'ur', 'zh']
    current_dir = os.getcwd()
    json_dir = os.path.join(current_dir, 'assets', 'json')
    
    print(f"Json Directory: {json_dir}")
    
    husn_en_path = os.path.join(json_dir, 'husn_en.json')
    if not os.path.exists(husn_en_path):
        print(f"Error: husn_en.json not found at {husn_en_path}")
        return

    # Read Template
    with open(husn_en_path, 'r', encoding='utf-8') as f:
        husn_en_json = json.load(f)
    
    # Get first key (usually "English")
    template_key = list(husn_en_json.keys())[0]
    template_list = husn_en_json[template_key]
    
    print(f"Loaded Template with {len(template_list)} chapters.")
    
    # 1. Process Supported Languages
    for lang in supported_languages:
        print(f"\nProcessing Language: {lang}")
        azkar_path = os.path.join(json_dir, f"azkar_{lang}.json")
        out_path = os.path.join(json_dir, f"husn_{lang}.json")
        
        if not os.path.exists(azkar_path):
            print(f"Warning: azkar_{lang}.json not found. Skipping.")
            continue
            
        # Build Map from Azkar
        with open(azkar_path, 'r', encoding='utf-8') as f:
            azkar_list = json.load(f)
            
        translation_map = {}
        category_map = {}
        
        azkar_items = 0
        for category in azkar_list:
            cat_name = category.get('category', '')
            array = category.get('array', [])
            for item in array:
                text = item.get('text', '')
                trans = item.get('translation', '')
                if text:
                    key = normalize(text)
                    if trans:
                        translation_map[key] = trans
                        if cat_name:
                            category_map[key] = cat_name
                azkar_items += 1
        
        print(f"  Loaded {len(translation_map)} translations from {azkar_items} items.")
        
        # Migrate
        new_husn_list = []
        matches = 0
        total_dhikrs = 0
        
        for chapter in template_list:
            new_chapter = chapter.copy()
            text_list = new_chapter.get('TEXT', [])
            new_text_list = []
            
            category_votes = {}
            
            for item in text_list:
                total_dhikrs += 1
                dhikr = item.copy()
                arabic = dhikr.get('ARABIC_TEXT', '')
                key = normalize(arabic)
                
                if key in translation_map:
                    dhikr['TRANSLATED_TEXT'] = translation_map[key]
                    matches += 1
                    
                    if key in category_map:
                        cat = category_map[key]
                        category_votes[cat] = category_votes.get(cat, 0) + 1
                
                new_text_list.append(dhikr)
            
            new_chapter['TEXT'] = new_text_list
            
            # Update Title
            if category_votes:
                best_cat = max(category_votes, key=category_votes.get)
                if best_cat:
                    new_chapter['TITLE'] = best_cat
            
            new_husn_list.append(new_chapter)
            
        # Save
        out_json = {lang: new_husn_list}
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(out_json, f, ensure_ascii=False, indent=4)
            
        print(f"  Saved husn_{lang}.json. Match Rate: {matches}/{total_dhikrs}")

    # 2. Process Arabic
    print("\nProcessing Language: ar")
    azkar_ar_path = os.path.join(json_dir, 'azkar.json')
    out_ar_path = os.path.join(json_dir, 'husn_ar.json')
    
    category_map_ar = {}
    if os.path.exists(azkar_ar_path):
        with open(azkar_ar_path, 'r', encoding='utf-8') as f:
            azkar_ar_list = json.load(f)
        for category in azkar_ar_list:
            cat_name = category.get('category', '')
            array = category.get('array', [])
            for item in array:
                text = item.get('text', '')
                if text and cat_name:
                    category_map_ar[normalize(text)] = cat_name
    
    new_husn_list_ar = []
    
    for chapter in template_list:
        new_chapter = chapter.copy()
        text_list = new_chapter.get('TEXT', [])
        new_text_list = []
        
        category_votes = {}
        
        for item in text_list:
            dhikr = item.copy()
            arabic = dhikr.get('ARABIC_TEXT', '')
            key = normalize(arabic)
            
            # Clear translated text for Arabic
            dhikr['TRANSLATED_TEXT'] = ""
            
            if key in category_map_ar:
                cat = category_map_ar[key]
                category_votes[cat] = category_votes.get(cat, 0) + 1
            
            new_text_list.append(dhikr)
        
        new_chapter['TEXT'] = new_text_list
        
        if category_votes:
            best_cat = max(category_votes, key=category_votes.get)
            if best_cat:
                new_chapter['TITLE'] = best_cat
        
        new_husn_list_ar.append(new_chapter)
        
    out_json_ar = {'ar': new_husn_list_ar}
    with open(out_ar_path, 'w', encoding='utf-8') as f:
        json.dump(out_json_ar, f, ensure_ascii=False, indent=4)
        
    print("  Saved husn_ar.json")
    print("\nMigration Complete.")

if __name__ == "__main__":
    main()
