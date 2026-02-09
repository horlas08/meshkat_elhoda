
import json
import os

def add_keys():
    file_path = 'lib/l10n/app_en.arb'
    
    new_keys = {
        "directionsApiError": "Error getting directions",
        "quranFeatures": "Holy Quran",
        "hadithFeatures": "Hadiths",
        "azkarFeatures": "Azkar & Duas",
        "allahNamesFeatures": "Names of Allah",
        "khatmaFeatures": "Khatma Tracking",
        "prayerFeatures": "Prayer Times & Qibla",
        "mosqueFeatures": "Nearby Mosques",
        "audioFeatures": "Islamic Audio",
        "broadcastFeatures": "Live Broadcast",
        "assistantFeatures": "Smart Assistant",
        "zakatFeatures": "Zakat Calculator",
        "dateFeatures": "Date Converter",
        "subscriptionFeatures": "Premium Subscription",
        "hijriToGregorianResult": "Gregorian: {gregorianDate}\nHijri: {hijriDate}",
        "@hijriToGregorianResult": {
            "placeholders": {
                "hijriDate": {"type": "String"},
                "gregorianDate": {"type": "String"}
            }
        },
        "ayahsRangeText": "Ayah {start} - {end}",
        "@ayahsRangeText": {
            "placeholders": {
                "start": {"type": "Object"},
                "end": {"type": "Object"}
            }
        },
        "pagesCountText": "{count} Pages",
        "@pagesCountText": {
            "placeholders": {
                "count": {"type": "Object"}
            }
        }
    }

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated = False
        for k, v in new_keys.items():
            if k not in data:
                data[k] = v
                updated = True
                print(f"Added {k}")
        
        if updated:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.write('\n')
            print("Successfully updated app_en.arb")
        else:
            print("No new keys added (all existed)")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    add_keys()
