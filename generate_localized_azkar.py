import json
import os
import re

def normalize_text(text):
    if not text: return ""
    # Remove diacritics (tashkeel)
    text = re.sub(r'[\u064B-\u065F\u0670]', '', text)
    # Remove punctuation and extra spaces
    text = re.sub(r'[^\w\s]', '', text)
    return text.strip()

def generate_localized_azkar():
    json_dir = 'assets/json'
    azkar_path = os.path.join(json_dir, 'azkar.json')
    husn_path = os.path.join(json_dir, 'husn_en.json')
    output_path = os.path.join(json_dir, 'azkar_en.json')

    if not os.path.exists(azkar_path) or not os.path.exists(husn_path):
        print("Input files not found.")
        return

    try:
        with open(azkar_path, 'r', encoding='utf-8') as f:
            azkar_data = json.load(f)
        
        with open(husn_path, 'r', encoding='utf-8') as f:
            husn_data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        return

    # Create a map of normalized Arabic text to (Translation, CategoryTitle)
    # Also map category title if possible.
    
    # We will map ITEM -> (Translation, CategoryTitle)
    item_map = {}

    for category in data_source:
        cat_title = category.get('TITLE', '')
        for item in category.get('TEXT', []):
            arabic = item.get('ARABIC_TEXT', '')
            translated = item.get('TRANSLATED_TEXT', '')
            if arabic:
                norm_arabic = normalize_text(arabic)
                if norm_arabic:
                    item_map[norm_arabic] = (translated, cat_title)
                    if len(norm_arabic) > 50:
                        item_map[norm_arabic[:50]] = (translated, cat_title)

    # Iterate Azkar data
    translated_count = 0
    total_count = 0

    new_azkar_data = []

    for category in azkar_data:
        new_category = category.copy()
        new_items = []
        
        # Collect potential category titles from items
        potential_titles = {}

        for item in category.get('array', []):
            total_count += 1
            new_item = item.copy()
            arabic_text = item.get('text', '')
            norm_text = normalize_text(arabic_text)
            
            translation = ""
            cat_title_match = ""
            
            if norm_text in item_map:
                translation, cat_title_match = item_map[norm_text]
            elif len(norm_text) > 50 and norm_text[:50] in item_map:
                translation, cat_title_match = item_map[norm_text[:50]]
            
            if translation:
                new_item['translation'] = translation
                translated_count += 1
                if cat_title_match:
                    potential_titles[cat_title_match] = potential_titles.get(cat_title_match, 0) + 1
            else:
                new_item['translation'] = ""
            
            new_item['source'] = "Hisn al-Muslim"
            new_items.append(new_item)
        
        # Determine best category title
        if potential_titles:
            best_title = max(potential_titles, key=potential_titles.get)
            new_category['category'] = best_title # Replace Arabic category with English
        
        new_category['array'] = new_items
        new_azkar_data.append(new_category)

    print(f"Translated {translated_count} out of {total_count} items.")

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(new_azkar_data, f, indent=4, ensure_ascii=False)
    
    print(f"Generated {output_path}")

if __name__ == "__main__":
    generate_localized_azkar()
