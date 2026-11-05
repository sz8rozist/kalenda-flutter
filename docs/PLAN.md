# Kalenda mobilalkalmazás – terv

Állapot: javaslat (2026-11-05), a **kalenda-java-backend** (Java 25, Spring Boot 4, MariaDB)
és a **kalenda-angular-frontend** (Angular 21) alapján átdolgozva. A régi Laravel/.NET/Vue
feltevések már nem érvényesek.

## 1. Mi van már a backendben (újrahasznosítható)

| Terület | Állapot a Java backendben |
| --- | --- |
| Mobil bejelentkezés | `POST /api/v1/auth/login` – mobilnál a `deviceName` kötelező, Bearer-tokent ad (Sanctum-formátum, `personal_access_tokens`); `logout`, `register`, `/me` (módosítás, jelszócsere, **`DELETE /me` = fiók törlése**) |
| Ügyfélfiók | `/api/v1/customer`: e-mailes belépő link (`login-link`, 30 perc) → `login` → ügyfél-token (30 nap, `["customer"]` jogosultság); `account`, `consents/{business}` |
| Munkatársi portál | `/api/v1/staff-portal`: dashboard, naptár, státuszváltás, áthelyezés, szabadságkérés, **clock-in/out**, profil – pont a munkatársi mód alapja |
| Nyilvános foglalás | `PublicBooking`, várólista, csoportos alkalmak, pálya-/terembérlés, bérletek, értékelés, foglalás-kezelő link |
| Üzemeltetői API | naptár, foglalások, ügyfelek, riportok, számlák, termékek, munkaidő, értesítések (`/businesses/{b}/notifications`, csak lista + „mind olvasott") |
| Fizetés | Stripe **Checkout** (átirányítás) + Connect, webhook |
| API-leírás | `docs/openapi.json` (243 művelet, springdoc) – az Angular-kliens ebből generálódik, a mobilé is ebből fog |
| Kompatibilitás | snake_case JSON, egységes 401/403/404/422 hibaforma, lapozás `{data, meta}` |

Ami **hiányzik** a mobilhoz:

| Hiány | Megjegyzés |
| --- | --- |
| Push értesítés | nincs eszköz-regisztráció, nincs FCM/APNs küldő; most csak e-mail és a vállalkozói harang van |
| Ügyfél-fiók törlése | a `DELETE /me` csak a vállalkozói felhasználóra van; az ügyfélfióknak (`/customer/account`) nincs – **bolti követelmény** |
| Apple / Google bejelentkezés | nincs; az iOS-en kötelező, ha harmadik féles belépés van |
| Belépő link az appba | a levél linkje a webre mutat (`/fiokom/belepes/{token}`); kell univerzális link vagy 6 jegyű kód az appban |
| Token-életciklus | a vállalkozói tokennek nincs lejárata és nincs refresh; eszközlista / „kijelentkeztetés minden eszközről" végpont sincs |
| Fizetés appból | Checkout-átirányítás helyett PaymentSheet (PaymentIntent + ephemeral key) a jobb élményhez; működhet a Checkout böngészős megnyitással is (MVP) |
| Minimum kliensverzió | nincs kényszerfrissítési mechanizmus |
| Univerzális linkek | `apple-app-site-association`, `assetlinks.json` a Caddyből kiszolgálva |

## 2. Célcsoportok és funkciók

### Ügyfél (1. fázis – MVP)
- Belépés e-mailes linkkel/kóddal (a meglévő ügyfélfiókra építve), később Apple/Google
- Vállalkozás megnyitása link/QR-kód alapján (deep link a `/booking/...` oldalra)
- Foglalás: szolgáltatás → munkatárs → szabad időpont; **csoportos alkalmakra jelentkezés**, **pálya-/teremfoglalás**
- Online fizetés (előleg, bérlet), Apple Pay / Google Pay
- Saját foglalások: lista, lemondás, áthelyezés, újrafoglalás egy koppintással
- **Push**: visszaigazolás, 24 ó / 2 ó emlékeztető, lemondás, várólistáról felszabadult hely
- Várólista, bérletek/utalványok, hűségpontok, értékelés
- Hozzájárulások kezelése (`consents`), fiók törlése az appból
- Magyar + angol nyelv

### Munkatárs (2. fázis) – a `staff-portal` végpontokra
- Mai nap/heti naptár, új foglalás push
- Státuszváltás (megjelent / nem jelent meg), áthelyezés
- Szabadságkérés, belépés/kilépés (clock-in/out), saját munkaidő

### Üzemeltető (3. fázis)
- Naptár, foglalás létrehozás/áthelyezés/törlés, push új foglalásról
- Ügyfélkártya, jegyzet, hívás/üzenet
- Mai bevétel, gyors riportok, számlák megtekintése
- Előfizetés **csak megtekintés** (vásárlás a weben, lásd 6. pont)

### Későbbi
Face ID, widget („következő időpontom"), offline cache a saját foglalásokra, Apple/Google Wallet bérlet.

## 3. Technológia – Flutter (Dart)

Döntés: **Flutter**. Egy kódbázis iOS-re és Androidra, saját renderelés (egyforma és sima
a naptár, az animációk), erős csomagkínálat a mobilos igényekre, és a backend OpenAPI-jából
Dart-kliens generálható. A nyelv új (Dart), de Javából/TypeScriptből jövőnek gyorsan megtanulható.

| Terület | Javasolt megoldás |
| --- | --- |
| Állapotkezelés | Riverpod |
| Navigáció + deep link | `go_router` + `app_links` (univerzális linkek) |
| API-kliens | `openapi-generator` `dart-dio` generátor a `docs/openapi.json`-ból + `dio` interceptor (Bearer, 401 kezelés, `X-App-Version`) |
| Token tárolás | `flutter_secure_storage` (Keychain/Keystore) |
| Push | `firebase_messaging` + `flutter_local_notifications` |
| Fizetés | `flutter_stripe` (PaymentSheet, Apple Pay, Google Pay) |
| Naptár nézet | `table_calendar` (hónap), naptári nap/hét nézethez `kalender` vagy saját `CustomPainter`; a Syncfusion naptár licencköteles, kerüld |
| Belépés | `local_auth` (Face ID / ujjlenyomat), később `sign_in_with_apple`, `google_sign_in` |
| Nyelv | `flutter_localizations` + ARB fájlok (hu, en) |
| Hibafigyelés | `sentry_flutter` |
| Tesztek | `flutter_test`, `integration_test`, Maestro |

**Mit kell tudni:**
- **iOS-build Windowson nem megy**: Xcode csak Macen fut. Megoldás: felhős build – **Codemagic** (Flutter-központú, ingyenes keretes, aláírást kezeli) vagy GitHub Actions macOS runner. Fejlesztés Windowson, Android emulátorral, iOS-t a CI buildeli és TestFlight-ra tölti. iOS-eszközön kipróbálni így csak TestFlighttal lehet; ha sokat kell iOS-en debugolni, egy használt Mac mini megéri.
- Az Angular-kód (szolgáltatások, sablonok) **nem** használható újra; az API-szerződés és az üzleti szabályok igen. A modelleket és klienst generálni kell, nem kézzel írni.
- Az Angular webes felület marad a vállalkozói teljes körű felület; az app ezt kiegészíti, nem váltja le.
- A Dart-kliens generálás miatt az `openapi.json` operationId-jai és sémái stabilak legyenek (ne nevezd át őket menet közben).

Javasolt kódszerkezet (`kalenda-mobile` repó): `lib/core` (api, auth, push, l10n), `lib/features/{booking,appointments,passes,account,staff,business}`, `lib/shared` (widgetek), `lib/api` (generált, nem kézzel szerkeszthető).


## 4. Backend-teendők (kalenda-java-backend)

Priorizálva:

1. **Push**: `device_tokens` tábla (Liquibase XML), `POST /api/v1/devices` / `DELETE /api/v1/devices/{id}` (felhasználó és ügyfél tokenhez is), küldő szolgáltatás FCM HTTP v1-gyel (Firebase Admin SDK vagy kézi HTTP), JobRunr-feladatként (újrapróbálás, érvénytelen token törlése). Bekötési pontok: a meglévő foglalási levelek, az emlékeztető-ütemező (`appointment-reminder`), várólista, vállalkozói értesítés.
2. **Ügyfélfiók törlése**: `DELETE /api/v1/customer/account` (anonimizálás, tokenek törlése, számlák megőrzése jogszabály szerint).
3. **Belépés az appban**: a login-link levélben univerzális link (`https://…/fiokom/belepes/{token}`) + app-ban beírható rövid kód; `.well-known/apple-app-site-association` és `assetlinks.json` a Caddy-ben.
4. **Token-életciklus**: eszköznévhez kötött tokenek listázása/visszavonása (`GET/DELETE /me/tokens`), a vállalkozói mobil-tokenre lejárat (pl. 90 nap csúszó) – a `PersonalAccessToken.expiresAt` már támogatja.
5. **Apple / Google belépés**: id-token ellenőrzés szerveroldalon (JWKS), összekötés az `users`/ügyfélfiókkal.
6. **Minimum kliensverzió**: `X-App-Version` fejléc + `426 Upgrade Required` elavult kliensnek; `GET /app-config`.
7. **Mobil fizetés**: PaymentIntent + ephemeral key végpont a meglévő `PaymentIntegrations` mellé (Connect-fiókkal); MVP-ben elég a Checkout-URL megnyitása.
8. **Értesítés-beállítások**: ügyfélenként push/e-mail kapcsoló (`consents` mellé).
9. `openapi.json` frissítése + a tagek/operationId-k stabilan tartása (a generált kliens ettől függ).

Megjegyzés: a Java backend `PLAN.md`-jében a build/teszt még „a végső körre" van tartogatva – a mobil
fejlesztés megkezdése előtt a teljes build+teszt kör lefutása erősen ajánlott, mert az app a stabil API-ra épít.

## 5. Fázisok

| Fázis | Tartalom | Becslés (1 fő) |
| --- | --- | --- |
| 0. Előkészítés | Apple Developer (99 USD/év), Google Play (25 USD), Firebase projekt, adatvédelmi nyilatkozat, app név/ikon, design; a backend build+teszt kör | 1–2 hét |
| 1. Backend | push, ügyfélfiók-törlés, deep link, app-config (4. pont 1–3, 6) | 2–3 hét |
| 2. Ügyfél MVP | auth, foglalási folyamat, saját foglalások, push, fizetés, hozzájárulások | 6–8 hét |
| 3. Béta | TestFlight + Play belső teszt, hibák, akadálymentesség | 2–3 hét |
| 4. Publikálás | bolti anyagok, review | 1–2 hét |
| 5. Munkatárs mód | `staff-portal` végpontokra | 3–4 hét |
| 6. Üzemeltető mód | naptár, ügyfelek, riportok | 6–8 hét |

(A Dart új nyelv, ezért az első 1–2 hét a tanulásé; az MVP-becslés ezt már tartalmazza. Az iOS-build felhős CI beállítása +2–3 nap.)

## 6. Bolti szabályok

- **Előfizetés (Kalenda SaaS-csomag)** digitális szolgáltatás: iOS-en appból csak Apple IAP-val lenne árulható, ezért az appban csak a státusz látszik, vásárlás a weben. A szolgáltatások (hajvágás, pálya) és az előleg/bérlet fizikai/helyi szolgáltatás → Stripe megengedett. Beküldés előtt az Apple aktuális irányelveit újra ellenőrizni.
- **Fiók törlése** az appból – mindkét fióktípusra (vállalkozó: van, ügyfél: kell).
- **Sign in with Apple**, ha Google-belépés is van.
- Adatvédelmi címke / Data Safety űrlap, adatvédelmi URL, GDPR-hozzájárulások.
- Review-hez demó fiók és tesztvállalkozás.
- Android: új személyes fejlesztői fióknál 12 tesztelő / 14 nap (cégfióknál nincs).
- Push engedélyt az első foglalás után kérd, ne indításkor.

## 7. Minőség és üzemeltetés

- CI: Codemagic (vagy GitHub Actions macOS) → TestFlight / Play belső szakasz; `flutter analyze` + `flutter test` minden pushra
- Teszt: `flutter_test` (üzleti logika, providerek), widget-tesztek a foglalási folyamatra, Maestro a kritikus end-to-end útvonalakra
- Hibafigyelés: Sentry; a backend már Loki/Prometheus – a mobil hibák `X-App-Version` fejlécből szűrhetők
- Token: Keychain/Keystore (`flutter_secure_storage`), soha nem sima fájl/SharedPreferences
- Akadálymentesség: dinamikus betűméret, VoiceOver/TalkBack

## 8. Következő lépések

1. Flutter telepítése (Android Studio + emulátor), Codemagic-fiók, Firebase projekt
2. Backend: a végső build+teszt kör lefuttatása, majd push + ügyfélfiók-törlés + deep link felvétele a `kalenda-java-backend/docs/PLAN.md`-be (új modul: „Mobil-támogatás")
3. Új repó: `kalenda-mobile` (`flutter create`), a Dart-kliens generálása a `docs/openapi.json`-ból (`dart-dio`)
4. Ügyfél-folyamat drótváz
5. Bolti fiókok megnyitása (az Apple jóváhagyás napokig tarthat)
