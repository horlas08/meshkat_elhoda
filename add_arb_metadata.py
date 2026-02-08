
import json
import os
import re

def add_metadata():
    arb_file = 'lib/l10n/app_en.arb'
    
    # Keys that we know have placeholders and need metadata
    target_keys = [
        'hadithLoadError',
        'languageUpdateError',
        'copyrightNotice',
        'khatmaDuration',
        'partReservedSuccess',
        'partCompletedSuccess',
        'alreadyReservedPart',
        'partNumber',
        'createdBy',
        'reservedForUser',
        'favoriteItemDescription',
        'selectMuezzin',
        'muezzinSelected',
        'playingMuezzinSound'
    ]

    try:
        with open(arb_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        modified = False
        
        for key in target_keys:
            if key in data:
                # Check for placeholders in the value
                value = data[key]
                placeholders = re.findall(r'\{(\w+)\}', value)
                
                if placeholders:
                    meta_key = f"@{key}"
                    if meta_key not in data:
                        print(f"Adding metadata for {key} with placeholders: {placeholders}")
                        
                        placeholder_map = {}
                        for p in placeholders:
                            placeholder_map[p] = {
                                "type": "String",
                                "example": "example" # gen-l10n often likes examples
                            }
                        
                        data[meta_key] = {
                            "description": f"Auto-generated description for {key}",
                            "placeholders": placeholder_map
                        }
                        modified = True
                    else:
                        print(f"Metadata already exists for {key}")
        
        if modified:
            with open(arb_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.write('\n')
            print(f"Updated {arb_file}")
        else:
            print("No changes needed.")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    add_metadata()
