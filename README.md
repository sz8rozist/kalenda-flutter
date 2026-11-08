# Kalenda – mobilalkalmazás

Flutter-alkalmazás a Kalenda időpontfoglalóhoz (iOS + Android). Backend:
[kalenda-java-backend](https://github.com/sz8rozist/kalenda-java-backend) REST API (`/api/v1`).
Terv, funkciók, backend-teendők: [docs/PLAN.md](docs/PLAN.md).

## Állapot
Alap: Riverpod + go_router + Dio, hu/en lokalizáció, ügyfél-belépés e-mailes linkkel
(`/customer/login-link` → `/customer/login`), tárolt token (Keychain/Keystore),
„Foglalásaim" (`/customer/account`).

## Fejlesztés
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # Android emulátor -> a gép localhostja
flutter analyze && flutter test
```

Flutter nélkül, Dockerből:

```bash
docker run --rm -v "$PWD:/w" -w /w ghcr.io/cirruslabs/flutter:stable sh -c "flutter pub get && flutter analyze && flutter test"
```

Az iOS-build Windowson nem megy (Xcode): felhős CI (Codemagic / GitHub Actions macOS) kell hozzá.

## Push értesítések (Firebase)
Az app Firebase-konfiguráció nélkül is épül és fut (a push ilyenkor ki van kapcsolva). Bekapcsolás:
1. Firebase-projekt létrehozása, majd két alkalmazás felvétele – **a két platform csomagneve nem azonos**:
   Android: `hu.kalenda.kalenda_mobile`, iOS (bundle ID): `hu.kalenda.kalendaMobile`.
2. `dart pub global activate flutterfire_cli`, majd `flutterfire configure` – ez felveszi a `google-services.json` / `GoogleService-Info.plist` fájlokat és a Gradle/Xcode beállítást.
3. **iOS előfeltételek** (Apple Developer fiók – 99 USD/év): az App ID-n a *Push Notifications* képesség bekapcsolása, APNs-hitelesítési kulcs (`.p8`) létrehozása és feltöltése a Firebase-projekt Cloud Messaging beállításaiba (Key ID + Team ID).
   A projekt már tartalmazza az iOS-oldali beállítást: `Runner/Runner.entitlements` (Debug/Profile: `aps-environment = development`), `Runner/RunnerRelease.entitlements` (Release: `production`) és a `UIBackgroundModes → remote-notification` az `Info.plist`-ben. A `GoogleService-Info.plist`-et az Xcode-ban a Runner target erőforrásai közé kell venni (a `flutterfire configure` ezt megteszi). Az iOS-t csak Macen vagy felhős buildben (pl. Codemagic) lehet fordítani; push csak valódi eszközön megy.
4. A backenden `FCM_CREDENTIALS_FILE` a Firebase service account JSON útvonalával (ld. a backend `env.docker.example`); a kulcs titok, nem kerül git-be.
Az értesítés-engedélyt az app az első foglalás után kéri; belépés után az eszköz-token a `/customer/devices` végponton regisztrálódik.

## Architektúra: Riverpod + MVVM
Állapotkezelés: **Riverpod**. Tervezési minta: **MVVM**, funkciónként (`lib/features/<funkció>/`):

| Réteg | Mappa | Mi van benne |
| --- | --- | --- |
| **Model** | `model/`, `data/` | adatmodellek (JSON ↔ osztály) és repository-k (a HTTP-hívás csak itt van, `ApiClient`-en át) |
| **ViewModel** | `viewmodel/` | Riverpod `Notifier` / `AsyncNotifier`: az adat betöltése (`AsyncNotifier`), a műveletek és a képernyő állapota (`ActionNotifier` → `ActionState`: busy + visszajelzés), a form választásai és a küldés |
| **View** | `view/` | widgetek: csak megjelenítés és eseménykiváltás; a szövegmezők controllerei, párbeszédek és a navigáció itt vannak, üzleti állapot és repository-hívás nincs |

Szabályok: a View nem hív repository-t / Dio-t, és üzleti állapotot nem tart `setState`-tel; a ViewModel nem ismeri a `BuildContext`-et (a visszajelzést `Flash`-ként adja, a szöveget a View állítja össze – `shared/flash.dart`);
közös segédek: `core/viewmodel/` (`ActionNotifier`, fül-/hét-/dátumválasztó ViewModel-ek), `shared/` (`AsyncView`, `WeekHeader`, formázók).
Új képernyő = `view` + `viewmodel` (+ `model`/`data`, ha új adat kell).

## Fizetés (Stripe PaymentSheet)
Előleges foglalásnál a visszaigazoló képernyőn „Fizetés most" gomb indítja a Stripe PaymentSheetet (kártya, Apple Pay, Google Pay).
A backend (`POST /public/bookings/{token}/payment/sheet`) készíti a PaymentIntentet a vállalkozó Connect-fiókján; az app a `client_secret`-tel,
a publikus kulccsal és a `stripe_account_id`-val nyitja a lapot, majd a `…/payment/confirm-intent`-tel igazol vissza.
- **Backend beállítás:** `STRIPE_PUBLISHABLE_KEY`; a Connect webhook-végponton kapcsold be a `payment_intent.succeeded` eseményt.
- **Android:** a `MainActivity` `FlutterFragmentActivity`, a téma MaterialComponents (kész). Google Pay-hez a Stripe-fiókban és az éles appban engedélyezés kell.
- **iOS (teendő, Mac/CI-n):** minimum deployment target 13.0 a `Podfile`-ban; Apple Pay-hez Merchant ID az Apple Developer-fiókban és a *Apple Pay* capability az Xcode-ban.
- Teszteléshez Stripe teszt-kulcsok és a `4242 4242 4242 4242` tesztkártya.

## Alkalmazászár (biometrikus azonosítás)
A „Zárolás biometrikus azonosítással" kapcsoló az ügyfél **Fiókom** fülén, munkatársnak / vállalkozónak a **Beállítások** (fogaskerék) lapon van.
Bekapcsolva belépett fiók mellett az app indításkor és a háttérből való visszatéréskor (30 mp türelmi idő után) zárolt: ujjlenyomat / arcfelismerés,
ennek hiányában az eszköz képernyőzára oldja fel. Ha az azonosítás nem működik, a zárképernyőről kijelentkezéssel lehet továbblépni.
Bekapcsolás előtt egy próba-azonosítás fut. Android: `USE_BIOMETRIC` engedély, a `MainActivity` `FlutterFragmentActivity`; iOS: `NSFaceIDUsageDescription` az `Info.plist`-ben.
Architektúra: `features/app_lock` (`AppLockViewModel`, `AppLockGate` az egész app fölött a `MaterialApp.builder`-ben).

## Közösségi belépés (Google, Apple) – ügyfélfiók
A belépő képernyőn a „Folytatás Google-/Apple-fiókkal" gombok csak akkor látszanak, ha a szerver jelzi (`GET /app-config` → `google_login` / `apple_login`).
Az app a szolgáltató id-tokenjét küldi a `/customer/login/google|apple` végpontra; a szerver ellenőrzi, és ugyanazt az ügyfél-tokent adja, mint a belépő link.
A munkatársi / vállalkozói belépés továbbra is e-mail + jelszó.

Beállítás (a fejlesztői fiókokból):
- **Google:** Google Cloud Console → OAuth-kliensek: egy *Web* típusú (ennek az azonosítója a `--dart-define=GOOGLE_SERVER_CLIENT_ID=…` és a backend `GOOGLE_CLIENT_IDS`-e), egy *Android* (csomagnév `hu.kalenda.kalenda_mobile` + az aláíró SHA-1) és egy *iOS* (bundle ID). iOS-en az `Info.plist`-be a `GIDClientID` és a fordított kliensazonosító URL-séma is kell.
- **Apple:** az Apple Developer-fiókban az App ID-n a *Sign in with Apple* képesség, Xcode-ban a *Sign in with Apple* capability; a backend `APPLE_CLIENT_IDS`-e az iOS bundle azonosító.
- Az iOS-store megköveteli a Sign in with Apple-t, ha más külső belépés is van (ezért az Apple gomb az iOS-en mindig megjelenik, ha a szerver be van állítva).

## Felület és design

- **Téma:** márka-kék Material 3 téma világos/sötét módban, Inter betűtípus (`lib/core/theme/app_theme.dart`); oldalátmenetek platformonként.
- **Közös elemek** (`lib/shared/ui/`): `AppLogo`, `StatusChip`, `DateBadge`, `EmptyState`/`EmptyNote`, skeleton-betöltés, `StepSection`, `DayStrip`, `AppImage` (gyorsítótáras kép), `Haptics`.
- **Hibák és visszajelzés:** `describeError` → barátságos hibaablak „Újra" gombbal (`showErrorAlert`), `showToast`, `showConfirmAlert`.
- **Indulás:** natív splash + animált Flutter splash; első indításkor háromlépéses bevezető (`features/onboarding`).
- **Kedvencek / legutóbbiak:** az eszközön tárolva (`features/favorites`, `shared_preferences`).
- **Offline:** „nincs internet" sáv (`features/connectivity`); a Foglalásaim/Fiókom utolsó állapota gyorsítótárban, kijelentkezéskor törlődik.
- **Értékelés kérése:** a második sikeres foglalás után egyszer, a rendszer saját ablakával (`in_app_review`).
- **Akadálymentesség:** betűméret-skálázás 0,9–1,4 között, `Semantics` a választókon.

## Ügyfél-funkciók (összefoglaló)
Vállalkozás megnyitása azonosítóval / linkkel / **QR-kóddal**; foglalás (munkatárs, kiegészítők, időpont), **várólista** a betelt napokra, **csoportos alkalmakra jelentkezés**,
**bérlet- és ajándékutalvány-vásárlás** (Stripe Checkout böngészőben), előleg fizetése PaymentSheettel, foglalás kezelése (áthelyezés, lemondás, **mentés az eszköz naptárába**),
**értékelés** a levélből (`/velemeny/{token}`), Fiókom (profil, hűségpont, bérletek, hozzájárulások, fióktörlés), push, biometrikus zár, Google/Apple belépés.
Engedélyek: kamera (QR), naptár (mentés) – Android `CAMERA`, iOS `NSCameraUsageDescription` / `NSCalendars…UsageDescription`.

## Tesztek
```bash
flutter test      # 146 teszt: modellek, ViewModel-ek, az app indulása (widget-tesztek)
flutter analyze
```
- `test/model` – JSON-értelmezés, verzió-összehasonlítás, `SlotQuery` egyenlőség, nyitvatartás/számla/foglalás modellek.
- `test/viewmodel` – `ActionNotifier`, hét/fül ViewModel-ek, linkek értelmezése, alkalmazászár (türelmi idő, feloldás, bekapcsolás), ügyfél-munkamenet és belépés (kód, beillesztett link, Google/Apple, fióktörlés), foglalási űrlap és várólista.
- `test/app_smoke_test.dart` – az app elindul magyar felülettel: fülek belépés előtt/után, közösségi gombok a szerver jelzése szerint, zárképernyő, kötelező frissítés.
- `test/support` – fake repository-k, token-tár, alkalmazászár és push (a hálózat, a Keychain, a biometria és a Firebase nélkül futnak).

## Android fejlesztői környezet (Windows)
- SDK: `D:\dev\android-sdk` (platform 36, build-tools 36.0.0, emulátor, `system-images;android-36;google_apis;x86_64`), JDK 21: `D:\dev\jdk-21`.
  Beállítás: `flutter config --android-sdk D:\dev\android-sdk --jdk-dir D:\dev\jdk-21`.
- Emulátor: az AVD a `D:\dev\avd\kalenda.avd` mappában van; indítás: `$env:ANDROID_AVD_HOME = 'D:\dev\avd'; & 'D:\dev\android-sdk\emulator\emulator.exe' -avd kalenda`
  (az `avdmanager create avd` a 36-os képpel `devices.xml`-hibát ad, ezért az AVD kézzel készült a `config.ini`-vel).
- Futtatás: `flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080` (a 10.0.2.2 az emulátorból a gép localhostja).
- Az `android/gradle.properties`-ben a `kotlin.incremental=false` kell: a pub-gyorsítótár (C:) és a projekt (D:) külön meghajtón van.

## Csatlakozás a backendhez
A cím a build-idejű `API_BASE_URL`-ből jön (`--dart-define=API_BASE_URL=…`), alapértéke `http://10.0.2.2:8080`.

| Hol fut az app | `API_BASE_URL` | Megjegyzés |
| --- | --- | --- |
| Android emulátor | `http://10.0.2.2:8080` (alapérték) | a 10.0.2.2 az emulátorból a gép localhostja |
| Valódi telefon, ugyanazon a Wi-Fin | `http://<a gép LAN IP-je>:8080` | a gép tűzfalán engedélyezni kell a 8080-at |
| Valódi telefon, USB-vel | `http://localhost:8080` + `adb reverse tcp:8080 tcp:8080` | nem kell hálózat |
| iOS szimulátor | `http://localhost:8080` | a Mac helyi gépe |
| Éles / teszt-kiadás | `https://<a domain>` | **kötelezően HTTPS**; a sima HTTP csak a debug buildben engedélyezett |

Helyi backend: a `kalenda-java-backend` repóban `docker compose -f docker-compose.mobile-dev.yml up -d --build`, majd `bash scripts/seed-dev.sh` (próba-vállalkozás + vállalkozói fiók).
A belépő linkek e-mail helyett a backend naplójában jelennek meg: `docker compose -f docker-compose.mobile-dev.yml logs app`.
Android: a `main` manifestben az `INTERNET` engedély (enélkül a release build nem érné el a hálózatot), a `debug` manifestben a `usesCleartextTraffic` (sima HTTP a helyi backendhez).
