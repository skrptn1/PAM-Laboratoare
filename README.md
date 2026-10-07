# GemStore - Laborator nr. 3

Aplicatie Flutter copiata din laboratorul 2, cu designul existent si functionalitate
bazata pe **Cubit**, din package-ul `flutter_bloc`.

## Pornire

Din `Laborator 3/gemstore`:

```sh
flutter pub get
flutter run
```

Aplicatia Android este identificata prin `com.pam.gemstore.lab3` si apare ca
**GemStore Lab 3**, astfel incat poate fi instalata alaturi de laboratorul 2.

## Cerinte implementate

- JSON local: `assets/data/lab_v1.json`, copie nemodificata a fisierului primit.
- Incarcare asincrona cu `rootBundle.loadString` si decodare JSON cu `compute`.
- Stari Loading, Success, Empty si Error; reincercare dupa eroare.
- Catalog cu cautare dupa nume, filtrare dupa categorie si resetarea filtrelor.
- Sortare dupa pret crescator/descrescator, nume, rating sau ordinea initiala.
- Favorite comune intre Home, catalog, detalii si ecranul Favorites.
- Navigare catre detaliile fiecarui produs, galerie si sectiuni extensibile.
- Culori si marimi preluate din JSON; marimile indisponibile sunt dezactivate.
- Cos functional: variante, cantitati, eliminare si calcularea totalului.
- Componente UI reutilizabile si teste de logica, navigare si afisare.

## Organizarea proiectului

```text
lib/
  models/    Product, ProductColor, Review, StoreData, CollectionBanner
  data/      StoreRepository: incarcare si decodare asincrona
  state/     StoreCubit/StoreState si ProductCubit/ProductSelection
  screens/   Home, AllProducts, Product, Cart
  widgets/   CatalogControls, ProductCard, FavoriteButton, StoreStatusView,
             AppImage, StarRow, SectionHeader
  main.dart  BlocProvider deasupra MaterialApp, aceeasi stare intre rute
```

Logica de cautare, filtrare, sortare, favorite si cos este in `StoreCubit`.
`ProductCubit` controleaza alegerea variantei produsului. Starea locala a
widgeturilor se foloseste pentru animatii, scroll si extinderea sectiunilor.

## Utilizare

Lupa din Home deschide catalogul. Campul Search products filtreaza imediat;
chipurile aleg categoria, iar Sort by schimba ordinea. Reset filters elimina
cautarea, categoria si sortarea. Meniul lateral contine Discover, Favorites
si Shopping bag. Inima de pe un produs adauga/elimina acelasi ID din favorite.
Add To Cart adauga varianta selectata, iar VIEW BAG deschide cosul.
Catalogul poate fi reincarcat prin tragere in jos.

## Particularitatile datelor primite

JSON-ul contine 8 produse unice. Produsul `p003` (Sportwear Set) apare atat
in Home, cat si in productPage; repository-ul combina aceste inregistrari
intr-un singur produs, pastrand detaliile complete. Recenziile, ratingul,
culorile, marimile si produsele similare sunt furnizate numai pentru acesta.
Pentru celelalte produse se afiseaza explicit lipsa detaliilor si a recenziilor.
Nu sunt inventate descrieri, ratinguri sau variante.

Produsele nu au campul category in JSON-ul primit. Asocierea documentata este:
`p005` Cotton T-shirt -> Men; celelalte produse din design -> Women.
Accessories si Beauty afiseaza o lista goala. Parser-ul accepta un camp
optional category (`women`, `men`, `accessories`, `beauty`) daca este adaugat
ulterior in JSON. Categoriile, denumirea magazinului si textele promotiilor
se citesc din JSON.

URL-urile imaginilor din JSON se pastreaza in modelele produselor. Pentru
ID-urile cunoscute se folosesc fotografiile locale din laboratorul 2,
pastrand designul si functionarea fara internet. ID-urile noi folosesc URL-ul
primit. Bannerul Summer Collection este un decupaj din macheta originala.

Favoritele si cosul se pastreaza pe durata sesiunii si intre ecrane;
la repornire se reiau valorile initiale din JSON. Aplicatia nu are checkout,
autentificare sau server pentru trimiterea comenzilor/recenziilor.

## Verificare

```sh
flutter analyze
flutter test
flutter build apk --debug
```

Testele acopera incarcarea asincrona, combinarea inregistrarilor, erori JSON,
erori de citire si retry, catalog gol, cautare combinata cu filtre si sortare,
favorite la reincarcare, marimi indisponibile, variantele si totalul cosului,
stari UI, navigare si afisare la 320, 375 si 390 pixeli.

Documentatie: [flutter_bloc](https://pub.dev/packages/flutter_bloc) si
[decodare asincrona JSON in Flutter](https://docs.flutter.dev/cookbook/networking/background-parsing).
