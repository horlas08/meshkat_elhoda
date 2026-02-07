/// أدعية رمضان اليومية - 30 دعاء لكل يوم من أيام الشهر الفضيل
class RamadanDuas {
  /// الحصول على دعاء اليوم بناءً على رقم اليوم واللغة
  static String getDuaForDay(int dayNumber, String language) {
    if (dayNumber < 1 || dayNumber > 30) {
      dayNumber = 1;
    }

    final duas = _getDuasForLanguage(language);
    return duas[dayNumber - 1];
  }

  /// الحصول على رقم اليوم الحالي في رمضان
  static int getCurrentRamadanDay() {
    final now = DateTime.now();
    return (now.day % 30) + 1;
  }

  /// الحصول على الأدعية حسب اللغة
  static List<String> _getDuasForLanguage(String language) {
    switch (language) {
      case 'ar':
        return _arabicDuas;
      case 'en':
        return _englishDuas;
      case 'fr':
        return _frenchDuas;
      case 'id':
        return _indonesianDuas;
      case 'ur':
        return _urduDuas;
      case 'tr':
        return _turkishDuas;
      case 'bn':
        return _bengaliDuas;
      case 'ms':
        return _malayDuas;
      case 'fa':
        return _persianDuas;
      case 'es':
        return _spanishDuas;
      case 'de':
        return _germanDuas;
      case 'zh':
        return _chineseDuas;
      default:
        return _arabicDuas;
    }
  }

  // الأدعية بالعربية
  static const List<String> _arabicDuas = [
    "اللهم اجعل صيامي فيه صيام الصائمين، وقيامي فيه قيام القائمين، ونبّهني فيه عن نومة الغافلين، وهب لي جرمي فيه يا إله العالمين",
    "اللهم قربني فيه إلى مرضاتك، وجنبني فيه من سخطك ونقماتك، ووفقني فيه لقراءة آياتك، برحمتك يا أرحم الراحمين",
    "اللهم ارزقني فيه الذهن والتنبيه، وباعدني فيه من السفاهة والتمويه، واجعل لي نصيباً من كل خير تنزله فيه، بجودك يا أجود الأجودين",
    "اللهم قوني فيه على إقامة أمرك، وأذقني فيه حلاوة ذكرك، وأوزعني فيه لأداء شكرك بكرمك، واحفظني فيه بحفظك وسترك يا أبصر الناظرين",
    "اللهم اجعلني فيه من المستغفرين، واجعلني فيه من عبادك الصالحين القانتين، واجعلني فيه من أوليائك المقربين، برأفتك يا أرحم الراحمين",
    "اللهم لا تخذلني فيه لتعرض معصيتك، ولا تضربني بسياط نقمتك، وزحزحني فيه من موجبات سخطك، بمنك وأياديك يا منتهى رغبة الراغبين",
    "اللهم أعني فيه على صيامه وقيامه، وجنبني فيه من هفواته وآثامه، وارزقني فيه ذكرك بدوامه، بتوفيقك يا هادي المضلين",
    "اللهم ارزقني فيه رحمة الأيتام، وإطعام الطعام، وإفشاء السلام، وصحبة الكرام، بطولك يا ملجأ الآملين",
    "اللهم اجعل لي فيه نصيباً من رحمتك الواسعة، واهدني فيه لبراهينك الساطعة، وخذ بناصيتي إلى مرضاتك الجامعة، بمحبتك يا أمل المشتاقين",
    "اللهم اجعلني فيه من المتوكلين عليك، واجعلني فيه من الفائزين لديك، واجعلني فيه من المقربين إليك، بإحسانك يا غاية الطالبين",
    "اللهم حبب إلي فيه الإحسان، وكره إلي فيه الفسوق والعصيان، وحرم علي فيه سخطك والنيران، بعونك يا غياث المستغيثين",
    "اللهم زيني فيه بالستر والعفاف، واسترني فيه بلباس القنوع والكفاف، واحملني فيه على العدل والإنصاف، وآمني فيه من كل ما أخاف، بعصمتك يا عصمة الخائفين",
    "اللهم طهرني فيه من الدنس والأقذار، وصبرني فيه على كائنات الأقدار، ووفقني فيه للتقى وصحبة الأبرار، بعونك يا قرة عين المساكين",
    "اللهم لا تؤاخذني فيه بالعثرات، وأقلني فيه من الخطايا والهفوات، ولا تجعلني فيه غرضاً للبلايا والآفات، بعزتك يا عز المسلمين",
    "اللهم ارزقني فيه طاعة الخاشعين، واشرح فيه صدري بإنابة المخبتين، بأمانك يا أمان الخائفين",
    "اللهم وفقني فيه لموافقة الأبرار، وجنبني فيه مرافقة الأشرار، وآوني فيه برحمتك إلى دار القرار، بإلهيتك يا إله العالمين",
    "اللهم اهدني فيه لصالح الأعمال، واقض لي فيه الحوائج والآمال، يا من لا يحتاج إلى التفسير والسؤال، يا عالماً بما في صدور العالمين",
    "اللهم نبهني فيه لبركات أسحاره، ونور فيه قلبي بضياء أنواره، وخذ بكل أعضائي إلى اتباع آثاره، بنورك يا منور قلوب العارفين",
    "اللهم وفر فيه حظي من بركاته، وسهل سبيلي إلى خيراته، ولا تحرمني قبول حسناته، يا هادياً إلى الحق المبين",
    "اللهم افتح لي فيه أبواب الجنان، وأغلق عني فيه أبواب النيران، ووفقني فيه لتلاوة القرآن، يا منزل السكينة في قلوب المؤمنين",
    "اللهم اجعل لي فيه إلى مرضاتك دليلاً، ولا تجعل للشيطان فيه علي سبيلاً، واجعل الجنة لي منزلاً ومقيلاً، يا قاضي حوائج الطالبين",
    "اللهم افتح لي فيه أبواب فضلك، وأنزل علي فيه بركاتك، ووفقني فيه لموجبات مرضاتك، وأسكني فيه بحبوحات جناتك، يا مجيب دعوة المضطرين",
    "اللهم اغسلني فيه من الذنوب، وطهرني فيه من العيوب، وامتحن قلبي فيه بتقوى القلوب، يا مقيل عثرات المذنبين",
    "اللهم إني أسألك فيه ما يرضيك، وأعوذ بك مما يؤذيك، وأسألك التوفيق فيه لأن أطيعك ولا أعصيك، يا جواد السائلين",
    "اللهم اجعلني فيه محباً لأوليائك، ومعادياً لأعدائك، مستناً بسنة خاتم أنبيائك، يا عاصم قلوب النبيين",
    "اللهم اجعل سعيي فيه مشكوراً، وذنبي فيه مغفوراً، وعملي فيه مقبولاً، وعيبي فيه مستوراً، يا أسمع السامعين",
    "اللهم ارزقني فيه فضل ليلة القدر، وصير أموري فيه من العسر إلى اليسر، واقبل معاذيري وحط عني الذنب والوزر، يا رؤوفاً بعباده الصالحين",
    "اللهم وفر حظي فيه من النوافل، وأكرمني فيه بإحضار المسائل، وقرب فيه وسيلتي إليك من بين الوسائل، يا من لا يشغله إلحاح الملحين",
    "اللهم غشني فيه بالرحمة، وارزقني فيه التوفيق والعصمة، وطهر قلبي من غياهب التهمة، يا رحيماً بعباده المؤمنين",
    "اللهم اجعل صيامي فيه بالشكر والقبول على ما ترضاه ويرضاه الرسول، محكمة فروعه بالأصول، بحق سيدنا محمد وآله الطاهرين، والحمد لله رب العالمين",
  ];

  // الأدعية بالإنجليزية (مختصرة)
  static const List<String> _englishDuas = [
    "O Allah, make my fasting in it the fasting of those who fast, and my prayer the prayer of those who pray",
    "O Allah, bring me closer to Your pleasure and keep me away from Your anger",
    "O Allah, grant me wisdom and alertness, and keep me away from foolishness",
    "O Allah, strengthen me to establish Your command and let me taste the sweetness of Your remembrance",
    "O Allah, make me among those who seek forgiveness and Your righteous servants",
    "O Allah, do not abandon me to disobedience and do not strike me with Your punishment",
    "O Allah, help me in fasting and standing in prayer, and keep me away from sins",
    "O Allah, grant me mercy for orphans, feeding the hungry, and spreading peace",
    "O Allah, grant me a share of Your vast mercy and guide me to Your clear proofs",
    "O Allah, make me among those who trust in You and are successful with You",
    "O Allah, make me love goodness and hate sin and disobedience",
    "O Allah, adorn me with modesty and cover me with contentment",
    "O Allah, purify me from impurities and grant me patience with Your decree",
    "O Allah, do not hold me accountable for my mistakes and forgive my sins",
    "O Allah, grant me the obedience of the humble and expand my chest",
    "O Allah, grant me success in agreeing with the righteous",
    "O Allah, guide me to righteous deeds and fulfill my needs",
    "O Allah, awaken me to the blessings of dawn and illuminate my heart",
    "O Allah, increase my share of blessings and ease my path to goodness",
    "O Allah, open for me the gates of Paradise and close the gates of Hell",
    "O Allah, make for me a guide to Your pleasure",
    "O Allah, open for me the doors of Your bounty",
    "O Allah, wash me from sins and purify me from faults",
    "O Allah, I ask You for what pleases You",
    "O Allah, make me love Your friends and oppose Your enemies",
    "O Allah, make my efforts appreciated and my sins forgiven",
    "O Allah, grant me the virtue of Laylat al-Qadr",
    "O Allah, increase my share of voluntary worship",
    "O Allah, cover me with mercy and grant me success",
    "O Allah, make my fasting accepted with gratitude",
  ];

  static const List<String> _frenchDuas = [
    "Ô Allah, fais que mon jeûne soit celui des jeûneurs et ma prière celle des prieurs",
    "Ô Allah, rapproche-moi de Ta satisfaction et éloigne-moi de Ta colère",
    "Ô Allah, accorde-moi la sagesse et la vigilance, éloigne-moi de la sottise",
    "Ô Allah, renforce-moi pour établir Ton commandement et fais-moi goûter la douceur de Ton souvenir",
    "Ô Allah, fais que je sois parmi ceux qui cherchent le pardon et Tes serviteurs pieux",
    "Ô Allah, ne m'abandonne pas à la désobéissance et ne me frappe pas de Ton châtiment",
    "Ô Allah, aide-moi dans le jeûne et la prière, éloigne-moi des péchés",
    "Ô Allah, accorde-moi la miséricorde envers les orphelins, nourrir les affamés et répandre la paix",
    "Ô Allah, accorde-moi une part de Ta vaste miséricorde et guide-moi vers Tes preuves claires",
    "Ô Allah, fais que je sois parmi ceux qui Te font confiance et réussissent auprès de Toi",
    "Ô Allah, fais-moi aimer le bien et détester le péché et la désobéissance",
    "Ô Allah, pare-moi de modestie et couvre-moi de contentement",
    "Ô Allah, purifie-moi des impuretés et accorde-moi la patience face à Ton décret",
    "Ô Allah, ne me tiens pas compte de mes erreurs et pardonne mes péchés",
    "Ô Allah, accorde-moi l'obéissance des humbles et élargis ma poitrine",
    "Ô Allah, accorde-moi le succès en étant d'accord avec les justes",
    "Ô Allah, guide-moi vers les bonnes actions et exauce mes besoins",
    "Ô Allah, réveille-moi aux bénédictions de l'aube et illumine mon cœur",
    "Ô Allah, augmente ma part de bénédictions et facilite mon chemin vers le bien",
    "Ô Allah, ouvre pour moi les portes du Paradis et ferme les portes de l'Enfer",
    "Ô Allah, fais pour moi un guide vers Ta satisfaction",
    "Ô Allah, ouvre pour moi les portes de Ta générosité",
    "Ô Allah, lave-moi des péchés et purifie-moi des défauts",
    "Ô Allah, je Te demande ce qui Te satisfait",
    "Ô Allah, fais que j'aime Tes amis et que je m'oppose à Tes ennemis",
    "Ô Allah, fais que mes efforts soient appréciés et mes péchés pardonnés",
    "Ô Allah, accorde-moi la vertu de Laylat al-Qadr",
    "Ô Allah, augmente ma part d'adoration volontaire",
    "Ô Allah, couvre-moi de miséricorde et accorde-moi le succès",
    "Ô Allah, fais que mon jeûne soit accepté avec gratitude",
  ];

  // الأدعية بالإندونيسية (مختصرة)
  static const List<String> _indonesianDuas = [
    "Ya Allah, jadikan puasaku seperti puasa orang-orang yang berpuasa",
    "Ya Allah, dekatkan aku dengan keridhaan-Mu dan jauhkan dari kemurkaan-Mu",
    "Ya Allah, berikan aku kebijaksanaan dan kewaspadaan, jauhkan dari kebodohan",
    "Ya Allah, kuatkan aku untuk menegakkan perintah-Mu dan rasakan manisnya zikir-Mu",
    "Ya Allah, jadikan aku termasuk orang yang memohon ampun dan hamba-Mu yang shaleh",
    "Ya Allah, jangan tinggalkan aku dalam ketidaktaatan dan jangan hukum aku",
    "Ya Allah, bantu aku dalam puasa dan shalat, jauhkan dari dosa-dosa",
    "Ya Allah, berikan aku rahmat untuk anak yatim, memberi makan dan menyebarkan salam",
    "Ya Allah, berikan aku bagian dari rahmat-Mu yang luas dan tunjukkan bukti-Mu",
    "Ya Allah, jadikan aku termasuk orang yang bertawakal dan berhasil dengan-Mu",
    "Ya Allah, buat aku mencintai kebaikan dan membenci dosa",
    "Ya Allah, hiasi aku dengan kesederhanaan dan tutupi dengan kepuasan",
    "Ya Allah, bersihkan aku dari kotoran dan berikan kesabaran atas takdir-Mu",
    "Ya Allah, jangan hukum aku atas kesalahanku dan ampuni dosa-dosaku",
    "Ya Allah, berikan aku ketaatan orang-orang yang rendah hati",
    "Ya Allah, berikan aku keberhasilan dalam menyetujui orang-orang shaleh",
    "Ya Allah, tunjukkan aku pada amal shaleh dan penuhi kebutuhanku",
    "Ya Allah, bangunkan aku untuk berkah fajar dan terangi hatiku",
    "Ya Allah, tingkatkan bagianku dari berkah dan mudahkan jalanku",
    "Ya Allah, bukakan pintu surga untukku dan tutup pintu neraka",
    "Ya Allah, jadikan untukku penuntun menuju keridhaan-Mu",
    "Ya Allah, bukakan pintu karunia-Mu untukku",
    "Ya Allah, basuh aku dari dosa-dosa dan bersihkan dari cacat",
    "Ya Allah, aku meminta apa yang membuat-Mu ridha",
    "Ya Allah, buat aku mencintai sahabat-Mu dan memusuhi musuh-Mu",
    "Ya Allah, jadikan usahaku dihargai dan dosaku diampuni",
    "Ya Allah, berikan aku keutamaan Lailatul Qadar",
    "Ya Allah, tingkatkan bagianku dari ibadah sunnah",
    "Ya Allah, selimuti aku dengan rahmat dan berikan keberhasilan",
    "Ya Allah, jadikan puasaku diterima dengan syukur",
  ];

  // الأدعية بالأردية (مختصرة)
  static const List<String> _urduDuas = [
    "اے اللہ، میرے روزے کو روزہ داروں کا روزہ اور میری نماز کو نمازیوں کی نماز بنا",
    "اے اللہ، مجھے اپنی رضا کے قریب کر اور اپنے غضب سے دور کر",
    "اے اللہ، مجھے عقل اور ہوشیاری عطا کر، اور بیوقوفی سے دور رکھ",
    "اے اللہ، مجھے اپنے حکم کے قائم کرنے میں مضبوط کر اور اپنے ذکر کی مٹھاس چکھا",
    "اے اللہ، مجھے بخشش مانگنے والوں اور تیرے نیک بندوں میں شامل کر",
    "اے اللہ، مجھے نافرمانی میں نہ چھوڑ اور نہ اپنے عذاب سے مار",
    "اے اللہ، روزہ اور نماز میں میری مدد کر، اور مجھے گناہوں سے بچا",
    "اے اللہ، مجھے یتیموں پر رحم، کھانا کھلانے اور سلام پھیلانے کی توفیق عطا کر",
    "اے اللہ، مجھے اپنی وسیع رحمت کا حصہ دے اور اپنی واضح نشانیوں کی طرف ہدایت دے",
    "اے اللہ، مجھے توکل کرنے والوں اور تیرے ہاں کامیاب ہونے والوں میں شامل کر",
    "اے اللہ، مجھے نیکی سے محبت اور گناہ سے نفرت عطا کر",
    "اے اللہ، مجھے حیا اور قناعت کے لباس سے آراستہ کر",
    "اے اللہ، مجھے ناپاکیوں سے پاک کر اور تیرے فیصلے پر صبر عطا کر",
    "اے اللہ، مجھے میری غلطیوں کا مواخذہ نہ کر اور میرے گناہ معاف کر",
    "اے اللہ، مجھے عاجزوں کی اطاعت اور سینے کی کشادگی عطا کر",
    "اے اللہ، مجھے نیکوکاروں کی موافقت میں کامیابی عطا کر",
    "اے اللہ، مجھے نیک اعمال کی ہدایت دے اور میری حاجتیں پوری کر",
    "اے اللہ، مجھے سحری کے برکتوں کے لیے جگا اور میرے دل کو روشنی دے",
    "اے اللہ، میرے برکتوں کے حصے میں اضافہ کر اور میرے راستے آسان کر",
    "اے اللہ، میرے لیے جنت کے دروازے کھول اور دوزخ کے دروازے بند کر",
    "اے اللہ، میرے لیے اپنی رضا کی طرف رہنما بنا",
    "اے اللہ، میرے لیے اپنے فضل کے دروازے کھول",
    "اے اللہ، مجھے گناہوں سے دھو اور عیبوں سے پاک کر",
    "اے اللہ، میں تجھ سے وہ چیز مانگتا ہوں جو تجھے راضی کرے",
    "اے اللہ، مجھے اپنے دوستوں سے محبت اور دشمنوں سے عداوت عطا کر",
    "اے اللہ، میری محنت کو مقبول اور میرے گناہوں کو معاف کر",
    "اے اللہ، مجھے لیلت القدر کی فضیلت عطا کر",
    "اے اللہ، میرے نوافل کے حصے میں اضافہ کر",
    "اے اللہ، مجھے اپنی رحمت سے ڈھانپ اور کامیابی عطا کر",
    "اے اللہ، میرے روزے کو شکر کے ساتھ قبول فرما",
  ];

  // الأدعية بالتركية (مختصرة)
  static const List<String> _turkishDuas = [
    "Allah'ım, orucumu oruç tutanların orucu, namazımı namaz kılanların namazı yap",
    "Allah'ım, beni rızana yaklaştır ve gazabından uzaklaştır",
    "Allah'ım, bana hikmet ve uyanıklık ver, aptallıktan uzak tut",
    "Allah'ım, emrini yerine getirmemde beni güçlendir ve zikrinin tadını tattır",
    "Allah'ım, beni bağışlanma dileyenlerden ve salih kullarından eyle",
    "Allah'ım, beni isyana terk etme ve cezanla vurma",
    "Allah'ım, oruç ve namazda bana yardım et, günahlardan uzak tut",
    "Allah'ım, bana yetimlere merhamet, açları doyurma ve selamı yayma nasip et",
    "Allah'ım, bana geniş rahmetinden bir pay ver ve açık delillerine yönlendir",
    "Allah'ım, beni sana tevekkül edenlerden ve başarılı olanlardan eyle",
    "Allah'ım, bana iyiliği sevdir, günah ve isyandan nefret ettir",
    "Allah'ım, beni haya ile süsle ve kanaatle ört",
    "Allah'ım, beni kirlerden temizle ve kaderine sabır ver",
    "Allah'ım, hatalarımdan dolayı beni hesaba çekme ve günahlarımı bağışla",
    "Allah'ım, bana mütevazıların itaatini ver ve göğsümü genişlet",
    "Allah'ım, salihlerle uyum içinde olmamda başarı ver",
    "Allah'ım, beni salih amellere yönlendir ve ihtiyaçlarımı karşıla",
    "Allah'ım, beni seher vaktinin bereketlerine uyandır ve kalbimi aydınlat",
    "Allah'ım, bereketlerimdeki payımı artır ve yolumumu iyiliğe kolaylaştır",
    "Allah'ım, benim için cennet kapılarını aç ve cehennem kapılarını kapat",
    "Allah'ım, benim için rızana bir rehber yap",
    "Allah'ım, benim için lütuf kapılarını aç",
    "Allah'ım, beni günahlardan yıka ve kusurlardan temizle",
    "Allah'ım, senden seni razı edecek şeyi istiyorum",
    "Allah'ım, beni dostlarını seven ve düşmanlarına karşı olanlardan eyle",
    "Allah'ım, çabamı makbul, günahımı mağfiret eyle",
    "Allah'ım, bana Kadir Gecesi'nin faziletini ver",
    "Allah'ım, nafile ibadetlerdeki payımı artır",
    "Allah'ım, beni rahmetinle ört ve başarı ver",
    "Allah'ım, orucumu şükürle kabul eyle",
  ];

  // الأدعية بالبنغالية (مختصرة)
  static const List<String> _bengaliDuas = [
    "হে আল্লাহ, আমার রোজা যেন রোজাদারদের রোজা হয় এবং আমার নামায যেন নামাযীদের নামায হয়",
    "হে আল্লাহ, আমাকে আপনার সন্তুষ্টির নিকটবর্তী করুন এবং আপনার ক্রোধ থেকে দূরে রাখুন",
    "হে আল্লাহ, আমাকে প্রজ্ঞা ও সতর্কতা দিন এবং মূর্খতা থেকে দূরে রাখুন",
    "হে আল্লাহ, আমাকে আপনার আদেশ প্রতিষ্ঠা করতে শক্তিশালী করুন এবং আপনার স্মরণের মাধুর্য আস্বাদন করান",
    "হে আল্লাহ, আমাকে ক্ষমাপ্রার্থীদের মধ্যে এবং আপনার নেক বান্দাদের মধ্যে অন্তর্ভুক্ত করুন",
    "হে আল্লাহ, আমাকে অবাধ্যতায় পরিত্যাগ করবেন না এবং আপনার শাস্তি দ্বারা আঘাত করবেন না",
    "হে আল্লাহ, রোজা ও নামাযে আমাকে সাহায্য করুন এবং পাপ থেকে দূরে রাখুন",
    "হে আল্লাহ, আমাকে এতিমদের প্রতি দয়া, ক্ষুধার্তদের খাওয়ানো এবং শান্তি ছড়ানো দান করুন",
    "হে আল্লাহ, আমাকে আপনার বিশাল রহমতের অংশ দিন এবং আপনার স্পষ্ট প্রমাণের দিকে পরিচালিত করুন",
    "হে আল্লাহ, আমাকে আপনার উপর ভরসা করা এবং আপনার নিকট সফল হওয়া ব্যক্তিদের অন্তর্ভুক্ত করুন",
    "হে আল্লাহ, আমাকে ভালোবাসা দিন এবং পাপ ও অবাধ্যতা থেকে ঘৃণা দিন",
    "হে আল্লাহ, লজ্জা দিয়ে আমাকে সজ্জিত করুন এবং তৃপ্তি দিয়ে আবৃত করুন",
    "হে আল্লাহ, আমাকে অপবিত্রতা থেকে পবিত্র করুন এবং আপনার ফয়সালায় ধৈর্য দিন",
    "হে আল্লাহ, আমাকে আমার ভুলের জন্য জবাবদিহি করবেন না এবং আমার পাপ ক্ষমা করুন",
    "হে আল্লাহ, আমাকে বিনয়ীদের আনুগত্য দিন এবং আমার বুক প্রশস্ত করুন",
    "হে আল্লাহ, আমাকে নেককারদের সাথে সামঞ্জস্য রাখতে সফলতা দিন",
    "হে আল্লাহ, আমাকে সৎ কাজের দিকে পরিচালিত করুন এবং আমার প্রয়োজন পূরণ করুন",
    "হে আল্লাহ, আমাকে ভোরের বরকতের জন্য জাগ্রত করুন এবং আমার হৃদয় আলোকিত করুন",
    "হে আল্লাহ, আমার বরকতের অংশ বৃদ্ধি করুন এবং আমার পথ সহজ করুন",
    "হে আল্লাহ, আমার জন্য জান্নাতের দরজা খুলুন এবং জাহান্নামের দরজা বন্ধ করুন",
    "হে আল্লাহ, আমার জন্য আপনার সন্তুষ্টির দিকে একটি পথপ্রদর্শক করুন",
    "হে আল্লাহ, আমার জন্য আপনার অনুগ্রহের দরজা খুলুন",
    "হে আল্লাহ, আমাকে পাপ থেকে ধুয়ে ফেলুন এবং দোষ থেকে পবিত্র করুন",
    "হে আল্লাহ, আমি আপনার কাছ থেকে এমন জিনিস চাই যা আপনাকে সন্তুষ্ট করে",
    "হে আল্লাহ, আমাকে আপনার বন্ধুদের ভালোবাসা এবং শত্রুদের বিরোধিতা করুন",
    "হে আল্লাহ, আমার প্রচেষ্টা প্রশংসিত করুন এবং আমার পাপ ক্ষমা করুন",
    "হে আল্লাহ, আমাকে লাইলাতুল কদরের মর্যাদা দিন",
    "হে আল্লাহ, আমার নফল ইবাদতের অংশ বৃদ্ধি করুন",
    "হے আল্লাহ, আমাকে আপনার রহমত দিয়ে ঢেকে দিন এবং সফলতা দিন",
    "হে আল্লাহ, আমার রোজা কৃতজ্ঞতার সাথে গ্রহণ করুন",
  ];

  // الأدعية بالملايوية (مختصرة)
  static const List<String> _malayDuas = [
    "Ya Allah, jadikan puasaku seperti puasa orang yang berpuasa",
    "Ya Allah, dekatkan aku dengan redha-Mu dan jauhkan dari murka-Mu",
    "Ya Allah, berikan aku hikmah dan kewaspadaan, jauhkan dari kebodohan",
    "Ya Allah, kuatkan aku untuk menegakkan perintah-Mu dan rasakan kemanisan zikir-Mu",
    "Ya Allah, jadikan aku termasuk orang yang memohon ampun dan hamba-Mu yang soleh",
    "Ya Allah, jangan tinggalkan aku dalam maksiat dan jangan hukum aku",
    "Ya Allah, bantu aku dalam berpuasa dan solat, jauhkan dari dosa",
    "Ya Allah, berikan aku rahmat untuk anak yatim, memberi makan dan menyebar salam",
    "Ya Allah, berikan aku bahagian dari rahmat-Mu yang luas dan tunjukkan bukti-Mu",
    "Ya Allah, jadikan aku termasuk orang yang bertawakal dan berjaya dengan-Mu",
    "Ya Allah, buat aku cinta kebaikan dan benci dosa",
    "Ya Allah, hiasi aku dengan kesopanan dan tutupi dengan kepuasan",
    "Ya Allah, bersihkan aku dari kekotoran dan berikan kesabaran atas takdir-Mu",
    "Ya Allah, jangan hukum aku atas kesalahanku dan ampunkan dosa-dosaku",
    "Ya Allah, berikan aku ketaatan orang yang rendah hati",
    "Ya Allah, berikan aku kejayaan dalam bersetuju dengan orang soleh",
    "Ya Allah, tunjukkan aku kepada amal soleh dan penuhi keperluanku",
    "Ya Allah, bangunkan aku untuk berkat subuh dan terangi hatiku",
    "Ya Allah, tingkatkan bahagianku dari berkat dan mudahkan jalanku",
    "Ya Allah, bukakan pintu syurga untukku dan tutup pintu neraka",
    "Ya Allah, jadikan untukku penunjuk ke redha-Mu",
    "Ya Allah, bukakan pintu kurnia-Mu untukku",
    "Ya Allah, basuh aku dari dosa dan bersihkan dari kecacatan",
    "Ya Allah, aku meminta apa yang membuat-Mu redha",
    "Ya Allah, buat aku cinta sahabat-Mu dan memusuhi musuh-Mu",
    "Ya Allah, jadikan usahaku dihargai dan dosaku diampuni",
    "Ya Allah, berikan aku keutamaan Lailatul Qadar",
    "Ya Allah, tingkatkan bahagianku dari ibadah sunat",
    "Ya Allah, selimuti aku dengan rahmat dan berikan kejayaan",
    "Ya Allah, jadikan puasaku diterima dengan syukur",
  ];

  // الأدعية بالفارسية (مختصرة)
  static const List<String> _persianDuas = [
    "خدایا، روزه‌ام را مانند روزه‌داران و نمازم را مانند نمازگزاران قرار بده",
    "خدایا، مرا به رضایت خود نزدیک کن و از خشم خود دور نگه دار",
    "خدایا، به من خرد و بیداری عطا کن و از نادانی دورم بدار",
    "خدایا، مرا در برپایی فرمانت نیرو بخش و شیرینی یادت را به من بچشان",
    "خدایا، مرا از استغفارکنندگان و بندگان صالحت قرار بده",
    "خدایا، مرا به نافرمانی رها مکن و با عذابت مکوب",
    "خدایا، در روزه و نمازم یاری‌ام کن و از گناهان دورم بدار",
    "خدایا، رحمت به یتیمان، اطعام غذا و گسترش سلام را به من عطا کن",
    "خدایا، به من سهمی از رحمت گسترده‌ات بده و مرا به نشانه‌های روشنت راهنمایی کن",
    "خدایا، مرا از توکل‌کنندگان و موفقان نزد خود قرار بده",
    "خدایا، نیکی را دوست و گناه و نافرمانی را دشمن من گردان",
    "خدایا، مرا با حیا بیارای و با قناعت بپوشان",
    "خدایا، از پلیدی‌ها پاکم کن و بر تقدیرت صبرم بده",
    "خدایا، مرا برای اشتباهاتم مؤاخذه مکن و گناهانم را ببخش",
    "خدایا، اطاعت فروتنان را به من عطا کن و سینه‌ام را گشاده گردان",
    "خدایا، در هماهنگی با نیکان موفقم بدار",
    "خدایا، مرا به کارهای شایسته راهنمایی کن و نیازهایم را برآورده ساز",
    "خدایا، مرا برای برکت‌های سحر بیدار کن و قلبم را روشن ساز",
    "خدایا، بهره‌ام از برکت‌ها را بیفزا و راهم را به خیر آسان گردان",
    "خدایا، درهای بهشت را به روی من بگشا و درهای دوزخ را ببند",
    "خدایا، برایم راهنمایی به سوی رضایت خود قرار بده",
    "خدایا، درهای فضل خود را به روی من بگشا",
    "خدایا، مرا از گناهان بشوی و از عیوب پاک کن",
    "خدایا، از تو چیزی می‌خواهم که تو را خشنود کند",
    "خدایا، مرا دوستدار دوستانت و دشمن دشمنانت قرار بده",
    "خدایا، تلاش‌ام را مورد تقدیر و گناهم را مورد بخشش قرار بده",
    "خدایا، فضیلت شب قدر را به من عطا کن",
    "خدایا، بهره‌ام از نوافل را بیفزا",
    "خدایا، مرا با رحمت خود بپوشان و موفقیت عطا کن",
    "خدایا، روزه‌ام را با شکر بپذیر",
  ];

  // الأدعية بالإسبانية (مختصرة)
  static const List<String> _spanishDuas = [
    "Oh Allah, haz que mi ayuno sea como el de quienes ayunan",
    "Oh Allah, acércame a Tu complacencia y alejame de Tu ira",
    "Oh Allah, concédeme sabiduría y alerta, alejame de la necedad",
    "Oh Allah, fortaléceme para establecer Tu mandamiento y déjame saborear Tu recuerdo",
    "Oh Allah, hazme de los que buscan perdón y Tus siervos justos",
    "Oh Allah, no me abandones a la desobediencia ni me golpees con Tu castigo",
    "Oh Allah, ayúdame en el ayuno y la oración, alejame de los pecados",
    "Oh Allah, concédeme misericordia para los huérfanos, alimentar al hambriento y difundir la paz",
    "Oh Allah, concédeme una parte de Tu vasta misericordia y guíame a Tus claras pruebas",
    "Oh Allah, hazme de los que confían en Ti y tienen éxito contigo",
    "Oh Allah, haz que ame el bien y odie el pecado y la desobediencia",
    "Oh Allah, adórname con modestia y cúbreme con contentamiento",
    "Oh Allah, purifícame de impurezas y concédeme paciencia con Tu decreto",
    "Oh Allah, no me responsabilices por mis errores y perdona mis pecados",
    "Oh Allah, concédeme la obediencia de los humildes y expande mi pecho",
    "Oh Allah, concédeme éxito al estar de acuerdo con los justos",
    "Oh Allah, guíame a obras rectas y satisface mis necesidades",
    "Oh Allah, despiértame a las bendiciones del amanecer e ilumina mi corazón",
    "Oh Allah, aumenta mi parte de bendiciones y facilita mi camino al bien",
    "Oh Allah, ábreme las puertas del Paraíso y cierra las puertas del Infierno",
    "Oh Allah, hazme una guía hacia Tu complacencia",
    "Oh Allah, ábreme las puertas de Tu favor",
    "Oh Allah, lávame de pecados y purifícame de defectos",
    "Oh Allah, te pido lo que Te complace",
    "Oh Allah, haz que ame a Tus amigos y me oponga a Tus enemigos",
    "Oh Allah, haz que mis esfuerzos sean apreciados y mis pecados perdonados",
    "Oh Allah, concédeme la virtud de Laylat al-Qadr",
    "Oh Allah, aumenta mi parte de adoración voluntaria",
    "Oh Allah, cúbreme con misericordia y concédeme éxito",
    "Oh Allah, haz que mi ayuno sea aceptado con gratitud",
  ];

  // الأدعية بالألمانية (مختصرة)
  static const List<String> _germanDuas = [
    "Oh Allah, mache mein Fasten wie das der Fastenden",
    "Oh Allah, bringe mich näher zu Deinem Wohlgefallen und halte mich fern von Deinem Zorn",
    "Oh Allah, gewähre mir Weisheit und Wachsamkeit, halte mich fern von Torheit",
    "Oh Allah, stärke mich, Dein Gebot aufrechtzuerhalten und lass mich die Süße Deines Gedenkens schmecken",
    "Oh Allah, mache mich zu denen, die Vergebung suchen und Deinen rechtschaffenen Dienern",
    "Oh Allah, verlasse mich nicht zum Ungehorsam und schlage mich nicht mit Deiner Strafe",
    "Oh Allah, hilf mir beim Fasten und Beten, halte mich fern von Sünden",
    "Oh Allah, gewähre mir Barmherzigkeit für Waisen, Speisung der Hungernden und Verbreitung des Friedens",
    "Oh Allah, gewähre mir einen Anteil an Deiner weitreichenden Barmherzigkeit und führe mich zu Deinen klaren Beweisen",
    "Oh Allah, mache mich zu denen, die Dir vertrauen und bei Dir Erfolg haben",
    "Oh Allah, lass mich das Gute lieben und Sünde und Ungehorsam hassen",
    "Oh Allah, schmücke mich mit Bescheidenheit und bedecke mich mit Zufriedenheit",
    "Oh Allah, reinige mich von Unreinheiten und gewähre mir Geduld mit Deinem Dekret",
    "Oh Allah, halte mich nicht für meine Fehler verantwortlich und vergib meine Sünden",
    "Oh Allah, gewähre mir den Gehorsam der Demütigen und erweitere meine Brust",
    "Oh Allah, gewähre mir Erfolg darin, mit den Rechtschaffenen übereinzustimmen",
    "Oh Allah, führe mich zu guten Taten und erfülle meine Bedürfnisse",
    "Oh Allah, wecke mich zu den Segnungen der Morgendämmerung und erleuchte mein Herz",
    "Oh Allah, erhöhe meinen Anteil an Segnungen und erleichtere meinen Weg zum Guten",
    "Oh Allah, öffne mir die Tore des Paradieses und schließe die Tore der Hölle",
    "Oh Allah, mache mir einen Führer zu Deinem Wohlgefallen",
    "Oh Allah, öffne mir die Tore Deiner Gunst",
    "Oh Allah, wasche mich von Sünden und reinige mich von Fehlern",
    "Oh Allah, ich bitte Dich um das, was Dich zufriedenstellt",
    "Oh Allah, lass mich Deine Freunde lieben und mich Deinen Feinden widersetzen",
    "Oh Allah, lass meine Bemühungen geschätzt und meine Sünden vergeben werden",
    "Oh Allah, gewähre mir die Tugend der Lailat al-Qadr",
    "Oh Allah, erhöhe meinen Anteil an freiwilliger Anbetung",
    "Oh Allah, bedecke mich mit Barmherzigkeit und gewähre mir Erfolg",
    "Oh Allah, lass mein Fasten mit Dankbarkeit angenommen werden",
  ];

  // الأدعية بالصينية (مختصرة)
  static const List<String> _chineseDuas = [
    "安拉啊，让我的斋戒如同斋戒者的斋戒",
    "安拉啊，让我接近你的喜悦，远离你的愤怒",
    "安拉啊，赐我智慧和警觉，使我远离愚昧",
    "安拉啊，加强我执行你的命令，让我品尝你纪念的甜美",
    "安拉啊，使我成为寻求宽恕者和你正直的仆人",
    "安拉啊，不要让我陷入不顺从，不要用你的惩罚打击我",
    "安拉啊，在斋戒和礼拜中帮助我，使我远离罪恶",
    "安拉啊，赐我怜悯孤儿、施舍食物和传播和平",
    "安拉啊，赐我你广阔仁慈的一份，指引我到你明确的证据",
    "安拉啊，使我成为信赖你并在你那里成功的人",
    "安拉啊，让我热爱善行，憎恶罪恶和悖逆",
    "安拉啊，以谦逊装饰我，以知足覆盖我",
    "安拉啊，净化我脱离污秽，赐我耐心面对你的判决",
    "安拉啊，不要因我的错误而责问我，宽恕我的罪过",
    "安拉啊，赐我谦卑者的顺从，开阔我的胸怀",
    "安拉啊，赐我在赞同善良者方面取得成功",
    "安拉啊，引导我行善，满足我的需求",
    "安拉啊，唤醒我迎接黎明的祝福，照亮我的心",
    "安拉啊，增加我的福分，使我的道路顺畅",
    "安拉啊，为我打开天堂之门，关闭地狱之门",
    "安拉啊，为我设置通往你喜悦的向导",
    "安拉啊，为我打开你恩惠之门",
    "安拉啊，洗净我的罪过，净化我的缺陷",
    "安拉啊，我向你祈求使你喜悦的事物",
    "安拉啊，让我热爱你的朋友，反对你的敌人",
    "安拉啊，让我的努力受到赞赏，我的罪过得到宽恕",
    "安拉啊，赐我盖德尔夜的尊贵",
    "安拉啊，增加我副功拜的份额",
    "安拉啊，用仁慈覆盖我，赐我成功",
    "安拉啊，让我的斋戒带着感恩被接受",
  ];
}
