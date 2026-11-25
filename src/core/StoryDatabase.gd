class_name StoryDatabase
extends RefCounted

## StoryDatabase — Centralized Bilingual Narrative Repository
## Stores cutscene lines, prologues, epilogues, and boss dialogues in English ('en') and Indonesian ('id').

# ==============================================================================
# UNIVERSAL STORY PROLOGUE (11 PANELS)
# ==============================================================================

const UNIVERSAL_PROLOGUE_DATA: Array[Dictionary] = [
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 1.jpg",
			"res://assets/Scene/cerita_fallen/prologue_01.jpg",
			"res://assets/Scene/cerita_fallen/prologue_01.png"
		],
		"title_en": "1. A WORLD IN CHAOS",
		"title_id": "1. DUNIA DALAM KEKACAUAN",
		"text_en": "\"A world in chaos... This realm has long been without a ruler.\"",
		"text_id": "\"Dunia dalam kekacauan... Alam ini telah lama kehilangan sang penguasa.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 2.jpg",
			"res://assets/Scene/cerita_fallen/prologue_02.jpg",
			"res://assets/Scene/cerita_fallen/prologue_02.png"
		],
		"title_en": "2. A PERSISTING LEGEND",
		"title_id": "2. SEBUAH LEGENDA ABADI",
		"text_en": "\"Yet, a legend persists.\"",
		"text_id": "\"Namun, sebuah legenda purba tetap bertahan melintasi zaman.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 3.jpg",
			"res://assets/Scene/cerita_fallen/prologue_03.jpg",
			"res://assets/Scene/cerita_fallen/prologue_03.png"
		],
		"title_en": "3. THE FALLEN",
		"title_id": "3. TAKHTA THE FALLEN",
		"text_en": "\"A legendary seat of power... known only as The Fallen.\"",
		"text_id": "\"Sebuah takhta kekuasaan legendaris... yang hanya dikenal sebagai The Fallen.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 4.jpg",
			"res://assets/Scene/cerita_fallen/prologue_04.jpg",
			"res://assets/Scene/cerita_fallen/prologue_04.png"
		],
		"title_en": "4. AN ANCIENT MYTH",
		"title_id": "4. MITOS PURBA",
		"text_en": "\"It is whispered that whoever sits upon it shall be granted absolute power... and the unconditional fulfillment of their deepest ambitions.\"",
		"text_id": "\"Dikisahkan bahwa barang siapa yang berhasil mendudukinya akan dianugerahi kekuatan mutlak... dan pengabulan tanpa syarat atas ambisi terdalam mereka.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 5.jpg",
			"res://assets/Scene/cerita_fallen/prologue_05.jpg",
			"res://assets/Scene/cerita_fallen/prologue_05.png"
		],
		"title_en": "5. AND SO THEY CAME",
		"title_id": "5. MAKA MEREKA PUN DATANG",
		"text_en": "\"Challengers from every corner of a shattered world. They are known as... The Claimants.\"",
		"text_id": "\"Para penantang dari setiap sudut dunia yang hancur. Mereka dikenal sebagai... The Claimants.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 6.jpg",
			"res://assets/Scene/cerita_fallen/prologue_06.jpg",
			"res://assets/Scene/cerita_fallen/prologue_06.png"
		],
		"title_en": "6. THE FLOATING ARENA",
		"title_id": "6. ARENA MELAYANG",
		"text_en": "\"They gather upon a brutal, floating arena.\"",
		"text_id": "\"Mereka berkumpul di atas arena melayang yang brutal dan tanpa ampun.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 7.jpg",
			"res://assets/Scene/cerita_fallen/prologue_07.jpg",
			"res://assets/Scene/cerita_fallen/prologue_07.png"
		],
		"title_en": "7. WHERE STRENGTH RULES",
		"title_id": "7. HUKUM KEKUATAN",
		"text_en": "\"A ruler is not chosen by bloodlines or morality, but by close-combat skill, precision, and the will to survive on the platform.\"",
		"text_id": "\"Seorang penguasa tidak dipilih oleh garis darah atau moralitas, melainkan oleh keahlian bertarung jarak dekat, presisi, dan tekad bertahan hidup di atas platform.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 8.jpg",
			"res://assets/Scene/cerita_fallen/prologue_08.jpg",
			"res://assets/Scene/cerita_fallen/prologue_08.png"
		],
		"title_en": "8. TO FALL IS THE END",
		"title_id": "8. JATUH ADALAH KEMATIAN",
		"text_en": "\"One mistake, one misstep, can cast a fighter into the endless void... the Death Zone.\"",
		"text_id": "\"Satu kesalahan, satu langkah ceroboh, dapat melempar petarung ke dalam jurang kehampaan abadi... sang Death Zone.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 9.png",
			"res://assets/Scene/cerita_fallen/prologue_09.jpg",
			"res://assets/Scene/cerita_fallen/prologue_09.png"
		],
		"title_en": "9. MANY AMBITIONS",
		"title_id": "9. BERBAGAI AMBISI",
		"text_en": "\"They fight for no single cause. Each Claimant carries their past, their purpose... and their own dark ambitions.\"",
		"text_id": "\"Mereka bertarung bukan demi satu tujuan yang sama. Setiap Claimant memikul masa lalu mereka, tujuan mereka... dan ambisi gelap mereka masing-masing.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 10.jpg",
			"res://assets/Scene/cerita_fallen/prologue_10.jpg",
			"res://assets/Scene/cerita_fallen/prologue_10.png"
		],
		"title_en": "10. ONE THRONE",
		"title_id": "10. SATU TAKHTA",
		"text_en": "\"One throne... So many ambitions.\"",
		"text_id": "\"Satu takhta... begitu banyak ambisi yang saling berbenturan.\""
	},
	{
		"paths": [
			"res://assets/Scene/cerita_fallen/cutscene 11.jpg",
			"res://assets/Scene/cerita_fallen/prologue_11.jpg",
			"res://assets/Scene/cerita_fallen/prologue_11.png"
		],
		"title_en": "11. THE THRONE HAS FALLEN",
		"title_id": "11. TAKHTA TELAH JATUH",
		"text_en": "\"In this world, power is never inherited. It is seized.\"",
		"text_id": "\"Di dunia ini, kekuasaan tak pernah diwariskan. Kekuasaan... harus direbut!\""
	}
]

static func get_universal_prologue(locale: String = "en") -> Array[Dictionary]:
	var is_id := (locale.to_lower().strip_edges() == "id")
	var result: Array[Dictionary] = []
	for item in UNIVERSAL_PROLOGUE_DATA:
		result.append({
			"paths": item["paths"],
			"title": item["title_id"] if is_id else item["title_en"],
			"text": item["text_id"] if is_id else item["text_en"]
		})
	return result

# ==============================================================================
# CHARACTER PROLOGUES DATA
# ==============================================================================

const CHARACTER_PROLOGUES: Dictionary = {
	"aron": [
		{
			"paths": ["res://assets/Scene/aron_story/aron_prologue_01.jpg", "res://assets/characters/aron/raw/aron idle.jpg"],
			"speaker_role": "aron",
			"speaker_en": "ARON",
			"speaker_id": "ARON",
			"text_en": "\"Every morning I wake up at 5 AM, wrap my hands, and pound the heavy bag until my knuckles are numb. On my bedroom wall, the gaze of these anime action heroes always reminds me... that a grand destiny awaits.\"",
			"text_id": "\"Setiap pagi aku bangun jam lima, memasang handwrap, dan memukul samsak sampai buku jariku kebas. Di dinding kamarku, tatapan para pahlawan anime laga ini selalu mengingatkanku... bahwa takdir besar sedang menungguku.\""
		},
		{
			"paths": ["res://assets/Scene/aron_story/aron_prologue_02.jpg", "res://assets/characters/aron/raw/aron hit 1.jpg"],
			"speaker_role": "warga",
			"speaker_en": "TOWNSMAN",
			"speaker_id": "PEMUDA / WARGA",
			"text_en": "\"Hahaha! Look at Aron, still playing boxer all by himself with those thick nerdy glasses! Wake up, kid, you're just an awkward nerd who watched too many cartoons!\"",
			"text_id": "\"Hahaha! Lihat si Aron, masih saja main tinju-tinjuan sendirian pakai kacamata tebal itu! Sadar diri woy, kau itu cuma anak culun yang kebanyakan nonton kartun!\""
		},
		{
			"paths": ["res://assets/Scene/aron_story/aron_prologue_02.jpg", "res://assets/characters/aron/raw/aron hit 1.jpg"],
			"speaker_role": "aron",
			"speaker_en": "ARON",
			"speaker_id": "ARON",
			"text_en": "\"(Clenching fists, staring down bitterly) 'They mock me. Years of grueling training brushed off as a joke, my sweat labeled as cheap delusion. Not a single person cares to see who I truly am...'\"",
			"text_id": "\"(Mengepalkan tangan, menunduk getir) 'Mereka menertawakanku. Latihan keras bertahun-tahun dianggap lelucon, dan keringatku dicap delusi murahan. Tak seorang pun mau melihat siapa aku sebenarnya...'\""
		},
		{
			"paths": ["res://assets/Scene/aron_story/aron_prologue_03.jpg", "res://assets/characters/aron/raw/aron hit 3.jpg"],
			"speaker_role": "aron",
			"speaker_en": "ARON",
			"speaker_id": "ARON",
			"text_en": "\"Fine then. If this world considers me crazy, then I'll seize that throne and prove to every last one of you... that I am the main protagonist!\"",
			"text_id": "\"Baiklah. Kalau dunia menganggapku gila, maka aku akan rebut takhta itu dan membuktikan pada kalian semua... bahwa akulah sang karakter utama!\""
		}
	],
	"mike": [
		{
			"paths": ["res://assets/Scene/mike_story/mike_prologue_01.jpg", "res://assets/Scene/mike_story/mike_prologue_01.png", "res://assets/characters/mike/raw/mike idle.jpg"],
			"speaker_role": "mike",
			"speaker_en": "MIKE",
			"speaker_id": "MIKE",
			"text_en": "\"Four agonizing years... hundreds of cheap instant coffees, thirteen brutal revisions on chapter four, and thousands of sleepless hours sacrificed. Today, this thick hardbound thesis draft is finally bound. Just one more step toward my graduation cap and sweet freedom.\"",
			"text_id": "\"Empat tahun... ratusan cangkir kopi sachet, revisi bab empat sebanyak tiga belas kali, dan ribuan jam tidur yang kukorbankan. Hari ini, draf skripsi bersampul tebal ini akhirnya selesai dijilid rapi. Tinggal selangkah lagi menuju toga dan kebebasan.\""
		},
		{
			"paths": ["res://assets/Scene/mike_story/mike_prologue_02.jpg", "res://assets/Scene/mike_story/mike_prologue_02.png", "res://assets/characters/mike/raw/mike hit 1.jpg"],
			"speaker_role": "warga",
			"speaker_en": "CAMPUS OFFICER",
			"speaker_id": "PETUGAS KAMPUS",
			"text_en": "\"We deeply regret to inform you, Mr. Mike. Because the 3rd floor defense hall was crushed by rogue Fallen tournament fighters, your exam schedule is cancelled. Per university policy, you must pay tuition for semester nine by tomorrow morning, or face immediate Academic Dismissal.\"",
			"text_id": "\"Mohon maaf, Saudara Mike. Karena ruang sidang lantai tiga hancur tertimpa petarung liar turnamen Fallen, jadwal ujian Anda dibatalkan. Sesuai regulasi sistem, Anda wajib membayar UKT semester sembilan besok pagi, atau status Anda resmi Drop Out.\""
		},
		{
			"paths": ["res://assets/Scene/mike_story/mike_prologue_03.jpg", "res://assets/Scene/mike_story/mike_prologue_03.png", "res://assets/characters/mike/raw/mike hit 3.jpg"],
			"speaker_role": "mike",
			"speaker_en": "MIKE",
			"speaker_id": "MIKE",
			"text_en": "\"(Gripping the iron frame of a classroom folding chair and hoisting it onto his shoulder) 'Four years of pulling all-nighters, and now you want to drop me out just like that?! To hell with your campus bureaucracy! If the Fallen Throne grants any desire... then this folding chair is going to flatten anyone up there for my graduation diploma!'\"",
			"text_id": "\"(Mencengkeram kerangka besi kursi lipat kuliah dan menyandarkannya di pundak) 'Empat tahun begadang, dan sekarang kalian mau DO-kan aku begitu saja?! Persetan dengan birokrasi kampus! Kalau Takhta Fallen bisa mengabulkan apa saja... maka kursi lipat ini yang akan meratakan siapa pun di atas sana demi ijazah kelulusanku!'\""
		}
	],
	"rin": [
		{
			"paths": ["res://assets/Scene/rin_story/rin_prologue_01.jpg", "res://assets/Scene/rin_story/rin_prologue_01.png", "res://assets/characters/rin/raw/Rin idle.jpg"],
			"speaker_role": "rin",
			"speaker_en": "RIN",
			"speaker_id": "RIN",
			"text_en": "\"From dawn till dusk, my fingers were trained only to spin thread and gaze upon the same wooden floorboards. They said a woman's highest horizon is bounded by the walls of this household... Yet through the window, I have always heard the call of the boundless heavens.\"",
			"text_id": "\"Dari fajar hingga senja, jemariku diajarkan hanya untuk memintal benang dan menatap lantai kayu yang sama. Mereka bilang batas tertinggi seorang perempuan adalah dinding rumah ini... Tapi dari balik jendela, aku selalu mendengar panggilan langit yang tak bertepi.\""
		},
		{
			"paths": ["res://assets/Scene/rin_story/rin_prologue_02.jpg", "res://assets/Scene/rin_story/rin_prologue_02.png", "res://assets/characters/rin/raw/Rin hit 1.jpg"],
			"speaker_role": "warga",
			"speaker_en": "TRIBAL ELDER",
			"speaker_id": "TETUA ADAT",
			"text_en": "\"Halt right there, Rin! You dare carry your footsteps toward the outer arenas?! Your place is weaving garments, not spilling blood in filthy combat! The sacred customs of this clan will never be disgraced by an insubordinate like you!\"",
			"text_id": "\"Berhenti di situ, Rin! Kau berani membawa langkahmu ke gelanggang luar?! Tempatmu adalah merajut kain, bukan menumpahkan darah di arena pertarungan kotor! Tradisi keluarga ini pantang dinodai oleh pembangkang sepertimu!\""
		},
		{
			"paths": ["res://assets/Scene/rin_story/rin_prologue_03.jpg", "res://assets/Scene/rin_story/rin_prologue_03.png", "res://assets/characters/rin/raw/Rin hit 2.jpg"],
			"speaker_role": "rin",
			"speaker_en": "RIN",
			"speaker_id": "RIN",
			"text_en": "\"(Unlocking her grandmother's heirloom chest, glowing with the radiance of a cosmic nebula) 'You weave threads solely to bind our wings... but grandmother bequeathed this fabric to set me free. If your tradition breeds only cages, then with this celestial shawl, I shall weave my own destiny!'\"",
			"text_id": "\"(Membuka peti rahasia pusaka neneknya yang memancarkan pendar nebula kosmik) 'Kalian menenun benang hanya untuk membelenggu sayap kami... tapi nenek mewariskan kain ini untuk membebaskanku. Jika tradisi kalian hanya melahirkan sangkar, maka dengan selendang bintang ini, aku sendiri yang akan menenun takdirku!'\""
		},
		{
			"paths": ["res://assets/Scene/rin_story/rin_prologue_04.jpg", "res://assets/Scene/rin_story/rin_prologue_04.png", "res://assets/characters/rin/raw/Rin hit 3.jpg"],
			"speaker_role": "rin",
			"speaker_en": "RIN",
			"speaker_id": "RIN",
			"text_en": "\"(The ancestral shawl gently wraps her hands, pulsing with blazing cosmic luminescence) 'The bonds of tradition end here today. With this sacred shawl, none shall ever dictate the limits of my stride. Throne of The Fallen... I am coming to claim you!'\"",
			"text_id": "\"(Selendang leluhur melilit lembut di tangannya memancarkan pendar energi kosmik yang membara) 'Ikatan tradisi ini resmi berakhir. Dengan selendang pusaka ini, tak ada lagi yang bisa mendikte batas langkahku. Takhta The Fallen... aku datang untuk merebutmu!'\""
		}
	],
	"muslan": [
		{
			"paths": ["res://assets/Scene/muslan_story/muslan_prologue_01.jpg", "res://assets/characters/muslan/raw/muslan idle.jpg"],
			"speaker_role": "muslan",
			"speaker_en": "MUSLAN",
			"speaker_id": "MUSLAN",
			"text_en": "\"To me, music is never just an arrangement of notes... it is the breath and honest truth of life. On this wooden stage scented by the salty sea breeze, playing for humble souls who listen with open hearts, I know my songs truly have a soul.\"",
			"text_id": "\"Bagiku, musik bukan sekadar susunan nada... tapi napas dan kejujuran hidup. Di panggung kayu beraroma asin laut ini, di hadapan orang-orang sederhana yang mendengarkan dengan hati, aku merasa laguku benar-benar memiliki jiwa.\""
		},
		{
			"paths": ["res://assets/Scene/muslan_story/muslan_prologue_02.jpg", "res://assets/characters/muslan/raw/muslan hit 1.jpg"],
			"speaker_role": "warga",
			"speaker_en": "RECORD PRODUCER",
			"speaker_id": "PRODUSER REKAMAN",
			"text_en": "\"Take this garbage back home, Beach Boy! Your lyrics are too idealistic and your arrangement is backwards, zero commercial value in this business! The market only buys instant pop hooks, not the poetic whining of a glorified busker!\"",
			"text_id": "\"Bawa pulang sampah ini, Anak Pantai! Lirikmu terlalu idealis dan aransemenmu kampungan, tidak ada nilai jualnya di industri! Pasar hanya butuh lagu pop instan, bukan rintihan sok puitis dari pengamen!\""
		},
		{
			"paths": ["res://assets/Scene/muslan_story/muslan_prologue_03.jpg", "res://assets/characters/muslan/raw/muslan hit 3.jpg"],
			"speaker_role": "muslan",
			"speaker_en": "MUSLAN",
			"speaker_id": "MUSLAN",
			"text_en": "\"(Tightening the strap of his guitar hardcase over his shoulder) 'If your corporate industry ears are too deaf to hear the truth... then I'll take the Throne of The Fallen. I'll turn this entire universe into my private arena, and all of you will have no choice but to listen!'\"",
			"text_id": "\"(Mengencangkan tali hardcase gitarnya di pundak) 'Jika telinga industri kalian terlalu tuli untuk mendengar kejujuran... maka aku akan menduduki Takhta The Fallen. Kan kujadikan seluruh semesta ini panggung pribadiku, dan kalian semua dipaksa untuk mendengarkan!'\""
		}
	],
	"kemet": [
		{
			"paths": ["res://assets/Scene/kemet_story/kemet_prologue_01.jpg", "res://assets/Scene/kemet_story/cutscene Kemet 1.jpg"],
			"speaker_role": "kemet",
			"speaker_en": "KEMET",
			"speaker_id": "KEMET",
			"text_en": "\"Submerged in the silence of this glowing green fluid, I had no name... only test subject designation K-07. Cold hydraulic machines relentlessly injected mutagen into my bloodstream, forcing my evolution into a biological weapon on demand.\"",
			"text_id": "\"Di dalam keheningan cairan hijau ini, aku tidak punya nama... hanya nomor subjek K-07. Mesin-mesin dingin ini terus menyuntikkan serum ke urat nadiku, memaksaku bermutasi menjadi senjata hidup pesanan mereka.\""
		},
		{
			"paths": ["res://assets/Scene/kemet_story/kemet_prologue_02.jpg", "res://assets/Scene/kemet_story/cutscene Kemet 2.jpg"],
			"speaker_role": "warga",
			"speaker_en": "LAB ALARM SYSTEM",
			"speaker_id": "SISTEM ALARM LAB",
			"text_en": "\"WARNING! Genetic mutation K-07 is highly unstable! Bio-metallic claws rejecting neural control override! Subject designated as 'FAILED DEFECT', engage containment purge protocols immediately!\"",
			"text_id": "\"PERINGATAN! Mutasi genetik K-07 tidak stabil! Cakar bio-metalik menolak kode kendali! Subjek dicap 'PRODUK GAGAL', aktifkan protokol pemusnahan sekarang juga!\""
		},
		{
			"paths": ["res://assets/Scene/kemet_story/kemet_prologue_02.jpg", "res://assets/Scene/kemet_story/cutscene Kemet 2.jpg"],
			"speaker_role": "kemet",
			"speaker_en": "KEMET",
			"speaker_id": "KEMET",
			"text_en": "\"(The glass canister shatters explosively! Kemet bares savage fangs in a bloodthirsty grin) 'Failed defect?! You grafted these fangs and claws onto my flesh, and now you cower before your own creation?! From this heartbeat forward, I am no lab rat... I am the apex predator!'\"",
			"text_id": "\"(Kaca tabung meledak hancur! Kemet menyeringai buas memperlihatkan taringnya) 'Produk gagal?! Kalian yang menanamkan taring dan cakar ini ke tubuhku, dan sekarang kalian takut melihat ciptaan kalian sendiri?! Mulai detik ini, aku bukan kelinci percobaan... akulah pemangsa puncak!'\""
		},
		{
			"paths": ["res://assets/Scene/kemet_story/kemet_prologue_03.png", "res://assets/Scene/kemet_story/cutscene Kemet 3.png", "res://assets/Scene/kemet_story/kemet_prologue_03.jpg"],
			"speaker_role": "kemet",
			"speaker_en": "KEMET",
			"speaker_id": "KEMET",
			"text_en": "\"(Gazing toward the skyborne colosseum vortex of The Fallen, flexing his crimson-veined claws) 'They whisper that above the clouds lies a throne granting absolute dominance to the sole survivor. That throne shall be the pinnacle of my food chain!'\"",
			"text_id": "\"(Menatap ke arah pusaran koloseum langit The Fallen sambil mencengkeram cakar berurat merahnya) 'Kudengar di atas sana ada singgasana yang menjanjikan kuasa mutlak bagi siapa pun yang bertahan hidup. Takhta itu akan kujadikan puncak rantai makananku!'\""
		}
	],
	"butler": [
		{
			"paths": ["res://assets/Scene/butler_story/butler_prologue_01.jpg", "res://assets/Scene/butler_story/Cutscene Butler 1.jpg"],
			"speaker_role": "butler",
			"speaker_en": "BUTLER",
			"speaker_id": "BUTLER",
			"text_en": "\"Impeccable courtesy, flawless flavor, and uncompromised devotion. For countless years, I poured my very soul into every droplet of cocktail behind this polished marble counter. Patrons praised my elegance... and I was naive enough to believe dedication was valued.\"",
			"text_id": "\"Keramahan, ketepatan rasa, dan dedikasi tanpa cela. Selama bertahun-tahun, aku menuangkan jiwa ke dalam setiap tetes koktail di balik meja bar marmer ini. Semua tamu memuji keanggunanku... dan aku mengira kerja keras ini dihargai.\""
		},
		{
			"paths": ["res://assets/Scene/butler_story/butler_prologue_02.jpg", "res://assets/Scene/butler_story/Cutscene butler 2.jpg"],
			"speaker_role": "warga",
			"speaker_en": "BAR OWNER",
			"speaker_id": "PEMILIK BAR",
			"text_en": "\"You're fired, Butler! Starting tomorrow, my nephew takes your station. Severance pay? Don't make me laugh! You're nothing more than an easily replaced domestic servant. Grab your used towel and get the hell out of my establishment!\"",
			"text_id": "\"Kau dipecat, Butler! Mulai besok ada keponakanku yang menggantikan posisimu. Pesangon? Jangan bermimpi! Kau itu cuma pelayan rendahan yang gampang diganti. Ambil serbet bekasmu dan enyah dari tempatku!\""
		},
		{
			"paths": ["res://assets/Scene/butler_story/butler_prologue_03.png", "res://assets/Scene/butler_story/Cutscene butler 3.png", "res://assets/Scene/butler_story/butler_prologue_03.jpg"],
			"speaker_role": "butler",
			"speaker_en": "BUTLER",
			"speaker_id": "BUTLER",
			"text_en": "\"(Gazing upon the cloth napkin draped over his arm as it suddenly ignites in a vortex of aristocratic flame) 'Elegance without power is mere slave's futility. If serving ungrateful masters yields only humiliation, then I shall claim the Throne of The Fallen. From this day forward, the entire universe shall serve me!'\"",
			"text_id": "\"(Menatap serbet kain di lengannya yang tiba-tiba meluap dalam pusaran api magis) 'Keanggunan tanpa kekuasaan hanyalah kesia-siaan seorang budak. Jika melayani manusia tamak hanya berujung penghinaan, maka aku akan menduduki Takhta The Fallen. Mulai hari ini, seluruh semesta yang akan melayaniku!'\""
		}
	],
	"om_hami": [
		{
			"paths": ["res://assets/Scene/om_hami_story/om_hami_prologue_01.jpg", "res://assets/Scene/om_hami_story/Gemini_Generated_Image_f8jpl7f8jpl7f8jp.jpg"],
			"speaker_role": "om_hami",
			"speaker_en": "OM HAMI",
			"speaker_id": "OM HAMI",
			"text_en": "\"A piping hot glass of black coffee, a hand-rolled clove cigarette, and a serene night breeze. For an old-timer like me, the most sacred duty is making sure the neighborhood kids can sleep peacefully without fear.\"",
			"text_id": "\"Segelas kopi hitam panas, sebatang rokok, dan angin malam yang tenang. Bagi orang seusiaku, tugas paling berharga adalah memastikan anak-anak kampung bisa tidur nyenyak tanpa rasa takut.\""
		},
		{
			"paths": ["res://assets/Scene/om_hami_story/om_hami_prologue_02.jpg", "res://assets/Scene/om_hami_story/Gemini_Generated_Image_eja2oyeja2oyeja2.jpg"],
			"speaker_role": "warga",
			"speaker_en": "TOWNSMAN",
			"speaker_id": "WARGA KAMPUNG",
			"text_en": "\"Disaster, Om Hami! Two bizarre fighters are beating each other senseless in the front alley! The food carts are smashed to splinters, neighborhood fences are torn down! They won't stop!\"",
			"text_id": "\"Gawat, Om Hami! Ada dua makhluk misterius saling hantam di gang depan! Gerobak dagangan warga hancur lebur, pagar rumah roboh semua! Mereka tidak mau berhenti!\""
		},
		{
			"paths": ["res://assets/Scene/om_hami_story/om_hami_prologue_03.png", "res://assets/Scene/om_hami_story/Pixel Warrior Beneath the Crimson Arena.png", "res://assets/Scene/om_hami_story/om_hami_prologue_03.jpg"],
			"speaker_role": "om_hami",
			"speaker_en": "OM HAMI",
			"speaker_id": "OM HAMI",
			"text_en": "\"(Drawing a deep, crackling drag from his clove cigarette and resting his wooden patrol club on his shoulder) 'Way past 10 PM and still making a ruckus smashing people's market stalls? In this neighborhood, rules are rules. Time for me to discipline that throne myself!'\"",
			"text_id": "\"(Mengisap rokoknya dalam-dalam sambil menyandarkan tongkat kayu ronda di pundaknya) 'Sudah lewat jam sepuluh malam masih bikin onar sampai merusak lapak warga. Di kampung ini aturan tetap aturan. Waktunya takhta itu kutertibkan sendiri!'\""
		}
	],
	"sunkibo": [
		{
			"paths": ["res://assets/Scene/sunkibo_story/sunkibo_prologue_01.jpg", "res://assets/Scene/sunkibo_story/Gemini_Generated_Image_w9l5d9w9l5d9w9l5.jpg"],
			"speaker_role": "sunkibo",
			"speaker_en": "SUNKIBO",
			"speaker_id": "SUNKIBO",
			"text_en": "\"Spending the day napping on celestial clouds, feasting on sweet peaches, and enjoying the heavenly breeze. To me, life up in paradise was peaceful enough... before those decrepit gods opened their haughty mouths.\"",
			"text_id": "\"Menghabiskan hari dengan tidur siang di atas awan, makan buah persik manis, dan menikmati semilir angin surgawi. Bagiku, hidup di kahyangan ini sudah cukup damai... sebelum para dewa tua itu mulai membuka mulut.\""
		},
		{
			"paths": ["res://assets/Scene/sunkibo_story/sunkibo_prologue_02.jpg", "res://assets/Scene/sunkibo_story/Gemini_Generated_Image_6fzxya6fzxya6fzx.jpg"],
			"speaker_role": "warga",
			"speaker_en": "CELESTIAL GOD",
			"speaker_id": "DEWA KAHYANGAN",
			"text_en": "\"Hahaha! Look at Sun Wukong's little runt descendant! Wearing those nerdy glasses and doing nothing but slacking off! He is nothing but a family disgrace without an ounce of divine martial talent!\"",
			"text_id": "\"Hahaha! Lihatlah kera kecil keturunan Sun Wukong itu. Memakai kacamata culun dan hanya bisa bermalas-malasan! Dia hanyalah aib keluarga yang tidak punya bakat sedikit pun!\""
		},
		{
			"paths": ["res://assets/Scene/sunkibo_story/sunkibo_prologue_03.png", "res://assets/Scene/sunkibo_story/Sunkibo_ Golden Cloud Warrior.png", "res://assets/Scene/sunkibo_story/sunkibo_prologue_03.jpg"],
			"speaker_role": "sunkibo",
			"speaker_en": "SUNKIBO",
			"speaker_id": "SUNKIBO",
			"text_en": "\"(Resting his golden staff playfully across his shoulders with a cheeky grin) 'Keep glorifying my great-grandpa all you want! If the heavens are too arrogant to recognize my greatness... then I'll seize the Throne of The Fallen and make every last one of you bow down to me!'\"",
			"text_id": "\"(Menyandarkan tongkat saktinya di pundak, menyeringai nakal penuh percaya diri) 'Terus saja kalian memuji kakek buyutku! Jika langit ini terlalu sombong untuk melihatku... maka aku akan rebut Takhta The Fallen dan memaksa kalian semua menunduk padaku!'\""
		}
	]
}

static func get_character_prologue(character_id: String, locale: String = "en") -> Array[Dictionary]:
	var key := _normalize_character_id(character_id)
	var is_id := (locale.to_lower().strip_edges() == "id")
	var raw_list: Array = CHARACTER_PROLOGUES.get(key, CHARACTER_PROLOGUES["aron"])
	var result: Array[Dictionary] = []
	for item in raw_list:
		result.append({
			"paths": item["paths"],
			"speaker": item["speaker_id"] if is_id else item["speaker_en"],
			"speaker_color": get_speaker_color(item["speaker_role"]),
			"text": item["text_id"] if is_id else item["text_en"]
		})
	return result

# ==============================================================================
# CHARACTER EPILOGUES DATA
# ==============================================================================

const CHARACTER_EPILOGUES: Dictionary = {
	"aron": [
		{
			"paths": ["res://assets/Scene/aron_story/aron_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With one final, earth-shattering blow that echoed through the quiet colosseum, the ancient ruler was cast down into the endless void.\"",
			"text_id": "\"Dengan satu dentuman tinju terakhir yang memecah hening koloseum, sang penguasa purba terhempas ke jurang ketiadaan.\""
		},
		{
			"paths": ["res://assets/Scene/aron_story/aron_epilogue_02.jpg", "res://assets/Scene/cerita_fallen/cutscene 11.jpg"],
			"speaker_role": "aron",
			"speaker_en": "ARON",
			"speaker_id": "ARON",
			"text_en": "\"Take a good look, world. The background extra you all looked down upon... now holds the fate of everyone in his hands.\"",
			"text_id": "\"Lihat ini, dunia. Figuran yang dulu kalian remehkan... sekarang memegang takdir kalian semua.\""
		}
	],
	"mike": [
		{
			"paths": ["res://assets/Scene/mike_story/mike_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With a thunderous crash of the iron folding chair echoing across the entire cosmos, the ancient form of The First Fallen shattered into dust and tumbled into oblivion.\"",
			"text_id": "\"Dengan satu hantaman kursi lipat besi yang menggema ke seluruh semesta, wujud purba The First Fallen hancur lebur dan terhempas ke jurang ketiadaan.\""
		},
		{
			"paths": ["res://assets/Scene/mike_story/mike_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "mike",
			"speaker_en": "MIKE",
			"speaker_id": "MIKE",
			"text_en": "\"(Seated on the Fallen throne, leaning against his dust-covered steel chair) 'Hear this, universe! By the absolute sovereign power of this throne... my thesis is officially PASSED Magna Cum Laude with zero revisions, and campus administration is hereby dissolved!'\"",
			"text_id": "\"(Duduk di takhta Fallen sambil menyandarkan kursi besi berlumur debu) 'Dengar ini, semesta! Dengan kuasa mutlak takhta ini... skripsiku resmi LULUS predikat Dengan Pujian tanpa revisi, dan birokrasi kampus resmi kububarkan!'\""
		}
	],
	"rin": [
		{
			"paths": ["res://assets/Scene/rin_story/rin_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"The radiant nebula vortex of Rin's cosmic shawl cleaved the heavens with absolute grace. Cast down from his throne, the ancient sovereign shattered and was buried deep within the abyssal void.\"",
			"text_id": "\"Pusaran cahaya nebula selendang kosmik Rin membelah angkasa dengan keanggunan mutlak. Sang penguasa purba terhempas dari takhtanya, hancur terkubur ke dalam kehampaan jurang ketiadaan.\""
		},
		{
			"paths": ["res://assets/Scene/rin_story/rin_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "rin",
			"speaker_en": "RIN",
			"speaker_id": "RIN",
			"text_en": "\"(Seated with serene nobility upon the Throne of The Fallen, cosmic silk draping across the obsidian seat) 'To all who once shackled and belittled our journey, bear witness. A new era of civilization now dawns under the sanctuary of this throne.'\"",
			"text_id": "\"(Duduk anggun dan bermartabat di Takhta The Fallen, membiarkan selendang sutra kosmiknya menyelimuti singgasana) 'Untuk kalian yang pernah membelenggu dan meremehkan langkah kami, saksikanlah. Era baru peradaban kini bermula di bawah naungan takhta ini.'\""
		}
	],
	"muslan": [
		{
			"paths": ["res://assets/Scene/muslan_story/muslan_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With one crushing swing of his guitar case and a final chord of distorted resonance cleaving the universe, the ancient sovereign plunged into the void. The grand amphitheater of the gods fell silent... leaving behind only the acoustic strums of the coastal troubadour.\"",
			"text_id": "\"Dengan satu hantaman hardcase dan dentuman akord nada distorsi terakhir yang membelah semesta, sang penguasa purba terhempas ke jurang ketiadaan. Panggung para dewa kini sunyi... menyisakan petikan senar sang musisi jalanan.\""
		},
		{
			"paths": ["res://assets/Scene/muslan_story/muslan_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"],
			"speaker_role": "muslan",
			"speaker_en": "MUSLAN",
			"speaker_id": "MUSLAN",
			"text_en": "\"(Lounging lazily on the Throne of The Fallen, leaning his guitar gig bag against the stone dais) 'Finally... a magnificent stage without greedy producers who can pull the plug on my mic. Take a deep breath, tune your ears in... Hear my song, entire universe!'\"",
			"text_id": "\"(Duduk santai di Takhta The Fallen sambil menyandarkan tas gitarnya di singgasana batu) 'Akhirnya... sebuah panggung megah tanpa ada produser serakah yang bisa mematikan mikrofonku. Tarik napas, pasang telinga kalian baik-baik... Dengarkan laguku, seluruh semesta!'\""
		}
	],
	"kemet": [
		{
			"paths": [
				"res://assets/Scene/kemet_story/kemet_epilogue_01.jpg",
				"res://assets/Scene/kemet_story/cutscene Kemet 4.jpg",
				"res://assets/Scene/kemet_story/kemet_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With a savage rupture of lethal bio-metallic claws, The First Fallen was hurled into the void. Upon the ancient obsidian seat, the apex predator now commands the destiny of the cosmos.\"",
			"text_id": "\"Dengan satu terobosan cakar mematikan, The First Fallen terhempas ke jurang ketiadaan. Di atas singgasana purba, sang pemangsa puncak kini memegang takdir semesta.\""
		},
		{
			"paths": [
				"res://assets/Scene/kemet_story/kemet_epilogue_01.jpg",
				"res://assets/Scene/kemet_story/cutscene Kemet 4.jpg",
				"res://assets/Scene/kemet_story/kemet_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "kemet",
			"speaker_en": "KEMET",
			"speaker_id": "KEMET",
			"text_en": "\"(Perched arrogantly atop the Throne of The Fallen, plunging metallic talons into the stone) 'Who is the failed defect now?! Let those sniveling scientists tremble inside their cages... Because from this throne, the entire universe is officially my hunting grounds!'\"",
			"text_id": "\"(Duduk congkak di atas Takhta The Fallen sambil menancapkan cakar logamnya ke singgasana batu hitam) 'Siapa sekarang yang kalian sebut produk gagal?! Biarkan para ilmuwan itu gemetar di balik sangkar mereka... Karena dari takhta ini, seluruh semesta resmi menjadi wilayah perburuanku!'\""
		}
	],
	"butler": [
		{
			"paths": [
				"res://assets/Scene/butler_story/butler_epilogue_01.jpg",
				"res://assets/Scene/butler_story/cutscene butler 4.jpg",
				"res://assets/Scene/butler_story/butler_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With one sweeping lash of absolute roaring flame, The First Fallen plummeted into the void. The crude hospitality of the ancient sovereign has drawn to a close... supplanted by the refinement of a new master.\"",
			"text_id": "\"Dengan satu kibasan cambukan api mutlak, The First Fallen terhempas ke jurang ketiadaan. Pelayanan kasar sang penguasa purba telah usai... berganti keanggunan sang tuan baru.\""
		},
		{
			"paths": [
				"res://assets/Scene/butler_story/butler_epilogue_01.jpg",
				"res://assets/Scene/butler_story/cutscene butler 4.jpg",
				"res://assets/Scene/butler_story/butler_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "butler",
			"speaker_en": "BUTLER",
			"speaker_id": "BUTLER",
			"text_en": "\"(Cross-legged in aristocratic poise upon the Throne of The Fallen, swirling a golden chalice of vintage wine) 'From this moment forth, never again shall a master discard me. All the grandeur, luxury, and destiny of the cosmos now bow to my sovereign command.'\"",
			"text_id": "\"(Duduk bersilang kaki anggun di singgasana Takhta The Fallen sambil memegang piala anggur emas) 'Mulai detik ini, tak ada lagi tuan yang bisa membuangku. Seluruh kemewahan dan takdir semesta kini resmi tunduk di bawah telunjukku.'\""
		}
	],
	"om_hami": [
		{
			"paths": [
				"res://assets/Scene/om_hami_story/om_hami_epilogue_01.jpg",
				"res://assets/Scene/om_hami_story/Gemini_Generated_Image_somelssomelssome.jpg",
				"res://assets/Scene/om_hami_story/om_hami_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With one firm, authoritative tap of his wooden night-patrol club, The First Fallen was sent tumbling into oblivion. Universal curfew is now officially in effect.\"",
			"text_id": "\"Dengan satu ketukan tegas tongkat kayu rondanya, The First Fallen terhempas ke jurang ketiadaan. Jam malam semesta kini resmi ditegakkan.\""
		},
		{
			"paths": [
				"res://assets/Scene/om_hami_story/om_hami_epilogue_01.jpg",
				"res://assets/Scene/om_hami_story/Gemini_Generated_Image_somelssomelssome.jpg",
				"res://assets/Scene/om_hami_story/om_hami_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "om_hami",
			"speaker_en": "OM HAMI",
			"speaker_id": "OM HAMI",
			"text_en": "\"(Reclining lazily in his sarong on the Throne of The Fallen, puffing fragrant clove smoke) 'Not a bad chair for the night patrol, actually. Pretty comfy. Alright... the entire sector is peaceful, orderly, and no punks are stirring up trouble. Time for a well-deserved break.'\"",
			"text_id": "\"(Duduk selonjoran santai di Takhta The Fallen sambil mengisap rokok dan menyandarkan tongkat kayunya) 'Kursinya lumayan empuk juga buat ronda malam. Nah... sekarang seluruh wilayah aman, tertib, dan tidak ada lagi bocah nakal yang bikin keributan. Waktunya istirahat.'\""
		}
	],
	"sunkibo": [
		{
			"paths": [
				"res://assets/Scene/sunkibo_story/sunkibo_epilogue_01.jpg",
				"res://assets/Scene/sunkibo_story/Gemini_Generated_Image_dxb1b4dxb1b4dxb1.jpg",
				"res://assets/Scene/sunkibo_story/sunkibo_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "narrator",
			"speaker_en": "NARRATOR",
			"speaker_id": "NARRATOR",
			"text_en": "\"With one titanic sweep of his expanding celestial staff cleaving the stratosphere, The First Fallen was cast into the abyss. The throne of the gods has now been conquered by the audacious heir of the Monkey King.\"",
			"text_id": "\"Dengan satu ayunan tongkat emas yang memanjang membelah angkasa, The First Fallen terhempas ke jurang ketiadaan. Takhta para dewa kini dikuasai oleh sang pewaris kera sakti.\""
		},
		{
			"paths": [
				"res://assets/Scene/sunkibo_story/sunkibo_epilogue_01.jpg",
				"res://assets/Scene/sunkibo_story/Gemini_Generated_Image_dxb1b4dxb1b4dxb1.jpg",
				"res://assets/Scene/sunkibo_story/sunkibo_epilogue_01.png",
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
			],
			"speaker_role": "sunkibo",
			"speaker_en": "SUNKIBO",
			"speaker_id": "SUNKIBO",
			"text_en": "\"(Sitting cross-legged comfortably upon the Throne of The Fallen, happily crunching a sweet peach and laughing at the sky) 'Hey, all you stuffy gods up in paradise! Open your eyes wide! Look who rules the cosmos now... Still dare to ignore Sunkibo?! Hahahaha!'\"",
			"text_id": "\"(Duduk bersila santai di Takhta The Fallen sambil mengunyah buah persik manis, tertawa puas menantang langit) 'Woy, para dewa di kahyangan! Buka mata kalian lebar-lebar! Lihat siapa sekarang penguasa baru semesta... Masih berani mengabaikan Sunkibo?! Hahaha!'\""
		}
	]
}

static func get_character_epilogue(character_id: String, locale: String = "en") -> Array[Dictionary]:
	var key := _normalize_character_id(character_id)
	var is_id := (locale.to_lower().strip_edges() == "id")
	var raw_list: Array = CHARACTER_EPILOGUES.get(key, CHARACTER_EPILOGUES["aron"])
	var result: Array[Dictionary] = []
	for item in raw_list:
		result.append({
			"paths": item["paths"],
			"speaker": item["speaker_id"] if is_id else item["speaker_en"],
			"speaker_color": get_speaker_color(item["speaker_role"]),
			"text": item["text_id"] if is_id else item["text_en"]
		})
	return result

# ==============================================================================
# BOSS INTRO & EVOLVE DIALOGUES
# ==============================================================================

const BOSS_INTRO_DIALOGUES: Dictionary = {
	"aron": {
		"boss_en": "\"A mere boy with boxing handwraps and delusions of heroism... You think this throne of creation is your fairytale stage? Prove to me if your soul is worthy, or if you are merely mortal refuse destined for the void!\"",
		"boss_id": "\"Bocah dengan sarung tinju dan delusi kepahlawanan... Kau kira takhta penciptaan ini panggung dongengmu? Tunjukkan padaku apakah jiwamu layak, atau kau hanya sampah fana yang akan terlempar ke jurang!\"",
		"char_en": "\"A true protagonist never retreats in the climax! Take your stance, Old King!\"",
		"char_id": "\"Protagonis tidak pernah lari di babak klimaks! Pasang kudakudamu, Raja Tua!\""
	},
	"muslan": {
		"boss_en": "\"A shabby street busker smelling of salt and dust... This domain was forged upon a mountain of crushed bones, not pathetic songs of remorse!\"",
		"boss_id": "\"Pengamen jalanan berpenampilan lusuh... Tempat ini dibangun di atas tumpukan tulang, bukan nyanyian cengeng penyesalan!\"",
		"char_en": "\"Blood or music, it's all the same, boss. Both require pain to make people truly listen. Let's finish this track!\"",
		"char_id": "\"Darah atau musik, sama saja, Bos. Dua-duanya butuh rasa sakit biar orang mau dengar. Ayo selesaikan lagu ini.\""
	},
	"mike": {
		"boss_en": "\"Dragging an iron folding chair before the throne of cosmic creation... How utterly pathetic and frail you mortal insects are.\"",
		"boss_id": "\"Membawa kursi lipat besi ke hadapan takhta penciptaan... Betapa hinanya manusia fana selemah dirimu.\"",
		"char_en": "\"Sign my graduation thesis approval and refund my tuition fees! Get off that chair before I cave your skull in!\"",
		"char_id": "\"Tanda tangan kelulusan dan ganti rugi biaya UKT-ku! Minggir dari kursi itu sebelum kepalamu kupukul rata!\""
	},
	"om_hami": {
		"boss_en": "\"A man reeking of cheap tobacco wielding a weathered wooden stick... You step upon the sacred altar of sovereigns without a shred of reverence.\"",
		"boss_id": "\"Pria beraroma tembakau dengan sebatang kayu lapuk... Kau datang ke altar suci para penguasa tanpa rasa hormat sedikit pun.\"",
		"char_en": "\"Sacred my foot! The noise from your floating arena reached my neighborhood, messing up everyone's night gathering. Step down right now, don't make trouble.\"",
		"char_id": "\"Suci apaan? Berisiknya kedengaran sampai ke RT sebelah, tongkrongan warga jadi kacau. Cepat turun, jangan bikin masalah lagi.\""
	},
	"butler": {
		"boss_en": "\"A servant accustomed to pouring vintage wine for others... This throne is no stage for powerless slaves.\"",
		"boss_id": "\"Pelayan yang terbiasa menuangkan anggur untuk orang lain... Takhta ini bukan panggung bagi budak yang tak berdaya.\"",
		"char_en": "\"Precisely because I have witnessed how insatiably greedy masters can be, I comprehend the absolute value of sovereign power. Now, allow me to take your order.\"",
		"char_id": "\"Justru karena aku telah melihat betapa rakusnya para majikan, aku tahu nilai mutlak dari kekuasaan. Mari kita selesaikan pesanan Anda.\""
	},
	"kemet": {
		"boss_en": "\"A broken anomaly crawling out of a bio-waste incinerator... The rusted metal on your hands is an emblem of defective shame!\"",
		"boss_id": "\"Ciptaan rusak yang merangkak keluar dari tabung buangan... Logam karatan di tanganmu itu adalah simbol aib kegagalan!\"",
		"char_en": "\"This metal... is going to rip your throat out and claim your throne! RRRGH!\"",
		"char_id": "\"Logam ini... yang akan merobek lehermu dan merebut singgasanamu! RRRGH!\""
	},
	"rin": {
		"boss_en": "\"A weaver maiden armed with a fragile silk cloth... You dare challenge a destiny guarded by ten thousand blades of ruin?\"",
		"boss_id": "\"Gadis penenun dengan sehelai kain sutra rapuh... Kau berani menantang takdir yang dijaga ribuan bilah kehancuran?\"",
		"char_en": "\"This fabric is far more than woven thread—it is the bridge of our dignity and justice. The time has come for your arrogance to end!\"",
		"char_id": "\"Kain ini bukan sekadar rajutan benang, melainkan titian martabat dan keadilan. Waktunya keangkuhanmu berakhir di sini.\""
	},
	"sunkibo": {
		"boss_en": "\"The juvenile bloodline of a mythological monkey... This throne is no circus ring to satisfy your desperate craving for celestial approval.\"",
		"boss_id": "\"Darah kera mitologi yang kekanakan... Takhta ini bukan arena sirkus untuk memuaskan rasa haus pengakuan dari kaum langitmu.\"",
		"char_en": "\"Haha! Circus or not, you've gotta admit the audience is spectacular! Let's see if your royal title is anything more than empty boasts!\"",
		"char_id": "\"Haha! Sirkus atau bukan, penontonnya megah banget, kan? Ayo buktikan apakah gelarmu sebagai raja tua bukan sekadar omong kosong!\""
	},
	"default": {
		"boss_en": "\"Whoever you insolent mortal may be stepping upon this throne... your soul shall dissolve as an offering to the void!\"",
		"boss_id": "\"Siapapun dirimu fana yang lancang melangkah ke takhta ini... jiwamu akan lebur menjadi tumbal kehampaan!\"",
		"char_en": "\"I came to seize this throne! Prepare yourself!\"",
		"char_id": "\"Aku datang untuk merebut takhta ini! Bersiaplah!\""
	}
}

static func get_boss_intro(character_id: String, locale: String = "en") -> Dictionary:
	var key := _normalize_character_id(character_id)
	var is_id := (locale.to_lower().strip_edges() == "id")
	var dial: Dictionary = BOSS_INTRO_DIALOGUES.get(key, BOSS_INTRO_DIALOGUES["default"])

	var narrator_text := "\"Dikisahkan bahwa setelah melewati pertarungan berdarah di atas koloseum terapung, sang penantang akhirnya melangkah ke puncak takhta kuno. Namun sebelum jemarinya menyentuh singgasana... sebuah bayangan hitam raksasa bangkit menghunus pedang purba.\"" if is_id else "\"After enduring brutal, blood-drenched trials atop the floating colosseum, the claimant finally ascends to the foot of the ancient throne. Yet before their fingers can graze the seat of power... a towering dark shadow rises, brandishing an ancient greatsword.\""

	return {
		"narrator_text": narrator_text,
		"boss_speaker": "THE FIRST FALLEN",
		"boss_color": get_speaker_color("boss"),
		"boss_text": dial["boss_id"] if is_id else dial["boss_en"],
		"char_speaker": get_character_display_name(key),
		"char_color": get_speaker_color(key),
		"char_text": dial["char_id"] if is_id else dial["char_en"]
	}

const BOSS_EVOLVE_DIALOGUES: Dictionary = {
	"aron": {
		"roar_en": "\"ROOOAAARRR! YOU THINK YOU CAN TOPPLE ME WITH TOY PUNCHES?! WITNESS THE TRUE POWER OF THE FALLEN!\"",
		"roar_id": "\"ROOOAAARRR! KAU PIKIR BISA MENUMBANGKANKU DENGAN PUKULAN MAINAN ITU?! SAKSIKAN KEKUATAN SEJATI THE FALLEN!\"",
		"react_en": "\"I don't care how monstrous you transform into... in the final chapter, the hero is the one who stands victorious!\"",
		"react_id": "\"Mau kau berubah jadi monster sebesar apa pun... di babak akhir, pahlawanlah yang berdiri tegak!\""
	},
	"muslan": {
		"roar_en": "\"I SHALL CRUSH EVERY STRING AND BONE IN YOUR FRAIL BODY! DEATH IS THE ONLY REMAINING MELODY!\"",
		"roar_id": "\"AKU AKAN MEREMUKKAN SETIAP SENAR DAN TULANG DI TUBUHMU! KEMATIAN ADALAH SATU-SATUNYA NADA YANG TERSISA!\"",
		"react_en": "\"Your vocal distortion sounds awful. Let me fix your arrangement!\"",
		"react_id": "\"Distorsi suaramu jelek banget. Biar kubereskan aransemennya!\""
	},
	"mike": {
		"roar_en": "\"PETTY WRATH FROM BUREAUCRATIC CATTLE! I SHALL BURN ALL YOUR PATHETIC DREAMS TO ASH!\"",
		"roar_id": "\"KEMARAHAN SEPELE DARI HEWAN TERNAK BIROKRASI! AKU AKAN MEMBAKAR SEGALA HARAPANMU MENJADI ABU!\"",
		"react_en": "\"You have no idea what it's like staying up for years just to watch it all crumble... COME AT ME, YOU THESIS NIGHTMARE!\"",
		"react_id": "\"Kau tidak tahu rasanya begadang bertahun-tahun cuma untuk dihancurkan begitu saja... MAJU SINI KAU MONSTER SKRIPSI!\""
	},
	"om_hami": {
		"roar_en": "\"INSOLENT WRETCH! I SHALL TEAR YOUR FLESH ASUNDER UNTIL NONE REMEMBER YOUR EXISTENCE!\"",
		"roar_id": "\"LANCANG! AKU AKAN MENCABIK DAGINGMU HINGGA TAK ADA LAGI YANG MENGENALIMU!\"",
		"react_en": "\"See? I tried talking sense into you and you throw a tantrum like you're possessed. Curfew time, kiddo!\"",
		"react_id": "\"Nah kan, dibilangin baik-baik malah ngamuk kayak orang kesurupan. Waktunya jam malam, Tong!\""
	},
	"butler": {
		"roar_en": "\"YOU ARE MERELY AN INSECT IN FINE ATTIRE! TASTE THE UTTER DESPAIR OF ABSOLUTE EMPTINESS!\"",
		"roar_id": "\"KAU HANYA SERANGGA BERPAKAIAN RAPI! RASAKAN KEPUTUSASAAN DARI KEHAMPANAN MUTLAK!\"",
		"react_en": "\"Service this uncouth is strictly omitted from my menu. It is time to settle your invoice in full!\"",
		"react_id": "\"Pelayanan sekasar ini tidak ada dalam daftar menu saya. Waktunya melunasi seluruh tagihan Anda!\""
	},
	"kemet": {
		"roar_en": "\"YOU WISH TO SEE A TRUE MONSTER?! YOUR CRIPPLED MUTATION IS NOTHING BEFORE MY ABYSSAL CURSE!\"",
		"roar_id": "\"KAU INGIN MELIHAT MONSTER SEJATI?! BENTUK CACATMU ITU BUKAN TANDINGAN BAGI KUTUKAN KEHAMPANANKU!\"",
		"react_en": "\"Excellent... monster against monster. Let's find out whose claws sink deeper into flesh!\"",
		"react_id": "\"Bagus... monster lawan monster. Kita buktikan cakar siapa yang lebih dalam menembus daging!\""
	},
	"rin": {
		"roar_en": "\"JUSTICE IS A COWARD'S DELUSION! YOUR SKULL SHALL CRUSH BENEATH MY TALONS!\"",
		"roar_id": "\"KEADILAN ADALAH ILUSI PARA PENGECUT! KEPALAMU AKAN MEREMUK DI BAWAH CAKARKU!\"",
		"react_en": "\"Even the brightest stars ascend from the darkest void. Rest now, sorrowful beast... this sacred shawl shall purify your soul!\"",
		"react_id": "\"Bahkan bintang paling terang pun terbit dari kegelapan yang pekat. Rehatlah, monster nestapa... selendang ini yang akan menyucikanmu!\""
	},
	"sunkibo": {
		"roar_en": "\"IMPUDENT APE! I SHALL CRUSH THAT CROWN ALONG WITH YOUR WORTHLESS SKULL!\"",
		"roar_id": "\"KERA KURANG AJAR! AKU AKAN MEREMUKKAN MAHKOTA ITU BERSAMA TENGKORAK KEPALAMU!\"",
		"react_en": "\"Whoa, your monster form finally came out! My grandpa used to smack around hundreds of monsters like you. Now it's my turn!\"",
		"react_id": "\"Wah, akhirnya wujud monstermu keluar juga! Kakekku dulu menghajar ratusan monster sepertimu. Sekarang giliranku!\""
	},
	"default": {
		"roar_en": "\"INSOLENCE! THE ABYSSAL VOID SHALL CONSUME THE ENTIRE COSMOS!\"",
		"roar_id": "\"LANCANG! KEKUATAN KEHAMPANAN INI AKAN MENELAN SELURUH SEMESTA!\"",
		"react_en": "\"I won't back down a single step!\"",
		"react_id": "\"Aku tidak akan mundur sejengkal pun!\""
	}
}

static func get_boss_evolve(character_id: String, locale: String = "en") -> Dictionary:
	var key := _normalize_character_id(character_id)
	var is_id := (locale.to_lower().strip_edges() == "id")
	var dial: Dictionary = BOSS_EVOLVE_DIALOGUES.get(key, BOSS_EVOLVE_DIALOGUES["default"])

	var narrator_text := "\"Hantaman telak meretakkan zirah kuno sang penguasa purba. The First Fallen berlutut tersungkur di atas lantai arena yang remuk, Greatsword raksasanya terpental lepas dari genggaman.\"" if is_id else "\"A devastating impact fractures the ancient sovereign's archaic armor. The First Fallen collapses to one knee upon the fractured arena stones, his colossal greatsword knocked from his grip.\""

	return {
		"narrator_text": narrator_text,
		"boss_speaker": "THE FIRST FALLEN",
		"boss_color": get_speaker_color("boss"),
		"boss_roar": dial["roar_id"] if is_id else dial["roar_en"],
		"char_speaker": get_character_display_name(key),
		"char_color": get_speaker_color(key),
		"char_react": dial["react_id"] if is_id else dial["react_en"]
	}

# ==============================================================================
# HELPERS
# ==============================================================================

static func _normalize_character_id(raw_id: String) -> String:
	var id := raw_id.to_lower().strip_edges()
	match id:
		"om_hami", "om hami", "hami":
			return "om_hami"
		"the_first_fallen", "first_fallen", "boss":
			return "the_first_fallen"
		_:
			return id

static func get_character_display_name(raw_id: String) -> String:
	var key := _normalize_character_id(raw_id)
	match key:
		"om_hami":
			return "OM HAMI"
		"the_first_fallen":
			return "THE FIRST FALLEN"
		_:
			return key.to_upper()

static func get_speaker_color(role: String) -> Color:
	match role.to_lower().strip_edges():
		"aron":
			return Color(0.2, 0.85, 1.0)       # Cyan Blue
		"mike":
			return Color(1.0, 0.65, 0.2)      # Amber Gold
		"rin":
			return Color(0.85, 0.45, 1.0)      # Mystic Violet
		"muslan":
			return Color(0.9, 0.65, 0.25)     # Warm Troubadour
		"kemet":
			return Color(1.0, 0.25, 0.2)      # Crimson Blood
		"butler":
			return Color(0.95, 0.25, 0.25)    # Crimson Flame
		"om_hami", "om hami", "hami":
			return Color(0.85, 0.58, 0.32)    # Warm Tobacco
		"sunkibo":
			return Color(1.0, 0.78, 0.17)     # Sunburst Gold
		"narrator":
			return Color(1.0, 0.85, 0.3)      # Warm Gold
		"boss", "the_first_fallen":
			return Color(0.9, 0.2, 0.3)       # Void Crimson
		"warga", "townsman", "npc":
			return Color(1.0, 0.6, 0.2)       # Orange / Amber
		_:
			return Color(1.0, 1.0, 1.0)
