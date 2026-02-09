import json
import os

def add_keys():
    l10n_dir = 'lib/l10n'
    if not os.path.exists(l10n_dir):
        print(f"Directory not found: {l10n_dir}")
        return

    new_keys = {
        "hajjAndUmrahGuide": "Hajj & Umrah Guide",
        "zakatTotalAmount": "Total Amount: {amount}",
        "@zakatTotalAmount": {
            "placeholders": {
                "amount": {
                    "type": "Object"
                }
            }
        },
        "zakatDueAmount": "Zakat Due: {amount} (2.5%)",
        "@zakatDueAmount": {
             "placeholders": {
                "amount": {
                    "type": "Object"
                }
            }
        },
        "zakatBelowNisaab": "Likely no Zakat is due as the amount is below Nisaab ({nisaab}). Please consult a scholar.",
        "@zakatBelowNisaab": {
             "placeholders": {
                "nisaab": {
                    "type": "Object"
                }
            }
        },
        "zakatNisaabAlert": "\n\n* Alert: Nisaab check skipped (Gold price missing).",
        "zakatIntroduction": "No significant amount entered."
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

    # Now propagate to all other ARB files (excluding @ keys for simplicity in non-en files if not needed, but flutter gen might need them if they have placeholders)
    # Correct approach: Add keys to all files. For @ keys, we should add them too.
    for filename in os.listdir(l10n_dir):
        if filename.endswith('.arb') and filename != 'app_en.arb':
            file_path = os.path.join(l10n_dir, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                updated = False
                for k, v in new_keys.items():
                    if k not in data:
                         data[k] = v # Use English as fallback
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
