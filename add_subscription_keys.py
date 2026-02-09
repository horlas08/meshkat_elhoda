import json
import os

def add_keys():
    l10n_dir = 'lib/l10n'
    if not os.path.exists(l10n_dir):
        print(f"Directory not found: {l10n_dir}")
        return

    new_keys = {
        "featureRemoveAds": "Remove Ads",
        "featureUnlockReciters": "Unlock All Reciters",
        "featureDownloadContent": "Download Content"
    }

    # First upgrade app_en.arb
    en_path = os.path.join(l10n_dir, 'app_en.arb')
    try:
        with open(en_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated = False
        for k, v in new_keys.items():
            if k not in data:
                data[k] = v
                updated = True
                print(f"Added {k} to app_en.arb")
            else:
                print(f"{k} already exists in app_en.arb")
        
        if updated:
            with open(en_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print("Updated app_en.arb")
    except Exception as e:
        print(f"Error processing app_en.arb: {e}")
        return

    # Now propagate to all other ARB files
    for filename in os.listdir(l10n_dir):
        if filename.endswith('.arb') and filename != 'app_en.arb':
            file_path = os.path.join(l10n_dir, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                updated = False
                for k, v in new_keys.items():
                    if k not in data:
                        data[k] = v # Use English as fallback/default
                        updated = True
                        print(f"Added {k} to {filename}")
                
                if updated:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, indent=2, ensure_ascii=False)
                    print(f"Updated {filename}")
            
            except Exception as e:
                print(f"Error processing {filename}: {e}")

if __name__ == "__main__":
    add_keys()
