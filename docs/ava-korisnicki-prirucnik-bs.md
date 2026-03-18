# AVA — Tvoja KI Marketing Asistentica
## Potpuni Korisnički Priručnik

**Za koga je ovaj priručnik?**
Ovaj priručnik objašnjava korak po korak kako radiš s Avom.
Ne trebaš tehničko znanje niti marketing obrazovanje.
Sve je objašnjeno tako jednostavno da možeš odmah početi.

---

# SADRŽAJ

| Poglavlje | Tema | Stranica |
|-----------|------|----------|
| 1 | Šta je Ava? — Tvoja KI asistentica | 3 |
| 2 | Koji AI modeli rade iza Ave | 4 |
| 3 | Koji skill radi kada — pregled | 6 |
| 4 | 4 adrese tvog sistema | 8 |
| 5 | Prva prijava — kako početi | 9 |
| 6 | OpenClaw Dashboard — upravljanje Avom | 10 |
| 7 | Razgovor s Avom — komande i primjeri | 12 |
| 8 | Content planovi — kako Ava planira tvoje objave | 14 |
| 9 | Odobravanje ili odbijanje plana | 16 |
| 10 | Postiz — upravljanje kalendarom sadržaja | 18 |
| 11 | Povezivanje društvenih mreža | 20 |
| 12 | Automatski zadaci (Cron-Jobs) | 22 |
| 13 | Upravljanje leadovima — upiti kupaca | 24 |
| 14 | Izvještaji — šta funkcioniše dobro? | 26 |
| 15 | Česti problemi i rješenja | 27 |
| 16 | Važni pristupni podaci — pregled | 29 |

---

---

# Stranica 3 — Poglavlje 1: Šta je Ava?

## Ava je tvoja digitalna marketing saradnica

Zamislite da imaš saradnicu koja:
- Radi za tebe **24 sata, 7 dana u tjednu**
- Automatski **planira i objavljuje** Instagram i Facebook postove
- **Odgovara na poruke** kupaca
- Svake sedmice kreira **content planove** i šalje ti ih na odobravanje
- Sama sebe poboljšava i uči iz grešaka

To je Ava.

---

## Šta Ava NE radi (bez tvoje dozvole)

Ava **nikad** ne objavljuje post bez tvog odobrenja.
Uvijek ti prvo pokaže plan i čeka tvoje odobrenje.
**Ti uvijek imaš posljednju riječ.**

---

## Kako komuniciraš s Avom?

Imaš dvije mogućnosti:
1. **Putem Facebook Messengera** — jednostavno napiši na svoju stranicu
2. **Putem Dashboarda** — kroz web sučelje na računalu

---

## Tok rada — kako sve funkcioniše zajedno

```
TI                    AVA                    SISTEM
 │                     │                       │
 │  Svaki ponedjeljak  │                       │
 │ ←─────────────────── Plan za 2 sedmice      │
 │                     │                       │
 │  "plan odobren"     │                       │
 │ ─────────────────→  │                       │
 │                     │  Piše tekstove        │
 │                     │ ──────────────────→   │
 │                     │  Provjera kvalitete   │
 │                     │ ──────────────────→   │
 │                     │  Objavljuje u Postiz  │
 │                     │ ──────────────────→   │
 │                     │                       │
 │  ←─────────────────── Postovi objavljeni ✅ │
```

---

---

# Stranica 4 — Poglavlje 2: Koji AI modeli rade iza Ave

## Zašto više modela?

Ava koristi nekoliko različitih AI modela. Svaki je specijaliziran za određene zadatke. Ako jedan model nije dostupan, automatski se prebacuje na sljedeći.

---

## Pregled modela

### 🥇 Primarni model — GLM-5 Cloud
```
Ime modela: ollama/glm-5:cloud
```

**Za šta se koristi:**
- Pisanje svih tekstova (caption, odgovori, planovi)
- Razgovor s tobom u chatu
- Analiza poruka od kupaca
- Kreiranje content planova
- Sve skille: planner, writer, reviewer, inbox, lead-nurturing

**Zašto ovaj model?**
GLM-5 je izuzetno sposoban za višejezičan sadržaj — odlično piše na bosanskom, njemačkom i srpskom jeziku. Razumije kulturni kontekst (Ramadan, Bajram, regionalni praznici).

---

### Stranica 5

### 🥈 Rezervni model 1 — MiniMax M2.5 Cloud
```
Ime modela: ollama/minimax-m2.5:cloud
```

**Za šta se koristi:**
- Preuzima sve zadatke ako GLM-5 nije dostupan
- Posebno dobar za duže tekstove i analize
- Izvještaji i analytics

**Kada se aktivira:** Automatski, ako GLM-5 ne odgovori u roku od 30 sekundi.

---

### 🥉 Rezervni model 2 — Kimi K2.5 Cloud
```
Ime modela: ollama/kimi-k2.5:cloud
```

**Za šta se koristi:**
- Treća linija odbrane ako prethodni modeli nisu dostupni
- Kreativno pisanje, Reel koncepti, Story ideje

**Kada se aktivira:** Automatski, ako prva dva modela ne odgovaraju.

---

### 🔄 Rezervni model 3 — Qwen 3.5 Uncensored Cloud
```
Ime modela: ollama/qwen3.5:397b
```

**Za šta se koristi:**
- Zadnja rezerva za sve zadatke
- Bez filtera — može pisati direktniji marketinški sadržaj

**Kada se aktivira:** Samo ako sva tri prethodna modela nisu dostupna.

---

### 📝 Napomena o slikama

GLM-5 je multimodalni model — razumije i tekst i slike bez posebnog Vision modela.
Kada kupac pošalje sliku, GLM-5 je direktno obrađuje.

---

## Promjena modela u Dashboardu

Ako želiš ručno odabrati model:
1. Otvori Dashboard
2. Klikni na **Chat**
3. Vidi dropdown na vrhu: **"Default (glm-5:cloud)"**
4. Klikni i odaberi drugi model

> 💡 **Preporuka:** Ostavi na "Default" — Ava automatski bira najbolji dostupni model.

---

---

# Stranica 6 — Poglavlje 3: Koji skill radi kada

## Šta su skills?

Skills su specijalizirani "djelovi" Avine inteligencije. Svaki skill je zadužen za jednu specifičnu funkciju. Ava automatski odabire pravi skill za pravi zadatak.

---

## Pregled svih skills

---

### 📅 SKILL: Planner — Content strategija

| | |
|--|--|
| **Kada se aktivira** | Automatski svaki ponedjeljak u 09:00 |
| **Također** | Kada napišeš: *"Napravi plan"*, *"Šta objavljujemo ove sedmice?"* |
| **Model** | GLM-5 Cloud (primarni) |
| **Trajanje** | 2–5 minuta |

**Šta radi:**
1. Analizira zadnjih 7 dana — šta je dobro funkcionisalo
2. Provjerava aktivne kampanje
3. Gleda praznike i događaje (DE/BA/RS)
4. Kreira plan za **1–2 sedmice** (standardno 14 postova)
5. Šalje ti plan na odobravanje putem Messengera

**Pravila koja primjenjuje:**
- 70% organski sadržaj, 30% reklame/proizvodi
- Nikad dva ista formata jedan za drugim
- Uvijek predlaže A/B varijante za važne postove

---

### Stranica 7

### ✍️ SKILL: Writer — Pisanje tekstova

| | |
|--|--|
| **Kada se aktivira** | Automatski nakon što odobravaš plan |
| **Također** | Kada napišeš: *"Napiši Instagram post o..."*, *"Napiši caption za..."* |
| **Model** | GLM-5 Cloud (primarni) |
| **Trajanje** | 30 sekundi po postu |

**Šta radi:**
1. Uzima plan od Plannera
2. Piše potpune caption tekstove na željenom jeziku
3. Dodaje hashtagove
4. Predaje Revieweru na provjeru

---

### 🔍 SKILL: Reviewer — Provjera kvalitete

| | |
|--|--|
| **Kada se aktivira** | Automatski nakon Writer-a |
| **Ručno** | Kada napišeš: *"Provjeri ovaj tekst"* |
| **Model** | GLM-5 Cloud (primarni) |
| **Trajanje** | 10–20 sekundi po postu |

**Šta provjerava:**
- Ton i glas brenda
- Pravopis i gramatika (BS/DE/SR)
- Usklađenost (nema problematičnog sadržaja)
- Relevantnost hashtagova
- Ako pronađe rizik → eskalira tebi na odobravanje

---

### 📤 SKILL: Publisher — Objavljivanje

| | |
|--|--|
| **Kada se aktivira** | Automatski u zakazano vrijeme, nakon Reviewer odobrenja |
| **Model** | Nije model — direktna API veza s Postizom |
| **Trajanje** | 5–10 sekundi |

**Šta radi:**
1. Čeka zakazano vrijeme
2. Objavljuje putem Postiz API-ja
3. Bilježi rezultat
4. Sprema potvrdu objave u memoriju

---

### 📥 SKILL: Inbox — Obrada poruka

| | |
|--|--|
| **Kada se aktivira** | Svako primanje poruke na Facebook/Instagram |
| **Automatska provjera** | Svake 15 minuta |
| **Model** | GLM-5 Cloud (primarni) |
| **Trajanje** | 5–15 sekundi |

**Šta radi:**
1. Klasificira poruku (lead, pitanje, podrška, spam)
2. Na jednostavna pitanja odgovara automatski
3. Složene upite eskalira tebi
4. Sprema podatke o leadovima u memoriju

---

### 🌱 SKILL: Lead-Nurturing — Praćenje kupaca

| | |
|--|--|
| **Kada se aktivira** | Automatski svaki dan u 10:00 |
| **Okidač** | Kada Inbox klasificira poruku kao "lead" |
| **Model** | GLM-5 Cloud (primarni) |
| **Trajanje** | 1–3 minute |

**Šta radi:**
1. Sprema podatke o leadu (ime, interes, vrijeme kontakta)
2. Šalje follow-up poruke nakon 24h, 48h, 7 dana
3. Prati status konverzije
4. Obavještava te o vrućim leadovima

---

### 📊 SKILL: Analytics — Analiza performansi

| | |
|--|--|
| **Kada se aktivira** | Automatski svaki ponedjeljak u 08:00 |
| **Ručno** | Kada napišeš: *"Kako idu naši postovi?"* |
| **Model** | MiniMax M2.5 (specijalizovan za analize) |
| **Trajanje** | 3–8 minuta |

**Šta radi:**
1. Čita performanse postova iz Postiza
2. Analizira stope angažmana
3. Identificira top postove
4. Daje preporuke za sljedeću sedmicu
5. Sprema učenja u memoriju za Planner

---

### 🧠 SKILL: Memory-Critic — Čišćenje memorije

| | |
|--|--|
| **Kada se aktivira** | Automatski svake nedjelje u 02:00 |
| **Model** | GLM-5 Cloud (primarni) |
| **Trajanje** | 5–15 minuta |

**Šta radi:**
- Provjerava sačuvane informacije na relevantnost
- Uklanja zastarjele unose
- Kondenzira slične unose
- Poboljšava kvalitetu pretrage

---

### 🔺 SKILL: Escalation — Eskalacija

| | |
|--|--|
| **Kada se aktivira** | Kada Reviewer pronađe rizik, ili nejasne poruke |
| **Model** | GLM-5 Cloud |
| **Trajanje** | Odmah — hitna obavijest |

**Šta radi:**
- Šalje ti obavijest putem Messengera
- Čeka tvoj odgovor
- Izvršava tvoje upute

---

### 🔮 SKILL: Reflexion — Samorefleksija

| | |
|--|--|
| **Kada se aktivira** | Automatski svaki dan u 23:00 |
| **Model** | GLM-5 Cloud |
| **Trajanje** | 2–5 minuta |

**Šta radi:**
1. Analizira današnje akcije
2. Identificira greške i poboljšanja
3. Ažurira vlastita pravila (samoučenje)
4. Sprema spoznaje u memoriju

---

---

# Stranica 8 — Poglavlje 4: 4 adrese tvog sistema

## Tvoji najvažniji linkovi

---

### 🗓️ Link 1 — Postiz (Content kalendar)
```
https://marki.ac.activi.io
```
**Šta je to?** Ovdje vidiš sve zakazane postove u kalendaru.
Kao digitalni urednički plan.

---

### 🤖 Link 2 — Ava Dashboard (upravljanje)
```
https://oc.marki.ac.activi.io/#token=5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```
**Šta je to?** Ovdje razgovaraš direktno s Avom i upravljaš sistemom.

---

### 📱 Link 3 — Facebook Webhook (samo za Meta)
```
https://meta.marki.ac.activi.io/webhook
```
**Šta je to?** Ova adresa prima poruke od Facebooka/Instagrama.
**Ne otvaraš je sam** — Facebook je koristi automatski.

---

### 🔒 Link 4 — Ava Dashboard (siguran, Tailscale)
```
https://hetzner4-marki.tail47b17c.ts.net/#token=5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```
**Šta je to?** Isti kao Link 2, ali dostupan samo u Tailscale mreži. Sigurniji.

---

### 🔑 Tvoj Dashboard token (lozinka)
```
5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```

---

---

# Stranica 9 — Poglavlje 5: Prva prijava

## Postiz — prva prijava

**Korak 1:** Otvori u browseru: `https://marki.ac.activi.io`

**Korak 2:** Vidiš Postiz stranicu za prijavu. Klikni **"Create Account"**

**Korak 3:** Unesi svoju email adresu i lozinku

**Korak 4:** Klikni **"Create Account"**

**Korak 5:** Prijavljen/a si i vidiš dashboard

---

## OpenClaw Dashboard — prva prijava

**Korak 1:** Otvori dashboard link iz Poglavlja 4 (Link 2)

**Korak 2:** Vidiš prozor za spajanje s OpenClaw logom

**Korak 3:** Token je već unesen (dio linka)

**Korak 4:** Klikni **"Verbinden"** (Spoji)

**Korak 5:** Pri prvom korištenju pojavljuje se "pairing required"
→ To je normalno. Obavijesti svog administratora — on odobrava tvoj uređaj.
→ Nakon toga veza funkcioniše odmah.

**Korak 6:** Vidiš dashboard s Avom

---

---

# Stranica 10 — Poglavlje 6: OpenClaw Dashboard — pregled

## Izgled dashboarda

```
┌─────────────────┬──────────────────────────────────────┐
│  LIJEVA STRANA  │         DESNA STRANA                 │
│  (Navigacija)   │         (Sadržaj)                    │
│                 │                                      │
│  OpenClaw       │  [Chat s Avom]                       │
│  ──────────     │                                      │
│  📊 Pregled     │  Ti pišeš ovdje...                   │
│  💬 Chat        │                                      │
│  📅 Kalendar    │                                      │
│  👥 Kontakti    │                                      │
│  ⚙️ Postavke    │                                      │
│                 │                                      │
└─────────────────┴──────────────────────────────────────┘
```

---

## Najvažniji dijelovi — objašnjenje

---

### Stranica 11

### 📊 Pregled (Übersicht)
**Šta vidiš:** Trenutne sistemske informacije, zadnje aktivnosti Ave, status veza.

**Kada koristiš:** Kada brzo želiš provjeriti da li sve radi.

---

### 💬 Chat
**Šta vidiš:** Prozor za chat — kao WhatsApp, ali s Avom.

**Skill koji se koristi:** Zavisi od pitanja — automatski odabire pravi skill
**Model:** GLM-5 Cloud (primarni)

**Kada koristiš:** Uvijek kada želiš nešto pitati ili naručiti Avi.

---

### 📅 Zakazani zadaci (Geplante Aufgaben)
**Šta vidiš:** Svi automatski zadaci (dnevno, sedmično, svaki sat).

**Kada koristiš:** Kada želiš upravljati automatskim rasporedom Avine aktivnosti.

---

### ⚙️ Postavke → Communications (Komunikacija)
**Šta vidiš:** Svi povezani kanali (Facebook, Instagram, Telegram, itd.)

**Kada koristiš:** Kada želiš spojiti novi kanal.

---

### ⚙️ Postavke → Konfiguracija
**Šta vidiš:** Tehničke postavke za Avu (model, gateway).

**Kada koristiš:** Rijetko — samo ako mijenjаš model ili gateway postavke.

---

---

# Stranica 12 — Poglavlje 7: Razgovor s Avom

## Kako pišeš s Avom

Otvori Dashboard → Klikni lijevo na **"Chat"**

Vidiš gore **"main"** (to je Ava) i model **"glm-5:cloud"**

Napiši svoju poruku dole i pritisni Enter.

---

## Najvažnije komande i šta pokreću

### 📅 Planiranje sadržaja — SKILL: Planner

| Šta pišeš | Šta Ava radi | Model |
|-----------|-------------|-------|
| `"Šta objavljujemo ove sedmice?"` | Kreira 7-dnevni plan | GLM-5 |
| `"Napravi plan za sljedeće 2 sedmice"` | Kreira 14-dnevni plan | GLM-5 |
| `"Planiraj sadržaj za Ramazan"` | Tematski Ramazan plan | GLM-5 |
| `"Napravi plan za [tema]"` | Plan po tvojoj temi | GLM-5 |

---

### Stranica 13

### 📊 Izvještaji — SKILL: Analytics

| Šta pišeš | Šta Ava radi | Model |
|-----------|-------------|-------|
| `"Kako idu naši postovi?"` | Pregled performansi | MiniMax M2.5 |
| `"Šta je prošle sedmice dobro funkcionisalo?"` | Top postovi i uvidi | MiniMax M2.5 |
| `"Koji hashtagovi rade najbolje?"` | Hashtag analiza | MiniMax M2.5 |

---

### 👥 Kupci i leadovi — SKILL: Lead-Nurturing + Inbox

| Šta pišeš | Šta Ava radi | Model |
|-----------|-------------|-------|
| `"Koje nove leadove imamo?"` | Prikazuje nove upite kupaca | GLM-5 |
| `"Napiši [kupcu] follow-up poruku"` | Automatski šalje poruku | GLM-5 |
| `"Ko još nije dobio odgovor?"` | Prikazuje otvorene upite | GLM-5 |

---

### ✏️ Kreiranje sadržaja — SKILL: Writer

| Šta pišeš | Šta Ava radi | Model |
|-----------|-------------|-------|
| `"Napiši Instagram post o [temi]"` | Kreira caption + hashtagove | GLM-5 |
| `"Napiši to na bosanskom/njemačkom/srpskom"` | Prevodi post | GLM-5 |
| `"Skrati post"` | Skraćuje tekst | GLM-5 |
| `"Napravi to formalnije/ležernije"` | Prilagođava ton | GLM-5 |

---

### 🔧 Upravljanje

| Šta pišeš | Šta Ava radi |
|-----------|-------------|
| `/new` | Pokreće novi razgovor |
| `/reset` | Resetuje sesiju |
| `"Šta si radila danas?"` | Ava daje sažetak aktivnosti |

---

## Također putem Facebook Messengera!

Kada su Meta ključevi uneseni, možeš pisati Avi direktno putem Messengera na svojoj Facebook stranici. Iste komande, iste funkcije.

---

---

# Stranica 14 — Poglavlje 8: Content planovi s Avom

## Kako funkcioniše automatski content plan?

**SKILL koji se koristi: Planner**
**Model: GLM-5 Cloud**

Ava automatski svaki ponedjeljak ujutro u 09:00 sati kreira plan za sljedeće 1–2 sedmice.

**Tok:**

```
Ponedjeljak 09:00
       ↓
[SKILL: Analytics] Ava analizira: zadnji postovi,
                   šta je dobro funkcionisalo,
                   praznici, aktuelni trendovi
       ↓
[SKILL: Planner] Ava kreira: plan za 14 postova (1 dnevno)
       ↓
Ava ti šalje: zahtjev za odobravanje putem Messengera
       ↓
Ti odgovaraš: ✅ odobren / ✏️ promijeni / ❌ odbijen
       ↓
Nakon odobravanja:
[SKILL: Writer]    Piše potpune tekstove → Model: GLM-5
[SKILL: Reviewer]  Provjera kvalitete → Model: GLM-5
[SKILL: Publisher] Objavljuje u Postiz → API veza
```

---

### Stranica 15

## Kako izgleda zahtjev za odobravanje

Dobijaš u Facebook Messengeru poruku od Ave:

```
📅 ZAHTJEV ZA ODOBRAVANJE CONTENT PLANA [18.03. – 31.03.2026]

Sedmice 12–13 — 14 postova

Pon 18.03.: Instagram slika — "Proljetne ponude: 3 savjeta za..."
Uto 19.03.: Instagram Reel — "Iza kulisa kod nas"
Sri 20.03.: Facebook tekst — "Zašto naši kupci vole nas"
Čet 21.03.: Instagram Story — "Anketa: Šta želite vidjeti?"
Pet 22.03.: Instagram slika — "Vikend specijal: ..."
...

Odgovor:
✅ "plan odobren" → Ava automatski objavljuje po rasporedu
✏️ "promijeni: [tvoj feedback]" → Plan se prilagođava
❌ "odbij plan" → nema objava ove sedmice
```

---

## Šta Ava uzima u obzir pri planiranju

### Pravilo 70/30
- **70% postova:** Korisni sadržaj, savjeti, priče, zajednica
- **30% postova:** Proizvodi, ponude, direktne reklame

**Zašto?** Previše reklama nervira pratioce. Mješavina osigurava pravi angažman.

---

### Praznici i događaji
Ava automatski zna za:
- Ramazan, Eid al-Fitr, Bajram
- Božić, Uskrs
- Nacionalni praznici (Njemačka, Bosna, Srbija)

---

### Vrste sadržaja

| Vrsta | Opis | Model |
|-------|------|-------|
| **Foto post** | Slika s captionom i hashtagovima | GLM-5 |
| **Reel koncept** | Ideja za kratki video (scenarij) | GLM-5 |
| **Story ideja** | Prijedlog za 24h story | GLM-5 |
| **Tekst post** | Duži informativni tekst (dobro za Facebook) | GLM-5 |
| **Karusel ideja** | Više slika s narativnom strukturom | GLM-5 |

---

### Jezici
Ava piše postove na:
- **Bosanskom (latinica)**
- **Njemačkom**
- **Srpskom (latinica)**
- Na zahtjev: engleski ili drugi jezici

---

---

# Stranica 16 — Poglavlje 9: Odobravanje ili odbijanje plana

## Odgovor putem Facebook Messengera

Kada dobijaš zahtjev za odobravanje putem Messengera, imaš 3 opcije:

---

### Opcija 1 — ✅ Odobri plan

**Napiši:** `plan odobren`

**Šta se dešava:**
- [SKILL: Writer] Ava odmah počinje pisati sve postove → Model: GLM-5
- [SKILL: Reviewer] Svaki post se provjerava → Model: GLM-5
- [SKILL: Publisher] Postovi se planiraju u Postiz
- Svaki dan u zakazano vrijeme automatski se objavljuje
- Ne moraš ništa više raditi

---

### Stranica 17

### Opcija 2 — ✏️ Promijeni plan

**Napiši:** `promijeni: [tvoj feedback]`

**Primjeri:**
- `promijeni: Ponedjeljak treba biti Reel, ne slika`
- `promijeni: Manje reklama, više savjeta`
- `promijeni: Molim piši na bosanskom`
- `promijeni: Ramazan post pomjeri na petak`

**Šta se dešava:**
- [SKILL: Planner] Ava prilagođava plan → Model: GLM-5
- Dobijaš revidirani plan na novo odobravanje

---

### Opcija 3 — ❌ Odbij plan

**Napiši:** `odbij plan`

**Šta se dešava:**
- Ove sedmice se ne objavljuje ništa
- Sljedeće sedmice Ava automatski kreira novi plan

---

## Šta se dešava ako ne odgovoriš?

| Vremenski period | Šta Ava radi |
|-----------------|--------------|
| Nakon 48 sati bez odgovora | Ava šalje podsjetnik |
| Nakon 96 sati bez odgovora | Plan se odbacuje, novo planiranje sljedeće sedmice |

---

## Ručno zatraži plan

Ne moraš čekati ponedjeljak. Napiši Avi u bilo koje vrijeme:

`"Napravi odmah novi content plan"`

Ava kreira plan i direktno ti šalje zahtjev za odobravanje.

---

---

# Stranica 18 — Poglavlje 10: Postiz — tvoj content kalendar

## Šta je Postiz?

Postiz je tvoj vizualni urednički plan. Ovdje na jedan pogled vidiš:
- Koji postovi se objavljuju kada
- Šta je već objavljeno
- Šta još čeka kao nacrt

Adresa: `https://marki.ac.activi.io`

---

## Ručno kreiranje posta

**Korak 1:** Klikni gore desno na **"+ New Post"**

**Korak 2:** Napiši svoj tekst u veliki tekstualni okvir

**Korak 3:** Učitaj sliku ili video (opcionalno)

**Korak 4:** Odaberi platformu(e): Instagram, Facebook, ili obje

**Korak 5:** Odaberi datum i vrijeme → Klikni **"Schedule for"**

**Korak 6:** Klikni **"Schedule"**

---

### Stranica 19

## Uređivanje zakazanog posta

**Korak 1:** Otvori kalendar

**Korak 2:** Klikni na post koji želiš promijeniti

**Korak 3:** Uredi šta želiš (tekst, slika, vrijeme)

**Korak 4:** Klikni **"Save"**

---

## Brisanje posta

**Korak 1:** Klikni na post u kalendaru

**Korak 2:** Klikni na tri tačke (**...**) ili ikonu kante za smeće

**Korak 3:** Potvrdi brisanje

---

## Odmah objavi post

**Korak 1:** Kreiraj post kao gore opisano

**Korak 2:** Umjesto "Schedule" klikni **"Post Now"**

---

## Pregled kalendara

**Calendar prikaz:** Prikaz svih postova po mjesecima
- 🟢 Zeleno = Objavljeno
- 🔵 Plavo = Zakazano
- ⚫ Sivo = Nacrt

---

---

# Stranica 20 — Poglavlje 11: Povezivanje društvenih mreža

## Zašto moraš spojiti račune?

Bez veze Postiz ne može automatski objavljivati.
Vezu radiš jednom — nakon toga sve radi automatski.

---

## Spajanje Instagrama

**Preduvjet:** Trebaš **Instagram Business nalog** (ne privatni nalog).

**Korak 1:** Otvori Postiz (`https://marki.ac.activi.io`)

**Korak 2:** Idi na **Settings → Channels**

**Korak 3:** Klikni **"Add Channel"**

**Korak 4:** Odaberi **"Instagram"**

**Korak 5:** Bit ćeš preusmjeren na Facebook/Instagram

**Korak 6:** Prijavi se s Facebook podacima

**Korak 7:** Dozvoli Postizy pristup (označi sve kvačice)

**Korak 8:** Odaberi svoju Instagram stranicu

**Korak 9:** Klikni **"Connect"**

✅ Instagram je sada spojen.

---

### Stranica 21

## Spajanje Facebooka

**Korak 1:** Idi na **Settings → Channels → Add Channel**

**Korak 2:** Odaberi **"Facebook"**

**Korak 3:** Prijavi se s Facebook podacima

**Korak 4:** Odaberi svoju Facebook stranicu

**Korak 5:** Klikni **"Connect"**

✅ Facebook je sada spojen.

---

## Provjera veze

**Settings → Channels** prikazuje ti sve spojene naloge.

🟢 Zelena tačka = Veza aktivna ✅
🔴 Crvena tačka = Veza prekinuta — ponovo spoji

---

## Šta učiniti ako se veza prekine?

Društvene mreže ponekad prekidaju vezu iz sigurnosnih razloga.

**Rješenje:**
1. **Settings → Channels**
2. Klikni na pogođeni nalog
3. Klikni **"Reconnect"**
4. Ponovo se prijavi

---

---

# Stranica 22 — Poglavlje 12: Automatski zadaci

## Pregled automatskih zadataka s modelima

| Zadatak | Kada | Skill | Model | Šta radi |
|---------|------|-------|-------|----------|
| **Dnevno planiranje** | Svaki dan 09:00 | Planner | GLM-5 | Provjerava da li postoji dnevni plan |
| **Sedmično planiranje** | Pon 09:00 | Planner | GLM-5 | Kreira 2-sedmični plan, šalje na odobravanje |
| **Lead Follow-up** | Svaki dan 10:00 | Lead-Nurturing | GLM-5 | Šalje follow-up poruke zainteresiranim |
| **Sedmični izvještaj** | Pon 08:00 | Analytics | MiniMax M2.5 | Analizira prošlu sedmicu |
| **Samorefleksija** | Svaki dan 23:00 | Reflexion | GLM-5 | Ava analizira dan, poboljšava se |
| **Čišćenje memorije** | Ned 02:00 | Memory-Critic | GLM-5 | Organizira i čisti memoriju |
| **Heartbeat** | Svaki sat | — | — | Sistemska provjera |
| **Inbox provjera** | Svakih 15 min | Inbox | GLM-5 | Provjerava nove poruke |

---

### Stranica 23

## Upravljanje zadacima u Dashboardu

**Korak 1:** Otvori Dashboard

**Korak 2:** Klikni lijevo na **"Geplante Aufgaben"** (Zakazani zadaci)

**Korak 3:** Vidiš listu svih automatskih zadataka

---

### Aktiviranje/deaktiviranje zadatka

Klikni na **toggle prekidač** pored zadatka:
- Prekidač zelen = Zadatak aktivan ✅
- Prekidač siv = Zadatak deaktiviran ⏸️

---

### Ručno pokretanje zadatka

Klikni na **▶️ Play simbol** pored zadatka.

Ili napiši Avi u chatu:

| Šta napišeš | Šta se pokrene | Skill | Model |
|-------------|----------------|-------|-------|
| `"Napravi odmah content plan"` | Sedmično planiranje | Planner | GLM-5 |
| `"Analiziraj naše postove prošle sedmice"` | Sedmični izvještaj | Analytics | MiniMax M2.5 |
| `"Provjeri nove poruke kupaca"` | Inbox provjera | Inbox | GLM-5 |
| `"Uradi samorefleksiju"` | Reflexion | Reflexion | GLM-5 |

---

---

# Stranica 24 — Poglavlje 13: Upravljanje leadovima

## Šta je lead?

**Lead** je potencijalni kupac — neko ko piše na tvoju Facebook stranicu ili Instagram i pokazuje interes za tvoje proizvode/usluge.

---

## Kako Ava obrađuje leadove

**SKILL: Inbox + Lead-Nurturing**
**Model: GLM-5 Cloud**

```
Kupac piše na tvoju Facebook stranicu
           ↓
[SKILL: Inbox] Ava prima poruku automatski
           ↓
[Model: GLM-5] Ava analizira: Šta ova osoba želi?
           ↓
┌────────────────────────────────────────────────┐
│ Jednostavno pitanje → Ava odgovara odmah       │
│ Interes za proizvod → Sprema lead              │
│ Pritužbe → Ava obavještava tebe               │
└────────────────────────────────────────────────┘
           ↓
[SKILL: Lead-Nurturing] Follow-up nakon 24h, 48h, 7 dana
```

---

### Stranica 25

## Pregled leadova

Napiši Avi u chatu:
- `"Prikaži mi sve nove leadove"`
- `"Koji leadovi još nisu dobili odgovor?"`
- `"Prikaži mi leadove iz prošlog mjeseca"`

---

## Ručna poruka leadu

Napiši Avi:
`"Pošalji [imenu ili ID-u] poruku: [tvoj tekst]"`

Primjer:
`"Pošalji kupcu od ponedjeljka poruku: Hvala na interesu, javit ćemo se sutra"`

---

## Vrući lead — hitna obavijest

Kada Ava prepozna da je neko jako zainteresiran, odmah te obavještava putem Messengera:

```
⚠️ VRUĆI LEAD
PSID: 123456789
Interes: [Proizvod]
Zadnja poruka: "Koliko to točno košta?"
→ Preporuka: Sada osobno odgovori
```

---

---

# Stranica 26 — Poglavlje 14: Izvještaji

## Šta Ava može analizirati?

**SKILL: Analytics**
**Model: MiniMax M2.5 Cloud** (specijalizovan za analize)

---

## Sedmični izvještaj (automatski svaki ponedjeljak)

Svaki ponedjeljak dobijaš sažetak:

```
📊 SEDMIČNI IZVJEŠTAJ Sedmica 11

Top post: "Proljetni savjeti" → 432 lajka, 89 komentara
Najslabiji post: "Predstavljanje proizvoda" → 23 lajka
Ukupni doseg: 8.400 osoba
Novi pratioci: +47

Preporuka za Sedmicu 12:
• Više foto postova (rade 3x bolje od tekstova)
• Promijeni vrijeme objave: 11:00 umjesto 09:00
• Dodaj hashtag #proljeće2026
```

---

## Ručni izvještaj

Napiši Avi:
- `"Kako idu naši postovi ove sedmice?"`
- `"Koji su naša 3 najbolja posta ikada?"`
- `"Koje vrijeme objave donosi najviše lajkova?"`
- `"Usporedi Instagram s Facebook performansama"`

---

---

# Stranica 27 — Poglavlje 15: Česti problemi i rješenja

## Problem: "Ava ne odgovara"

**Moguć uzrok 1:** Prekid veze s modelom

**Rješenje:** Napiši ponovo. Ako više puta nema rezultata:
1. Otvori Dashboard → Pregled
2. Provjeri da li je Gateway status zelen
3. Kontaktiraj svog administratora

---

### Stranica 28

## Problem: "Post nije objavljen"

**Moguć uzrok 1:** Veza s društvenom mrežom istekla

**Rješenje:**
1. Otvori Postiz (`https://marki.ac.activi.io`)
2. Idi na Settings → Channels
3. Provjeri da li svi nalozi imaju zelenu tačku
4. Kod crvene tačke: Klikni "Reconnect"

**Moguć uzrok 2:** Plan nije odobren

**Rješenje:** Provjeri da li si odgovorio/la na zahtjev za odobravanje.

---

## Problem: "Ne vidim nove leadove"

**Moguć uzrok:** Facebook Webhook nije postavljen

**Rješenje:** Kontaktiraj administratora — Webhook `https://meta.marki.ac.activi.io/webhook` mora biti unesen na Facebooku.

---

## Problem: "Dashboard prikazuje 'pairing required'"

**Rješenje:**
1. Klikni na "Verbinden" (Spoji)
2. Kontaktiraj administratora
3. On odobrava tvoj uređaj za nekoliko minuta
4. Nakon toga veza funkcioniše odmah

---

## Problem: "Ava je pogriješila u tonu"

**Rješenje:** Napiši Avi direktno:
`"Zadnji post je bio previše formalan. Piši ležernije i prijatelјski."`

---

## Problem: "Plan ne stiže putem Messengera"

**Moguć uzrok:** Meta veza nije konfigurirana (API ključevi nedostaju)

**Rješenje:** Alternativa — otvori Dashboard → Chat i napiši:
`"Prikaži mi trenutni content plan"`

---

---

# Stranica 29 — Poglavlje 16: Važni pristupni podaci

## Svi pristupni podaci na jednom mjestu

> ⚠️ **Sigurnosna napomena:** Dijeli ove podatke samo s osobama kojima vjeruješ.

---

### Sistemski URL-ovi

| Usluga | URL |
|--------|-----|
| Postiz (Content kalendar) | `https://marki.ac.activi.io` |
| OpenClaw Dashboard | `https://oc.marki.ac.activi.io` |
| Dashboard (Tailscale) | `https://hetzner4-marki.tail47b17c.ts.net` |
| Meta Webhook | `https://meta.marki.ac.activi.io/webhook` |

---

### Dashboard token

```
5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```

---

### AI modeli — pregled

| Model | Uloga | Za šta |
|-------|-------|--------|
| `ollama/glm-5:cloud` | Primarni | Sve — planiranje, pisanje, chat, inbox |
| `ollama/minimax-m2.5:cloud` | Rezerva 1 | Analize, dugi izvještaji |
| `ollama/kimi-k2.5:cloud` | Rezerva 2 | Kreativno pisanje |
| `ollama/qwen3.5:397b` | Rezerva 3 | Zadnja rezerva |
| `qwen3.5:cloud` | Vision | Analiza slika |

---

### Skills — pregled

| Skill | Kada radi | Model |
|-------|-----------|-------|
| Planner | Pon 09:00 + na zahtjev | GLM-5 |
| Writer | Nakon odobrenja plana | GLM-5 |
| Reviewer | Nakon Writer-a | GLM-5 |
| Publisher | U zakazano vrijeme | API |
| Inbox | Svakih 15 min | GLM-5 |
| Lead-Nurturing | Svaki dan 10:00 | GLM-5 |
| Analytics | Pon 08:00 + na zahtjev | MiniMax M2.5 |
| Memory-Critic | Ned 02:00 | GLM-5 |
| Escalation | Na rizik/alarm | GLM-5 |
| Reflexion | Svaki dan 23:00 | GLM-5 |

---

### Server (za administratore)

| Šta | Vrijednost |
|-----|------------|
| IP servera | `91.98.26.220` |
| Tailscale IP | `100.84.189.53` |
| SSH komanda | `ssh hetzner4` |

---

---

# Brza referenca (za štampanje)

```
╔═══════════════════════════════════════════════════════╗
║              AVA — BRZA REFERENCA                     ║
╠═══════════════════════════════════════════════════════╣
║ POSTIZ:       https://marki.ac.activi.io              ║
║ DASHBOARD:    https://oc.marki.ac.activi.io           ║
║               /#token=5d936f9c...585f                 ║
╠═══════════════════════════════════════════════════════╣
║ ODOBRI PLAN:  "plan odobren"                          ║
║ PROMIJENI:    "promijeni: [feedback]"                 ║
║ ODBIJ PLAN:   "odbij plan"                            ║
╠═══════════════════════════════════════════════════════╣
║ NOVI PLAN:    "Napravi content plan"                  ║
║ IZVJEŠTAJ:    "Kako idu naši postovi?"                ║
║ LEADOVI:      "Prikaži mi nove leadove"               ║
║ RESET:        /new ili /reset                         ║
╠═══════════════════════════════════════════════════════╣
║ MODELI:  GLM-5 (sve) | MiniMax (analize)              ║
║          Vision: qwen3.5 (samo za slike)              ║
╚═══════════════════════════════════════════════════════╝
```

---

*AVA Korisnički priručnik v1.0 | Mart 2026. | Marki-Stack*
*Sve stranice: 29 | Ovaj dokument je povjerljiv.*
