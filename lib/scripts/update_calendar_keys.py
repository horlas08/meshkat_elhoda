
import json
import os

def main():
    base_path = 'lib/l10n'
    files = {
        'fr': 'app_fr.arb', 'id': 'app_id.arb', 'ur': 'app_ur.arb',
        'tr': 'app_tr.arb', 'bn': 'app_bn.arb', 'ms': 'app_ms.arb',
        'fa': 'app_fa.arb', 'es': 'app_es.arb', 'de': 'app_de.arb',
        'zh': 'app_zh.arb'
    }

    translations = {
        'fr': {
            "islamicCalendar": "Calendrier Islamique",
            "hijriCalendar": "Hégirien",
            "gregorianCalendar": "Grégorien",
            "islamicEvents": "Événements Islamiques",
            "eventRamadanStart": "Début du Ramadan",
            "eventLaylatAlQadr": "Laylat al-Qadr",
            "eventEidAlFitr": "Aïd el-Fitr",
            "eventHajj": "Hajj",
            "eventEidAlAdha": "Aïd el-Adha",
            "eventAlHijra": "Nouvel An Islamique",
            "eventAshura": "Achoura",
            "eventMawlidAlNabi": "Mawlid al-Nabi",
            "eventLaylatAlMiraj": "Laylat al-Miraj",
            "eventLaylatAlBaraat": "Laylat al-Baraat"
        },
        'id': {
            "islamicCalendar": "Kalender Islam",
            "hijriCalendar": "Hijriah",
            "gregorianCalendar": "Masehi",
            "islamicEvents": "Acara Islam",
            "eventRamadanStart": "Awal Ramadan",
            "eventLaylatAlQadr": "Lailatul Qadar",
            "eventEidAlFitr": "Idul Fitri",
            "eventHajj": "Haji",
            "eventEidAlAdha": "Idul Adha",
            "eventAlHijra": "Tahun Baru Islam",
            "eventAshura": "Asyura",
            "eventMawlidAlNabi": "Maulid Nabi",
            "eventLaylatAlMiraj": "Isra Mi'raj",
            "eventLaylatAlBaraat": "Nisfu Sya'ban"
        },
        'ur': {
            "islamicCalendar": "اسلامی کیلنڈر",
            "hijriCalendar": "ہجری",
            "gregorianCalendar": "عیسوی",
            "islamicEvents": "اسلامی تہوار",
            "eventRamadanStart": "رمضان کا آغاز",
            "eventLaylatAlQadr": "شب قدر",
            "eventEidAlFitr": "عید الفطر",
            "eventHajj": "حج",
            "eventEidAlAdha": "عید الاضحیٰ",
            "eventAlHijra": "اسلامی نیا سال",
            "eventAshura": "عاشورہ",
            "eventMawlidAlNabi": "عید میلاد النبی",
            "eventLaylatAlMiraj": "شب معراج",
            "eventLaylatAlBaraat": "شب برات"
        },
        'tr': {
            "islamicCalendar": "İslami Takvim",
            "hijriCalendar": "Hicri",
            "gregorianCalendar": "Miladi",
            "islamicEvents": "İslami Günler",
            "eventRamadanStart": "Ramazan Başlangıcı",
            "eventLaylatAlQadr": "Kadir Gecesi",
            "eventEidAlFitr": "Ramazan Bayramı",
            "eventHajj": "Hac",
            "eventEidAlAdha": "Kurban Bayramı",
            "eventAlHijra": "Hicri Yılbaşı",
            "eventAshura": "Aşure Günü",
            "eventMawlidAlNabi": "Mevlid Kandili",
            "eventLaylatAlMiraj": "Miraç Kandili",
            "eventLaylatAlBaraat": "Berat Kandili"
        },
        'bn': {
            "islamicCalendar": "ইসলামি ক্যালেন্ডার",
            "hijriCalendar": "হিজরি",
            "gregorianCalendar": "ইংরেজি",
            "islamicEvents": "ইসলামি দিবস",
            "eventRamadanStart": "রমজান শুরু",
            "eventLaylatAlQadr": "শবে কদর",
            "eventEidAlFitr": "ঈদুল ফিতর",
            "eventHajj": "হজ",
            "eventEidAlAdha": "ঈদুল আজহা",
            "eventAlHijra": "ইসলামি হিজরি নববর্ষ",
            "eventAshura": "আশুরা",
            "eventMawlidAlNabi": "ঈদে মিলাদুন্নবী",
            "eventLaylatAlMiraj": "শবে মেরাজ",
            "eventLaylatAlBaraat": "শবে বরাত"
        },
        'ms': {
            "islamicCalendar": "Kalendar Islam",
            "hijriCalendar": "Hijrah",
            "gregorianCalendar": "Masihi",
            "islamicEvents": "Peristiwa Islam",
            "eventRamadanStart": "Awal Ramadan",
            "eventLaylatAlQadr": "Lailatul Qadar",
            "eventEidAlFitr": "Hari Raya Aidilfitri",
            "eventHajj": "Haji",
            "eventEidAlAdha": "Hari Raya Aidiladha",
            "eventAlHijra": "Awal Muharam",
            "eventAshura": "Asyura",
            "eventMawlidAlNabi": "Maulidur Rasul",
            "eventLaylatAlMiraj": "Israk Mikraj",
            "eventLaylatAlBaraat": "Nisfu Syaaban"
        },
        'fa': {
            "islamicCalendar": "تقویم اسلامی",
            "hijriCalendar": "هجری",
            "gregorianCalendar": "میلادی",
            "islamicEvents": "مناسبت‌های اسلامی",
            "eventRamadanStart": "آغاز رمضان",
            "eventLaylatAlQadr": "شب قدر",
            "eventEidAlFitr": "عید فطر",
            "eventHajj": "حج",
            "eventEidAlAdha": "عید قربان",
            "eventAlHijra": "سال نو هجری",
            "eventAshura": "عاشورا",
            "eventMawlidAlNabi": "میلاد پیامبر",
            "eventLaylatAlMiraj": "شب معراج",
            "eventLaylatAlBaraat": "نیمه شعبان"
        },
        'es': {
            "islamicCalendar": "Calendario Islámico",
            "hijriCalendar": "Hijri",
            "gregorianCalendar": "Gregoriano",
            "islamicEvents": "Eventos Islámicos",
            "eventRamadanStart": "Inicio de Ramadán",
            "eventLaylatAlQadr": "Laylat al-Qadr",
            "eventEidAlFitr": "Eid al-Fitr",
            "eventHajj": "Hajj",
            "eventEidAlAdha": "Eid al-Adha",
            "eventAlHijra": "Año Nuevo Islámico",
            "eventAshura": "Ashura",
            "eventMawlidAlNabi": "Mawlid al-Nabi",
            "eventLaylatAlMiraj": "Laylat al-Miraj",
            "eventLaylatAlBaraat": "Laylat al-Baraat"
        },
        'de': {
            "islamicCalendar": "Islamischer Kalender",
            "hijriCalendar": "Hidschri",
            "gregorianCalendar": "Gregorianisch",
            "islamicEvents": "Islamische Anlässe",
            "eventRamadanStart": "Ramadan Beginn",
            "eventLaylatAlQadr": "Laylat al-Qadr",
            "eventEidAlFitr": "Eid al-Fitr",
            "eventHajj": "Hadsch",
            "eventEidAlAdha": "Eid al-Adha",
            "eventAlHijra": "Islamisches Neujahr",
            "eventAshura": "Aschura",
            "eventMawlidAlNabi": "Maulid an-Nabi",
            "eventLaylatAlMiraj": "Laylat al-Miraj",
            "eventLaylatAlBaraat": "Laylat al-Baraat"
        },
        'zh': {
            "islamicCalendar": "伊斯兰历",
            "hijriCalendar": "回历",
            "gregorianCalendar": "公历",
            "islamicEvents": "伊斯兰节日",
            "eventRamadanStart": "斋月开始",
            "eventLaylatAlQadr": "盖德尔夜",
            "eventEidAlFitr": "开斋节",
            "eventHajj": "朝觐",
            "eventEidAlAdha": "古尔邦节",
            "eventAlHijra": "伊斯兰新年",
            "eventAshura": "阿舒拉节",
            "eventMawlidAlNabi": "圣纪节",
            "eventLaylatAlMiraj": "登霄夜",
            "eventLaylatAlBaraat": "拜拉特夜"
        }
    }

    print("Starting ARB update process for Calendar keys...")

    for lang_code, filename in files.items():
        file_path = os.path.join(base_path, filename)
        if not os.path.exists(file_path):
            print(f"Skipping {filename}: File not found.")
            continue
            
        print(f"Updating {filename}...")
        
        try:
            # Force UTF-8 encoding for reading
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Check and add missing keys
            updated = False
            lang_translations = translations.get(lang_code, {})
            
            for key, value in lang_translations.items():
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

    print("Process complete.")

if __name__ == "__main__":
    main()
