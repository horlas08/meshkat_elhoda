
import json
import os

def main():
    json_path = os.path.join(os.getcwd(), 'assets', 'json', 'hajj_umrah_detailed.json')
    if not os.path.exists(json_path):
        print("Error: File not found")
        return

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Full Translation Dictionary
    # Structure: Key (English text snippet or ID) -> { lang: translation }
    
    # helper for safety
    def t(obj, key, lang_dict):
        for lang, text in lang_dict.items():
            if lang not in obj[key]:
                obj[key][lang] = text
            else:
                # Overwrite if it's identical to English (the fallback)
                if obj[key][lang] == obj[key]['en'] and text != obj[key]['en']:
                     obj[key][lang] = text

    # ========================== UMRAH ==========================
    
    # U1: Ihram
    u1 = data['umrah'][0]
    # Description
    u1['description']['fr'] = "L'Ihram est l'intention d'entrer dans le rituel depuis des Miqats spécifiques (ex: Dhul-Hulaifah, Juhfah...)."
    u1['description']['id'] = "Ihram adalah niat untuk memasuki ritual dari Miqat tertentu (mis: Dhul-Hulaifah, Juhfah...)."
    u1['description']['ur'] = "احرام مخصوص میقات (جیسے ذوالحلیفہ، جحفہ...) سے عبادت میں داخل ہونے کی نیت ہے۔"
    u1['description']['tr'] = "İhram, belirli Mikatlardan (örn. Zülhuleyfe, Cuhfe...) ibarate girme niyetidir."
    u1['description']['bn'] = "ইহরাম হলো নির্দিষ্ট মিকাত (যেমন ধুল-হুলাইফাহ, জুহফাহ...) থেকে ইবাদতে প্রবেশের নিয়ত।"
    u1['description']['ms'] = "Ihram adalah niat untuk memasuki ritual dari Miqat tertentu."
    u1['description']['fa'] = "احرام نیت ورود به مناسک از میقات‌های خاص است."
    u1['description']['es'] = "Ihram es la intención de entrar en el ritual desde Miqats específicos."
    u1['description']['de'] = "Ihram ist die Absicht, von bestimmten Miqats aus in das Ritual einzutreten."
    u1['description']['zh'] = "受戒是从特定的戒关（如祖鲁哈莱法、朱赫法等）进入仪式的意图。"

    # Steps
    # 1. Preparation
    u1['steps'][0]['fr'] = "Préparation : Ghusl (bain rituel) et se parfumer le corps (avant l'intention)."
    u1['steps'][0]['id'] = "Persiapan: Mandi (Ghusl) dan memakai wangi-wangian di badan (sebelum niat)."
    u1['steps'][0]['ur'] = "تیاری: غسل (رسمی غسل) اور جسم پر خوشبو لگانا (نیت سے پہلے)۔"
    u1['steps'][0]['tr'] = "Hazırlık: Gusül (boy abdesti) ve vücuda koku sürmek (niyetten önce)."
    u1['steps'][0]['bn'] = "প্রস্তুতি: গোসল (ফরজ গোসল) এবং শরীরে সুগন্ধি লাগানো (নিয়তের আগে)।"
    u1['steps'][0]['ms'] = "Persediaan: Mandi sunat Ihram dan memakai wangi-wangian pada badan."
    u1['steps'][0]['fa'] = "آمادگی: غسل و خوشبو کردن بدن (قبل از نیت)."
    u1['steps'][0]['es'] = "Preparación: Ghusl (baño ritual) y perfumarse el cuerpo (antes de la intención)."
    u1['steps'][0]['de'] = "Vorbereitung: Ghusl (rituelle Waschung) und Parfümieren des Körpers."
    u1['steps'][0]['zh'] = "准备：大净（Ghusl）并在身体上涂抹香水（在举意之前）。"

    # 2. Clothing
    u1['steps'][1]['fr'] = "Hommes : Porter Izar et Rida. Femmes : Tout vêtement couvrant (sans Niqab ni gants)."
    u1['steps'][1]['id'] = "Pria: Memakai Izar dan Rida. Wanita: Pakaian menutup aurat (tanpa Niqab atau sarung tangan)."
    u1['steps'][1]['ur'] = "مرد: ازار اور ردا پہنیں۔ خواتین: کوئی بھی ڈھانپنے والا لباس (نقاب یا دستانے کے بغیر)۔"
    u1['steps'][1]['tr'] = "Erkekler: İzar ve Rida giyer. Kadınlar: Örtünen herhangi bir kıyafet (Peçe veya eldiven yok)."
    u1['steps'][1]['bn'] = "পুরুষ: ইজার ও রিদা পরুন। নারী: যেকোনো শালীন পোশাক (নিকাব বা দস্তানা ছাড়া)।"
    u1['steps'][1]['ms'] = "Lelaki memakai Izar dan Rida. Wanita memakai pakaian menutup aurat."
    u1['steps'][1]['fa'] = "مردان: ازار و ردا بپوشند. زنان: لباس پوشیده (بدون نقاب و دستکش)."
    u1['steps'][1]['es'] = "Hombres: Vestir Izar y Rida. Mujeres: Ropa modesta (sin Niqab ni guantes)."
    u1['steps'][1]['de'] = "Männer: Izar und Rida tragen. Frauen: Bedeckende Kleidung."
    u1['steps'][1]['zh'] = "男士：穿戒衣（Izar和Rida）。女士：穿任何遮盖的衣服（不戴面纱或手套）。"

    # 3. Intention
    u1['steps'][2]['fr'] = "Intention : 'Labbayk Umrah' ou 'Allahumma Labbayk Umrah'."
    u1['steps'][2]['id'] = "Niat: 'Labbayk Umrah' atau 'Allahumma Labbayk Umrah'."
    u1['steps'][2]['ur'] = "نیت: 'لبیک عمرہ' یا 'اللہم لبیک عمرہ'۔"
    u1['steps'][2]['tr'] = "Niyet: 'Lebbeyk Umre' veya 'Allahümme Lebbeyk Umre'."
    u1['steps'][2]['bn'] = "নিয়ত: 'লাব্বাইক ওমরাহ' বা 'আল্লাহুম্মা লাব্বাইক ওমরাহ'।"
    u1['steps'][2]['ms'] = "Niat: 'Labbayk Umrah' atau 'Allahumma Labbayk Umrah'."
    u1['steps'][2]['fa'] = "نیت: «لبیک عمره» یا «اللهم لبیک عمره»."
    u1['steps'][2]['es'] = "Intención: 'Labbayk Umrah' o 'Allahumma Labbayk Umrah'."
    u1['steps'][2]['de'] = "Absicht: 'Labbayk Umrah' oder 'Allahumma Labbayk Umrah'."
    u1['steps'][2]['zh'] = "举意：'Labbayk Umrah' 或 'Allahumma Labbayk Umrah'。"

    # 4. Talbiyah
    u1['steps'][3]['fr'] = "Talbiyah (continuer jusqu'au Tawaf) : 'Labbayk Allahumma Labbayk...'"
    u1['steps'][3]['id'] = "Talbiyah (lanjutkan sampai Tawaf): 'Labbayk Allahumma Labbayk...'"
    u1['steps'][3]['ur'] = "تلبیہ (طواف تک جاری رکھیں): 'لبیک اللہم لبیک...'"
    u1['steps'][3]['tr'] = "Telbiye (Tavafa kadar devam): 'Lebbeyk Allahümme Lebbeyk...'"
    u1['steps'][3]['bn'] = "তালবিয়া (তাওয়াফ শুরু পর্যন্ত): 'লাব্বাইক আল্লাহুম্মা লাব্বাইক...'"
    u1['steps'][3]['ms'] = "Talbiah (berterusan sehingga Tawaf): 'Labbayk Allahumma Labbayk...'"
    u1['steps'][3]['fa'] = "تلبیه (تا شروع طواف ادامه دهید): «لبیک اللهم لبیک...»"
    u1['steps'][3]['es'] = "Talbiyah (continuar hasta Tawaf): 'Labbayk Allahumma Labbayk...'"
    u1['steps'][3]['de'] = "Talbiyah (bis zum Tawaf fortsetzen): 'Labbayk Allahumma Labbayk...'"
    u1['steps'][3]['zh'] = "应召词（Talbiyah，持续到巡游天房）：'Labbayk Allahumma Labbayk...'"

    # Tips
    u1['tips']['fr'] = "Vous pouvez ajouter 'Labbayk Ilahal-Haq'. Vous pouvez aussi faire des invocations."
    u1['tips']['id'] = "Anda boleh menambah 'Labbayk Ilahal-Haq'. Anda juga boleh berdoa bebas."
    u1['tips']['ur'] = "آپ 'لبیک الہ الحق' کا اضافہ کر سکتے ہیں۔ آپ دعا بھی کر سکتے ہیں۔"
    u1['tips']['tr'] = "'Lebbeyk İlahel-Hak' ekleyebilirsiniz. Arada dua da edebilirsiniz."
    u1['tips']['bn'] = "আপনি 'লাব্বাইক ইলাহাল-হক' যোগ করতে পারেন। আপনি দোয়াও করতে পারেন।"
    u1['tips']['ms'] = "Anda boleh menambah 'Labbayk Ilahal-Haq'. Boleh berdoa apa sahaja."
    u1['tips']['fa'] = "میتوانید «لبیک اله الحق» را اضافه کنید. همچنین میتوانید دعا کنید."
    u1['tips']['es'] = "Puedes añadir 'Labbayk Ilahal-Haq'. También puedes hacer Dua."
    u1['tips']['de'] = "Sie können 'Labbayk Ilahal-Haq' hinzufügen. Dua ist auch erlaubt."
    u1['tips']['zh'] = "你可以加上 'Labbayk Ilahal-Haq'。你也可以做通过祈祷。"


    # U2: Entering Masjid
    u2 = data['umrah'][1]
    u2['description']['fr'] = "Entrer dans la Mosquée Sacrée pour effectuer la Omra."
    u2['description']['id'] = "Masuk ke Masjidil Haram untuk melaksanakan Umrah."
    u2['description']['ur'] = "عمرہ ادا کرنے کے لیے مسجد الحرام میں داخل ہونا۔"
    u2['description']['tr'] = "Umre yapmak için Mescid-i Haram'a giriş."
    u2['description']['bn'] = "ওমরাহ পালনের জন্য পবিত্র মসজিদে প্রবেশ।"
    u2['description']['ms'] = "Memasuki Masjidil Haram untuk menunaikan Umrah."
    u2['description']['fa'] = "ورود به مسجد الحرام برای انجام عمره."
    u2['description']['es'] = "Entrar en la Mezquita Sagrada para realizar la Umrah."
    u2['description']['de'] = "Betreten der Heiligen Moschee zur Durchführung der Umrah."
    u2['description']['zh'] = "进入禁寺进行副朝。"

    u2['steps'][0]['fr'] = "Entrez du pied droit."
    u2['steps'][0]['id'] = "Masuk dengan kaki kanan."
    u2['steps'][0]['ur'] = "دائیں پاؤں سے داخل ہوں۔"
    u2['steps'][0]['tr'] = "Sağ ayakla girin."
    u2['steps'][0]['bn'] = "ডান পা দিয়ে প্রবেশ করুন।"
    u2['steps'][0]['ms'] = "Masuk dengan kaki kanan."
    u2['steps'][0]['fa'] = "با پای راست وارد شوید."
    u2['steps'][0]['es'] = "Entra con el pie derecho."
    u2['steps'][0]['de'] = "Treten Sie mit dem rechten Fuß ein."
    u2['steps'][0]['zh'] = "右脚迈入。"

    u2['steps'][1]['fr'] = "Dites : 'Bismillah... O Allah, ouvre-moi les portes de Ta miséricorde'."
    u2['steps'][1]['id'] = "Ucapkan: 'Bismillah... Ya Allah, bukakanlah pintu rahmat-Mu untukku'."
    u2['steps'][1]['ur'] = "کہیں: 'بسم اللہ... اے اللہ میرے لیے اپنی رحمت کے دروازے کھول دے'۔"
    u2['steps'][1]['tr'] = "De ki: 'Bismillah... Allah'ım, bana rahmet kapılarını aç'."
    u2['steps'][1]['bn'] = "বলুন: 'বিসমিল্লাহ... হে আল্লাহ, আমার জন্য তোমার রহমতের দরজা খুলে দাও'।"
    u2['steps'][1]['ms'] = "Baca doa masuk masjid."
    u2['steps'][1]['fa'] = "بگویید: «بسم الله... خدایا درهای رحمتت را به روی من بگشا»."
    u2['steps'][1]['es'] = "Di: 'Bismillah... Oh Allah, ábreme las puertas de Tu misericordia'."
    u2['steps'][1]['de'] = "Sprich: 'Bismillah... O Allah, öffne mir die Tore Deiner Barmherzigkeit'."
    u2['steps'][1]['zh'] = "说：'Bismillah... O Allah, open the gates of Your mercy for me.'" # Leaving dua translations simple

    # U3: Tawaf
    u3 = data['umrah'][2]
    u3['description']['fr'] = "7 tours autour de la Kaaba. La pureté (Wudu) est requise."
    u3['description']['id'] = "7 putaran mengelilingi Ka'bah. Diperlukan kesucian (Wudhu)."
    u3['description']['ur'] = "خانہ کعبہ کے گرد 7 چکر۔ پاکیزگی (وضو) شرط ہے۔"
    u3['description']['tr'] = "Kabe etrafında 7 şavt. Abdest gereklidir."
    u3['description']['bn'] = "কাবার চারপাশে ৭ বার প্রদক্ষিণ। পবিত্রতা (ওজু) আবশ্যক।"
    u3['description']['ms'] = "7 pusingan mengelilingi Kaabah. Wuduk diperlukan."
    u3['description']['fa'] = "۷ دور طواف کعبه. طهارت (وضو) واجب است."
    u3['description']['es'] = "7 vueltas alrededor de la Kaaba. Se requiere pureza (Wudu)."
    u3['description']['de'] = "7 Runden um die Kaaba. Reinheit (Wudu) ist erforderlich."
    u3['description']['zh'] = "绕行天房7圈。必须保持洁净（小净）。"

    u3['steps'][0]['fr'] = "À la Pierre Noire : Touchez-la ou pointez-la et dites 'Bismillah, Allahu Akbar'."
    u3['steps'][0]['id'] = "Di Hajar Aswad: Sentuh atau isyaratkan dan ucapkan 'Bismillah, Allahu Akbar'."
    u3['steps'][0]['ur'] = "حجر اسود پر: اسے چھوئیں یا اشارہ کریں اور 'بسم اللہ، واللہ اکبر' کہیں۔"
    u3['steps'][0]['tr'] = "Hacer-ül Esved'de: Dokunun veya işaret edip 'Bismillah, Allahu Ekber' deyin."
    u3['steps'][0]['bn'] = "হাজরে আসওয়াদে: স্পর্শ করুন বা ইশারা করুন এবং বলুন 'বিসমিল্লাহ, আল্লাহু আকবর'।"
    u3['steps'][0]['ms'] = "Di Hajar Aswad: Sentuh atau isyarat dan ucap 'Bismillah, Allahu Akbar'."
    u3['steps'][0]['fa'] = "مقابل حجرالاسود: لمس کنید یا اشاره کنید و بگویید «بسم الله، والله اکبر»."
    u3['steps'][0]['es'] = "En la Piedra Negra: Tócala o señálala y di 'Bismillah, Allahu Akbar'."
    u3['steps'][0]['de'] = "Am Schwarzen Stein: Berühren oder zeigen und 'Bismillah, Allahu Akbar' sagen."
    u3['steps'][0]['zh'] = "在黑石处：触摸或指向它并说 'Bismillah, Allahu Akbar'。"

    u3['steps'][1]['fr'] = "Entre le Coin Yéménite et la Pierre Noire : 'Rabbana atina fid-dunya hasanah...'"
    u3['steps'][1]['id'] = "Antara Rukun Yamani & Hajar Aswad: 'Rabbana atina fid-dunya hasanah...'"
    u3['steps'][1]['ur'] = "رکن یمانی اور حجر اسود کے درمیان: 'ربنا آتنا فی الدنیا حسنۃ...'"
    u3['steps'][1]['tr'] = "Rükn-ü Yemani ile Hacer-ül Esved arası: 'Rabbena atina fid-dunya hasene...'"
    u3['steps'][1]['bn'] = "রুকনে ইয়ামানি ও হাজরে আসওয়াদের মাঝে: 'রাব্বানা আতিনা ফিদ-দুনিয়া হাসানাহ...'"
    u3['steps'][1]['ms'] = "Antara Rukun Yamani & Hajar Aswad: 'Rabbana atina fid-dunya hasanah...'"
    u3['steps'][1]['fa'] = "بین رکن یمانی و حجرالاسود: «ربنا آتنا فی الدنیا حسنه...»"
    u3['steps'][1]['es'] = "Entre la Esquina Yemení y la Piedra Negra: 'Rabbana atina fid-dunya hasanah...'"
    u3['steps'][1]['de'] = "Zwischen Jemenitischer Ecke & Schwarzem Stein: 'Rabbana atina fid-dunya hasanah...'"
    u3['steps'][1]['zh'] = "在也门角和黑石之间：'Rabbana atina fid-dunya hasanah...'"

    u3['steps'][2]['fr'] = "Pendant le Tawaf : Faites les invocations que vous souhaitez."
    u3['steps'][2]['id'] = "Selama Tawaf: Berdoalah sesuka hati Anda."
    u3['steps'][2]['ur'] = "طواف کے دوران: کوئی بھی دعا مانگیں۔"
    u3['steps'][2]['tr'] = "Tavaf sırasında: Dilediğiniz duayı yapın."
    u3['steps'][2]['bn'] = "তাওয়াফের সময়: যেকোনো দোয়া করুন।"
    u3['steps'][2]['ms'] = "Semasa Tawaf: Berdoalah apa sahaja."
    u3['steps'][2]['fa'] = "در طول طواف: هر دعایی که می‌خواهید بخوانید."
    u3['steps'][2]['es'] = "Durante el Tawaf: Haz cualquier Dua que desees."
    u3['steps'][2]['de'] = "Während des Tawaf: Machen Sie jedes Dua, das Sie wünschen."
    u3['steps'][2]['zh'] = "巡游期间：做任何你想要的祈祷。"

    # U4: Prayer & Zamzam
    u4 = data['umrah'][3]
    u4['description']['fr'] = "Priez 2 Rak'ahs derrière Maqam Ibrahim et buvez de l'eau de Zamzam."
    u4['description']['id'] = "Shalat 2 Rakaat di belakang Maqam Ibrahim dan minum Zamzam."
    u4['description']['ur'] = "مقام ابراہیم کے پیچھے 2 رکعت نماز پڑھیں اور آب زمزم پئیں۔"
    u4['description']['tr'] = "Makam-ı İbrahim arkasında 2 rekat namaz kılın ve Zemzem için."
    u4['description']['bn'] = "মাকামে ইব্রাহিমের পেছনে ২ রাকাত নামাজ পড়ুন এবং জমজম পান করুন।"
    u4['description']['ms'] = "Solat 2 Rakaat di belakang Maqam Ibrahim dan minum Zamzam."
    u4['description']['fa'] = "۲ رکعت نماز پشت مقام ابراهیم بخوانید و آب زمزم بنوشید."
    u4['description']['es'] = "Reza 2 Rak'ahs detrás de Maqam Ibrahim y bebe Zamzam."
    u4['description']['de'] = "Beten Sie 2 Rak'ahs hinter Maqam Ibrahim und trinken Sie Zamzam."
    u4['description']['zh'] = "在易卜拉欣站立处后礼两拜，并喝赞赞水。"

    u4['steps'][0]['fr'] = "Priez 2 Rak'ahs derrière Maqam Ibrahim (Récitez Al-Kafirun puis Al-Ikhlas)."
    u4['steps'][0]['id'] = "Shalat 2 Rakaat di belakang Maqam Ibrahim (Baca Al-Kafirun lalu Al-Ikhlas)."
    u4['steps'][0]['ur'] = "مقام ابراہیم کے پیچھے 2 رکعت پڑھیں (الکافرون اور پھر الاخلاص کی تلاوت کریں)۔"
    u4['steps'][0]['tr'] = "Makam-ı İbrahim arkasında 2 rekat kılın (Kafirun ve İhlas okuyun)."
    u4['steps'][0]['bn'] = "মাকামে ইব্রাহিমের পেছনে ২ রাকাত পড়ুন (সূরা কাফিরুন ও ইখলাস পড়ুন)।"
    u4['steps'][0]['ms'] = "Solat 2 Rakaat sunat Tawaf."
    u4['steps'][0]['fa'] = "۲ رکعت نماز طواف بخوانید (در رکعت اول کافرون و در دوم اخلاص)."
    u4['steps'][0]['es'] = "Reza 2 Rak'ahs detrás de Maqam Ibrahim (Recita Al-Kafirun luego Al-Ikhlas)."
    u4['steps'][0]['de'] = "Beten Sie 2 Rak'ahs (Rezitation Al-Kafirun, dann Al-Ikhlas)."
    u4['steps'][0]['zh'] = "在易卜拉欣站立处后礼两拜（念《不信道者章》和《忠诚章》）。"

    u4['steps'][1]['fr'] = "Buvez Zamzam et dites : 'O Allah, je te demande une science utile...'"
    u4['steps'][1]['id'] = "Minum Zamzam dan berdoa minta ilmu bermanfaat, rezeki luas, dan kesembuhan."
    u4['steps'][1]['ur'] = "زمزم پئیں اور دعا کریں: 'اے اللہ میں تجھ سے نفع بخش علم مانگتا ہوں...'"
    u4['steps'][1]['tr'] = "Zemzem için ve dua edin: 'Allah'ım, senden faydalı ilim istiyorum...'"
    u4['steps'][1]['bn'] = "জমজম পান করুন এবং বলুন: 'হে আল্লাহ, আমি তোমার কাছে উপকারী জ্ঞান চাই...'"
    u4['steps'][1]['ms'] = "Minum air Zamzam dan berdoa."
    u4['steps'][1]['fa'] = "آب زمزم بنوشید و بگویید: «خدایا از تو علم نافع میخواهم...»"
    u4['steps'][1]['es'] = "Bebe Zamzam y di: 'Oh Allah, te pido conocimiento beneficioso...'"
    u4['steps'][1]['de'] = "Trinken Sie Zamzam und bitten Sie um nützliches Wissen."
    u4['steps'][1]['zh'] = "喝赞赞水并祈祷：'O Allah, I ask You for beneficial knowledge...'"

    # U5: Sai
    u5 = data['umrah'][4]
    u5['description']['fr'] = "7 trajets commençant par Safa."
    u5['description']['id'] = "7 perjalanan dimulai dari Safa."
    u5['description']['ur'] = "صفا سے شروع ہونے والے 7 چکر۔"
    u5['description']['tr'] = "Safa'dan başlayan 7 şavt."
    u5['description']['bn'] = "সাফা থেকে শুরু করে ৭ চক্কর।"
    u5['description']['ms'] = "7 pusingan bermula dari Safa."
    u5['description']['fa'] = "۷ شوط که از صفا شروع می‌شود."
    u5['description']['es'] = "7 recorridos comenzando desde Safa."
    u5['description']['de'] = "7 Strecken beginnend bei Safa."
    u5['description']['zh'] = "从萨法开始奔走7次。"

    u5['steps'][2]['fr'] = "Marchez vers Marwah (Les hommes courent entre les feux verts)."
    u5['steps'][2]['id'] = "Jalan ke Marwah (Pria berlari kecil di antara lampu hijau)."
    u5['steps'][2]['ur'] = "مروہ کی طرف چلیں (مرد سبز روشنیوں کے درمیان دوڑیں)۔"
    u5['steps'][2]['tr'] = "Merve'ye yürüyün (Erkekler yeşil ışıklar arasında koşar)."
    u5['steps'][2]['bn'] = "মারওয়ায় দিকে হাঁটুন (পুরুষরা সবুজ বাতির মাঝে দৌড়াবে)।"
    u5['steps'][2]['ms'] = "Berjalan ke Marwah (Lelaki berlari-lari anak di antara lampu hijau)."
    u5['steps'][2]['fa'] = "به سمت مروه بروید (مردان بین چراغ‌های سبز هروله کنند)."
    u5['steps'][2]['es'] = "Camina hacia Marwah (Hombres corren entre luces verdes)."
    u5['steps'][2]['de'] = "Gehen Sie zu Marwah (Männer laufen zwischen grünen Lichtern)."
    u5['steps'][2]['zh'] = "走向Marwah（男士在绿灯之间慢跑）。"

    # U6: Shaving
    u6 = data['umrah'][5]
    u6['description']['fr'] = "Ceci conclut la Omra."
    u6['description']['id'] = "Ini mengakhiri Umrah."
    u6['description']['ur'] = "یہ عمرہ مکمل کرتا ہے۔"
    u6['description']['tr'] = "Bu, Umre'yi tamamlar."
    u6['description']['bn'] = "এটি ওমরাহ শেষ করে।"
    u6['description']['ms'] = "Ini menyempurnakan Umrah."
    u6['description']['fa'] = "این عمره را به پایان می‌رساند."
    u6['description']['es'] = "Esto concluye la Umrah."
    u6['description']['de'] = "Dies schließt die Umrah ab."
    u6['description']['zh'] = "副朝结束。"

    u6['steps'][0]['fr'] = "Hommes : Le rasage est préférable. Femmes : Couper une longueur de bout de doigt."
    u6['steps'][0]['id'] = "Pria: Mencukur lebih baik. Wanita: Potong sepanjang ujung jari."
    u6['steps'][0]['ur'] = "مرد: منڈوانا بہتر ہے۔ خواتین: انگلی کے پور کے برابر بال کاٹیں۔"
    u6['steps'][0]['tr'] = "Erkekler: Tıraş daha iyidir. Kadınlar: Parmak ucu kadar kesin."
    u6['steps'][0]['bn'] = "পুরুষ: মুণ্ডন করা উত্তম। নারী: আঙ্গুলের ডগা পরিমাণ কাটুন।"
    u6['steps'][0]['ms'] = "Lelaki: Bercukur lebih afdal. Wanita: Bergunting sedikit rambut."
    u6['steps'][0]['fa'] = "مردان: تراشیدن بهتر است. زنان: مقداری از نوک مو را کوتاه کنند."
    u6['steps'][0]['es'] = "Hombres: Afeitarse es mejor. Mujeres: Recortar la longitud de la punta del dedo."
    u6['steps'][0]['de'] = "Männer: Rasieren ist besser. Frauen: Eine Fingerspitze Länge kürzen."
    u6['steps'][0]['zh'] = "男士：剃光更好。女士：剪去指尖长度的头发。"

    # U7: Prohibitions
    u7 = data['umrah'][6]
    u7['description']['fr'] = "Choses interdites en état d'Ihram."
    u7['description']['id'] = "Hal-hal yang dilarang saat Ihram."
    u7['description']['ur'] = "احرام کی حالت میں ممنوع کام۔"
    u7['description']['tr'] = "İhramdayken yasak olan şeyler."
    u7['description']['bn'] = "ইহরাম অবস্থায় নিষিদ্ধ কাজসমূহ।"
    u7['description']['ms'] = "Perkara yang dilarang semasa Ihram."
    u7['description']['fa'] = "محرمات احرام."
    u7['description']['es'] = "Cosas prohibidas mientras se está en Ihram."
    u7['description']['de'] = "Dinge, die im Ihram verboten sind."
    u7['description']['zh'] = "受戒期间禁止的事项。"

    steps7 = u7['steps']
    # 1. Hair/Nails
    steps7[0]['fr'] = "Enlever les poils/cheveux et couper les ongles."
    steps7[0]['id'] = "Mencabut rambut/bulu dan memotong kuku."
    steps7[0]['ur'] = "بال ہٹانا اور ناخن کاٹنا۔"
    steps7[0]['tr'] = "Kıl koparmak ve tırnak kesmek."
    steps7[0]['bn'] = "চুল/লোম উপড়ানো এবং নখ কাটা।"
    steps7[0]['fa'] = "کندن مو و گرفتن ناخن."
    
    # 2. Perfume
    steps7[1]['fr'] = "Utiliser du parfum."
    steps7[1]['id'] = "Memakai wangi-wangian."
    steps7[1]['ur'] = "خوشبو استعمال کرنا۔"
    steps7[1]['tr'] = "Koku sürünmek."
    steps7[1]['fa'] = "استفاده از بوی خوش."

    # 3. Intimacy
    steps7[2]['fr'] = "Intimité, préliminaires et contrats de mariage."
    steps7[2]['id'] = "Hubungan suami istri, bermesraan, akad nikah."
    steps7[2]['ur'] = "ہمبستری، بوس و کنار اور نکاح کا معاہدہ۔"
    steps7[2]['tr'] = "Cinsel ilişki ve evlilik akdi."
    steps7[2]['fa'] = "جماع و عقد نکاح."

    # 4. Hunting
    steps7[3]['fr'] = "Chasser les animaux terrestres."
    steps7[3]['id'] = "Berburu hewan darat."
    steps7[3]['ur'] = "خشکی کے جانوروں کا شکار۔"
    steps7[3]['tr'] = "Kara hayvanlarını avlamak."
    steps7[3]['fa'] = "شکار حیوانات صحرایی."
    
    # 5. Men
    steps7[4]['fr'] = "Hommes : Porter des vêtements cousus et se couvrir la tête."
    steps7[4]['id'] = "Pria: Memakai pakaian berjahit dan menutup kepala."
    steps7[4]['ur'] = "مرد: سلا ہوا لباس پہننا اور سر ڈھانپنا۔"
    steps7[4]['tr'] = "Erkekler: Dikişli elbise giymek ve başı örtmek."
    steps7[4]['fa'] = "مردان: پوشیدن لباس دوخته و پوشاندن سر."

    # 6. Women
    steps7[5]['fr'] = "Femmes : Porter le Niqab et des gants."
    steps7[5]['id'] = "Wanita: Memakai Niqab dan sarung tangan."
    steps7[5]['ur'] = "خواتین: نقاب اور دستانے پہننا۔"
    steps7[5]['tr'] = "Kadınlar: Peçe ve eldiven takmak."
    steps7[5]['fa'] = "زنان: پوشیدن نقاب و دستکش."

    # Tips
    u7['tips']['fr'] = "Celui qui commet un interdit par oubli ne porte aucun péché."
    u7['tips']['id'] = "Siapa yang melanggar karena lupa tidak berdosa."
    u7['tips']['ur'] = "جو بھول کر کوئی ممانع فعل کرے اس پر کوئی گناہ نہیں۔"
    u7['tips']['tr'] = "Unutarak yasak işleyen kimseye günah yoktur."
    u7['tips']['fa'] = "کسی که از روی فراموشی مرتکب ممنوعیت شود گناهی ندارد."


    # ========================== HAJJ ==========================
    
    # H_Intro
    h_intro = data['hajj'][0]
    h_intro['description']['fr'] = "Le Hajj est la visite de la Mosquée Sacrée pour accomplir des rituels spécifiques."
    h_intro['description']['id'] = "Haji adalah mengunjungi Masjidil Haram untuk melakukan ritual tertentu."
    h_intro['description']['ur'] = "حج مخصوص مہینوں میں مخصوص مناسک ادا کرنے کے لیے مسجد حرام کی زیارت ہے۔"
    h_intro['description']['tr'] = "Hac, Hac aylarında belirli ibadetleri yapmak için Kabe'yi ziyarettir."
    h_intro['description']['fa'] = "حج زیارت مسجد الحرام برای انجام مناسک خاص در ماه های حج است."

    h_intro['steps'][0]['fr'] = "1. Tamattu' : Omra, sortie d'Ihram, puis Hajj (Sacrifice requis). Le meilleur."
    h_intro['steps'][0]['id'] = "1. Tamattu': Umrah, Tahallul, lalu Haji (Wajib Dam). Terbaik."
    h_intro['steps'][0]['ur'] = "1. تمتع: حج کے مہینوں میں عمرہ، احرام کھولنا، پھر حج (قربانی واجب)۔ بہترین قسم۔"
    h_intro['steps'][0]['tr'] = "1. Temettu: Hac aylarında Umre, İhramdan çıkış, sonra Hac (Kurban gerekir). En eftali."

    h_intro['steps'][1]['fr'] = "2. Qiran : Omra & Hajj combinés, sans pause (Sacrifice requis)."
    h_intro['steps'][1]['id'] = "2. Qiran: Umrah & Haji digabung tanpa Tahallul (Wajib Dam)."
    h_intro['steps'][1]['ur'] = "2. قران: عمرہ اور حج اکٹھے، درمیان میں وقفہ نہیں (قربانی واجب)۔"

    h_intro['steps'][2]['fr'] = "3. Ifrad : Hajj seulement (Pas de sacrifice)."
    h_intro['steps'][2]['id'] = "3. Ifrad: Haji saja (Tidak wajib Dam)."
    h_intro['steps'][2]['ur'] = "3. افراد: صرف حج (کوئی قربانی نہیں)۔"

    # H1: Ihram
    h1 = data['hajj'][1]
    h1['description']['fr'] = "Jour de Tarwiyah pour les pèlerins Tamattu' et ceux à La Mecque."
    h1['description']['id'] = "Hari Tarwiyah bagi jemaah Tamattu' dan yang berada di Makkah."
    h1['description']['ur'] = "متمتع زائرین اور مکہ میں موجود لوگوں کے لیے یوم ترویہ۔"
    h1['description']['tr'] = "Temettu hacıları ve Mekke'dekiler için Terviye Günü."
    h1['description']['fa'] = "روز ترویه برای حجاج تمتع و کسانی که در مکه هستند."

    h1['steps'][0]['fr'] = "Ghusl, parfum, porter l'Ihram."
    h1['steps'][0]['id'] = "Mandi, wangi-wangian, pakai Ihram."
    h1['steps'][0]['ur'] = "غسل، خوشبو، احرام پہننا۔"
    h1['steps'][0]['tr'] = "Gusül, koku sürünmek, İhram giymek."
    h1['steps'][0]['fa'] = "غسل، خوشبو، پوشیدن احرام."

    h1['steps'][1]['fr'] = "Intention : 'Labbayk Hajjan'."
    h1['steps'][1]['id'] = "Niat: 'Labbayk Hajjan'."
    h1['steps'][1]['ur'] = "نیت: 'لبیک حجا'۔"
    h1['steps'][1]['tr'] = "Niyet: 'Lebbeyk Haccen'."
    h1['steps'][1]['fa'] = "نیت: «لبیک حجا»."

    h1['steps'][2]['fr'] = "Talbiyah : 'Labbayk Allahumma Labbayk...'."
    h1['steps'][2]['id'] = "Talbiyah: 'Labbayk Allahumma Labbayk...'."
    h1['steps'][2]['ur'] = "تلبیہ: 'لبیک اللہم لبیک...'۔"
    h1['steps'][2]['tr'] = "Telbiye: 'Lebbeyk Allahümme Lebbeyk...'."
    h1['steps'][2]['fa'] = "تلبیه: «لبیک اللهم لبیک...»."

    # H2: Tarwiyah
    h2 = data['hajj'][2]
    h2['description']['fr'] = "Se diriger vers Mina."
    h2['description']['id'] = "Menuju ke Mina."
    h2['description']['ur'] = "منیٰ کی طرف روانگی۔"
    h2['description']['tr'] = "Mina'ya gidiş."
    h2['description']['fa'] = "رفتن به منا."

    h2['steps'][0]['fr'] = "Aller à Mina. Prier Dhuhr, Asr, Maghrib, Isha, Fajr (Raccourcis)."
    h2['steps'][0]['id'] = "Pergi ke Mina. Shalat Dzuhur, Ashar, Maghrib, Isya, Subuh (Diqashar)."
    h2['steps'][0]['ur'] = "منیٰ جائیں۔ ظہر، عصر، مغرب، عشاء، فجر کی نمازیں پڑھیں (قصر)۔"
    h2['steps'][0]['tr'] = "Mina'ya gidin. Öğle, İkindi, Akşam, Yatsı, Sabah namazlarını kılın (Kısaltarak)."
    h2['steps'][0]['fa'] = "به منا بروید. نمازهای ظهر، عصر، مغرب، عشاء و صبح را بخوانید (شکسته)."

    h2['steps'][1]['fr'] = "Augmenter le Dhikr, la Talbiyah et les invocations."
    h2['steps'][1]['id'] = "Perbanyak Dzikir, Talbiyah, dan Doa."
    h2['steps'][1]['ur'] = "ذکر، تلبیہ اور دعا کی کثرت کریں۔"
    h2['steps'][1]['tr'] = "Zikri, Telbiyeyi ve Duayı artırın."
    h2['steps'][1]['fa'] = "ذکر، تلبیه و دعا را زیاد کنید."

    # H3: Arafah
    h3 = data['hajj'][3]
    h3['description']['fr'] = "Le plus grand pilier du Hajj."
    h3['description']['id'] = "Rukun Haji terbesar."
    h3['description']['ur'] = "حج کا سب سے بڑا رکن۔"
    h3['description']['tr'] = "Haccın en büyük rüknü."
    h3['description']['fa'] = "بزرگترین رکن حج."

    h3['steps'][0]['fr'] = "Aller à Arafat après le lever du soleil."
    h3['steps'][0]['id'] = "Pergi ke Arafah setelah matahari terbit."
    h3['steps'][0]['ur'] = "سورج طلوع ہونے کے بعد عرفات جائیں۔"
    h3['steps'][0]['tr'] = "Güneş doğduktan sonra Arafat'a gidin."
    h3['steps'][0]['fa'] = "بعد از طلوع خورشید به عرفات بروید."

    h3['steps'][1]['fr'] = "Combiner Dhuhr et Asr."
    h3['steps'][1]['id'] = "Jamak Dzuhur dan Ashar."
    h3['steps'][1]['ur'] = "ظہر اور عصر کو جمع کریں۔"
    h3['steps'][1]['tr'] = "Öğle ve İkindi namazlarını cem edin."
    h3['steps'][1]['fa'] = "نماز ظهر و عصر را جمع کنید."

    h3['steps'][2]['fr'] = "Consacrer du temps aux invocations jusqu'au coucher du soleil."
    h3['steps'][2]['id'] = "Fokus berdoa sampai matahari terbenam."
    h3['steps'][2]['ur'] = "غروب آفتاب تک دعا میں مشغول رہیں۔"
    h3['steps'][2]['tr'] = "Güneş batana kadar duaya zaman ayırın."
    h3['steps'][2]['fa'] = "تا غروب خورشید وقت خود را صرف دعا کنید."

    h3['tips']['fr'] = "La meilleure Doua est celle du jour d'Arafat."
    h3['tips']['id'] = "Doa terbaik adalah doa hari Arafah."
    h3['tips']['ur'] = "بہترین دعا یوم عرفہ کی دعا ہے۔"
    h3['tips']['tr'] = "En hayırlı dua Arefe günü yapılan duadır."
    h3['tips']['fa'] = "بهترین دعا، دعای روز عرفه است."

    # H4: Muzdalifah
    h4 = data['hajj'][4]
    h4['description']['fr'] = "Nuit à Muzdalifah."
    h4['description']['id'] = "Mabit di Muzdalifah."
    h4['description']['ur'] = "مزدلفہ میں رات گزارنا۔"
    h4['description']['tr'] = "Müzdelife'de geceleme."
    h4['description']['fa'] = "شب ماندن در مزدلفه."

    h4['steps'][0]['fr'] = "Après le coucher du soleil, aller à Muzdalifah. Prier Maghrib & Isha."
    h4['steps'][0]['id'] = "Setelah matahari terbenam, ke Muzdalifah. Shalat Maghrib & Isya."
    h4['steps'][0]['ur'] = "سورج غروب ہونے کے بعد مزدلفہ جائیں۔ مغرب اور عشاء پڑھیں۔"
    h4['steps'][0]['tr'] = "Güneş battıktan sonra Müzdelife'ye gidin. Akşam ve Yatsı'yı kılın."
    h4['steps'][0]['fa'] = "بعد از غروب به مزدلفه بروید. نماز مغرب و عشاء را بخوانید."

    h4['steps'][1]['fr'] = "Dormir là-bas. Faire des invocations à Mash'ar Al-Haram après le Fajr."
    h4['steps'][1]['id'] = "Tidur di sana. Berdoa di Masy'aril Haram setelah Subuh."
    h4['steps'][1]['ur'] = "وہاں سوئیں۔ فجر کے بعد مشعر الحرام کے پاس دعا کریں۔"
    h4['steps'][1]['tr'] = "Orada uyuyun. Sabah namazından sonra Meş'ar-i Haram'da dua edin."
    h4['steps'][1]['fa'] = "آنجا بخوابید. بعد از فجر در مشعرالحرام دعا کنید."

    h4['steps'][2]['fr'] = "Ramasser des cailloux (7 pour Aqabah)."
    h4['steps'][2]['id'] = "Kumpulkan kerikil (7 untuk Aqabah)."
    h4['steps'][2]['ur'] = "کنکریاں جمع کریں (عقبہ کے لیے 7)۔"
    h4['steps'][2]['tr'] = "Taş toplayın (Akabe için 7 tane)."
    h4['steps'][2]['fa'] = "سنگریزه جمع کنید (۷ تا برای عقبه)."

    # H5: Nahr
    h5 = data['hajj'][5]
    h5['description']['fr'] = "Rituels du jour de l'Aïd."
    h5['description']['id'] = "Ritual Hari Idul Adha."
    h5['description']['ur'] = "عید کے دن کے مناسک۔"
    h5['description']['tr'] = "Bayram Günü Ritüelleri."
    h5['description']['fa'] = "مناسک روز عید."

    h5['steps'][0]['fr'] = "1. Lapider Jamrat Al-Aqabah (7 cailloux, dire Allahu Akbar)."
    h5['steps'][0]['id'] = "1. Lempar Jumrah Aqabah (7 kerikil, baca Allahu Akbar)."
    h5['steps'][0]['ur'] = "1. جمرہ عقبہ کو کنکریاں مارنا (7 کنکریاں، اللہ اکبر کہیں)۔"
    h5['steps'][0]['tr'] = "1. Akabe Cemresini taşlayın (7 taş, Allahu Ekber diyerek)."
    h5['steps'][0]['fa'] = "۱. رمی جمره عقبه (۷ سنگریزه، بگویید الله اکبر)."

    h5['steps'][1]['fr'] = "2. Sacrifice (pour Tamattu' & Qiran)."
    h5['steps'][1]['id'] = "2. Menyembelih Dam (untuk Tamattu' & Qiran)."
    h5['steps'][1]['ur'] = "2. قربانی (تمتع اور قران کے لیے)۔"
    h5['steps'][1]['tr'] = "2. Kurban (Temettu ve Kıran için)."
    h5['steps'][1]['fa'] = "۲. قربانی (برای تمتع و قران)."

    h5['steps'][2]['fr'] = "3. Rasage ou Coupe (Le rasage est meilleur)."
    h5['steps'][2]['id'] = "3. Cukur atau Potong (Cukur lebih baik)."
    h5['steps'][2]['ur'] = "3. حلق یا قصر (حلق بہتر ہے)۔"
    h5['steps'][2]['tr'] = "3. Tıraş veya Kısaltma (Tıraş daha iyidir)."
    h5['steps'][2]['fa'] = "۳. حلق یا تقصیر (حلق بهتر است)."

    h5['steps'][3]['fr'] = "4. Tawaf Al-Ifidah & Sa'i (pour Tamattu')."
    h5['steps'][3]['id'] = "4. Tawaf Ifadah & Sa'i (untuk Tamattu')."
    h5['steps'][3]['ur'] = "4. طواف افادہ اور سعی (تمتع کے لیے)۔"
    h5['steps'][3]['tr'] = "4. İfada Tavafı ve Sa'y (Temettu için)."
    h5['steps'][3]['fa'] = "۴. طواف افاضه و سعی (برای تمتع)."

    # H6: Tashreeq
    h6 = data['hajj'][6]
    h6['description']['fr'] = "Rester à Mina & Lapider les Jamarat."
    h6['description']['id'] = "Mabit di Mina & Lempar Jumrah."
    h6['description']['ur'] = "منیٰ میں قیام اور جمرات کو کنکریاں مارنا۔"
    h6['description']['tr'] = "Mina'da Kalış ve Şeytan Taşlama."
    h6['description']['fa'] = "ماندن در منا و رمی جمرات."

    h6['steps'][0]['fr'] = "Rester à Mina."
    h6['steps'][0]['id'] = "Mabit di Mina."
    h6['steps'][0]['ur'] = "منیٰ میں قیام۔"
    h6['steps'][0]['tr'] = "Mina'da kalın."
    h6['steps'][0]['fa'] = "در منا بمانید."

    h6['steps'][1]['fr'] = "Lapider les 3 Jamarat chaque jour (Petit, Moyen, Grand)."
    h6['steps'][1]['id'] = "Lempar 3 Jumrah setiap hari (Kecil, Sedang, Besar)."
    h6['steps'][1]['ur'] = "ہر روز تینوں جمرات کو کنکریاں مارنا (چھوٹا، درمیانہ، بڑا)۔"
    h6['steps'][1]['tr'] = "Her gün 3 Cemreyi taşlayın (Küçük, Orta, Büyük)."
    h6['steps'][1]['fa'] = "هر روز سه جمره را رمی کنید (کوچک، متوسط، بزرگ)."

    h6['steps'][2]['fr'] = "Doua après le Petit et le Moyen seulement."
    h6['steps'][2]['id'] = "Berdoa setelah Jumrah Kecil & Sedang saja."
    h6['steps'][2]['ur'] = "صرف چھوٹے اور درمیانے کے بعد دعا۔"
    h6['steps'][2]['tr'] = "Sadece Küçük ve Orta'dan sonra dua edin."
    h6['steps'][2]['fa'] = "فقط بعد از جمره کوچک و متوسط دعا کنید."

    h6['steps'][3]['fr'] = "Permis de partir tôt le 12ème jour."
    h6['steps'][3]['id'] = "Boleh Nafar Awal pada tanggal 12."
    h6['steps'][3]['ur'] = "12 تاریخ کو جلدی نکلنا جائز ہے۔"
    h6['steps'][3]['tr'] = "Ayın 12'sinde erken ayrılmak caizdir."
    h6['steps'][3]['fa'] = "خروج زود هنگام در روز دوازدهم جایز است."

    # H7: Farewell
    h7 = data['hajj'][7]
    h7['description']['fr'] = "Rituel final."
    h7['description']['id'] = "Ritual terakhir."
    h7['description']['ur'] = "آخری رسم۔"
    h7['description']['tr'] = "Son ritüel."
    h7['description']['fa'] = "آخرین مناسک."

    h7['steps'][0]['fr'] = "Effectuer 7 tours de Tawaf avant de partir."
    h7['steps'][0]['id'] = "Lakukan 7 putaran Tawaf sebelum pergi."
    h7['steps'][0]['ur'] = "روانہ ہونے سے پہلے طواف کے 7 چکر لگائیں۔"
    h7['steps'][0]['tr'] = "Ayrılmadan önce 7 şavt Tavaf yapın."
    h7['steps'][0]['fa'] = "قبل از رفتن ۷ دور طواف کنید."

    h7['steps'][1]['fr'] = "Dispensé pour les femmes menstruées."
    h7['steps'][1]['id'] = "Gugur bagi wanita haid."
    h7['steps'][1]['ur'] = "حائضہ خواتین کے لیے معاف ہے۔"
    h7['steps'][1]['tr'] = "Adetli kadınlar için muaftır."
    h7['steps'][1]['fa'] = "برای زنان حائض ساقط است."
    
    # H8: Summary
    h8 = data['hajj'][8]
    h8['description']['fr'] = "Piliers (Arkan) et Devoirs (Wajib) du Hajj."
    h8['description']['id'] = "Rukun dan Wajib Haji."
    h8['description']['ur'] = "حج کے ارکان اور واجبات۔"
    h8['description']['tr'] = "Haccın Rükünleri ve Vacipleri."
    h8['description']['fa'] = "ارکان و واجبات حج."

    h8['steps'][0]['fr'] = "Piliers : Ihram, Station à Arafat, Tawaf Al-Ifadah, Sa'i."
    h8['steps'][0]['id'] = "Rukun: Ihram, Wukuf di Arafah, Tawaf Ifadah, Sa'i."
    h8['steps'][0]['ur'] = "ارکان: احرام، وقوف عرفہ، طواف افادہ، سعی۔"
    h8['steps'][0]['tr'] = "Rükünler: İhram, Arafat Vakfesi, İfada Tavafı, Sa'y."
    h8['steps'][0]['fa'] = "ارکان: احرام، وقوف در عرفات، طواف افاضه، سعی."

    h8['steps'][1]['fr'] = "Devoirs : Ihram du Miqat, Nuit à Muzdalifah/Mina, Lapidation, Rasage/Coupe, Tawaf d'Adieu."
    h8['steps'][1]['id'] = "Wajib: Ihram dari Miqat, Mabit di Muzdalifah/Mina, Lempar Jumrah, Cukur/Potong, Tawaf Wada'."
    h8['steps'][1]['ur'] = "واجبات: میقات سے احرام، مزدلفہ/منیٰ میں رات، رمی، حلق/قصر، طواف وداع۔"
    h8['steps'][1]['tr'] = "Vatipler: Mikattan İhram, Müzdelife/Mina'da geceleme, Taşlama, Tıraş, Veda Tavafı."
    h8['steps'][1]['fa'] = "واجبات: احرام از میقات، بیتوته در مزدلفه/منا، رمی، حلق/تقصیر، طواف وداع."

    h1['description']['bn'] = "তামাত্তু হাজীদের এবং মক্কায় অবস্থানকারীদের জন্য তারবিয়ার দিন।"
    h1['description']['ms'] = "Hari Tarwiyah bagi jemaah Tamattu' dan mereka yang berada di Makkah."
    h1['description']['es'] = "Día de Tarwiyah para los peregrinos de Tamattu' y los que están en La Meca."
    h1['description']['de'] = "Tag von Tarwiyah für Tamattu'-Pilger und diejenigen in Mekka."
    h1['description']['zh'] = "享受朝觐者和麦加居民的塔尔维亚日。"

    h1['steps'][0]['bn'] = "গোসল, সুগন্ধি, ইহরাম পরিধান।"
    h1['steps'][0]['ms'] = "Mandi, memakai wangi-wangian, memakai Ihram."
    h1['steps'][0]['es'] = "Ghusl, perfume, vestir Ihram."
    h1['steps'][0]['de'] = "Ghusl, Parfüm, Ihram tragen."
    h1['steps'][0]['zh'] = "大净，香水，穿戒衣。"

    h1['steps'][1]['bn'] = "নিয়ত: 'লাব্বাইক হাজ্জান'।"
    h1['steps'][1]['ms'] = "Niat: 'Labbayk Hajjan'."
    h1['steps'][1]['es'] = "Intención: 'Labbayk Hajjan'."
    h1['steps'][1]['de'] = "Absicht: 'Labbayk Hajjan'."
    h1['steps'][1]['zh'] = "举意：'Labbayk Hajjan'。"

    h1['steps'][2]['bn'] = "তালবিয়া: 'লাব্বাইক আল্লাহুম্মা লাব্বাইক...'।"
    h1['steps'][2]['ms'] = "Talbiyah: 'Labbayk Allahumma Labbayk...'."
    h1['steps'][2]['es'] = "Talbiyah: 'Labbayk Allahumma Labbayk...'."
    h1['steps'][2]['de'] = "Talbiyah: 'Labbayk Allahumma Labbayk...'."
    h1['steps'][2]['zh'] = "应召词：'Labbayk Allahumma Labbayk...'。"

    # H2
    h2['description']['bn'] = "মিনার দিকে রওনা।"
    h2['description']['ms'] = "Menuju ke Mina."
    h2['description']['es'] = "Dirigiéndose a Mina."
    h2['description']['de'] = "Aufbruch nach Mina."
    h2['description']['zh'] = "前往米纳。"

    h2['steps'][0]['bn'] = "মিনায় যান। জোহর, আসর, মাগরিব, এশা, ফজর (কসর) পড়ুন।"
    h2['steps'][0]['ms'] = "Pergi ke Mina. Solat Zohor, Asar, Maghrib, Isyak, Subuh (Diqasar)."
    h2['steps'][0]['es'] = "Ir a Mina. Rezar Dhuhr, Asr, Maghrib, Isha, Fajr (Acortado)."
    h2['steps'][0]['de'] = "Gehe nach Mina. Bete Dhuhr, Asr, Maghrib, Isha, Fajr (Gekürzt)."
    h2['steps'][0]['zh'] = "去米纳。礼晌礼、晡礼、昏礼、宵礼、晨礼（缩短）。"

    h2['steps'][1]['bn'] = "জিকির, তালবিয়া এবং দোয়া বাড়ান।"
    h2['steps'][1]['ms'] = "Perbanyakkan Zikir, Talbiyah, dan Doa."
    h2['steps'][1]['es'] = "Aumentar Dhikr, Talbiyah y Dua."
    h2['steps'][1]['de'] = "Vermehre Dhikr, Talbiyah und Dua."
    h2['steps'][1]['zh'] = "增加记主、应召词和祈祷。"

    # H3
    h3['description']['bn'] = "হজ্জের সবচেয়ে বড় রুকন।"
    h3['description']['ms'] = "Rukun Haji yang paling agung."
    h3['description']['es'] = "El pilar más grande del Hajj."
    h3['description']['de'] = "Die größte Säule des Hajj."
    h3['description']['zh'] = "朝觐的最大支柱。"

    h3['steps'][0]['bn'] = "সূর্যোদয়ের পর আরাফাতে যান।"
    h3['steps'][0]['ms'] = "Pergi ke Arafah selepas terbit matahari."
    h3['steps'][0]['es'] = "Ir a Arafat después del amanecer."
    h3['steps'][0]['de'] = "Gehe nach Arafat nach Sonnenaufgang."
    h3['steps'][0]['zh'] = "日出后前往阿拉法特。"

    h3['steps'][1]['bn'] = "জোহর ও আসর একসাথে পড়ুন।"
    h3['steps'][1]['ms'] = "Jamak Zohor dan Asar."
    h3['steps'][1]['es'] = "Combinar Dhuhr y Asr."
    h3['steps'][1]['de'] = "Kombiniere Dhuhr und Asr."
    h3['steps'][1]['zh'] = "合并晌礼和晡礼。"

    h3['steps'][2]['bn'] = "সূর্যাস্ত পর্যন্ত দোয়ায় মগ্ন থাকুন।"
    h3['steps'][2]['ms'] = "Tumpukan masa untuk berdoa sehingga terbenam matahari."
    h3['steps'][2]['es'] = "Dedicar tiempo a Dua hasta el atardecer."
    h3['steps'][2]['de'] = "Widme Zeit für Dua bis zum Sonnenuntergang."
    h3['steps'][2]['zh'] = "专心祈祷直到日落。"

    h3['tips']['bn'] = "শ্রেষ্ঠ দোয়া হলো আরাফাতের দিনের দোয়া।"
    h3['tips']['ms'] = "Sebaik-baik doa adalah doa pada hari Arafah."
    h3['tips']['es'] = "La mejor Dua es la Dua del Día de Arafah."
    h3['tips']['de'] = "Das beste Dua ist das Dua am Tag von Arafah."
    h3['tips']['zh'] = "最好的祈祷是阿拉法特日的祈祷。"

    # H4
    h4['description']['bn'] = "মুজদালিফায় রাত যাপন।"
    h4['description']['ms'] = "Bermalam di Muzdalifah."
    h4['description']['es'] = "Pasar la noche en Muzdalifah."
    h4['description']['de'] = "Übernachtung in Muzdalifah."
    h4['description']['zh'] = "在穆兹达里法过夜。"

    h4['steps'][0]['bn'] = "সূর্যাস্থের পর মুজদালিফায় যান। মাগরিব ও এশা পড়ুন।"
    h4['steps'][0]['ms'] = "Selepas terbenam matahari, pergi ke Muzdalifah. Solat Maghrib & Isyak."
    h4['steps'][0]['es'] = "Después del atardecer, ir a Muzdalifah. Rezar Maghrib e Isha."
    h4['steps'][0]['de'] = "Nach Sonnenuntergang nach Muzdalifah gehen. Maghrib & Isha beten."
    h4['steps'][0]['zh'] = "日落后前往穆兹达里法。礼昏礼和宵礼。"

    h4['steps'][1]['bn'] = "সেখানে ঘুমান। ফজরের পর মাশআর আল-হারামে দোয়া করুন।"
    h4['steps'][1]['ms'] = "Tidur di sana. Berdoa di Masy'aril Haram selepas Subuh."
    h4['steps'][1]['es'] = "Dormir allí. Hacer Dua en Mash'ar Al-Haram después de Fajr."
    h4['steps'][1]['de'] = "Dort schlafen. Nach Fajr Dua im Mash'ar Al-Haram machen."
    h4['steps'][1]['zh'] = "在那里睡觉。晨礼后在禁标处祈祷。"

    h4['steps'][2]['bn'] = "পাথর সংগ্রহ করুন (আকাবার জন্য ৭টি)।"
    h4['steps'][2]['ms'] = "Kutip anak batu (7 untuk Aqabah)."
    h4['steps'][2]['es'] = "Recoger guijarros (7 para Aqabah)."
    h4['steps'][2]['de'] = "Kieselsteine sammeln (7 für Aqabah)."
    h4['steps'][2]['zh'] = "捡石子（7颗用于阿卡巴）。"

    # H5
    h5['description']['bn'] = "ঈদের দিনের আমল।"
    h5['description']['ms'] = "Amalan Hari Raya Aidiladha."
    h5['description']['es'] = "Rituales del Día de Eid."
    h5['description']['de'] = "Rituale am Eid-Tag."
    h5['description']['zh'] = "节日仪式。"

    h5['steps'][0]['bn'] = "১. জামরাতুল আকাবায় পাথর নিক্ষেপ (৭টি পাথর, আল্লাহু আকবর বলে)।"
    h5['steps'][0]['ms'] = "1. Melontar Jamrah Aqabah (7 anak batu, baca Allahu Akbar)."
    h5['steps'][0]['es'] = "1. Ipedrear Jamrat Al-Aqabah (7 guijarros, decir Allahu Akbar)."
    h5['steps'][0]['de'] = "1. Jamrat Al-Aqabah bewerfen (7 Kieselsteine, Allahu Akbar sagen)."
    h5['steps'][0]['zh'] = "1. 投掷阿卡巴石柱（7颗石子，说Allahu Akbar）。"

    h5['steps'][1]['bn'] = "২. কোরবানি (তামাত্তু ও কিরানের জন্য)।"
    h5['steps'][1]['ms'] = "2. Korban (untuk Tamattu' & Qiran)."
    h5['steps'][1]['es'] = "2. Sacrificio (para Tamattu' y Qiran)."
    h5['steps'][1]['de'] = "2. Opfer (für Tamattu' & Qiran)."
    h5['steps'][1]['zh'] = "2. 宰牲（针对享受朝和连朝）。"

    h5['steps'][2]['bn'] = "৩. মুণ্ডন বা ছাঁটা (মুণ্ডন উত্তম)।"
    h5['steps'][2]['ms'] = "3. Bercukur atau Bergunting (Bercukur lebih afdal)."
    h5['steps'][2]['es'] = "3. Afeitar o Recortar (Afeitar es mejor)."
    h5['steps'][2]['de'] = "3. Rasieren oder Kürzen (Rasieren ist besser)."
    h5['steps'][2]['zh'] = "3. 剃度或剪发（剃度更好）。"

    h5['steps'][3]['bn'] = "৪. তাওয়াফ আল-ইফাদাহ ও সাঈ (তামাত্তুর জন্য)।"
    h5['steps'][3]['ms'] = "4. Tawaf Ifadah & Sa'i (untuk Tamattu')."
    h5['steps'][3]['es'] = "4. Tawaf Al-Ifidah y Sa'i (para Tamattu')."
    h5['steps'][3]['de'] = "4. Tawaf Al-Ifidah & Sa'i (für Tamattu')."
    h5['steps'][3]['zh'] = "4. 巡游天房和奔走（针对享受朝）。"

    # H6
    h6['description']['bn'] = "মিনায় অবস্থান ও জামারাতে পাথর নিক্ষেপ।"
    h6['description']['ms'] = "Bermalam di Mina & Melontar Jamrah."
    h6['description']['es'] = "Quedarse en Mina y apedrear Jamarat."
    h6['description']['de'] = "Aufenthalt in Mina & Jamarat bewerfen."
    h6['description']['zh'] = "在米纳过夜并投掷石柱。"

    h6['steps'][0]['bn'] = "মিনায় থাকা।"
    h6['steps'][0]['ms'] = "Bermalam di Mina."
    h6['steps'][0]['es'] = "Quedarse en Mina."
    h6['steps'][0]['de'] = "In Mina bleiben."
    h6['steps'][0]['zh'] = "留在米纳。"

    h6['steps'][1]['bn'] = "প্রতিদিন ৩টি জামারায় পাথর নিক্ষেপ (ছোট, মাঝারি, বড়)।"
    h6['steps'][1]['ms'] = "Melontar 3 Jamrah setiap hari (Kecil, Sederhana, Besar)."
    h6['steps'][1]['es'] = "Apedrear 3 Jamarat diariamente (Pequeño, Mediano, Grande)."
    h6['steps'][1]['de'] = "Täglich 3 Jamarat bewerfen (Klein, Mittel, Groß)."
    h6['steps'][1]['zh'] = "每天投掷3个石柱（小、中、大）。"

    h6['steps'][2]['bn'] = "শুধুমাত্র ছোট ও মাঝারি জামারার পর দোয়া।"
    h6['steps'][2]['ms'] = "Berdoa selepas Jamrah Kecil & Sederhana sahaja."
    h6['steps'][2]['es'] = "Dua solo después de Pequeño y Mediano."
    h6['steps'][2]['de'] = "Dua nur nach Klein & Mittel."
    h6['steps'][2]['zh'] = "仅在小和中石柱后祈祷。"

    h6['steps'][3]['bn'] = "১২ তারিখে দ্রুত প্রস্থান বৈধ।"
    h6['steps'][3]['ms'] = "Dibenarkan Nafar Awal pada 12 Zulhijjah."
    h6['steps'][3]['es'] = "Permisible irse temprano el día 12."
    h6['steps'][3]['de'] = "Erlaubt, am 12. früh aufzubrechen."
    h6['steps'][3]['zh'] = "允许在12日提前离开。"

    # H7
    h7['description']['bn'] = "বিদায়ী কাজ।"
    h7['description']['ms'] = "Ibadah terakhir."
    h7['description']['es'] = "Ritual final."
    h7['description']['de'] = "Abschließendes Ritual."
    h7['description']['zh'] = "最后的仪式。"

    h7['steps'][0]['bn'] = "যাওয়ার আগে ৭ বার তাওয়াফ করুন।"
    h7['steps'][0]['ms'] = "Lakukan 7 pusingan Tawaf sebelum berangkat."
    h7['steps'][0]['es'] = "Realizar 7 vueltas de Tawaf antes de salir."
    h7['steps'][0]['de'] = "Führe 7 Runden Tawaf durch, bevor du gehst."
    h7['steps'][0]['zh'] = "离开前进行7圈巡游。"

    h7['steps'][1]['bn'] = "ঋতুস্রাবগ্রস্ত নারীদের জন্য মাফ।"
    h7['steps'][1]['ms'] = "Dikecualikan bagi wanita haid."
    h7['steps'][1]['es'] = "Exento para mujeres menstruantes."
    h7['steps'][1]['de'] = "Für menstruierende Frauen erlassen."
    h7['steps'][1]['zh'] = "经期妇女免除。"

    # H8
    h8['description']['bn'] = "হজ্জের রুকন ও ওয়াজিবসমূহ।"
    h8['description']['ms'] = "Rukun dan Wajib Haji."
    h8['description']['es'] = "Pilares y Deberes del Hajj."
    h8['description']['de'] = "Säulen und Pflichten des Hajj."
    h8['description']['zh'] = "朝觐的支柱和义务。"

    h8['steps'][0]['bn'] = "রুকন: ইহরাম, আরাফাতে অবস্থান, তাওয়াফ আল-ইফাদাহ, সাঈ।"
    h8['steps'][0]['ms'] = "Rukun: Ihram, Wukuf di Arafah, Tawaf Ifadah, Sa'i."
    h8['steps'][0]['es'] = "Pilares: Ihram, Estar en Arafat, Tawaf Al-Ifadah, Sa'i."
    h8['steps'][0]['de'] = "Säulen: Ihram, Stehen in Arafat, Tawaf Al-Ifadah, Sa'i."
    h8['steps'][0]['zh'] = "支柱：受戒，驻阿拉法特，巡游天房，奔走。"

    h8['steps'][1]['bn'] = "ওয়াজিব: মিকাত থেকে ইহরাম, মুজদালিফা/মিনায় রাত যাপন, পাথর নিক্ষেপ, মুণ্ডন/ছাঁটা, বিদায়ী তাওয়াফ।"
    h8['steps'][1]['ms'] = "Wajib: Ihram dari Miqat, Bermalam di Muzdalifah/Mina, Melontar, Bercukur/Bergunting, Tawaf Wada'."
    h8['steps'][1]['es'] = "Deberes: Ihram desde Miqat, Noche en Muzdalifah/Mina, Apedrear, Afeitar/Recortar, Tawaf de Despedida."
    h8['steps'][1]['de'] = "Pflichten: Ihram vom Miqat, Übernachtung in Muzdalifah/Mina, Bewerfen, Rasieren/Kürzen, Abschieds-Tawaf."
    h8['steps'][1]['zh'] = "义务：从戒关受戒，在穆兹达里法/米纳过夜，投掷，剃度/剪发，辞朝。"

    # ========================== TITLES & DUAS UPDATE ==========================

    def set_title(obj, t_dict):
        if 'title' not in obj: obj['title'] = {}
        for lang, text in t_dict.items():
            obj['title'][lang] = text

    def set_dua_trans(obj, dua_index, trans_dict):
        if 'duas' in obj and len(obj['duas']) > dua_index:
            d = obj['duas'][dua_index]
            if 'translation' not in d: d['translation'] = {}
            for lang, text in trans_dict.items():
                d['translation'][lang] = text

    def set_dua_title(obj, dua_index, title_dict):
        if 'duas' in obj and len(obj['duas']) > dua_index:
            d = obj['duas'][dua_index]
            if 'title' not in d: d['title'] = {}
            for lang, text in title_dict.items():
                d['title'][lang] = text

    # --- U1: Ihram ---
    set_title(u1, {
        "fr": "Premier: Ihram du Miqat", "id": "Pertama: Ihram dari Miqat", "ur": "پہلا: میقات سے احرام",
        "tr": "Birinci: Mikattan İhram", "bn": "প্রথম: মিকাত থেকে ইহরাম", "ms": "Pertama: Ihram dari Miqat",
        "fa": "اول: احرام از میقات", "es": "Primero: Ihram desde Miqat", "de": "Erstens: Ihram vom Miqat", "zh": "第一：从戒关受戒"
    })
    set_dua_title(u1, 0, {
        "fr": "Talbiyah", "id": "Talbiyah", "ur": "تلبیہ", "tr": "Telbiye", 
        "bn": "তালবিয়া", "ms": "Talbiyah", "fa": "تلبیه", "es": "Talbiyah", 
        "de": "Talbiyah", "zh": "应召词"
    })
    set_dua_trans(u1, 0, {
        "fr": "Me voici, ô Allah, me voici. Me voici, Tu n'as pas d'associé, me voici. Certes la louange et le bienfait T'appartiennent, ainsi que la royauté, Tu n'as pas d'associé.",
        "id": "Aku memenuhi panggilan-Mu ya Allah, aku memenuhi panggilan-Mu. Aku memenuhi panggilan-Mu, tiada sekutu bagi-Mu, aku memenuhi panggilan-Mu. Sesungguhnya pujian dan nikmat adalah milik-Mu, begitu juga kerajaan, tiada sekutu bagi-Mu.",
        "ur": "میں حاضر ہوں اے اللہ میں حاضر ہوں۔ میں حاضر ہوں، تیرا کوئی شریک نہیں، میں حاضر ہوں۔ بے شک تمام تعریفیں اور نعمتیں تیرے ہی لیے ہیں اور بادشاہت بھی، تیرا کوئی شریک نہیں ہے۔",
        "tr": "Buyur Allah'ım buyur! Buyur, senin ortağın yoktur. Buyur, şüphesiz hamd sanadır, nimet senindir, mülk senindir. Senin ortağın yoktur.",
        "bn": "আমি হাজির হে আল্লাহ, আমি হাজির। আমি হাজির, আপনার কোন শরীক নেই, আমি হাজির। নিশ্চয়ই সকল প্রশংসা ও নিয়ামত আপনারই এবং রাজত্বও, আপনার কোন শরীক নেই।",
        "ms": "Hamba-Mu datang menyahut panggilan-Mu ya Allah. Hamba-Mu datang menyahut panggilan-Mu. Hamba-Mu datang menyahut panggilan-Mu. Tiada sekutu bagi-Mu. Sesungguhnya segala puji, nikmat dan kerajaan adalah kepunyaan-Mu, tiada sekutu bagi-Mu.",
        "fa": "لبیک ای خدا، لبیک. لبیک، تو را شریکی نیست، لبیک. همانا ستایش و نعمت و پادشاهی از آن توست، تو را شریکی نیست.",
        "es": "Heme aquí, oh Allah, heme aquí. Heme aquí, no tienes copartícipes, heme aquí. Ciertamente, todas las alabanzas y las gracias son Tuyas, y también la soberanía. No tienes copartícipes.",
        "de": "Hier bin ich, o Allah, hier bin ich. Hier bin ich, Du hast keinen Partner, hier bin ich. Wahrlich, alles Lob und alle Huld sind Dein, und auch die Herrschaft. Du hast keinen Partner.",
        "zh": "我在这里，噢真主，我在这里。我在这里，你没有伙伴，我在这里。确实，所有的赞美和恩典都归于你，主权也归于你，你没有伙伴。"
    })

    # --- U2: Entering Masjid ---
    set_title(u2, {
        "fr": "Deuxième: Entrer à la Mosquée Sacrée", "id": "Kedua: Masuk Masjidil Haram", "ur": "دوسرا: مسجد الحرام میں داخل ہونا",
        "tr": "İkinci: Mescid-i Haram'a Giriş", "bn": "দ্বিতীয়: মসজিদে হারামে প্রবেশ", "ms": "Kedua: Masuk Masjidil Haram",
        "fa": "دوم: ورود به مسجد الحرام", "es": "Segundo: Entrar en la Mezquita Sagrada", "de": "Zweitens: Betreten der Heiligen Moschee", "zh": "第二：进入禁寺"
    })
    set_dua_title(u2, 0, {
        "fr": "Doua d'entrée à la mosquée", "id": "Doa Masuk Masjid", "ur": "مسجد میں داخل ہونے کی دعا", 
        "tr": "Mescide Giriş Duası", "bn": "মসজিদে প্রবেশের দোয়া", "ms": "Doa Masuk Masjid", 
        "fa": "دعای ورود به مسجد", "es": "Súplica al entrar a la mezquita", "de": "Bittgebet beim Betreten der Moschee", "zh": "进寺杜阿"
    })
    set_dua_trans(u2, 0, {
        "fr": "Au nom d'Allah, et prière et salut sur le Messager d'Allah. Ô Allah, ouvre-moi les portes de Ta miséricorde.",
        "id": "Dengan nama Allah, dan shalawat serta salam kepada Rasulullah. Ya Allah, bukakanlah pintu-pintu rahmat-Mu untukku.",
        "ur": "اللہ کے نام سے، اور اللہ کے رسول پر درود و سلام ہو۔ اے اللہ، میرے لیے اپنی رحمت کے دروازے کھول دے۔",
        "tr": "Allah'ın adıyla, salat ve selam Resulullah'ın üzerine olsun. Allah'ım, bana rahmet kapılarını aç.",
        "bn": "আল্লাহর নামে, এবং আল্লাহর রাসূলের ওপর দুরুদ ও সালাম বর্ষিত হোক। হে আল্লাহ, আমার জন্য আপনার রহমতের দরজাগুলো খুলে দিন।",
        "ms": "Dengan nama Allah, dan selawat serta salam ke atas Rasulullah. Ya Allah, bukakanlah pintu-pintu rahmat-Mu untukku.",
        "fa": "به نام خدا، و درود و سلام بر رسول خدا. خدایا، درهای رحمتت را به روی من بگشا.",
        "es": "En el nombre de Allah, y las bendiciones y la paz sean con el Mensajero de Allah. Oh Allah, ábreme las puertas de Tu misericordia.",
        "de": "Im Namen Allahs, und Segen und Frieden seien auf dem Gesandten Allahs. O Allah, öffne mir die Tore Deiner Barmherzigkeit.",
        "zh": "以真主之名，祈求真主赐福安于真主的使者。噢真主，请为我打开你的仁慈之门。"
    })

    # --- U3: Tawaf ---
    set_title(u3, {
        "fr": "Troisième: Tawaf (Circumambulation)", "id": "Ketiga: Tawaf", "ur": "تیسرا: طواف",
        "tr": "Üçüncü: Tavaf", "bn": "তৃতীয়: তাওয়াফ", "ms": "Ketiga: Tawaf",
        "fa": "سوم: طواف", "es": "Tercero: Tawaf", "de": "Drittens: Tawaf", "zh": "第三：巡游天房"
    })
    set_dua_title(u3, 0, {
        "fr": "Entre les deux Coins", "id": "Di antara Dua Rukun", "ur": "دونوں ارکان کے درمیان", 
        "tr": "İki Köşe Arası", "bn": "দুই রুকনের মাঝে", "ms": "Di antara Dua Rukun", 
        "fa": "بین دو رکن", "es": "Entre las dos esquinas", "de": "Zwischen den beiden Ecken", "zh": "两角之间"
    })
    set_dua_trans(u3, 0, {
        "fr": "Seigneur, donne-nous ici-bas un bien et dans l'au-delà un bien et protège-nous du châtiment du Feu.",
        "id": "Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat dan peliharalah kami dari siksa neraka.",
        "ur": "اے ہمارے رب! ہمیں دنیا میں بھلائی دے اور آخرت میں بھلائی دے اور ہمیں آگ کے عذاب سے بچا۔",
        "tr": "Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.",
        "bn": "হে আমাদের পালনকর্তা! আমাদের দুনিয়াতে কল্যাণ দিন এবং আখেরাতেও কল্যাণ দিন এবং আমাদেরকে আগুনের শাস্তি থেকে রক্ষা করুন।",
        "ms": "Wahai Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat dan peliharalah kami dari azab neraka.",
        "fa": "پروردگارا! در دنیا به ما نیکی عطا کن و در آخرت نیز نیکی عطا فرما و ما را از عذاب آتش نگه دار.",
        "es": "¡Señor nuestro! Danos lo bueno en este mundo y lo bueno en el Más Allá, y líbranos del castigo del Fuego.",
        "de": "Unser Herr, gib uns in dieser Welt Gutes und im Jenseits Gutes und bewahre uns vor der Strafe des Feuers.",
        "zh": "我们的主啊！求你在今世赏赐我们要好，在后世也赏赐我们美好，求你保护我们免受火狱的刑罚。"
    })

    # --- U4: Prayer & Zamzam ---
    set_title(u4, {
        "fr": "Quatrième: Prière et Zamzam", "id": "Keempat: Shalat dan Zamzam", "ur": "چوتھا: نماز اور زمزم",
        "tr": "Dördüncü: Namaz ve Zemzem", "bn": "চতুর্থ: নামাজ ও জমজম", "ms": "Keempat: Solat dan Zamzam",
        "fa": "چهارم: نماز و زمزم", "es": "Cuarto: Oración y Zamzam", "de": "Viertens: Gebet und Zamzam", "zh": "第四：礼拜与赞赞水"
    })
    
    # --- U5: Sa'i ---
    set_title(u5, {
        "fr": "Cinquième: Sa'i (Safa et Marwah)", "id": "Kelima: Sa'i", "ur": "پانچواں: سعی",
        "tr": "Beşinci: Sa'y", "bn": "পঞ্চম: সাঈ", "ms": "Kelima: Sa'i",
        "fa": "پنجم: سعی", "es": "Quinto: Sa'i", "de": "Fünftens: Sa'i", "zh": "第五：奔走"
    })
    set_dua_title(u5, 0, {
        "fr": "Dhikr sur Safa", "id": "Dzikir di Safa", "ur": "صفا پر ذکر", 
        "tr": "Safa'da Zikir", "bn": "সাফায় জিকির", "ms": "Zikir di Safa", 
        "fa": "ذکر بر صفا", "es": "Dhikr en Safa", "de": "Dhikr auf Safa", "zh": "萨法上的记主"
    })
    set_dua_trans(u5, 0, {
        "fr": "Il n'y a de divinité qu'Allah seul, sans associé. À Lui la royauté, à Lui la louange, et Il est capable de toute chose.",
        "id": "Tidak ada Tuhan selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu.",
        "ur": "اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، بادشاہت اسی کی ہے اور تعریف اسی کے لیے ہے، اور وہ ہر چیز پر قادر ہے۔",
        "tr": "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'nadır. O her şeye kadirdir.",
        "bn": "আল্লাহ ছাড়া কোন উপাস্য নেই, তিনি একক, তার কোন শরীক নেই। রাজত্ব তারই এবং সকল প্রশংসা তারই, এবং তিনি সব কিছুর উপর ক্ষমতাবান।",
        "ms": "Tiada Tuhan melainkan Allah yang Esa, tiada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas setiap sesuatu.",
        "fa": "معبودی جز الله نیست، یگانه است و شریکی ندارد. پادشاهی و ستایش از آن اوست و او بر هر چیزی تواناست.",
        "es": "No hay dios más que Allah solo, sin copartícipes. Suyo es el dominio y Suya es la alabanza, y Él es capaz de todas las cosas.",
        "de": "Es gibt keinen Gott außer Allah allein, ohne Partner. Sein ist die Herrschaft und Sein ist das Lob, und Er ist zu allem fähig.",
        "zh": "万物非主，唯有真主，独一无二。主权归他，赞颂归他，他是万能的。"
    })

    # --- U6: Shaving ---
    set_title(u6, {
        "fr": "Sixième: Rasage ou Coupe", "id": "Keenam: Mencukur atau Memotong", "ur": "چھٹا: حلق یا قصر",
        "tr": "Altıncı: Tıraş veya Kısaltma", "bn": "ষষ্ঠ: মুণ্ডন বা ছাঁটা", "ms": "Keenam: Bercukur atau Bergunting",
        "fa": "ششم: حلق یا تقصیر", "es": "Sexto: Afeitar o Recortar", "de": "Sechstens: Rasieren oder Kürzen", "zh": "第六：剃度或剪发"
    })
    
    # Fill recommended dua step in U6
    u6['steps'][1]['fr'] = "Il est recommandé de dire : 'Ô Allah, accepte de moi'."
    u6['steps'][1]['id'] = "Disunnahkan membaca: 'Ya Allah, terimalah dariku'."
    u6['steps'][1]['ur'] = "یہ کہنا مستحب ہے: 'اے اللہ، مجھ سے قبول فرما'۔"
    u6['steps'][1]['tr'] = "Şunu söylemek müstehaptır: 'Allah'ım, benden kabul et'."
    u6['steps'][1]['bn'] = "এটি বলা বাঞ্ছনীয়: 'হে আল্লাহ, আমার পক্ষ থেকে কবুল করুন'।"
    u6['steps'][1]['ms'] = "Digalakkan menyebut: 'Ya Allah, terimalah daripadaku'."
    u6['steps'][1]['fa'] = "مستحب است بگویید: «خدایا از من بپذیر»."
    u6['steps'][1]['es'] = "Se recomienda decir: 'Oh Allah, acepta de mí'."
    u6['steps'][1]['de'] = "Es wird empfohlen zu sagen: 'O Allah, nimm von mir an'."
    u6['steps'][1]['zh'] = "建议说：'噢真主，求你接纳我的（功课）'。"

    # --- U7: Prohibitions ---
    set_title(u7, {
        "fr": "Interdits de l'Ihram", "id": "Larangan Ihram", "ur": "احرام کی ممانعتیں",
        "tr": "İhram Yasakları", "bn": "ইহরামের নিষেধাজ্ঞা", "ms": "Larangan Ihram",
        "fa": "محرّمات احرام", "es": "Prohibiciones del Ihram", "de": "Verbote des Ihram", "zh": "受戒禁忌"
    })
    
    # Fill missing steps for U7 (bn, ms, etc which were English in valid check)
    steps7 = u7['steps']
    # 0: Hair/Nails
    steps7[0]['ms'] = "Mencabut rambut dan memotong kuku."
    steps7[0]['bn'] = "চুল ও নখ কাটা।"
    steps7[0]['es'] = "Quitarse el pelo y cortarse las uñas."
    steps7[0]['de'] = "Haare entfernen und Nägel schneiden."
    steps7[0]['zh'] = "去除毛发和修剪指甲。"
    # 1: Perfume
    steps7[1]['ms'] = "Memakai wangi-wangian."
    steps7[1]['bn'] = "সুগন্ধি ব্যবহার করা।"
    steps7[1]['es'] = "Usar perfume."
    steps7[1]['de'] = "Parfüm benutzen."
    steps7[1]['zh'] = "使用香水。"
    # 2: Intimacy
    steps7[2]['ms'] = "Bersetubuh dan permulaannya."
    steps7[2]['bn'] = "যৌন মিলন ও তার পূর্বলক্ষণ।"
    steps7[2]['es'] = "Intimidad, juegos previos y contratos matrimoniales."
    steps7[2]['de'] = "Intimität, Vorspiel und Heiratsverträge."
    steps7[2]['zh'] = "亲密关系、前戏和婚约。"
    # 3: Hunting
    steps7[3]['ms'] = "Memburu haiwan darat."
    steps7[3]['bn'] = "স্থলচর প্রাণী শিকার।"
    steps7[3]['es'] = "Cazar animales terrestres."
    steps7[3]['de'] = "Landtiere jagen."
    steps7[3]['zh'] = "狩猎陆地动物。"
    # 4: Men Sewn
    steps7[4]['ms'] = "Lelaki: Memakai pakaian berjahit dan menutup kepala."
    steps7[4]['bn'] = "পুরুষ: সেলাই করা কাপড় পরা এবং মাথা ঢাকা।"
    steps7[4]['es'] = "Hombres: Usar ropa cosida y cubrirse la cabeza."
    steps7[4]['de'] = "Männer: Genähte Kleidung tragen und den Kopf bedecken."
    steps7[4]['zh'] = "男士：穿缝制衣服和遮盖头部。"
    # 5: Women Niqab
    steps7[5]['ms'] = "Wanita: Memakai purdah dan sarung tangan."
    steps7[5]['bn'] = "নারী: নিকাব ও দস্তানা পরা।"
    steps7[5]['es'] = "Mujeres: Usar Niqab y guantes."
    steps7[5]['de'] = "Frauen: Niqab und Handschuhe tragen."
    steps7[5]['zh'] = "女士：戴面纱和手套。"
    
    # Tips U7
    u7['tips']['ms'] = "Sesiapa yang melakukan larangan kerana terlupa tidak berdosa."
    u7['tips']['bn'] = "যে ভুলবশত নিষিদ্ধ কাজ করে তার কোন পাপ নেই।"
    u7['tips']['es'] = "Quien comete una prohibición por olvido no tiene pecado."
    u7['tips']['de'] = "Wer aus Vergesslichkeit ein Verbot begeht, trägt keine Sünde."
    u7['tips']['zh'] = "因遗忘而犯禁者无罪。"


    # --- HAJJ TITLES & DUAS ---
    set_title(h_intro, {
        "fr": "Qu'est-ce que le Hajj ? & Types", "id": "Apa itu Haji? & Jenisnya", "ur": "حج کیا ہے؟ اور اقسام",
        "tr": "Hac Nedir? & Çeşitleri", "bn": "হজ্জ কি? ও প্রকারভেদ", "ms": "Apa itu Haji? & Jenis-jenisnya",
        "fa": "حج چیست؟ و انواع آن", "es": "¿Qué es el Hajj? y Tipos", "de": "Was ist Hajj? & Arten", "zh": "什么是朝觐？& 类型"
    })
    # Fix h_intro steps for bn, ms, etc
    h_intro['steps'][0]['bn'] = "১. তামাত্তু: হজ্জের মাসে ওমরাহ, ইহরাম ভঙ্গ, তারপর হজ্জ (কোরবানি আবশ্যক)। সর্বোত্তম।"
    h_intro['steps'][0]['ms'] = "1. Tamattu': Umrah pada bulan Haji, Tahallul, kemudian Haji (Wajib Dam). Terbaik."
    h_intro['steps'][0]['es'] = "1. Tamattu': Umrah en meses de Hajj, romper Ihram, luego Hajj (Sacrificio requerido)."
    h_intro['steps'][0]['de'] = "1. Tamattu': Umrah in Hajj-Monaten, Ihram brechen, dann Hajj (Opfer erforderlich)."
    h_intro['steps'][0]['zh'] = "1. 享受朝：在朝觐月副朝，开戒，然后正朝（需宰牲）。最好。"

    h_intro['steps'][1]['bn'] = "২. কিরান: ওমরাহ ও হজ্জ একসাথে, মাঝখানে বিরতি নেই (কোরবানি আবশ্যক)।"
    h_intro['steps'][1]['ms'] = "2. Qiran: Umrah & Haji digabungkan, tiada Tahallul (Wajib Dam)."
    h_intro['steps'][1]['es'] = "2. Qiran: Umrah y Hajj combinados, sin descanso (Sacrificio requerido)."
    h_intro['steps'][1]['de'] = "2. Qiran: Umrah & Hajj kombiniert, keine Pause (Opfer erforderlich)."
    h_intro['steps'][1]['zh'] = "2. 连朝：副朝和正朝结合，中间不开戒（需宰牲）。"

    h_intro['steps'][2]['bn'] = "৩. ইফরাদ: শুধু হজ্জ (কোনো কোরবানি নেই)।"
    h_intro['steps'][2]['ms'] = "3. Ifrad: Haji sahaja (Tiada Dam)."
    h_intro['steps'][2]['es'] = "3. Ifrad: Solo Hajj (Sin sacrificio)."
    h_intro['steps'][2]['de'] = "3. Ifrad: Nur Hajj (Kein Opfer)."
    h_intro['steps'][2]['zh'] = "3. 单朝：仅正朝（无宰牲）。"

    set_title(h1, {
        "fr": "Étape 1: Ihram", "id": "Langkah 1: Ihram", "ur": "مرحلہ 1: احرام",
        "tr": "1. Adım: İhram", "bn": "ধাপ ১: ইহরাম", "ms": "Langkah 1: Ihram",
        "fa": "مرحله ۱: احرام", "es": "Paso 1: Ihram", "de": "Schritt 1: Ihram", "zh": "第一步：受戒"
    })
    
    set_title(h2, {
        "fr": "Étape 2: Tarwiyah", "id": "Langkah 2: Tarwiyah", "ur": "مرحلہ 2: ترویہ",
        "tr": "2. Adım: Terviye", "bn": "ধাপ ২: তারবিয়া", "ms": "Langkah 2: Tarwiyah",
        "fa": "مرحله ۲: ترویه", "es": "Paso 2: Tarwiyah", "de": "Schritt 2: Tarwiyah", "zh": "第二步：塔尔维亚"
    })

    set_title(h3, {
        "fr": "Étape 3: Arafat", "id": "Langkah 3: Arafah", "ur": "مرحلہ 3: عرفہ",
        "tr": "3. Adım: Arafat", "bn": "ধাপ ৩: আরাফাত", "ms": "Langkah 3: Arafah",
        "fa": "مرحله ۳: عرفات", "es": "Paso 3: Arafat", "de": "Schritt 3: Arafat", "zh": "第三步：阿拉法特"
    })
    set_dua_title(h3, 0, {
        "fr": "Doua d'Arafat", "id": "Doa Arafah", "ur": "عرفہ کی دعا", 
        "tr": "Arefe Duası", "bn": "আরাফাতের দোয়া", "ms": "Doa Arafah", 
        "fa": "دعای عرفه", "es": "Dua de Arafah", "de": "Dua von Arafah", "zh": "阿拉法特杜阿"
    })
    set_dua_trans(h3, 0, {
        "fr": "Il n'y a de divinité qu'Allah seul, sans associé. À Lui la royauté, à Lui la louange, et Il est capable de toute chose.",
        "id": "Tidak ada Tuhan selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas segala sesuatu.",
        "ur": "اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، بادشاہت اسی کی ہے اور تعریف اسی کے لیے ہے، اور وہ ہر چیز پر قادر ہے۔",
        "tr": "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'nadır. O her şeye kadirdir.",
        "bn": "আল্লাহ ছাড়া কোন উপাস্য নেই, তিনি একক, তার কোন শরীক নেই। রাজত্ব তারই এবং সকল প্রশংসা তারই, এবং তিনি সব কিছুর উপর ক্ষমতাবান।",
        "ms": "Tiada Tuhan melainkan Allah yang Esa, tiada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala puji, dan Dia Maha Kuasa atas setiap sesuatu.",
        "fa": "معبودی جز الله نیست، یگانه است و شریکی ندارد. پادشاهی و ستایش از آن اوست و او بر هر چیزی تواناست.",
        "es": "No hay dios más que Allah solo, sin copartícipes. Suyo es el dominio y Suya es la alabanza, y Él es capaz de todas las cosas.",
        "de": "Es gibt keinen Gott außer Allah allein, ohne Partner. Sein ist die Herrschaft und Sein ist das Lob, und Er ist zu allem fähig.",
        "zh": "万物非主，唯有真主，独一无二。主权归他，赞颂归他，他是万能的。"
    })

    set_title(h4, {
        "fr": "Étape 4: Muzdalifah", "id": "Langkah 4: Muzdalifah", "ur": "مرحلہ 4: مزدلفہ",
        "tr": "4. Adım: Müzdelife", "bn": "ধাপ ৪: মুজদালিফা", "ms": "Langkah 4: Muzdalifah",
        "fa": "مرحله ۴: مزدلفه", "es": "Paso 4: Muzdalifah", "de": "Schritt 4: Muzdalifah", "zh": "第四步：穆兹达里法"
    })

    set_title(h5, {
        "fr": "Étape 5: Aïd (Nahr)", "id": "Langkah 5: Idul Adha", "ur": "مرحلہ 5: عید (نحر)",
        "tr": "5. Adım: Bayram (Nahr)", "bn": "ধাপ ৫: ঈদ (নহর)", "ms": "Langkah 5: Aidiladha",
        "fa": "مرحله ۵: عید (نحر)", "es": "Paso 5: Eid (Nahr)", "de": "Schritt 5: Eid (Nahr)", "zh": "第五步：节日（宰牲）"
    })

    set_title(h6, {
        "fr": "Jours de Tashreeq", "id": "Hari Tasyriq", "ur": "ایام تشریق",
        "tr": "Teşrik Günleri", "bn": "আইয়ামে তাশরিক", "ms": "Hari Tasyrik",
        "fa": "ایام تشریق", "es": "Días de Tashreeq", "de": "Tage des Taschriq", "zh": "晒肉日"
    })

    set_title(h7, {
        "fr": "Tawaf d'Adieu", "id": "Tawaf Wada'", "ur": "طواف وداع",
        "tr": "Veda Tavafı", "bn": "বিদায়ী তাওয়াফ", "ms": "Tawaf Wada'",
        "fa": "طواف وداع", "es": "Tawaf de Despedida", "de": "Abschieds-Tawaf", "zh": "辞朝"
    })

    set_title(h8, {
        "fr": "Résumé des Piliers", "id": "Ringkasan Rukun", "ur": "ارکان کا خلاصہ",
        "tr": "Rükünler Özeti", "bn": "রুকন ও ওয়াজিবের সারসংক্ষেপ", "ms": "Ringkasan Rukun",
        "fa": "خلاصه ارکان", "es": "Resumen de Pilares", "de": "Zusammenfassung der Säulen", "zh": "支柱摘要"
    })

    # Save
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    
    print("Full Translation Update complete.")

if __name__ == "__main__":
    main()
