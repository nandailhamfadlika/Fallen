# GAME DESIGN DOCUMENT (GDD)
# FALLEN
> *"Siapa yang Pantas Duduk di Kursi Fallen?"*

---

## 1. Executive Summary & Vision

### 1.1 Visi Game
**FALLEN** dirancang sebagai game **2D PvP Platform Fighter** yang mengutamakan tempo pertarungan cepat, fluiditas gerakan (*movement*), penguasaan *combo*, dan pemanfaatan arena secara taktis. Karakter didesain memiliki identitas mekanik dan visual yang unik, menciptakan dinamika pertarungan yang berbeda di setiap pertarungan.

### 1.2 Gameplay Hook
Pertarungan 1 vs 1 lokal (*couch multiplayer*) memperebutkan gelar tertinggi dan takhta: **"Kursi Fallen"**. Keunikan FALLEN terletak pada perpaduan dua gaya pertarungan legendaris:
* **Tradisi Fighting Game Klasik (ala *The King of Fighters*):** Sistem kombo terangkai (light/heavy combo chaining), hitbox/hurtbox presisi, dan reduksi bar HP hingga knock-out.
* **Platform Fighter (ala *Brawlhalla* / *Super Smash Bros*):** Mobilitas vertikal tinggi (double jump, wall slide, wall jump) dan ancaman *ring out* (jatuh ke *Death Zone* / jurang).

### 1.3 Target Platform & Spesifikasi
* **Platform:** PC (Windows / Linux / macOS)
* **Mode:** 1 vs 1 Local Shared Keyboard / Controller
* **Engine:** Godot Engine 4.x (GDScript)
* **Visual Style:** 2D Pixel Art Gritty / Dark Fantasy

---

## 2. Project Scope & Roadmap

| Kategori | Di Dalam Scope (Current Prototype) | Di Luar Scope (Future Expansion) |
|---|---|---|
| **Roster** | 3 Karakter Playable (*Aron*, *Kemet*, *Om Hami*) + 1 Training Dummy | Penambahan 8+ Karakter, Guest Fighter |
| **Arena** | 2 Arena (*Throne Platform Stage*, *Temple Ruin Stage*) | Hazard arena interaktif, dynamic weather |
| **Game Mode** | 1 vs 1 Local PvP, Training Mode | Single-player Story Mode, Online Rollback Netcode |
| **Sistem Combat** | Combo 3-Step, Jump, Double Jump, Wall Slide, Wall Jump, Hitbox/Hurtbox, Knockback, Death Zone | Super Meter / EX Moves, Parrying, Air Dashing |
| **Audio & UI** | Main Menu, Character Select, Stage Select, In-Game HUD (HP Bar & Timer), Victory/Rematch Screen | Voice acting lengkap, Full Cinematic Cutscene |

---

## 3. Sistem Gameplay & Core Mechanics

### 3.1 Kondisi Kemenangan (Dual Win Condition)
Pemain dapat memenangkan pertandingan melalui dua cara:
1. **HP Depletion (Knock Out):** Menguras bar HP lawan dari 100/110 hingga mencapai 0.
2. **Ring Out (Death Zone Elimination):** Memanfaatkan *knockback* serangan atau situasi di udara untuk melempar lawan ke luar batas panggung (*Death Zone*).

### 3.2 Feedback & Internal Economy Loop
```
[Serangan Masuk] ──> Berkurangnya HP (Negative Feedback) ──> Defensif / Recovery
       │
       └──> Terkena Knockback ──> Mendekati Tepi Arena (Position Pressure) ──> Risiko Death Zone
       │
[Pembacaan Pola Lawan] ──> Menghindar / Wall Jump Counter ──> Buka Celah Combo (Positive Feedback)
```

* **Health Point (HP):** Sumber daya ketahanan karakter (100 - 110 HP).
* **Posisi Arena (Spatial Positioning):** Sumber daya taktis. Berada di tengah arena adalah posisi aman; terpojok ke tepi platform meningkatkan risiko terlempar keluar.

### 3.3 Sistem Mobilitas (Movement System)
* **Grounded Movement:** Jalan (*Walk*) & Lari (*Run*) dengan friksi deselerasi responsif.
* **Aerial Movement:** *Jump*, *Fall Gravity*, dan *Double Jump* (air jump) untuk recovery saat terlempar.
* **Wall Mechanics:** 
  * *Wall Slide:* Menempel dan meluncur perlahan di dinding panggung.
  * *Wall Jump:* Menendang dinding untuk melompat kembali ke platform utama.

### 3.4 Sistem Combo Chaining & Input Buffering
Sistem kombo menggunakan *state machine* dengan *combo window*:
* Setiap serangan memiliki jeda di mana input serangan berikutnya dapat di-*buffer* (`has_buffered_attack`).
* Jika tombol serang ditekan pada jendela yang tepat (`can_chain_combo`), karakter akan mengeksekusi sambungan kombo langkah berikutnya (Step 1 -> Step 2 -> Finisher) dengan animasi dan *damage* yang meningkat.

---

## 4. Karakter & Roster (Fighter Showcase)

### 4.1 Aron — "The Agile Striker"
* **Arketipe:** Balanced Striker / Street Boxer
* **Karakteristik:** Petarung serba bisa dengan kelincahan tinggi dan penguasaan teknik tinju jalanan yang cepat. Sangat efektif dalam pertarungan jarak dekat (*close-quarters*).
* **Base Stats:**
  * HP: `100.0`
  * Speed: `280.0`
  * Jump Velocity: `-520.0`
  * Wall Jump Impulse: `(380.0, -480.0)`
* **Combo Chain:**
  1. *Step 1: Jab* — Pukulan lurus cepat pembuka kombo.
  2. *Step 2: Cross* — Pukulan silang bertenaga yang mendorong musuh.
  3. *Step 3: Uppercut Finisher* — Pukulan ke atas dengan knockback vertikal tinggi, ideal melempar musuh ke udara.

### 4.2 Kemet — "The Claw Assassin"
* **Arketipe:** Rushdown Assassin
* **Karakteristik:** Pembunuh bayaran berkecepatan tinggi yang dipersenjatai cakar logam di buku-buku jarinya (*retractable knuckle claws*). Memiliki sprint tercepat dan mobilitas dinding terbaik.
* **Base Stats:**
  * HP: `100.0`
  * Speed: `310.0` (Tertinggi)
  * Jump Velocity: `-530.0`
  * Wall Jump Impulse: `(400.0, -500.0)`
* **Combo Chain:**
  1. *Step 1: Quick Claw Thrust* — Tusukan kilat berjangkauan menusuk.
  2. *Step 2: Dual X-Cross Slash* — Ayunan cakar menyilang ganda mematikan.
  3. *Step 3: Rising Crescent Finisher* — Serangan memutar melompat ke atas yang mencabik lawan.

### 4.3 Om Hami — "The Cane Zoner & Heavy Brawler"
* **Arketipe:** Mid-range Zoner / Heavy Bruiser
* **Karakteristik:** Tetua petarung jalanan berbadan kekar yang memanfaatkan tongkat pusaka dan kepulan asap. Memiliki jangkauan serang terjauh dan ketahanan tubuh paling tebal, namun pergerakan lebih lambat.
* **Base Stats:**
  * HP: `110.0` (Paling Tangguh)
  * Speed: `250.0`
  * Jump Velocity: `-500.0`
  * Wall Jump Impulse: `(350.0, -460.0)`
* **Combo Chain:**
  1. *Step 1: Long Reach Poke* — Sodokan tongkat jarak menengah yang menahan laju rushdown lawan.
  2. *Step 2: Low Cane Sweep* — Ayunan tongkat bawah yang mengincar kaki lawan.
  3. *Step 3: Heavy Smoke Smash Finisher* — Hantaman telak berkekuatan besar dengan efek asap dan knockback horizontal masif.

---

## 5. Arena & Stage Design

### 5.1 Throne Platform Stage (Panggung Utama)
* **Konsep:** Aula takhta tempat "Kursi Fallen" berada di latar belakang.
* **Layout:**
  * 1 Platform utama lebar di bagian tengah.
  * 2 Platform terapung simetris di sisi kiri dan kanan untuk manuver vertikal.
  * *Death Zone* luas di bagian bawah dan samping batas kamera.

### 5.2 Temple Ruin Stage
* **Konsep:** Reruntuhan kuil kuno bernuansa mistis dan misterius.
* **Layout:** Variasi pilar bertingkat yang menuntut pemain memanfaatkan *wall jumping* untuk bertahan dari eliminasi.

---

## 6. Kontrol & Skema Input

Game dirancang untuk **1 Keyboard, 2 Pemain** secara lokal:

| Aksi | Player 1 (P1) | Player 2 (P2) |
|---|---|---|
| **Bergerak Kiri / Kanan** | `A` / `D` | `Arrow Left` / `Arrow Right` |
| **Menunduk / Turun Platform** | `S` | `Arrow Down` |
| **Melompat / Wall Jump** | `W` | `Arrow Up` |
| **Serangan / Kombo** | `J` (atau `Space`) | `Numpad 1` (atau `Keypad Enter`) |
| **Pause / Menu** | `Escape` | `Escape` |

---

## 7. Arsitektur Teknis (Godot 4)

### 7.1 Struktur Folder Proyek
```
res://
├── assets/
│   ├── characters/       # Sprite animasi Aron, Kemet, Om Hami
│   ├── stages/           # Latar belakang dan platform
│   └── ui/               # Font, tombol, frame HUD
└── src/
    ├── characters/       # FighterBase.gd, Aron.gd, Kemet.gd, OmHami.gd
    ├── combat/           # Hitbox.gd, Hurtbox.gd, CombatData.gd
    ├── core/             # GameManager.gd
    ├── stages/           # ThronePlatformStage.gd, TempleRuinStage.gd, DeathZone.gd
    └── ui/               # MainMenu, CharacterSelect, StageSelect, HUD
```

### 7.2 Core Classes & Modularitas
* **`FighterBase.gd`:** Node kelas induk turunan `CharacterBody2D`. Mengelola mesin status (*State Machine*), gravitasi, penerimaan damage, knockback, dan kalkulasi gerak.
* **`Hitbox.gd`:** Area deteksi serang (`Area2D`). Menyimpan data damage, arah dan besar knockback, serta referensi penyerang.
* **`Hurtbox.gd`:** Area deteksi terima serang (`Area2D`). Terkoneksi ke sinyal pengurangan HP pada `FighterBase`.
* **`GameManager.gd`:** Singleton / Autoload pengelola aliran game (skor, durasi ronde, transisi scene antar menu dan stage).

---

## 8. Panduan Peningkatan Animasi (Visual Polish Roadmap)

Untuk mengatasi permasalahan animasi yang terasa patah-patah (*choppy*):
1. **Target Frame Rate Animasi:** Tingkatkan jumlah frame dari 4 frame menjadi 8–16 frame per *action state* (standar 12-24 FPS).
2. **Pipeline 3D-to-2D Spritesheet:**
   * Model dan rig di Tripo3D / Blender.
   * Render kamera ortografis samping (Orthographic Camera) dengan latar transparan.
   * Kemas frame menjadi Spritesheet PNG berkualitas tinggi.
3. **Interpolasi & Blending Godot:**
   * Aktifkan `Physics Interpolation` pada Project Settings untuk pergerakan mulus di layar 60Hz - 144Hz+.
   * Gunakan `AnimationTree` dengan *crossfade* 0.1s - 0.2s untuk transisi antar state (misal dari *Run* ke *Idle*).

---

## 9. Penutup & Tim Pengembang
Dokumen ini menjadi acuan tunggal (*single source of truth*) dalam pengembangan mekanik, estetika, dan implementasi kode untuk game **FALLEN**.
