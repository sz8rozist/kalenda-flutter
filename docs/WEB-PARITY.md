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
| Várólista-leiratkozás (WaitlistRemoved), marketing-leiratkozás | ⬜ |
| Ügyfél-dokumentumok (számla/blokk letöltése) | ⬜ |
| Eszköz-kölcsönzés (rentals) | ⬜ |

## Munkatárs-portál (StaffPortal)
| Web | Mobil |
|---|---|
| Ma, naptár, szabadság, időmérés (ki/bejelentkezés) | ✅ |
| Foglalás állapota, áthelyezése | ✅ |
| Munkaidő-nyilvántartás (Timesheet) saját | ⬜ |
| Saját profil, naptár-feed token (Profile, Account) | ⬜ |

## Vállalkozó (Business)
| Web | Mobil |
|---|---|
| Irányítópult (Dashboard) | 🟡 (bevétel, mai foglalások) |
| Naptár | ✅ |
| Foglalás létrehozása (Appointments/Create) | ✅ |
| Foglalás részletei, számla kiállítása (Appointments/Show) | ⬜ |
| Ügyfelek lista, ügyfél részletei, profil, számlázási adatok, hűségpont-váltás (Customer/Show) | ✅ |
| Szolgáltatások: lista, létrehozás, szerkesztés, törlés | ✅ · kiegészítők (addons), anyagok, kép ⬜ |
| Munkatársak: lista, létrehozás, szerkesztés, szolgáltatások, meghívó, hozzáférés-megvonás, törlés | ✅ · munkaidő, bér, fotó ⬜ |
| Nyitvatartás (Settings/Hours) | ✅ |
| Szabadságok (Settings/Leaves) | ✅ (jóváhagyás) · saját szabadság felvétele ⬜ |
| Szünetek (Calendar/Breaks) | ⬜ |
| Számlák (Invoices) | 🟡 (lista, fizetve, emlékeztető) · kiállítás, sztornó, hiányzó dokumentumok ⬜ |
| Riportok: könyvelés, cash-flow | ✅ · kifizetések (Payouts) ⬜ |
| Költségek (Expenses): lista, felvitel, törlés | ✅ · bizonylat, export ⬜ |
| Termékek (Products), értékesítés | ⬜ |
| Beszerzés (Purchasing), beszállítók | ⬜ |
| Pénztár (Register) | ⬜ |
| Ajánlatok (Quotes) | ⬜ |
| Hűségprogram (Loyalty) | ⬜ |
| Bérletek / utalványok: eladottak listája | 🟡 · típusok kezelése, helyszíni eladás ⬜ |
| Kampányok (Campaigns) | ⬜ |
| Értékelések (Reviews) + beállítás | ✅ |
| Munkaidő (Timesheet), zárás, export | ⬜ |
| Tevékenység-napló (ActivityLog) | ✅ |
| Várólista (Waitlist): lista, értesítés, eltávolítás | ✅ · csoportos alkalmak kezelése ⬜ |
| Értesítések (notifications) | ⬜ |
| Beállítások: foglalási oldal, logó/borító/fotók, szabályzat, mód, fizetés (Stripe Connect), számlázás, naptár-szinkron | ⬜ |
| Vállalkozás szerkesztése, első beállítás (Setup), regisztráció | ⬜ |
| Előfizetés: csomagok, számlázás (Subscription) | ⬜ ⚠ lásd lent |
| Fiók: profil, jelszócsere, jelszó-visszaállítás, visszajelzés (Profile, Feedback, ForgotPassword) | ⬜ |

## Admin
Irányítópult, vállalkozások (be/kikapcsolás), foglalások, visszajelzések | ⬜

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
