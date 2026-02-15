
import json
import os

def main():
    base_path = 'lib/l10n'
    
    # Keys to ensure exist (with English default)
    keys_to_add = {
        "weatherHeatTitle": "Severe Heat Supplication",
        "weatherHeatBody": "La ilaha illa Allah, how hot is this day! O Allah, protect me from the heat of Hellfire.",
        "weatherColdTitle": "Severe Cold Supplication",
        "weatherColdBody": "La ilaha illa Allah, how cold is this day! O Allah, protect me from the bitter cold of Hellfire."
    }

    # Iterate over all ARB files
    for filename in os.listdir(base_path):
        if filename.endswith('.arb'):
            file_path = os.path.join(base_path, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = json.load(f)
                
                modified = False
                for key, value in keys_to_add.items():
                    if key not in content:
                        print(f"Adding {key} to {filename}")
                        content[key] = value
                        modified = True
                    else:
                        print(f"{key} already exists in {filename}")

                if modified:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(content, f, indent=2, ensure_ascii=False)
                    print(f"Updated {filename}")
                else:
                    print(f"No changes for {filename}")

            except Exception as e:
                print(f"Error processing {filename}: {e}")

if __name__ == "__main__":
    main()
