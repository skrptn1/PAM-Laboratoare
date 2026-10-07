# GemStore

Aplicatie Flutter pentru laboratorul PAM 2, realizata dupa machetele
`homepage full.png` si `product full.png` din arhiva Laboratoare 2026.

Pornire, din acest director:

```sh
flutter pub get
flutter run
```

Verificare si compilare Android:

```sh
flutter analyze
flutter test
flutter build apk --debug
```

Fotografiile originale sunt incluse local in `assets/images`.
Fotografia rochiei cu maneci lungi, fotografia hanoracului alb si bannerul
Summer Collection au fost decupate din macheta, deoarece nu exista separat
in directorul de imagini primit. Fontul Poppins si licenta sa sunt incluse
in `assets/fonts`.

Laboratorul 2 contine exact doua ecrane: Home si macheta fixa Sportwear Set.
Apasarea oricarui produs de pe Home deschide aceeasi pagina Sportwear Set,
cu pretul de 80 USD si informatiile fixe din macheta. Sageata inapoi revine
la Home. Nu exista catalog sau alte pagini in acest laborator.

Categoria, culoarea, marimea, inima, indicatorii galeriei si sectiunile au
valori fixe. Show all, meniul, produsele similare, Add To Cart, Read more,
notificarile si Write a review sunt elemente vizuale fara actiuni.
Navigarea este instantanee (PageRouteBuilder cu durate zero). Nu exista
Hero, efecte la apasare sau indicatori animati de incarcare. Derularea nu
foloseste efecte de overscroll.
Continutul poate fi derulat pentru vizualizarea machetelor complete.
Datele dinamice si functionalitatile se afla separat in Laborator 3.

Fotografia Sportwear Set se afiseaza integral in carduri. Exportul primit
pentru Sport Sweater continea numai un fragment de 52 px latime; cardul
foloseste o fotografie completa alternativa, inclusa local.

Testele verifica afisarea la latimi de 320, 375 si 390 px si navigarea
catre detaliile unui produs.
