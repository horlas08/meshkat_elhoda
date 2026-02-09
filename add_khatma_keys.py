
import json
import os

def add_khatma_keys():
    file_path = 'lib/l10n/app_en.arb'
    
    new_keys = {
        "partNumber": "Part {number}",
        "@partNumber": {
            "placeholders": {
                "number": {"type": "Object"}
            }
        },
        "partReservedSuccess": "Part {number} reserved successfully",
        "@partReservedSuccess": {
            "placeholders": {
                "number": {"type": "Object"}
            }
        },
        "partCompletedSuccess": "Part {number} completed successfully",
        "@partCompletedSuccess": {
            "placeholders": {
                "number": {"type": "Object"}
            }
        },
        "createdBy": "Created by {name}",
        "@createdBy": {
            "placeholders": {
                "name": {"type": "Object"}
            }
        },
        "inviteLink": "Invite Link: {link}",
        "@inviteLink": {
            "placeholders": {
                "link": {"type": "Object"}
            }
        }
    }

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated = False
        for k, v in new_keys.items():
            # Force update or add
            data[k] = v
            updated = True
            print(f"Added/Updated {k}")

        # Check reservedForUser to ensure it matches specific placeholder if needed, 
        # but likely we just adapt Dart code to matches "user" placeholder in existing file.
        
        if updated:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.write('\n')
            print("Successfully updated app_en.arb with Khatma keys")
        else:
            print("No new Khtama keys added")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    add_khatma_keys()
