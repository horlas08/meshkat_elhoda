
import json
import os
import glob

def propagate_keys():
    en_path = 'lib/l10n/app_en.arb'
    
    # keys to propagate
    keys_to_add = [
        "partNumber",
        "partReservedSuccess",
        "partCompletedSuccess",
        "createdBy",
        "inviteLink"
    ]
    
    try:
        with open(en_path, 'r', encoding='utf-8') as f:
            en_data = json.load(f)
            
        arb_files = glob.glob('lib/l10n/app_*.arb')
        
        for file_path in arb_files:
            if file_path.endswith('app_en.arb'):
                continue
                
            print(f"Processing {file_path}...")
            
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            updated = False
            for k in keys_to_add:
                # Force update from EN
                if k in en_data:
                    data[k] = en_data[k]
                    updated = True
                
                # Copy metadata if exists in EN
                meta_k = f"@{k}"
                if meta_k in en_data:
                     data[meta_k] = en_data[meta_k]
                     updated = True

            if updated:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                    f.write('\n')
                print(f"Updated {file_path}")
            else:
                print(f"No changes for {file_path}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    propagate_keys()
