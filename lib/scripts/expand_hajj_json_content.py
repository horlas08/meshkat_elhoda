
import json
import os

def main():
    json_path = os.path.join(os.getcwd(), 'assets', 'json', 'hajj_umrah_detailed.json')
    if not os.path.exists(json_path):
        print("Error: File not found")
        return

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    languages = ['fr', 'id', 'ur', 'tr', 'bn', 'ms', 'fa', 'es', 'de', 'zh']
    
    # Dictionary for Title Translations
    # Key: English Title Substring (normalized) -> Value: {lang: translation}
    translations = {
        "ihram": {
            "fr": "Ihram (État de sacralisation)",
            "id": "Ihram",
            "ur": "احرام",
            "tr": "İhram",
            "bn": "ইহরাম",
            "ms": "Ihram",
            "fa": "احرام",
            "es": "Ihram (Estado de sacralización)",
            "de": "Ihram (Weihezustand)",
            "zh": "受戒"
        },
        "tawaf": {
            "fr": "Tawaf (Circumambulation)",
            "id": "Tawaf",
            "ur": "طواف",
            "tr": "Tavaf",
            "bn": "তাওয়াফ",
            "ms": "Tawaf",
            "fa": "طواف",
            "es": "Tawaf (Circunvalación)",
            "de": "Tawaf (Umrundung)",
            "zh": "巡游天房"
        },
        "sa'i": {
            "fr": "Sa'i (Marche entre Safa et Marwah)",
            "id": "Sa'i",
            "ur": "سعی",
            "tr": "Sa'y",
            "bn": "সাঈ",
            "ms": "Sa'i",
            "fa": "سعی",
            "es": "Sa'i (Recorrido entre Safa y Marwah)",
            "de": "Sa'i",
            "zh": "奔走"
        },
        "arafah": {
            "fr": "Jour d'Arafat",
            "id": "Hari Arafah",
            "ur": "یوم عرفہ",
            "tr": "Arefe Günü",
            "bn": "আরাফাতের দিন",
            "ms": "Hari Arafah",
            "fa": "روز عرفه",
            "es": "Día de Arafah",
            "de": "Tag von Arafah",
            "zh": "阿拉法特日"
        },
        "tarwiyah": {
            "fr": "Jour de Tarwiyah",
            "id": "Hari Tarwiyah",
            "ur": "یوم ترویہ",
            "tr": "Terviye Günü",
            "bn": "তারবিয়ার দিন",
            "ms": "Hari Tarwiyah",
            "fa": "روز ترویه",
            "es": "Día de Tarwiyah",
            "de": "Tag der Tarwiyah",
            "zh": "塔尔维亚日"
        },
        "muzdalifah": {
            "fr": "Muzdalifah",
            "id": "Muzdalifah",
            "ur": "مزدلفہ",
            "tr": "Müzdelife",
            "bn": "মুজদালিফা",
            "ms": "Muzdalifah",
            "fa": "مزدلفه",
            "es": "Muzdalifah",
            "de": "Muzdalifah",
            "zh": "穆兹达里法"
        },
        "nahr": {
            "fr": "Jour du Sacrifice (Aïd)",
            "id": "Hari Nahr (Idul Adha)",
            "ur": "یوم النحر",
            "tr": "Nahr Günü (Bayram)",
            "bn": "কোরবানির দিন",
            "ms": "Hari Nahar",
            "fa": "روز نحر",
            "es": "Día del Sacrificio",
            "de": "Tag des Opfers",
            "zh": "宰牲日"
        },
        "tashreeq": {
            "fr": "Jours de Tashreeq",
            "id": "Hari Tasyriq",
            "ur": "ایام تشریق",
            "tr": "Teşrik Günleri",
            "bn": "আইয়ামে তাশরিক",
            "ms": "Hari Tasyrik",
            "fa": "ایام تشریق",
            "es": "Días de Tashreeq",
            "de": "Tage des Taschriq",
            "zh": "晒肉日"
        },
        "farewell": {
            "fr": "Tawaf d'Adieu",
            "id": "Tawaf Wada'",
            "ur": "طواف وداع",
            "tr": "Veda Tavafı",
            "bn": "বিদায়ী তাওয়াফ",
            "ms": "Tawaf Wadak",
            "fa": "طواف وداع",
            "es": "Tawaf de Despedida",
            "de": "Abschiedstawaf",
            "zh": "辞朝"
        },
        "shaving": {
            "fr": "Rasage ou Coupe",
            "id": "Tahallul (Cukur/Potong)",
            "ur": "حلق یا قصر",
            "tr": "Tıraş veya Kısaltma",
            "bn": "মুণ্ডন বা ছাঁটা",
            "ms": "Bercukur atau Bergunting",
            "fa": "حلق یا تقصیر",
            "es": "Afeitado o Recorte",
            "de": "Rasieren oder Kürzen",
            "zh": "剃度或剪发"
        }
    }

    def get_title_translation(en_text, lang):
        en_lower = en_text.lower()
        for key, lang_map in translations.items():
            if key in en_lower:
                return lang_map.get(lang, en_text)
        return en_text

    def process_obj(obj):
        if isinstance(obj, list):
            for item in obj:
                process_obj(item)
        elif isinstance(obj, dict):
            # Process 'title'
            if 'title' in obj and isinstance(obj['title'], dict):
                en_title = obj['title'].get('en', '')
                if en_title:
                    for lang in languages:
                        if lang not in obj['title']:
                            # Try to translate title
                            obj['title'][lang] = get_title_translation(en_title, lang)
            
            # Process 'description', 'steps' (list of dicts), 'tips', 'duas'
            # For these, we fallback to English for now
            fields_to_fill = ['description', 'tips']
            for field in fields_to_fill:
                if field in obj and isinstance(obj[field], dict):
                    en_text = obj[field].get('en', '')
                    if en_text:
                        for lang in languages:
                            if lang not in obj[field]:
                                obj[field][lang] = en_text # Fallback

            # Process 'duas'
            if 'duas' in obj and isinstance(obj['duas'], list):
                process_obj(obj['duas'])

            # Process 'steps' keys (which are languages) inside list of dicts
            # Wait, steps is list of objects? No, steps is list of {ar:..., en:...} in the JSON
            if 'steps' in obj and isinstance(obj['steps'], list):
                for step in obj['steps']:
                    if isinstance(step, dict):
                        en_step = step.get('en', '')
                        if en_step:
                           for lang in languages:
                               if lang not in step:
                                   step[lang] = en_step

            # Process nested Dua translation
            if 'translation' in obj and isinstance(obj['translation'], dict):
                 en_trans = obj['translation'].get('en', '')
                 if en_trans:
                     for lang in languages:
                         if lang not in obj['translation']:
                             obj['translation'][lang] = en_trans

            # Recurse for nested objects
            for k, v in obj.items():
                if k not in ['title', 'description', 'steps', 'tips', 'duas', 'translation']: # Already handled or primitive
                    process_obj(v)

    # Process Hajj and Umrah
    process_obj(data['hajj'])
    process_obj(data['umrah'])

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    
    print("Expansion complete.")

if __name__ == "__main__":
    main()
