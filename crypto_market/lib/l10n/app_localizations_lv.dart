// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'Kripto tirgus';

  @override
  String get registerTitle => 'Reģistrēties';

  @override
  String get emailLabel => 'E-pasts';

  @override
  String get emailRequired => 'E-pasts ir obligāts';

  @override
  String get emailInvalid => 'Ievadiet derīgu e-pastu';

  @override
  String get usernameLabel => 'Lietotājvārds';

  @override
  String get usernameRequired => 'Lietotājvārds ir obligāts';

  @override
  String get usernameMinLength => 'Minimālais garums 3';

  @override
  String get usernameMaxLength => 'Maksimālais garums 30';

  @override
  String get usernameInvalidChars => 'Atļauti tikai burti, cipari, _ un -';

  @override
  String get passwordLabel => 'Parole';

  @override
  String get passwordRequired => 'Parole ir obligāta';

  @override
  String get passwordMinLength => 'Minimālais garums 8';

  @override
  String get createAccount => 'Izveidot kontu';

  @override
  String get continueWithGoogle => 'Turpināt ar Google';

  @override
  String get continueWithApple => 'Turpināt ar Apple';

  @override
  String get errorInvalidCredentials => 'Nederīgi akreditācijas dati';

  @override
  String get errorOAuthDenied => 'OAuth noraidīts vai atcelts';

  @override
  String get errorNetwork => 'Tīkla kļūda. Lūdzu mēģiniet vēlreiz';

  @override
  String get errorUnknown => 'Radās kļūda';

  @override
  String get errorImagePicker => 'Kļūda attēla izvēlē';

  @override
  String get homeTitle => 'Sākums';

  @override
  String get loginTitle => 'Pieteikšanās';

  @override
  String get goToRegister => 'Doties uz reģistrāciju';

  @override
  String get languageEnglish => 'Angļu';

  @override
  String get languageLatvian => 'Latviešu';

  @override
  String get languageSystem => 'Sistēma';

  @override
  String get configErrorTitle => 'Konfigurācijas kļūda';

  @override
  String get profile => 'Profils';

  @override
  String get username => 'Lietotājvārds';

  @override
  String get email => 'E-pasts';

  @override
  String get authProvider => 'Autentifikācijas sniedzējs';

  @override
  String get selectImageSource => 'Izvēlieties attēla avotu';

  @override
  String get gallery => 'Galerija';

  @override
  String get camera => 'Kamera';

  @override
  String get retry => 'Mēģināt vēlreiz';

  @override
  String get updatingProfile => 'Atjaunina profilu...';

  @override
  String get profileUpdatedSuccess => 'Profils veiksmīgi atjaunots';

  @override
  String get logout => 'Iziet';

  @override
  String get sessionRestored => 'Sesija atjaunota';

  @override
  String get sessionExpired =>
      'Sesijas laiks beidzies, lūdzu pieteikšanās vēlreiz';

  @override
  String get editListingTitle => 'Rediģēt sludinājumu';

  @override
  String get listingTitleLabel => 'Nosaukums';

  @override
  String get priceLabel => 'Cena';

  @override
  String get titleRequired => 'Nosaukums ir obligāts';

  @override
  String get priceRequired => 'Cena ir obligāta';

  @override
  String get pricePositive => 'Cenai jābūt lielākai par 0';

  @override
  String get replaceImage => 'Mainīt attēlu';

  @override
  String get confirmUpdateTitle => 'Atjaunināt sludinājumu?';

  @override
  String get confirmUpdateMessage =>
      'Vai tiešām vēlaties atjaunināt šo sludinājumu?';

  @override
  String get confirmUpdateYes => 'Atjaunināt';

  @override
  String get confirmUpdateNo => 'Atcelt';

  @override
  String get saveChanges => 'Saglabāt izmaiņas';

  @override
  String get editSuccess => 'Sludinājums veiksmīgi atjaunināts';

  @override
  String get editFailure => 'Neizdevās atjaunināt sludinājumu';

  @override
  String get ok => 'Labi';

  @override
  String get errorTitleAuthentication => 'Autentifikācijas kļūda';

  @override
  String get errorTitleConnection => 'Savienojuma kļūda';

  @override
  String get errorTitleInvalidInput => 'Nederīga ievade';

  @override
  String get errorTitleOperation => 'Operācijas kļūda';

  @override
  String get errorTitleGeneric => 'Kļūda';

  @override
  String get errorAuthInvalidCredentials => 'Nederīgs e-pasts vai parole';

  @override
  String get errorAuthUserNotFound => 'Lietotājs nav atrasts';

  @override
  String get errorAuthEmailExists => 'Konts ar šo e-pastu jau pastāv';

  @override
  String get errorAuthWeakPassword => 'Parole ir pārāk vāja';

  @override
  String get errorAuthAccountLocked => 'Konts ir īslaicīgi bloķēts';

  @override
  String get errorAuthSessionExpired =>
      'Sesijas laiks beidzies. Lūdzu piesakieties vēlreiz';

  @override
  String get errorAuthInvalidToken => 'Nederīgs autentifikācijas marķieris';

  @override
  String get errorAuthPrincipalMismatch =>
      'ICP autentifikācijas principal neatbilst';

  @override
  String get errorAuthRegistrationFailed =>
      'Reģistrācija neizdevās. Lūdzu mēģiniet vēlreiz';

  @override
  String get errorAuthLoginFailed => 'Pieteikšanās neizdevās';

  @override
  String get errorAuthInsufficientPrivileges =>
      'Nepietiekamas privilēģijas šai darbībai';

  @override
  String get errorNetworkConnectionTimeout =>
      'Savienojuma taimauts. Lūdzu pārbaudiet interneta savienojumu';

  @override
  String get errorNetworkNoInternet => 'Nav pieejams interneta savienojums';

  @override
  String get errorNetworkServerError => 'Radās servera kļūda';

  @override
  String get errorNetworkCanisterUnavailable =>
      'ICP kanistrs pašlaik nav pieejams';

  @override
  String get errorNetworkRateLimitExceeded =>
      'Pārāk daudz pieprasījumu. Lūdzu uzgaidiet un mēģiniet vēlreiz';

  @override
  String get errorNetworkInvalidResponse => 'Nederīga servera atbilde';

  @override
  String get errorNetworkRequestFailed => 'Pieprasījums neizdevās';

  @override
  String errorValidationRequired(Object field) {
    return '$field ir obligāts';
  }

  @override
  String errorValidationFormat(Object field) {
    return '$field formāts ir nederīgs';
  }

  @override
  String errorValidationLength(Object field) {
    return '$field garums ir nederīgs';
  }

  @override
  String errorValidationRange(Object field) {
    return '$field ir ārpus diapazona';
  }

  @override
  String get errorBusinessInsufficientBalance =>
      'Nepietiekams atlikums šim darījumam';

  @override
  String get errorBusinessMarketClosed => 'Tirgus pašlaik ir slēgts';

  @override
  String get errorBusinessInvalidOperation => 'Šī darbība nav atļauta';

  @override
  String get errorBusinessRateLimitExceeded =>
      'Pieprasījumu limits pārsniegts. Lūdzu mēģiniet vēlāk';

  @override
  String get successGeneric => 'Darbība veiksmīgi pabeigta';

  @override
  String get createListingTitle => 'Izveidot sludinājumu';

  @override
  String get descriptionLabel => 'Apraksts';

  @override
  String get categoryLabel => 'Kategorija';

  @override
  String get conditionLabel => 'Stāvoklis';

  @override
  String get locationLabel => 'Atrašanās vieta';

  @override
  String get cryptoTypeLabel => 'Kriptovalūta';

  @override
  String get shippingOptionsLabel => 'Piegādes iespējas';

  @override
  String get imagesLabel => 'Attēli';

  @override
  String get conditionNew => 'Jauns';

  @override
  String get conditionUsed => 'Lietots';

  @override
  String get conditionRefurbished => 'Atjaunots';

  @override
  String get addImages => 'Pievienot attēlus';

  @override
  String get removeImage => 'Noņemt attēlu';

  @override
  String get descriptionRequired => 'Apraksts ir obligāts';

  @override
  String get categoryRequired => 'Kategorija ir obligāta';

  @override
  String get locationRequired => 'Atrašanās vieta ir obligāta';

  @override
  String get cryptoTypeRequired => 'Kriptovalūta ir obligāta';

  @override
  String get shippingOptionsRequired =>
      'Vismaz viena piegādes iespēja ir obligāta';

  @override
  String get createListing => 'Izveidot sludinājumu';

  @override
  String get creating => 'Izveido...';

  @override
  String get listingCreatedSuccess => 'Sludinājums veiksmīgi izveidots!';

  @override
  String get listingCreatedFailure => 'Neizdevās izveidot sludinājumu';

  @override
  String get descriptionHint => 'Aprakstiet savu preci detalizēti...';

  @override
  String get titleHint => 'Ko jūs pārdodat?';

  @override
  String get locationHint => 'Pilsēta, Valsts/Reģions';

  @override
  String get addShippingOption => 'Pievienot piegādes iespēju';

  @override
  String get uploadingImages => 'Augšupielādē attēlus...';

  @override
  String get imageUploadFailed => 'Attēla augšupielāde neizdevās';

  @override
  String get searchListingsTitle => 'Pārlūkot sludinājumus';

  @override
  String get searchPlaceholder => 'Meklēt sludinājumus pēc atslēgvārdiem';

  @override
  String get searchFieldLabel => 'Meklēt';

  @override
  String get filtersTitle => 'Filtri';

  @override
  String get filterPriceMin => 'Min. cena (USD)';

  @override
  String get filterPriceMax => 'Maks. cena (USD)';

  @override
  String get filterLocationLabel => 'Atrašanās vieta';

  @override
  String get filterConditionLabel => 'Stāvoklis';

  @override
  String get filterSortLabel => 'Kārtot pēc';

  @override
  String get filtersApply => 'Pielietot filtrus';

  @override
  String get filtersClear => 'Notīrīt filtrus';

  @override
  String get filtersApplied => 'Filtri piemēroti';

  @override
  String get filtersCleared => 'Filtri notīrīti';

  @override
  String get searchNoResults =>
      'Nevienam sludinājumam neatbilst izvēlētie filtri. Precizējiet meklēšanu vai mēģiniet vēlreiz.';

  @override
  String get sortNewest => 'Jaunākie sākumā';

  @override
  String get sortPriceLowHigh => 'Cena: no zemākās uz augstāko';

  @override
  String get sortPriceHighLow => 'Cena: no augstākās uz zemāko';

  @override
  String get categoryElectronics => 'Elektronika';

  @override
  String get categoryFashion => 'Mode';

  @override
  String get categoryHomeGarden => 'Māja un dārzs';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryBooks => 'Grāmatas';

  @override
  String get categoryAutomotive => 'Auto';

  @override
  String get categoryCollectibles => 'Kolekcijas';

  @override
  String get categoryOther => 'Cits';
}
