import json
import os

# Base directory for ARB files
ARB_DIR = r"c:\Users\qozeem\Desktop\mobile\meshkat_elhoda\lib\l10n"

# Keys to add
KEYS_TO_ADD = ["umrahRituals", "hajjRituals", "stepsLabel", "supplicationsLabel", "stageCompletedLabel"]

# Translations for all languages
TRANSLATIONS = {
    "ar": {
        "umrahRituals": "مناسك العمرة",
        "hajjRituals": "مناسك الحج",
        "stepsLabel": "الخطوات",
        "supplicationsLabel": "أدعية",
        "stageCompletedLabel": "إتمام المناسك"
    },
    "en": {
        "umrahRituals": "Umrah Rituals",
        "hajjRituals": "Hajj Rituals",
        "stepsLabel": "Steps",
        "supplicationsLabel": "Supplications",
        "stageCompletedLabel": "Stage Completed"
    },
    "fr": {
        "umrahRituals": "Rituels de la Omra",
        "hajjRituals": "Rituels du Hajj",
        "stepsLabel": "Étapes",
        "supplicationsLabel": "Invocations",
        "stageCompletedLabel": "Étape terminée"
    },
    "id": {
        "umrahRituals": "Manasik Umrah",
        "hajjRituals": "Manasik Haji",
        "stepsLabel": "Langkah-langkah",
        "supplicationsLabel": "Doa-doa",
        "stageCompletedLabel": "Tahap Selesai"
    },
    "ur": {
        "umrahRituals": "عمرہ کے مناسک",
        "hajjRituals": "حج کے مناسک",
        "stepsLabel": "اقدامات",
        "supplicationsLabel": "دعائیں",
        "stageCompletedLabel": "مرحلہ مکمل"
    },
    "tr": {
        "umrahRituals": "Umre Ritüelleri",
        "hajjRituals": "Hac Ritüelleri",
        "stepsLabel": "Adımlar",
        "supplicationsLabel": "Dualar",
        "stageCompletedLabel": "Aşama Tamamlandı"
    },
    "bn": {
        "umrahRituals": "ওমরাহ পালন",
        "hajjRituals": "হজ্জ পালন",
        "stepsLabel": "ধাপসমূহ",
        "supplicationsLabel": "দোয়াসমূহ",
        "stageCompletedLabel": "ধাপ সম্পন্ন"
    },
    "ms": {
        "umrahRituals": "Ibadah Umrah",
        "hajjRituals": "Ibadah Haji",
        "stepsLabel": "Langkah",
        "supplicationsLabel": "Doa-doa",
        "stageCompletedLabel": "Tahap Selesai"
    },
    "fa": {
        "umrahRituals": "مناسک عمره",
        "hajjRituals": "مناسک حج",
        "stepsLabel": "مراحل",
        "supplicationsLabel": "ادعیه",
        "stageCompletedLabel": "مرحله تکمیل شد"
    },
    "es": {
        "umrahRituals": "Rituales de la Umrah",
        "hajjRituals": "Rituales del Hajj",
        "stepsLabel": "Pasos",
        "supplicationsLabel": "Súplicas",
        "stageCompletedLabel": "Etapa completada"
    },
    "de": {
        "umrahRituals": "Umrah Rituale",
        "hajjRituals": "Hajj Rituale",
        "stepsLabel": "Schritte",
        "supplicationsLabel": "Bittgebete",
        "stageCompletedLabel": "Stufe abgeschlossen"
    },
    "zh": {
        "umrahRituals": "副朝仪式",
        "hajjRituals": "朝觐仪式",
        "stepsLabel": "步骤",
        "supplicationsLabel": "祈祷",
        "stageCompletedLabel": "阶段完成"
    }
}

def update_arb_files():
    # Iterate over all language codes defined in TRANSLATIONS
    for lang_code, translations in TRANSLATIONS.items():
        filename = f"app_{lang_code}.arb"
        file_path = os.path.join(ARB_DIR, filename)
        
        if not os.path.exists(file_path):
            print(f"Warning: File {filename} not found. Skipping.")
            continue
            
        print(f"Updating {filename}...")
        
        try:
            # Force UTF-8 encoding for reading
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Check and add missing keys
            updated = False
            for key, value in translations.items():
                if key not in data or data[key] != value:
                    data[key] = value
                    updated = True
                    try:
                        print(f"  + Added/Updated key: {key}")
                    except:
                        pass
            
            if updated:
                # Write back to file, ensuring utf-8 and indentation
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                print(f"  Successfully saved {filename}.")
            else:
                print(f"  No changes needed for {filename}.")
                
        except Exception as e:
            print(f"  Error processing {filename}: {e}")

if __name__ == "__main__":
    print("Starting ARB update process...")
    update_arb_files()
    print("Process complete.")
