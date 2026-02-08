
import json
import os
import re

def fix_placeholders():
    l10n_dir = 'lib/l10n'
    files = [f for f in os.listdir(l10n_dir) if f.endswith('.arb')]
    
    replacements = {
        'hadithLoadError': '{error}',
        'languageUpdateError': '{error}',
        'copyrightNotice': '{channel}',
        'khatmaDuration': '{days}',
        'partReservedSuccess': '{part}',
        'partCompletedSuccess': '{part}',
        'alreadyReservedPart': '{part}',
        'partNumber': '{part}',
        'createdBy': '{creator}',
        'reservedForUser': '{user}',
        'favoriteItemDescription': '{item}',
        'selectMuezzin': '{muezzinName}',
        'muezzinSelected': '{muezzinName}',
        'playingMuezzinSound': '{muezzinName}',
    }

    base_path = 'c:\\Users\\qozeem\\Desktop\\mobile\\meshkat_elhoda\\lib\\l10n'

    for filename in files:
        filepath = os.path.join(base_path, filename)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Use regex to replace specific keys' values
            # Pattern: "key": "value containing {0}"
            # We need to be careful not to break JSON structure.
            # But string replacement might be safer if keys are unique enough?
            # Actually, standard string replacement on the line might differ if formatting varies.
            # Using JSON parsing is safer.
            
            data = json.loads(content)
            modified = False
            
            for key, new_placeholder in replacements.items():
                if key in data:
                    val = data[key]
                    if '{0}' in val:
                        data[key] = val.replace('{0}', new_placeholder)
                        modified = True
                        print(f"Fixed {key} in {filename}")
            
            if modified:
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                    # Add newline at end
                    f.write('\n')
                print(f"Saved {filename}")
                
        except Exception as e:
            print(f"Error processing {filename}: {e}")

if __name__ == '__main__':
    fix_placeholders()
