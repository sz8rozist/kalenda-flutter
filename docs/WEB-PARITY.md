# Webes funkciók a mobilappban (paritás-terv)

A webes felület (`kalenda/resources/js/Pages`) és a mobilapp összevetése. A backend API ugyanaz, a hiányzó részek tehát
„csak" mobil-felületet igényelnek. Állapot: ✅ kész · 🟡 részben · ⬜ hiányzik.

## Ügyfél (nyilvános foglalás és fiók)
| Web | Mobil |
|---|---|
| Foglalás (Booking/Show), csoportos alkalom, várólista | ✅ |
| Foglalás kezelése, áthelyezés, lemondás (Manage, Cancel, Cancelled) | ✅ |
| Fizetés, megszakított fizetés (PaymentCancelled) | ✅ |
| Bérlet / ajándékutalvány vásárlás (PassPurchaseModal, PassSuccess, Voucher) | ✅ (Stripe Checkout böngészőben) |
| Értékelés (Review/Show) | ✅ |
| Ügyfélfiók (CustomerAccount) | ✅ |
| Várólista-leiratkozás (WaitlistRemoved), marketing-leiratkozás | ✅ (a marketing-leiratkozás a szerver oldalán, böngészőben fejeződik be) |
| Ügyfél-dokumentumok (számla/nyugta letöltése a Fiókomban) | ✅ |
| Eszköz-kölcsönzés (rentals): erőforrás és időtartam választás, foglalás | ✅ |

## Munkatárs-portál (StaffPortal)
| Web | Mobil |
|---|---|
| Ma, naptár, szabadság, időmérés (ki/bejelentkezés) | ✅ |
| Foglalás állapota, áthelyezése | ✅ |
| Munkaidő-nyilvántartás (Timesheet) saját | ✅ |
| Saját profil, naptár-feed hivatkozás (másolás, újragenerálás) | ✅ |

## Vállalkozó (Business)
| Web | Mobil |
|---|---|
| Irányítópult (Dashboard) | 🟡 (bevétel, mai foglalások) |
| Naptár | ✅ |
| Foglalás létrehozása (Appointments/Create) | ✅ |
| Foglalás részletei, fizetések, számla/nyugta kiállítása, sztornó, PDF (Appointments/Show) | ✅ |
| Ügyfelek lista, ügyfél részletei, profil, számlázási adatok, hűségpont-váltás (Customer/Show) | ✅ |
| Szolgáltatások: lista, létrehozás, szerkesztés, törlés, kiegészítők (addons), anyagfelhasználás, kép | ✅ |
| Munkatársak: lista, létrehozás, szerkesztés, szolgáltatások, meghívó, hozzáférés-megvonás, törlés, munkaidő, bér/jutalék, fotó | ✅ |
| Nyitvatartás (Settings/Hours) | ✅ |
| Szabadságok (Settings/Leaves) | ✅ (jóváhagyás) · saját szabadság / zárva tartás felvétele ✅ |
| Szünetek (Calendar/Breaks): lista, felvétel, törlés | ✅ |
| Számlák (Invoices): lista, fizetve, emlékeztető, új önálló számla, PDF, sztornó | ✅ · hiányzó dokumentumok újrapróbálása ✅ · ajánlatok: az API nem tartalmaz végpontot |
| Riportok: könyvelés, cash-flow, kifizetések (Payouts) | ✅ · könyvelői csomag letöltése ✅ |
| Költségek (Expenses): lista, felvitel, törlés | ✅ · bizonylat feltöltés/megnyitás, export ✅ |
| Termékek (Products): lista, szűrés, létrehozás, szerkesztés, törlés, értékesítés | ✅ |
| Beszerzés: beszállítók, rendelések (létrehozás, leadás, bevételezés, sztornó) | ✅ |
| Pénztár (Register): napi összesítő, tételek, kifizetetlen foglalások, zárás/nyitás | ✅ |
| Ajánlatok (Quotes) | ✅ |
| Hűségprogram (Loyalty): beállítás, ranglista, statisztika | ✅ |
| Bérletek / utalványok: eladottak listája, típusok létrehozása/kapcsolása/törlése, helyszíni eladás | ✅ |
| Kampányok (Campaigns): lista, szerkesztés, célcsoport, címzett-szám, próbalevél, kiküldés | ✅ |
| Értékelések (Reviews) + beállítás | ✅ |
| Munkaidő (Timesheet): havi összesítő, műszakok, felvétel, hónap zárása/újranyitása, export | ✅ |
| Tevékenység-napló (ActivityLog) | ✅ |
| Várólista (Waitlist): lista, értesítés, eltávolítás | ✅ · csoportos alkalmak (lista, létrehozás, résztvevő, lemondás) ✅ |
| Értesítések (notifications) | ✅ |
| Beállítások: vállalkozás adatai, mód, foglalási oldal + logó/borító feltöltés, szabályzat, fizetés (Stripe Connect böngészőben), számlázás, naptár-szinkron | ✅ · szolgáltatás- és munkatárs-fotó feltöltés ✅ |
| Vállalkozás szerkesztése, első beállítás (Setup), regisztráció | ✅ |
| Előfizetés | ✅ csak olvasható (csomag, állapot, funkciók; a menü a csomag szerint zárol) – a vásárlás szándékosan a weben marad |
| Fiók: jelszócsere, elfelejtett jelszó, visszajelzés (Profile, Feedback, ForgotPassword) | ✅ |

## Admin
Irányítópult, vállalkozások (be/kikapcsolás), foglalások, visszajelzések (megválaszolás) | ✅

## Megjegyzések
- ⚠ **Előfizetés:** az App Store / Play szabályai szerint a digitális előfizetést az alkalmazáson belül az áruház fizetési rendszerével kell
  kínálni (vagy az appból csak megnyitni/megjeleníteni a meglévő előfizetést, vásárlás nélkül). A mobilon ezért csak az állapot megjelenítése
  és a webes kezelés megnyitása javasolt – ezt jóváhagyás előtt még egyeztetni kell.
- Az **Embed** (beágyazás weboldalba) csak webes funkció, a mobilon nincs értelme.
- A fájlkezelés (logó, borító, fotók, költség-bizonylat) képválasztót igényel (`image_picker`).

## Sorrend
1. Ügyfél-részletek, szolgáltatások és munkatársak teljes kezelése, foglalás-részletek
2. Költségek, termékek, pénztár, bérletek, hűség, értékelések
3. Beszerzés, kampányok, munkaidő, napló, várólista, csoportos alkalmak, szünetek
4. Beállítások, vállalkozás-szerkesztés, fiók, admin
