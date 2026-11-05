# GAME DESIGN DOCUMENT (GDD)
# FALLEN: THE CLAIMING OF THE THRONE
**Versi Dokumen:** 2.0 (Updated Full Release & Campaign Specification)  
**Pengembang:** Noxvera Game Design  
**Engine:** Godot Engine 4.3 (GDScript)  
**Target Platform:** PC (Windows, macOS, Linux) / Couch Multiplayer & Single Player Arcade  
**Tagline:** *"Di atas kehampaan jurang kematian, siapa yang pantas menduduki Takhta The Fallen?"*

---

## DAFTAR ISI (TABLE OF CONTENTS)
1. [Vision, Scope & Core Pillars](#1-vision-scope--core-pillars)
2. [Profil Pengembang & Tim Produksi](#2-profil-pengembang--tim-produksi)
3. [Core Gameplay & Sistem Pertarungan (Combat System)](#3-core-gameplay--sistem-pertarungan-combat-system)
   - 3.1 Dual Win Condition (HP KO vs Ring Out)
   - 3.2 Internal Economy & Feedback Loop
   - 3.3 Sistem Mobilitas Platform Fighter
   - 3.4 Sistem Kombo Darat, Udara & Input Buffering
   - 3.5 Sistem Pertahanan (Block, Dash & Hitstop)
4. [Mode Permainan (Game Modes)](#4-mode-permainan-game-modes)
   - 4.1 Mode 1v1 Local PvP
   - 4.2 Training Mode
   - 4.3 Campaign / Story Mode (Arcade Gauntlet)
5. [Roster Karakter (Playable Claimants)](#5-roster-karakter-playable-claimants)
   - 5.1 Aron — The Self-Proclaimed Hero
   - 5.2 Muslan — The Southern Troubadour
   - 5.3 Mike — The Enraged Senior
   - 5.4 Om Hami — The Local Peacekeeper
   - 5.5 Butler — The Disgraced Mixologist
   - 5.6 Kemet — The Defective Predator
   - 5.7 Rin — The Mystic Weaver
   - 5.8 Sunkibo — The Ignored Scion
   - 5.9 Training Dummy Target
6. [Final Boss: The First Fallen](#6-final-boss-the-first-fallen)
   - 6.1 Konsep & Lore Sang Penguasa Purba
   - 6.2 Fase 1: Armored Sovereign with Greatsword
   - 6.3 Fase 2: Monstrous Void Beast with Claws
   - 6.4 Mekanik Khusus Boss (Anti-Ring Out & Poise)
   - 6.5 Pola Serangan, Hitbox Data & AI Behavior
7. [Naskah Naratif Campaign & Cutscene Script](#7-naskah-naratif-campaign--cutscene-script)
   - 7.1 Universal Prologue (Mitos Takhta)
   - 7.2 Struktur Alur Cerita & Prolog Karakter
   - 7.3 Interaksi Dialog Pre-Boss, Mid-Boss & Epilog Takhta
8. [Desain Arena & Panggung Pertarungan (Stages)](#8-desain-arena--panggung-pertarungan-stages)
   - 8.1 Throne Platform Stage (The Claiming of the Fallen)
   - 8.2 Temple Ruin Stage
   - 8.3 Mad Lab Stage
   - 8.4 Magic Waterfall Stage
   - 8.5 Wild West Stage
   - 8.6 Heaven Secret Stage
   - 8.7 Rooftop Stage
9. [Sistem Kontrol & Antarmuka Pengguna (UI/UX)](#9-sistem-kontrol--antarmuka-pengguna-uiux)
   - 9.1 Skema Kontrol (Keyboard P1/P2 & Gamepad)
   - 9.2 In-Game HUD & Offscreen Indicator
   - 9.3 Out-of-Game UI Flow & Cutscene Player
10. [Arsitektur Teknis Godot 4 (Technical Architecture)](#10-arsitektur-teknis-godot-4-technical-architecture)
    - 10.1 Struktur Folder Proyek
    - 10.2 Hirarki Kelas & State Machine
    - 10.3 Dynamic Camera (BrawlhallaCamera)
    - 10.4 Fighter AI Controller
11. [Arah Seni (Visual Art & Audio Direction)](#11-arah-seni-visual-art--audio-direction)
12. [Lampiran: Neraca Balancing & Matriks Kesulitan](#12-lampiran-neraca-balancing--matriks-kesulitan)

---

## 1. VISION, SCOPE & CORE PILLARS

### 1.1 Visi Game
**FALLEN** adalah game **2D Retro Platform Fighter / Arcade Fighting** yang memadukan intensitas pertarungan jarak dekat khas era 16-bit (*The King of Fighters*, *Street Fighter III*) dengan kebebasan mobilitas vertikal dan ancaman tepi jurang ala platform fighter (*Brawlhalla*, *Super Smash Bros*).

Setiap pertarungan berpusat pada perebutan sebuah takhta keramat kuno—**Takhta The Fallen**—yang konon mampu mengabulkan ambisi apa pun bagi petarung yang sanggup berdiri terakhir di atas tanah pijakan.

### 1.2 Core Pillars
1. **High-Stakes Spatial Awareness:** Kemenangan tidak hanya ditentukan oleh siapa yang menghabiskan HP lawan, melainkan siapa yang mengendalikan ruang arena. Berada di tepi panggung adalah risiko kematian instan.
2. **Accessible Execution, Deep Mindgames:** Input kombo dirancang intuitif tanpa putaran stik yang rumit, namun menuntut kecerdasan membaca timing *parry/block*, *dodge baiting*, *wall recovery*, dan *knockback angling*.
3. **Character-Driven Narrative with Satirical Edge:** Delapan penantang (*The Claimants*) hadir dengan latar belakang sosial-kultural yang kontras dan satir (mulai dari mahasiswa tingkat akhir yang murka karena sidang batal, musisi indie pesisir selatan, hingga keturunan kera sakti yang diabaikan para dewa).

### 1.3 Target Platform & Spesifikasi
* **Platform Rilis:** PC Windows (Executable Standalone `.exe` + `.pck`), Linux, macOS.
* **Format Distribusi:** Full Portable ZIP Archive (`FALLEN.zip`).
* **Hardware Target:** PC berspesifikasi menengah (Integrated GPU Intel Iris Xe / AMD Radeon Vega atau GPU diskrit dasar), 60 FPS terkunci, respons input instan (< 16ms).

---

## 2. PROFIL PENGEMBANG & TIM PRODUKSI

Game ini dirancang dan dikembangkan oleh studio **Noxvera Game Design**:

| Nama Anggota | Student ID / Identitas | Peran & Tanggung Jawab Utama |
|---|---|---|
| **Muhammad Mikail Musa** | 0110223030 | **Project Manager** (Manajemen Milestone, Alur Rilis, & Integrasi Tim) |
| **Nanda Ilham Fadlika** | 0110223051 | **2D Engineer & Lead Programmer** (Arsitektur Kombat, State Machine, & Engine Pipeline) |
| **Galang Saputra** | 0110223036 | **2D Engineer & Game Writer** (Desain Sistem, Logika Arena, & Penulisan Naskah) |
| **Riani Aprianti** | 0110223157 | **Lead Game Writer** (Perancangan Naratif Karakter, Dialog Kampanye, & Lore Dunia) |
| **Rano Alamsyah** | 0110223024 | **Programmer** (Gameplay Mechanics, Input Mapping, & UI Programming) |
| **Kemal Fazani** | 0110223022 | **All Rounder** (Aset Visual, Audio Integration, QA Balancing & Testing) |

---

## 3. CORE GAMEPLAY & SISTEM PERTARUNGAN (COMBAT SYSTEM)

### 3.1 Dual Win Condition (HP KO vs Ring Out)
Pertandingan diakhiri dengan salah satu dari dua kondisi:
1. **Knock-Out (HP Depletion):** Menguras bar HP lawan dari batas maksimum hingga `0`. Begitu HP habis, karakter memasuki `State.DEAD` dan kehilangan satu stok nyawa (*Soul Stock*).
2. **Ring Out (Death Zone Boundary):** Mementalkan lawan keluar dari batas panggung melewati area *Death Zone* (kiri, kanan, atau bawah). Jatuh ke jurang mengeliminasi karakter secara instan tanpa memedulikan sisa HP.

### 3.2 Internal Economy & Feedback Loop
```
                      [Serangan Masuk]
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
   [Pengurangan HP]                 [Penerimaan Knockback]
 (Negative Feedback:               (Spatial Feedback:
  Ketahanan Menurun)                Terdesak ke Tepi Arena)
            │                                 │
            │                  ┌──────────────┴──────────────┐
            │                  ▼                             ▼
            │        [Berada di Tengah]            [Terlempar ke Jurang]
            │       (Posisi Aman/Taktis)          (RING OUT: INSTANT LOSS)
            ▼
    [HP Mencapai 0]
 (KNOCK-OUT: ROUND LOSS)
```

### 3.3 Sistem Mobilitas Platform Fighter
* **Grounded Movement:** Jalan (*Walk*) dan Lari (*Run*) dengan percepatan dan deselerasi responsif.
* **Air Jump (Double Jump):** Setiap karakter memiliki hak 1 kali lompatan tambahan di udara untuk manuver atau *recovery*.
* **Wall Slide:** Karakter yang menabrak dinding saat jatuh akan meluncur perlahan (`WALL_SLIDE_SPEED = 120.0`), membuka peluang manuver pembalikan.
* **Wall Jump:** Menekan tombol lompat saat *wall slide* memberikan dorongan diagonal menjauhi dinding (`wall_jump_impulse`), esensial untuk menyelamatkan diri dari jurang kematian.

### 3.4 Sistem Kombo Darat, Udara & Input Buffering
Sistem pertarungan menggunakan **State Machine Berbasis Jendela Kombo (*Combo Window & Input Buffer*)**:
* **3-Hit Ground Chain:**
  * *Hit 1 (Jab / Poke):* Serangan cepat berjarak pendek untuk memeriksa pertahanan (*startup 3-5 frame*).
  * *Hit 2 (Body Blow / Cross):* Serangan lanjutan bertenaga yang menambah *hitstun* lawan.
  * *Hit 3 (Finisher):* Serangan penutup dengan peluncuran *knockback* kuat (vertikal atau horizontal).
* **3-Hit Aerial Chain:**
  * Saat berada di udara, menekan tombol serang memicu kombo udara (*Air Jab -> Air Hook -> Air Slam*). *Air Slam* menukik tajam ke bawah (*spike*), sangat mematikan di dekat tepi jurang.
* **Input Buffering (`has_buffered_attack`):** Pemain dapat menekan tombol serang sebelum animasi selesai. Begitu *window* rantai terbuka (`can_chain_combo = true`), karakter otomatis melanjutkan kombo tanpa *miss input*.

### 3.5 Sistem Pertahanan (Block, Dash & Hitstop)
* **Block State:** Menahan tombol menghindar (*dodge button*) saat berdiri mengaktifkan kuda-kuda bertahan:
  * Mengurangi kerusakan sebesar **70%** (pemain hanya menerima **30% chip damage**).
  * Mengurangi dorongan *knockback* sebesar **60%**.
  * Memunculkan animasi *block impact* saat terkena pukulan musuh.
* **Tactical Dash Burst:** Menekan tombol menghindar dengan cepat memicu *dash* berkecepatan tinggi (`DASH_SPEED = 580.0`, durasi `0.22s`) dengan jeda *cooldown* `2.0 detik`. Digunakan untuk menembus proyektil atau menutup jarak (*gap closing*).
* **Hitstop & Hitstun:** Setiap serangan sukses menghentikan frame sepersekian detik (*hitstop* 0.05s - 0.12s) untuk bobot benturan yang nyata, diikuti waktu lumpuh (*hitstun*) yang menentukan apakah kombo bersambung murni.

---

## 4. MODE PERMAINAN (GAME MODES)

```
                       [MAIN MENU]
                            │
       ┌────────────────────┼────────────────────┐
       ▼                    ▼                    ▼
[VS MODE (1v1 PvP)]  [TRAINING MODE]    [CAMPAIGN MODE]
  ├─ Select Character  ├─ Free Practice   ├─ Universal Prologue
  ├─ Select Stage      ├─ Infinite Time   ├─ Character Prologue
  └─ Custom Stocks     └─ Practice Dummy  ├─ 5x Claimant Gauntlet
                                          ├─ Pre-Boss Cutscene
                                          ├─ The First Fallen (Ph.1 & 2)
                                          └─ Throne Epilogue
```

### 4.1 Mode 1v1 Local PvP
* Pertarungan 2 pemain langsung di satu perangkat PC menggunakan keyboard terbagi (*WASD vs Arrow Keys*) atau kombinasi Gamepad.
* Opsi durasi ronde: **99 Detik, 120 Detik, 150 Detik, atau Tanpa Batas (*Infinite*)**.
* Opsi stok nyawa: **1 Nyawa (*Sudden Death*), 2 Nyawa, 3 Nyawa (Standar Kompetitif), atau 5 Nyawa**.

### 4.2 Training Mode
* Menghadirkan lawan **Training Dummy Target** ber-HP `500.0`.
* Menampilkan *reset position*, latihan *wall bounce*, pengukuran *damage*, dan pengujian rangkaian kombo bebas gangguan.

### 4.3 Campaign / Story Mode (Arcade Gauntlet)
* **Alur Perjalanan:**
  1. **Universal Prologue:** Sinematik visual novel berlatar mitos Takhta The Fallen.
  2. **Character Prologue:** Menjelaskan kehidupan pra-premis, insiden pemicu konflik, dan sumpah penantang (*Claimant's Oath*).
  3. **The Gauntlet (Stage 1 s.d. 5):** Menghadapi 5 karakter Claimant lain yang dipilih secara acak di 5 arena berbeda dengan kecerdasan buatan (*AI*).
  4. **The Final Showdown (Stage 6):** Melangkah ke *Throne Platform Stage* untuk menantang sang legenda abadi: **The First Fallen** (2 Fase pertarungan lengkap dengan dialog Pre-Boss dan Mid-Boss Transformation).
  5. **Victory Epilogue:** Menampilkan adegan sinematik saat karakter pemain menaiki tangga takhta, menduduki singgasana, dan mewujudkan keinginan terdalam mereka.

---

## 5. ROSTER KARAKTER (PLAYABLE CLAIMANTS)

### Ringkasan Statistik Dasar Roster

| Karakter | Arketipe | Base HP | Speed | Jump Vel. | Knockback Res. | Senjata Utama |
|---|---|---|---|---|---|---|
| **Aron** | Shonen Boxer / Balanced Striker | 100.0 | 280.0 | -520.0 | Normal (1.0x) | Sarung Tinju & Balutan Handwrap |
| **Muslan** | Mid-Range Troubadour / Zoner | 250.0 | 290.0 | -525.0 | Normal (1.0x) | Hardcase Gitar Akustik & Sandal Jepit |
| **Mike** | Heavy Brawler / Berserker | 270.0 | 285.0 | -520.0 | Kokoh (0.9x) | Kursi Lipat Besi Kampus |
| **Om Hami** | Heavy Guardian / Spacing Zoner | 275.0 | 250.0 | -500.0 | Paling Tebal (0.85x) | Tongkat Kayu Ronda & Asap Rokok |
| **Butler** | Rushdown Mixologist / Flame Duelist | 260.0 | 295.0 | -530.0 | Normal (1.0x) | Serbet Pusaka Berenergi Api |
| **Kemet** | Assassin / Defective Predator | 240.0 | 310.0 | -530.0 | Ringan (1.05x) | Cakar Logam Biologis |
| **Rin** | Zoner / Mystic Nebula Weaver | 235.0 | 300.0 | -535.0 | Ringan (1.05x) | Selendang Sutra Kosmik Leluhur |
| **Sunkibo** | Trickster / Airborne Scion | 240.0 | 315.0 | -545.0 | Lincah (1.0x) | Ruyi Jingu Bang & Mahkota Emas |
| **The First Fallen** | Final Boss (Colossal Sovereign) | 500.0 (x2) | 240 / 340 | -540 / -600 | Super Poise (0.08x / 0.06x) | Greatsword Purba (F1) / Cakar Void (F2) |

---

### 5.1 Aron — "The Self-Proclaimed Hero"
* **Latar Belakang:** Pemuda berkacamata tebal dan bersweater hitam yang menghabiskan masa mudanya berlatih tinju sendirian di kamar berpajang poster anime shonen. Diejek oleh lingkungannya sebagai anak culun yang hidup dalam khayalan, Aron bersumpah merebut Takhta Fallen untuk membuktikan bahwa dialah sang protagonis sejati.
* **Gaya Bertarung:** *Peek-a-boo boxing guard*, pukulan cepat beruntun, serta *dash* lincah.
* **Rangkaian Serangan:**
  * *Darat:* Jab kilat (Hit 1) -> Hook silang (Hit 2) -> Shonen Uppercut beraura biru (Hit 3 Finisher).
  * *Udara:* Air Jab -> Air Cross -> Meteoric Ground Slam.
* **Keunggulan:** Pemulihan (*recovery*) cepat antar animasi, sangat mematikan dalam pertarungan jarak dekat.

### 5.2 Muslan — "The Southern Troubadour"
* **Latar Belakang:** Musisi jalanan asal pesisir selatan yang hidup dari warung kopi ke panggung kafe kayu. Ditolak oleh industri rekaman besar karena idealisme lagunya dianggap "kampungan tak bernilai komersil", Muslan membawa hardcase gitarnya ke arena demi memaksa seluruh semesta terdiam dan mendengarkan musiknya.
* **Gaya Bertarung:** Ayunan hardcase instrumen berjarak menengah dengan ledakan gelombang sonik.
* **Rangkaian Serangan:**
  * *Darat:* Swing Case Rendah -> Hantaman Sudut Kasus -> Akord Distorsi Sonik horizontal.
* **Keunggulan:** *Disjointed hitbox* yang mampu memotong serangan jarak dekat lawan sebelum menyentuh tubuhnya.

### 5.3 Mike — "The Enraged Senior"
* **Latar Belakang:** Mahasiswa tingkat akhir yang telah merampungkan draf skripsinya setelah empat tahun penuh begadang. Naas, ruang sidangnya hancur lebur akibat pertarungan liar turnamen Fallen dan birokrasi kampus memaksanya membayar UKT semester baru atau dinyatakan DO. Didorong oleh amarah *burnout* akademis murni, Mike memungut kursi lipat besi kampus untuk meratakan siapa saja yang menghalangi kelulusannya.
* **Gaya Bertarung:** *Brawling brute-force* tanpa teknik formal dengan kursi lipat besi.
* **Rangkaian Serangan:**
  * *Darat:* Ayunan Kursi Bawah -> Hantaman Kaki Kursi Depan -> *Chair Slam Downward*.
* **Keunggulan:** Serangan memiliki *armor frames* ringan pada Hit 2 dan *knockback* vertikal brutal.

### 5.4 Om Hami — "The Local Peacekeeper"
* **Latar Belakang:** Tetua ronda dan tokoh pelindung kampung yang terbiasa menjaga ketertiban malam hari di pos ronda. Muak melihat petarung-petarung dari berbagai dimensi saling berhantam dan merusak gerobak warga serta fasilitas RT, Om Hami berangkat membawa tongkat kayu rondanya untuk "menertibkan anak-anak nakal" yang melanggar jam malam.
* **Gaya Bertarung:** Pengendalian jarak (*spacing*), ketukan tongkat kayu presisi, dan daya tahan tubuh paling alot.
* **Rangkaian Serangan:**
  * *Darat:* Sodokan Ujung Tongkat -> Sapuan Kaki Rendah -> Hantaman Gada Kayu Berasap.
* **Keunggulan:** Base HP tertinggi di antara petarung biasa (`275.0`), resistansi *knockback* pasif tinggi.

### 5.5 Butler — "The Disgraced Mixologist"
* **Latar Belakang:** Eks-bartender hotel berbintang lima yang dipecat sepihak tanpa pesangon oleh majikannya yang korup dan diusir dari kontrakannya di bawah guyuran hujan. Menyadari bahwa keanggunan tanpa kekuasaan adalah kesia-siaan, ia mengubah serbet pusaka pelayannya menjadi senjata api magis untuk merebut takhta tertinggi dunia.
* **Gaya Bertarung:** *Flame duelist* anggun dengan kibasan kain api berputar dan gerak langkah cepat.
* **Rangkaian Serangan:**
  * *Darat:* Cambukan Serbet Api -> Putaran Kain Bara -> Ledakan Api Menyala (*Flambé Burst*).
* **Keunggulan:** Pergerakan cepat dan kombinasi serangan menyapu yang sulit dihindari saat musuh bangun (*okizeme*).

### 5.6 Kemet — "The Defective Predator"
* **Latar Belakang:** Subjek uji coba rekayasa genetika yang dicap gagal (*defective product*) dan dibuang ke saluran limbah karena cakar logam biologis di punggung tangannya bermutasi liar. Menolak dimusnahkan oleh fasilitas riset yang memburunya, Kemet bertarung untuk membuktikan bahwa sang "produk gagal" mampu menaklukkan puncak rantai makanan semesta.
* **Gaya Bertarung:** *Rushdown assassin berserker*, lompatan liar, dan tebasan cakar ganda bertubi-tubi.
* **Rangkaian Serangan:**
  * *Darat:* Tusukan Cakar Cepat -> Tebasan Menyilang X-Cross -> Ayunan Cakar Melompat (*Rend Finisher*).
* **Keunggulan:** Kecepatan lari tertinggi kedua (`310.0`) dan mobilitas dinding (*wall climb*) paling luwes.

### 5.7 Rin — "The Mystic Weaver"
* **Latar Belakang:** Putri penenun tradisional yang dikekang oleh adat kolot keluarga yang membatasi hak perempuan untuk melangkah ke gelanggang luar. Membuka peti pusaka rahasia neneknya, ia mengambil sehelai selendang sutra kosmik bercahaya nebula untuk membuktikan bahwa keteguhan dan martabat mampu menembus tirani tradisi.
* **Gaya Bertarung:** *Zoner* taktis berjarak jauh menggunakan lilitan dan kibasan selendang bercahaya bintang.
* **Rangkaian Serangan:**
  * *Darat:* Kibasan Kain Kosmik Jauh -> Gelombang Galaksi Berpendar -> Pusaran Nebula Penghempas.
* **Keunggulan:** Jangkauan *hitbox* terjauh di antara seluruh karakter biasa, ahli mengontrol sudut tepi jurang.

### 5.8 Sunkibo — "The Ignored Scion"
* **Latar Belakang:** Keturunan langsung sang Raja Kera legendaris (Sun Wukong) yang tinggal di kemewahan taman kahyangan. Muak selalu berada di bawah bayang-bayang keagungan kakek buyutnya dan diabaikan oleh para dewa langit, Sunkibo turun ke bumi membajak sayembara Takhta Fallen untuk memicu kehebohan mutlak hingga langit terpaksa menoleh padanya.
* **Gaya Bertarung:** *Airborne trickster*, tongkat pusaka yang memanjang, dan akrobatik udara tiada tanding.
* **Rangkaian Serangan:**
  * *Darat:* Ketukan Tongkat Depan -> Putaran Tongkat Helikopter -> Hantaman Ruyi Jingu Bang Raksasa.
* **Keunggulan:** Kecepatan lari tertinggi (`315.0`) dan lompatan tertinggi (`-545.0`), mendominasi pertempuran udara.

### 5.9 Training Dummy Target
* Karakter uji coba pasif berwujud boneka latihan kayu lapis besi.
* Memiliki HP masif (`500.0`), respons visual benturan jelas, dan kemampuan *auto-recovery* untuk memudahkan pemain mengkalibrasi *damage combo*.

---

## 6. FINAL BOSS: THE FIRST FALLEN

```
       [ENTERING THRONE PLATFORM STAGE]
                      │
                      ▼
        [Pre-Boss Cinematic Cutscene]
     (The First Fallen menghunus Greatsword)
                      │
                      ▼
         [PERTARUNGAN BOSS: PHASE 1]
    - HP: 500.0 | Speed: 240.0
    - Greatsword Cleave & Heavy Overhead Slam
    - Poise Resistance: 92% (Knockback diterima: 8%)
                      │
                      ▼ (HP Fase 1 Menjadi 0)
        [Mid-Boss Transformation Cutscene]
   (Armor Pecah -> Tubuh Membesar Menjadi Monster Void)
                      │
                      ▼
         [PERTARUNGAN BOSS: PHASE 2]
    - HP: 500.0 | Speed: 340.0 (Sangat Agresif)
    - Void Beast Claws, Savage Frenzy & Screen Shake
    - Poise Resistance: 94% (Knockback diterima: 6%)
                      │
                      ▼ (HP Fase 2 Menjadi 0)
            [DEFEAT & THRONE EPILOGUE]
```

### 6.1 Konsep & Lore Sang Penguasa Purba
**The First Fallen** adalah raja petarung pertama yang ribuan tahun silam menduduki takhta penciptaan. Tubuhnya telah menyatu dengan kutukan kehampaan (*the void*), membuatnya menjadi entitas tanpa ampun yang memusnahkan setiap penantang yang tidak layak.

### 6.2 Fase 1: Armored Sovereign with Greatsword
* **Visual:** Pendekar raksasa berzirah baja hitam kelam dengan jubah compang-camping, menghunus pedang raksasa purba (*Greatsword*).
* **Karakteristik & Parameter:**
  * **Max HP:** `500.0`
  * **Movement Speed:** `240.0`
  * **Jump Velocity:** `-540.0`
  * **Knockback Resistance:** `0.08` (Hanya menyerap 8% dorongan knockback; hampir mustahil didorong keluar panggung).
  * **Ukuran Sprite & Hitbox:** Skala 0.35x, tinggi tabung collider 110 px.
* **Rangkaian Kombo Pedang:**
  * *Hit 1 (Broadsword Sweep):* Damage `18.0`, Base Knockback `280.0`.
  * *Hit 2 (Overhead Cleave):* Damage `24.0`, Base Knockback `380.0`.
  * *Hit 3 (Abyssal Breaker Finisher):* Damage `38.0`, Base Knockback `620.0` sudut 45 derajat.

### 6.3 Fase 2: Monstrous Void Beast with Claws
* **Visual:** Zirah baja hancur lebur meledak, menyingkap wujud monster raksasa berotot hitam kelam dengan cakar buas bercahaya merah membara (*void crimson*) dan mata menyala.
* **Karakteristik & Parameter:**
  * **Max HP:** `500.0` (Bar HP terisi penuh kembali saat transformasi).
  * **Movement Speed:** `340.0` (Peningkatan drastis, bergerak lebih cepat dari seluruh petarung biasa).
  * **Jump Velocity:** `-600.0`.
  * **Knockback Resistance:** `0.06` (Menyerap 94% knockback).
  * **Ukuran Sprite & Hitbox:** Skala 0.38x, tinggi tabung collider 120 px, jangkauan cakar lebih luas.
* **Rangkaian Kombo Buas:**
  * *Hit 1 (Beast Swipe):* Damage `22.0`, Base Knockback `340.0`.
  * *Hit 2 (Feral Rend):* Damage `28.0`, Base Knockback `450.0`.
  * *Hit 3 (Void Cataclysm Slam):* Damage `45.0`, Base Knockback `720.0` dengan guncangan kamera intensif (*Camera Shake intensity = 26.0*).

### 6.4 Mekanik Khusus Boss (Anti-Ring Out & Poise)
* **Anti-Ring-Out Pit Clamp (`_enforce_arena_bounds`):**
  Untuk mencegah pemain mengalahkan sang boss purba secara murah (*cheese ring-out*), sistem mendeteksi posisi Y boss. Jika The First Fallen terlempar di bawah koordinat jurang (`Y > 560.0`), ia secara instan memicu ledakan partikel void, berteleportasi kembali ke atas platform utama (`Y = 350.0`, `X clamped 300 s.d. 850`), dan memulihkan posisinya dengan dorongan vertikal aman.
* **Super Poise:**
  Boss tidak mengalami *stagger* pada pukulan ringan biasa, memaksa pemain memanfaatkan serangan balik beruntun, blok taktis, atau serangan udara untuk mencuri celah.

### 6.5 Logika Kecerdasan Buatan (Boss AI State Machine)
AI boss beroperasi menggunakan interval keputusan reaktif:
* **Jarak Jauh (> 240px):** Melakukan sprint ganas ke arah pemain; peluang melompat tinggi untuk menyergap dari udara.
* **Jarak Menengah (115px - 240px):** Melancarkan *lunge attack* (sprint dipercepat 1.2x) langsung ke dalam rangkaian kombo.
* **Jarak Dekat (<= 115px):** 85% peluang mengeksekusi kombo pembantai 3 langkah secara instan; 15% peluang melakukan *backstep* cepat untuk memancing whiff pemain.
* **Airborne Punish:** Jika pemain melompat di atas kepala boss, boss otomatis melompat menyusul dalam waktu < 0.2 detik untuk menghajar pemain di udara.

---

## 7. NASKAH NARATIF CAMPAIGN & CUTSCENE SCRIPT

### 7.1 Universal Prologue (Mitos Takhta)
*Diputar saat pemain pertama kali memulai Campaign Mode setelah memilih karakter.*
* **Visual:** Kamera menyusuri langit kelam berbintang melintasi puing-puing platform kuno melayang, lalu menyorot ke singgasana batu hitam The Fallen yang dikelilingi ribuan pedang berkarat.
* **Naskah:**
  > **[NARRATOR]**  
  > "Di tengah sisa-sisa peradaban yang runtuh, berdirilah sebuah legenda sunyi bernama *The Fallen*."  
  > "Mitos kuno membisikkan bahwa siapa pun petarung yang berhasil menaklukkan seluruh lawan dan menduduki takhta tersebut, akan dianugerahi kuasa mutlak untuk mengabulkan ambisi apa pun tanpa syarat."  
  > "Namun, panggung ini tidak mengenal belas kasih. Takhta itu berdiri di atas kehampaan jurang kematian. Di sini, kebenaran tidak ditentukan oleh garis moralitas, melainkan siapa yang bertahan di atas tanah pijakan dan siapa yang terlempar ke ketiadaan."

---

### 7.2 Struktur Alur Cerita & Prolog Karakter

Setiap petarung memiliki 3 segmen prolog sebelum memasuki arena:
1. **Scene 1: Pra-Premis** (Gambaran kehidupan normal / masa tenang karakter).
2. **Scene 2: Titik Balik** (Insiden dramatis atau satir yang memicu konflik tak tertahankan).
3. **Scene 3: Panggilan Fallen** (Sumpah penantang saat memutuskan merebut takhta).

#### Contoh Rangkuman Prolog 8 Karakter:
* **Aron:** Ruang kamar penuh poster shonen -> Ditertawakan pemuda saat latihan tinju -> Bersumpah membuktikan status sebagai karakter utama.
* **Muslan:** Bernyanyi santai di pantai selatan -> Pintu kantor produser dibanting dan demo lagunya dicampakkan -> Bertekad membajak takhta agar lagunya didengar semesta.
* **Mike:** Menatap naskah skripsi berjilid rapi -> Ruang ujian sidang hancur oleh turnamen dan dipaksa bayar UKT baru -> Menyambar kursi lipat besi demi melumat siapa saja perusak kelulusannya.
* **Om Hami:** Menyeruput kopi hitam di pos ronda damai -> Lapak warga hancur akibat benturan petarung antar dimensi -> Mengambil tongkat kayu ronda demi menertibkan jam malam.
* **Butler:** Meracik koktail sempurna di hotel bintang lima -> Dipecat sepihak tanpa pesangon di tengah hujan -> Membakar kain serbetnya demi menjadi penguasa di puncak hierarki.
* **Kemet:** Memandang ilmuwan dengan polos dari inkubator lab -> Alarm bahaya berbunyi dan dicap sebagai produk gagal yang harus dimusnahkan -> Mengasah cakar biologis untuk memburu para penciptanya.
* **Rin:** Menenun kain sutra di beranda rumah kayu -> Dihadang tetua adat yang membatasi hak perempuan -> Membawa selendang kosmik leluhur untuk meruntuhkan stereotip usang.
* **Sunkibo:** Bersantai di cabang pohon persik istana awan -> Diabaikan para dewa yang hanya memuji sang kakek buyut Sun Wukong -> Turun ke bumi membajak takhta demi memaksa langit menoleh padanya.

---

### 7.3 Interaksi Dialog Pre-Boss, Mid-Boss & Epilog Takhta

#### 1. Aron vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Bocah dengan sarung tinju dan delusi kepahlawanan... Kau kira takhta penciptaan ini panggung dongengmu? Tunjukkan padaku apakah jiwamu layak, atau kau hanya sampah fana yang akan terlempar ke jurang!"
  * *Aron:* "Protagonis tidak pernah lari di babak klimaks! Pasang kudakudamu, Raja Tua!"
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "ROOOAAARRR! KAU PIKIR BISA MENUMBANGKANKU DENGAN PUKULAN MAINAN ITU?! SAKSIKAN KEKUATAN SEJATI THE FALLEN!"
  * *Aron:* "Mau kau berubah jadi monster sebesar apa pun... di babak akhir, pahlawanlah yang berdiri tegak!"
* **Epilog Kemenangan:** Uppercut Aron mementalkan monster purba ke jurang. Aron duduk di takhta The Fallen dan membenarkan letak kacamatanya.
  * *Aron:* "Lihat ini, dunia. Figuran yang dulu kalian remehkan... sekarang memegang takdir kalian semua."

#### 2. Muslan vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Pengamen jalanan berpenampilan lusuh... Tempat ini dibangun di atas tumpukan tulang, bukan nyanyian cengeng penyesalan!"
  * *Muslan:* "Darah atau musik, sama saja, Bos. Dua-duanya butuh rasa sakit biar orang mau dengar. Ayo selesaikan lagu ini."
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "AKU AKAN MEREMUKKAN SETIAP SENAR DAN TULANG DI TUBUHMU! KEMATIAN ADALAH SATU-SATUNYA NADA YANG TERSISA!"
  * *Muslan:* "Distorsi suaramu jelek banget. Biar kubereskan aransemennya!"
* **Epilog Kemenangan:** Petikan gitar Muslan menghempaskan sang raksasa ke jurang. Muslan duduk bersila memangku gitarnya di takhta.
  * *Muslan:* "Akhirnya... panggung megah tanpa produser serakah yang bisa mematikan mikrofonku. Dengarkan laguku, seluruh dunia."

#### 3. Mike vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Membawa kursi lipat besi ke hadapan takhta penciptaan... Betapa hinanya manusia fana selemah dirimu."
  * *Mike:* "Tanda tangan kelulusan dan ganti rugi biaya UKT-ku! Minggir dari kursi itu sebelum kepalamu kupukul rata!"
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "KEMARAHAN SEPELE DARI HEWAN TERNAK BIROKRASI! AKU AKAN MEMBAKAR SEGALA HARAPANMU MENJADI ABU!"
  * *Mike:* "Kau tidak tahu rasanya begadang bertahun-tahun cuma untuk dihancurkan begitu saja... MAJU SINI KAU MONSTER SKRIPSI!"
* **Epilog Kemenangan:** Kursi lipat besi Mike membanting monster ke jurang ketiadaan. Mike menduduki singgasana dengan napas memburu.
  * *Mike:* "Dengan kuasa mutlak takhta ini... skripsiku resmi lulus predikat terpuji tanpa revisi, dan birokrasi kampus resmi dibubarkan!"

#### 4. Om Hami vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Pria beraroma tembakau dengan sebatang kayu lapuk... Kau datang ke altar suci para penguasa tanpa rasa hormat sedikit pun."
  * *Om Hami:* "Suci apaan? Berisiknya kedengaran sampai ke RT sebelah, tongkrongan warga jadi kacau. Cepat turun, jangan bikin masalah lagi."
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "LANCANG! AKU AKAN MENCABIK DAGINGMU HINGGA TAK ADA LAGI YANG MENGENALIMU!"
  * *Om Hami:* "Nah kan, dibilangin baik-baik malah ngamuk kayak orang kesurupan. Waktunya jam malam, Tong!"
* **Epilog Kemenangan:** Ketukan tongkat kayu Om Hami menumbangkan monster ke jurang. Om Hami bersandar santai di takhta sambil merokok.
  * *Om Hami:* "Kursinya lumayan empuk buat jaga malam. Nah, sekarang seluruh wilayah aman, tertib, dan tidak ada lagi yang bikin keributan."

#### 5. Butler vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Pelayan yang terbiasa menuangkan anggur untuk orang lain... Takhta ini bukan panggung bagi budak yang tak berdaya."
  * *Butler:* "Justru karena aku telah melihat betapa rakusnya para majikan, aku tahu nilai mutlak dari kekuasaan. Mari kita selesaikan pesanan Anda."
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "KAU HANYA SERANGGA BERPAKAIAN RAPI! RASAKAN KEPUTUSASAAN DARI KEHAMPANAN MUTLAK!"
  * *Butler:* "Pelayanan sekasar ini tidak ada dalam daftar menu saya. Waktunya melunasi seluruh tagihan Anda!"
* **Epilog Kemenangan:** Cambukan kain api membakar sang monster ke jurang. Butler duduk bersilang kaki anggun di takhta.
  * *Butler:* "Mulai detik ini, tak ada lagi tuan yang bisa membuangku. Seluruh kemewahan dunia kini tunduk di bawah telunjukku."

#### 6. Kemet vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Ciptaan rusak yang merangkak keluar dari tabung buangan... Logam karatan di tanganmu itu adalah simbol aib kegagalan!"
  * *Kemet:* "Logam ini... yang akan merobek lehermu dan merebut singgasanamu! RRRGH!"
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "KAU INGIN MELIHAT MONSTER SEJATI?! BENTUK CACATMU ITU BUKAN TANDINGAN BAGI KUTUKAN KEHAMPANANKU!"
  * *Kemet:* "Bagus... monster lawan monster. Kita buktikan cakar siapa yang lebih dalam menembus daging!"
* **Epilog Kemenangan:** Cakar ganda Kemet mencabik monster hingga jatuh ke ketiadaan. Kemet melompat mencengkeram puncak takhta.
  * *Kemet:* "Siapa sekarang yang kalian sebut produk gagal?! Biarkan para penciptaku gemetar ketakutan... perburuan mereka resmi berakhir!"

#### 7. Rin vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Gadis penenun dengan sehelai kain sutra rapuh... Kau berani menantang takdir yang dijaga ribuan bilah kehancuran?"
  * *Rin:* "Kain ini bukan sekadar rajutan benang, melainkan titian martabat dan keadilan. Waktunya keangkuhanmu berakhir di sini."
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "KEADILAN ADALAH ILUSI PARA PENGECUT! KEPALAMU AKAN MEREMUK DI BAWAH CAKARKU!"
  * *Rin:* "Bahkan bintang paling terang pun terbit dari kegelapan yang pekat. Rehatlah, monster nestapa... selendang ini yang akan menyucikanmu!"
* **Epilog Kemenangan:** Pusaran cahaya nebula selendang Rin mementalkan monster jauh ke jurang. Rin duduk anggun di singgasana.
  * *Rin:* "Untuk kalian yang pernah membelenggu dan meremehkan langkah kami, saksikanlah. Era baru peradaban kini bermula di bawah naungan takhta ini."

#### 8. Sunkibo vs The First Fallen
* **Pre-Boss (Phase 1):**
  * *The First Fallen:* "Darah kera mitologi yang kekanakan... Takhta ini bukan arena sirkus untuk memuaskan rasa haus pengakuan dari kaum langitmu."
  * *Sunkibo:* "Haha! Sirkus atau bukan, penontonnya megah banget, kan? Ayo buktikan apakah gelarmu sebagai raja tua bukan sekadar omong kosong!"
* **Mid-Boss (Transisi Phase 2):**
  * *The First Fallen:* "KERA KURANG AJAR! AKU AKAN MEREMUKKAN MAHKOTA ITU BERSAMA TENGKORAK KEPALAMU!"
  * *Sunkibo:* "Wah, akhirnya wujud monstermu keluar juga! Kakekku dulu menghajar ratusan monster sepertimu. Sekarang giliranku!"
* **Epilog Kemenangan:** Hantaman tongkat emas memanjang mendepak monster jatuh dari koloseum langit. Sunkibo duduk santai menikmati persik di takhta.
  * *Sunkibo:* "Woy, para dewa di kahyangan! Buka mata kalian lebar-lebar! Lihat siapa sekarang penguasa bumi... Masih berani mengabaikan Sunkibo?!"

---

## 8. DESAIN ARENA & PANGGUNG PERTARUNGAN (STAGES)

FALLEN menghadirkan **7 panggung pertarungan 2D** dengan karakteristik platforming dan estetika tematik yang berbeda:

```
┌─────────────────────────────────────────────────────────────────┐
│                    THRONE PLATFORM STAGE                        │
│                 [The Claiming of the Fallen]                    │
│                                                                 │
│             ┌─────────┐                 ┌─────────┐             │
│             │Plat Kiri│                 │Plat Kanan│            │
│             └─────────┘                 └─────────┘             │
│                       ┌─────────────────┐                       │
│                       │  PLATFORM UTAMA │   [TAKHTA FALLEN]     │
│                       │   (LANTAI BATU) │                       │
│  [DEATH ZONE KIRI]    └─────────────────┘   [DEATH ZONE KANAN]  │
│~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~│
│                    [DEATH ZONE BAWAH / JURANG]                  │
└─────────────────────────────────────────────────────────────────┘
```

1. **Throne Platform Stage (`ruined_school` / The Claiming of the Fallen):**
   * *Peran:* Arena utama Final Boss The First Fallen dan puncak dari Story Mode.
   * *Fitur Layout:* 1 lantai platform batu utama yang kokoh di tengah, 2 platform gantung melayang di kiri dan kanan, serta jurang maut tanpa dasar di sekelilingnya. Takhta batu hitam berdiri megah di latar belakang.
2. **Temple Ruin Stage (`temple_ruin`):**
   * *Peran:* Panggung kuno reruntuhan candi dengan pilar-pilar batu bertingkat.
   * *Fitur Layout:* Struktur vertikal tinggi yang menuntut pemain memanfaatkan *wall jumping* untuk menyelamatkan diri saat terlempar dari platform tengah.
3. **Mad Lab Stage (`mad_lab`):**
   * *Peran:* Fasilitas bioteknologi bawah tanah tempat eksperimen genetik Kemet diciptakan.
   * *Fitur Layout:* Tangki-tangki kimia pecah, platform pipa logam bertingkat dengan pencahayaan neon dingin dan bahaya jurang saluran pembuangan limbah.
4. **Magic Waterfall Stage (`magic_waterfall`):**
   * *Peran:* Lembah tebing mistis berlatar belakang tirai air terjun raksasa bercahaya.
   * *Fitur Layout:* Platform kayu licin terapung dan batu lumut dengan jarak celah sempit yang menguji presisi *aerial dash*.
5. **Wild West Stage (`wild_west`):**
   * *Peran:* Dataran gersang berdebu pesisir selatan tempat pengembaraan Muslan.
   * *Fitur Layout:* Panggung atap bangunan kayu bergaya salon lama dengan sudut tepi rendah yang rentan terhadap *horizontal knockback*.
6. **Heaven Secret Stage (`heaven_secret`):**
   * *Peran:* Gerbang istana awan kahyangan tempat kediaman para dewa langit dan Sunkibo.
   * *Fitur Layout:* Awan-awan padat yang menjadi pijakan melayang di angkasa luas, memberi keleluasaan pertarungan udara (*aerial combat paradise*).
7. **Rooftop Stage (`rooftop`):**
   * *Peran:* Atap gedung metropolitan perkotaan dengan lanskap menara kampus di latar belakang (area Mike).
   * *Fitur Layout:* Platform datar luas dengan unit AC dan instalasi ventilasi yang dapat dijadikan perisai dari proyektil atau pijakan lompatan tinggi.

---

## 9. SISTEM KONTROL & ANTARMUKA PENGGUNA (UI/UX)

### 9.1 Skema Kontrol (1 Keyboard, 2 Pemain + Dukungan Gamepad)

| Aksi Kombat & Mobilitas | Player 1 (Keyboard WASD) | Player 2 (Keyboard Arrows) | Gamepad (Xbox / PS Layout) |
|---|---|---|---|
| **Gerak Kiri / Kanan** | `A` / `D` | `Arrow Left` / `Arrow Right` | `D-Pad Left/Right` / `L-Stick` |
| **Menunduk / Turun Platform** | `S` | `Arrow Down` | `D-Pad Down` / `L-Stick Down` |
| **Melompat / Double / Wall Jump**| `W` | `Arrow Up` | `Button Bottom (A / Cross)` |
| **Serangan / Rantai Kombo** | `J` (atau `Space`) | `Numpad 1` (atau `Keypad Enter`) | `Button West (X / Square)` |
| **Menghindar (Dash) / Tahan Blok**| `K` (atau `Shift`) | `Numpad 2` (atau `Keypad 0`) | `Right Trigger (RT / R2)` |
| **Pause / Kembali Menu** | `Escape` | `Escape` | `Start / Options` |

### 9.2 In-Game HUD & Offscreen Indicator
* **Health Bars:** Bilah HP gradasi tebal di sudut kiri atas (P1) dan kanan atas (P2) yang menampilkan sisa nyawa secara real-time disertai *white-damage ghost bar* saat menerima kombo.
* **Soul Stocks Tracker:** Ikon api/permata di bawah bilah HP yang menunjukkan sisa cadangan nyawa (1 s.d. 5 stok).
* **Match Timer:** Hitungan mundur digital retro di tengah atas layar (99s, 120s, atau simbol tak hingga `∞`).
* **Offscreen Indicator:** Jika seorang petarung terlempar keluar dari batas pandang kamera namun belum menyentuh *Death Zone*, muncul panah penunjuk arah berkedip yang melacak posisinya di udara luar layar.

### 9.3 Out-of-Game UI Flow & Cutscene Player
* **Main Menu:** Navigasi 4 opsi utama: *Campaign Mode*, *VS Mode (1v1)*, *Training Mode*, dan *Exit*.
* **Campaign Character Select:** Menampilkan potret besar, bio ringkas, arketipe, dan tingkat kesulitan yang dipilih (*Easy*, *Medium*, *Hard*).
* **Stage Select:** Carousel preview arena dengan thumbnail latar, nama panggung, dan musik tema.
* **Visual Novel Cutscene Player (`VisualNovelPlayer.gd`):** Sistem dialog sinematik dengan efek teks *typewriter* (45 karakter/detik), speaker badge dinamis berpalet warna spesifik karakter, tombol *Skip*, dan transisi *fade overlay*.

---

## 10. ARSITEKTUR TEKNIS GODOT 4 (TECHNICAL ARCHITECTURE)

```
res://
├── assets/
│   ├── characters/       # Spritesheet & animasi Aron, Butler, Kemet, Mike,
│   │                     # Muslan, Om Hami, Rin, Sunkibo, The First Fallen
│   ├── stages/           # Latar belakang beresolusi tinggi & tileset 2D
│   ├── ui/               # Font retro, frame HP bar, ikon tombol, potret VN
│   └── audio/            # BGM laga arcade & sound effect benturan hitstop
└── src/
    ├── characters/       # FighterBase.gd, Aron.gd, Butler.gd, Kemet.gd,
    │                     # Mike.gd, Muslan.gd, OmHami.gd, Rin.gd, Sunkibo.gd,
    │                     # TheFirstFallen.gd, DummyTarget.gd
    ├── combat/           # Hitbox.gd, Hurtbox.gd, CombatData.gd
    ├── core/             # GameManager.gd, BrawlhallaCamera.gd,
    │                     # FighterAIController.gd, PlayerInput.gd
    ├── stages/           # ThronePlatformStage.gd, DeathZone.gd, Stage Scenes
    └── ui/               # MainMenu, CharacterSelect, CampaignCharacterSelect,
                          # StageSelect, HUD, LoadingScreen, PauseMenu,
                          # cutscenes/ (CampaignStoryScene, VisualNovelPlayer)
```

### 10.1 Core Classes & Desain Berorientasi Objek
1. **`FighterBase.gd` (`CharacterBody2D`):**
   * Pondasi tunggal dari seluruh petarung di dalam game.
   * Mengatur mesin status (`enum State { IDLE, WALK, RUN, JUMP, FALL, WALL_SLIDE, ATTACK, DASH, BLOCK, HURT, DEAD }`).
   * Menangani fisika gerak, akselerasi, friksi udara/lantai, gravitasi, *double jump*, kalkulasi knockback, dan penerimaan *damage*.
2. **`TheFirstFallen.gd` (`FighterBase`):**
   * Kelas spesifik Boss Akhir yang memperluas `FighterBase`.
   * Mengimplementasikan `BossPhase.PHASE_1_ARMORED` dan `BossPhase.PHASE_2_BEAST`, *Anti-Ring-Out pit recovery*, *Poise absorption*, dan logika *Boss AI decision tree*.
3. **`Hitbox.gd` (`Area2D`):**
   * Node pemicu serang. Menyimpan variabel `damage`, `base_knockback`, `knockback_direction`, `hitstun_duration`, dan `attacker_node`.
4. **`Hurtbox.gd` (`Area2D`):**
   * Node penerima serang. Menghubungkan sinyal deteksi `area_entered` dengan kalkulasi damage dan mitigasi status *block* pada `FighterBase`.
5. **`BrawlhallaCamera.gd` (`Camera2D`):**
   * Kamera dinamis yang otomatis menghitung titik tengah (*bounding box center*) seluruh petarung yang aktif di arena.
   * Melakukan *smooth zoom in/out* sesuai jarak antar pemain, menjaga kedua petarung tetap berada dalam frame layar dengan batas min/max zoom yang nyaman, serta memicu *screen shake* saat serangan finisher atau hantaman boss mendarat.
6. **`GameManager.gd` (`Autoload / Singleton`):**
   * Pusat kendali alur permainan global yang persisten antar perpindahan scene.
   * Mengelola array `active_players`, penugasan device (WASD, Arrows, Gamepad, atau AI Bot), pemilihan stage, penghitungan stage kampanye (`campaign_stage_index`), dan transisi ke `LoadingScreen`.

---

## 11. ARAH SENI (VISUAL ART & AUDIO DIRECTION)

### 11.1 Visual Art Style
* **Gaya:** Pixel Art 16-bit bergaya arcade pertengahan era 90-an dengan palet warna kontras tinggi. Karakter didesain menonjol dengan *silhouette reading* yang jelas agar tidak tenggelam dalam latar belakang.
* **Efek Visual (VFX):**
  * *Slash & Impact Sparks:* Kilatan cakar, api, petir nebula, dan tebasan pedang saat serangan bersentuhan dengan hurtbox.
  * *Void Crimson Aura:* Efek partikel hitam kemerahan pada The First Fallen saat memasuki Fase 2.
  * *Flash on Hit:* Kedipan putih singkat (1 frame) pada karakter saat menerima benturan serangan berat.

### 11.2 Audio Direction
* **Musik (BGM):** Aransemen synth-rock berenergi tinggi yang memadukan distorsi gitar elektrik arcade dengan hentakan drum bertempo cepat (135 - 160 BPM) untuk panggung laga, dan paduan choir gelap orkestral sintetis untuk pertarungan The First Fallen.
* **Sound Effects (SFX):** Suara benturan berbobot (*heavy thud*, *blade swoosh*, *glass clink*, *wood impact*, *flame burst*) yang memberikan kepuasan auditif instan (*visceral tactile feedback*) di setiap pukulan kombo.

---

## 12. LAMPIRAN: NERACA BALANCING & MATRIKS KESULITAN

### 12.1 Matriks Kesulitan AI Kampanye

| Parameter AI | Tingkat Easy | Tingkat Medium (Default) | Tingkat Hard | The First Fallen (Boss AI) |
|---|---|---|---|---|
| **Interval Reaksi Input** | 0.45s - 0.70s | 0.25s - 0.45s | 0.10s - 0.20s | 0.12s - 0.30s (F1: 0.25-0.5s) |
| **Frekuensi Block/Parry** | 15% dari serangan masuk | 40% dari serangan masuk | 75% dari serangan masuk | Imunitas Super Poise (0.08x) |
| **Penggunaan Air Recovery** | Terkadang gagal | Konsisten double jump | Optimal Wall Jump | Teleportasi Void Anti-Ring-Out |
| **Agresivitas Kombo** | Jarang menyelesaikan 3-hit | Menyelesaikan jika kena | Optimal chaining & air slam | Full 3-hit combo agresif 1.2x spd |

### 12.2 Formula Kalkulasi Knockback
Besaran dorongan knockback akhir yang diterima petarung dihitung melalui persamaan:

$$\vec{V}_{\text{knockback}} = \left( \vec{D}_{\text{direction}} \times B_{\text{base}} \right) \times \left( 1.0 + \frac{HP_{\text{lost}}}{HP_{\text{max}}} \times 0.65 \right) \times R_{\text{poise}}$$

* $\vec{D}_{\text{direction}}$: Vektor normalisasi arah peluncuran dari Hitbox penyerang.
* $B_{\text{base}}$: Nilai dasar knockback serangan (misal: Finisher = 620.0).
* $\frac{HP_{\text{lost}}}{HP_{\text{max}}}$: Skala persentase kerusakan yang telah diderita korban (semakin sekarat HP korban, semakin jauh ia terlempar).
* $R_{\text{poise}}$: Pengali resistansi bobot karakter (Karakter biasa: `1.0`, Om Hami: `0.85`, The First Fallen Fase 1: `0.08`, Fase 2: `0.06`).

---

## 13. KESIMPULAN & STATUS PRODUKSI

Dokumen Game Design Document (GDD) versi 2.0 ini mencerminkan status aktual implementasi game **FALLEN** di Godot Engine 4.3. Seluruh fitur utama—mulai dari pertempuran 1v1 lokal, sistem 8 karakter unik penantang takhta, arena panggung terapung vertikal, alur visual novel kampanye, hingga pertempuran dua fase melawan sang penguasa purba **The First Fallen**—telah selesai diimplementasikan, divalidasi, dan dikemas ke dalam build siap rilis.

Dokumen ini menjadi acuan tunggal (*single source of truth*) untuk pengembangan konten, ekspansi naratif, balancing patch, serta integrasi pembaruan lanjutan proyek **FALLEN**.

*(Akhir dari Dokumen Game Design)*
