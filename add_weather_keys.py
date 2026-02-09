import json
import os

def add_keys():
    l10n_dir = 'lib/l10n'
    if not os.path.exists(l10n_dir):
        print(f"Directory not found: {l10n_dir}")
        return

    new_keys = {
        "weatherThunderTitle": "Thunder Supplication",
        "weatherThunderBody": "Glory be to Him whom thunder praises with His praise, and the angels from the fear of Him.",
        "weatherRainTitle": "Rain Supplication",
        "weatherRainBody": "O Allah, (make it) a beneficial downpour.",
        "weatherWindTitle": "Wind Supplication",
        "weatherWindBody": "O Allah, I ask You for the good of it, and the good of what it contains, and the good of what it is sent with. I seek refuge in You from the evil of it, and the evil of what it contains, and the evil of what it is sent with.",
        "weatherHeatTitle": "Severe Heat Supplication",
        "weatherHeatBody": "La ilaha illa Allah, how hot is this day! O Allah, protect me from the heat of Hellfire.",
        "weatherColdTitle": "Severe Cold Supplication",
        "weatherColdBody": "La ilaha illa Allah, how cold is this day! O Allah, protect me from the bitter cold of Hellfire."
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
