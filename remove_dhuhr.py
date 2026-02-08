
import os

def remove_dhuhr():
    files = [
        'lib/l10n/app_fr.arb',
        'lib/l10n/app_id.arb',
        'lib/l10n/app_ms.arb',
        'lib/l10n/app_tr.arb',
        'lib/l10n/app_ur.arb'
    ]
    
    base_path = 'c:\\Users\\qozeem\\Desktop\\mobile\\meshkat_elhoda'
    
    for rel_path in files:
        file_path = os.path.join(base_path, rel_path)
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            new_lines = [line for line in lines if '"dhuhr":' not in line]
            
            if len(lines) != len(new_lines):
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)
                print(f"Removed dhuhr from {rel_path}")
            else:
                print(f"dhuhr not found in {rel_path} (already removed?)")
                
        except Exception as e:
            print(f"Error processing {rel_path}: {e}")

if __name__ == '__main__':
    remove_dhuhr()
