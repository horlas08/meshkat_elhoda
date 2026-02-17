import json
import os

# Base directory for ARB files
ARB_DIR = r"c:\Users\qozeem\Desktop\mobile\meshkat_elhoda\lib\l10n"

# Keys to add
KEYS_TO_ADD = [
    "umrahRituals",
    "hajjRituals",
    "stepsLabel",
    "supplicationsLabel",
    "stageCompletedLabel",
    "athanOverlaySettingTitle",
    "suhoorAlarmTitle",
    "iftarAlarmTitle",
    "adhanTroubleshootFixExactAlarmTitle",
    "adhanTroubleshootFixExactAlarmDesc",
    "share",
    "save",
]

# Translations for all languages
TRANSLATIONS = {
    "ar": {
        "umrahRituals": "مناسك العمرة",
        "hajjRituals": "مناسك الحج",
        "stepsLabel": "الخطوات",
        "supplicationsLabel": "أدعية",
        "stageCompletedLabel": "إتمام المناسك",
        "athanOverlaySettingTitle": "شاشة الأذان (ملء الشاشة)",
        "suhoorAlarmTitle": "تنبيه السحور",
        "iftarAlarmTitle": "تنبيه الإفطار",
        "adhanTroubleshootFixExactAlarmTitle": "السماح بالتنبيهات الدقيقة (المنبهات والتذكيرات)",
        "adhanTroubleshootFixExactAlarmDesc": "فعّل التنبيهات الدقيقة لهذا التطبيق حتى تعمل مواقيت الصلاة وتنبيهات السحور والإفطار في وقتها حتى لو كان التطبيق مغلقاً.",
        "share": "مشاركة",
        "save": "حفظ",
    },
    "en": {
        "umrahRituals": "Umrah Rituals",
        "hajjRituals": "Hajj Rituals",
        "stepsLabel": "Steps",
        "supplicationsLabel": "Supplications",
        "stageCompletedLabel": "Stage Completed",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "fr": {
        "umrahRituals": "Rituels de la Omra",
        "hajjRituals": "Rituels du Hajj",
        "stepsLabel": "Étapes",
        "supplicationsLabel": "Invocations",
        "stageCompletedLabel": "Étape terminée",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "id": {
        "umrahRituals": "Manasik Umrah",
        "hajjRituals": "Manasik Haji",
        "stepsLabel": "Langkah-langkah",
        "supplicationsLabel": "Doa-doa",
        "stageCompletedLabel": "Tahap Selesai",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "ur": {
        "umrahRituals": "عمرہ کے مناسک",
        "hajjRituals": "حج کے مناسک",
        "stepsLabel": "اقدامات",
        "supplicationsLabel": "دعائیں",
        "stageCompletedLabel": "مرحلہ مکمل",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "tr": {
        "umrahRituals": "Umre Ritüelleri",
        "hajjRituals": "Hac Ritüelleri",
        "stepsLabel": "Adımlar",
        "supplicationsLabel": "Dualar",
        "stageCompletedLabel": "Aşama Tamamlandı",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "bn": {
        "umrahRituals": "ওমরাহ পালন",
        "hajjRituals": "হজ্জ পালন",
        "stepsLabel": "ধাপসমূহ",
        "supplicationsLabel": "দোয়াসমূহ",
        "stageCompletedLabel": "ধাপ সম্পন্ন",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "ms": {
        "umrahRituals": "Ibadah Umrah",
        "hajjRituals": "Ibadah Haji",
        "stepsLabel": "Langkah",
        "supplicationsLabel": "Doa-doa",
        "stageCompletedLabel": "Tahap Selesai",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "fa": {
        "umrahRituals": "مناسک عمره",
        "hajjRituals": "مناسک حج",
        "stepsLabel": "مراحل",
        "supplicationsLabel": "ادعیه",
        "stageCompletedLabel": "مرحله تکمیل شد",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "es": {
        "umrahRituals": "Rituales de la Umrah",
        "hajjRituals": "Rituales del Hajj",
        "stepsLabel": "Pasos",
        "supplicationsLabel": "Súplicas",
        "stageCompletedLabel": "Etapa completada",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Share",
        "save": "Save",
    },
    "de": {
        "umrahRituals": "Umrah Rituale",
        "hajjRituals": "Hajj Rituale",
        "stepsLabel": "Schritte",
        "supplicationsLabel": "Bittgebete",
        "stageCompletedLabel": "Stufe abgeschlossen",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "Teilen",
        "save": "Speichern",
    },
    "zh": {
        "umrahRituals": "副朝仪式",
        "hajjRituals": "朝觐仪式",
        "stepsLabel": "步骤",
        "supplicationsLabel": "祈祷",
        "stageCompletedLabel": "阶段完成",
        "athanOverlaySettingTitle": "Adhan full-screen alarm screen",
        "suhoorAlarmTitle": "Suhoor alarm",
        "iftarAlarmTitle": "Iftar alarm",
        "adhanTroubleshootFixExactAlarmTitle": "Allow exact alarms (Alarms & reminders)",
        "adhanTroubleshootFixExactAlarmDesc": "Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.",
        "share": "分享",
        "save": "保存",
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
