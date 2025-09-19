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
  String get listingDetailTitle => 'Sludinājuma informācija';

  @override
  String get contactSeller => 'Sazināties ar pārdevēju';

  @override
  String get reportListing => 'Ziņot par sludinājumu';

  @override
  String get shareListing => 'Kopīgot sludinājumu';

  @override
  String get sellerInfo => 'Pārdevēja informācija';

  @override
  String get sellerReputation => 'Reputācija';

  @override
  String get sellerLocation => 'Atrašanās vieta';

  @override
  String get memberSince => 'Biedrs kopš';

  @override
  String get viewProfile => 'Skatīt profilu';

  @override
  String get noImagesAvailable => 'Attēli nav pieejami';

  @override
  String get imageGallery => 'Attēlu galerija';

  @override
  String get previous => 'Iepriekšējais';

  @override
  String get next => 'Nākamais';

  @override
  String get imageOf => 'no';

  @override
  String get loadingListing => 'Ielādē sludinājumu...';

  @override
  String get listingNotFound => 'Sludinājums nav atrasts';

  @override
  String get errorLoadingListing => 'Kļūda ielādējot sludinājumu';

  @override
  String get buyNow => 'Pirkt tagad';

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

  @override
  String get paymentMethods => 'Maksājumu Metodes';

  @override
  String get managePaymentMethods => 'Pārvaldīt Maksājumu Metodes';

  @override
  String get paymentMethodsDescription =>
      'Pievienojiet un pārvaldiet savas maksājumu metodes drošām transakcijām.';

  @override
  String get addPaymentMethod => 'Pievienot Maksājuma Metodi';

  @override
  String get editPaymentMethod => 'Rediģēt Maksājuma Metodi';

  @override
  String get noPaymentMethods => 'Nav Maksājumu Metožu';

  @override
  String get addPaymentMethodPrompt =>
      'Pievienojiet maksājuma metodi, lai sāktu veikt drošas transakcijas.';

  @override
  String get selectPaymentType => 'Izvēlieties Maksājuma Veidu';

  @override
  String get bankTransfer => 'Bankas Pārskaitījums';

  @override
  String get bankTransferDescription =>
      'Tiešs pārskaitījums no bankas uz banku';

  @override
  String get digitalWallet => 'Digitālais Maciņš';

  @override
  String get digitalWalletDescription => 'PayPal, Wise, Venmo, utt.';

  @override
  String get cash => 'Skaidra Nauda';

  @override
  String get cashDescription => 'Tikšanās ar skaidras naudas maksājumu';

  @override
  String get accountNumber => 'Konta Numurs';

  @override
  String get accountNumberHint => 'Ievadiet konta numuru';

  @override
  String get accountNumberRequired => 'Konta numurs ir obligāts';

  @override
  String get routingNumber => 'Maršrutēšanas Numurs';

  @override
  String get routingNumberHint => 'Ievadiet maršrutēšanas numuru';

  @override
  String get routingNumberRequired => 'Maršrutēšanas numurs ir obligāts';

  @override
  String get accountHolderName => 'Konta Īpašnieka Vārds';

  @override
  String get accountHolderNameHint => 'Ievadiet konta īpašnieka vārdu';

  @override
  String get accountHolderNameRequired => 'Konta īpašnieka vārds ir obligāts';

  @override
  String get bankName => 'Bankas Nosaukums';

  @override
  String get bankNameHint => 'Ievadiet bankas nosaukumu';

  @override
  String get bankNameRequired => 'Bankas nosaukums ir obligāts';

  @override
  String get swiftCode => 'SWIFT Kods';

  @override
  String get swiftCodeHint => 'Ievadiet SWIFT/BIC kodu (neobligāts)';

  @override
  String get iban => 'IBAN';

  @override
  String get ibanHint => 'Ievadiet IBAN numuru (neobligāts)';

  @override
  String get walletId => 'Maciņa ID';

  @override
  String get walletIdHint => 'Ievadiet maciņa ID vai e-pastu';

  @override
  String get walletIdRequired => 'Maciņa ID ir obligāts';

  @override
  String get provider => 'Pakalpojuma Sniedzējs';

  @override
  String get providerHint => 'piem., PayPal, Wise, Venmo';

  @override
  String get providerRequired => 'Pakalpojuma sniedzējs ir obligāts';

  @override
  String get emailHint => 'Ievadiet e-pasta adresi';

  @override
  String get phoneNumber => 'Tālruņa Numurs';

  @override
  String get phoneNumberHint => 'Ievadiet tālruņa numuru';

  @override
  String get accountName => 'Konta Nosaukums';

  @override
  String get accountNameHint => 'Ievadiet konta nosaukumu (neobligāts)';

  @override
  String get meetingLocation => 'Tikšanās Vieta';

  @override
  String get meetingLocationHint => 'Ievadiet tikšanās vietu';

  @override
  String get meetingLocationRequired => 'Tikšanās vieta ir obligāta';

  @override
  String get preferredTime => 'Vēlamais Laiks';

  @override
  String get preferredTimeHint => 'Ievadiet vēlamo tikšanās laiku';

  @override
  String get preferredTimeRequired => 'Vēlamais laiks ir obligāts';

  @override
  String get contactInfo => 'Kontaktinformācija';

  @override
  String get contactInfoHint => 'E-pasts vai tālruņa numurs';

  @override
  String get contactInfoRequired => 'Kontaktinformācija ir obligāta';

  @override
  String get specialInstructions => 'Speciālas Norādes';

  @override
  String get specialInstructionsHint => 'Īpašas prasības (neobligāts)';

  @override
  String get optional => 'Neobligāts';

  @override
  String get cancel => 'Atcelt';

  @override
  String get save => 'Saglabāt';

  @override
  String get edit => 'Rediģēt';

  @override
  String get delete => 'Dzēst';

  @override
  String get deletePaymentMethod => 'Dzēst Maksājuma Metodi';

  @override
  String get deletePaymentMethodConfirmation =>
      'Vai tiešām vēlaties dzēst šo maksājuma metodi? Šī darbība ir neatgriezeniska.';

  @override
  String get verified => 'Apstiprināts';

  @override
  String get pending => 'Gaida apstiprinājumu';

  @override
  String get rejected => 'Noraidīts';

  @override
  String get lastUsed => 'Pēdējo Reizi Izmantots';

  @override
  String get paymentProof => 'Maksājuma Apliecinājums';

  @override
  String get submitPaymentProof => 'Iesniegt Maksājuma Apliecinājumu';

  @override
  String get paymentProofDescription =>
      'Augšupielādējiet savas maksājuma apliecinājumu, lai pabeigtu transakciju.';

  @override
  String get paymentProofSecurityNote =>
      'Jūsu apliecinājums tiks droši glabāts IPFS un koplietots tikai ar transakcijas otru pusi.';

  @override
  String get selectProofType => 'Izvēlieties Apliecinājuma Veidu';

  @override
  String get receipt => 'Čeks';

  @override
  String get transactionId => 'Transakcijas ID';

  @override
  String get photo => 'Foto';

  @override
  String get confirmation => 'Apstiprinājums';

  @override
  String get uploadProof => 'Augšupielādēt Apliecinājumu';

  @override
  String get uploadReceiptOrPhoto => 'Augšupielādēt Čeku vai Foto';

  @override
  String get uploadInstructions =>
      'Uzņemiet foto vai augšupielādējiet čeku/transakcijas apstiprinājumu';

  @override
  String get retake => 'Noņemt vēlreiz';

  @override
  String get chooseAnother => 'Izvēlēties citu';

  @override
  String get transactionDetails => 'Transakcijas Detaļas';

  @override
  String get transactionIdHint => 'Ievadiet transakcijas ID (ja piemērojams)';

  @override
  String get transactionIdRequired => 'Transakcijas ID ir obligāts';

  @override
  String get additionalNotes => 'Papildu Piezīmes';

  @override
  String get additionalNotesHint => 'Jebkura papildu informācija (neobligāts)';

  @override
  String get submitProof => 'Iesniegt Apliecinājumu';

  @override
  String get pleaseUploadImage =>
      'Lūdzu augšupielādējiet attēlu kā apliecinājumu';

  @override
  String get imagePickerError => 'Kļūda atlasot attēlu';

  @override
  String get paymentProofSubmitted =>
      'Maksājuma apliecinājums veiksmīgi iesniegts';

  @override
  String get paymentProofSubmitError =>
      'Neizdevās iesniegt maksājuma apliecinājumu';

  @override
  String get buyFlowTitle => 'Pirkt sludinājumu';

  @override
  String get buyFlowCancelButton => 'Atcelt';

  @override
  String get buyFlowErrorMessage => 'Izpildot pirkumu radās kļūda';

  @override
  String get buyFlowErrorRetry => 'Mēģināt vēlreiz';

  @override
  String get buyFlowPriceTitle => 'Apstiprināt cenu';

  @override
  String get buyFlowPriceDescription =>
      'Pirms turpināt, pārskatiet pašreizējo cenu un kriptovalūtas konversijas kursu.';

  @override
  String get buyFlowConfirmTitle => 'Apstiprināt pirkumu';

  @override
  String get buyFlowConfirmDescription =>
      'Lūdzu pārskatiet savas pirkuma detaļas zemāk pirms turpināt ar maksājumu.';

  @override
  String get buyFlowConfirmListing => 'Sludinājums';

  @override
  String get buyFlowConfirmSeller => 'Pārdevējs';

  @override
  String get buyFlowUsdAmount => 'USD summa';

  @override
  String get buyFlowCryptoAmount => 'Kripto summa';

  @override
  String get buyFlowPaymentTitle => 'Drošs maksājums';

  @override
  String get buyFlowPaymentDescription =>
      'Jūsu maksājums tiks nodrošināts caur atomārās apmaiņas līgumu, lai aizsargātu gan pircēju, gan pārdevēju.';

  @override
  String get buyFlowPaymentGenerating => 'Ģenerē drošu maksājumu...';

  @override
  String get buyFlowConfirmButton => 'Apstiprināt pirkumu';

  @override
  String get buyFlowCompleteTitle => 'Pirkums veiksmīgs';

  @override
  String get buyFlowCompleteSuccess => 'Jūsu pirkums ir veiksmīgi uzsākts!';

  @override
  String buyFlowCompleteSwapCreated(Object swapId) {
    return 'Apmaiņas ID: $swapId';
  }

  @override
  String get buyFlowCompleteNextSteps => 'Nākamās darbības';

  @override
  String buyFlowCompleteStep1(Object seller) {
    return 'Sazinieties ar $seller, lai vienotu maksājuma detaļas';
  }

  @override
  String get buyFlowCompleteStep2 =>
      'Veiciet maksājumu un iesniedziet apliecinājumu';

  @override
  String get buyFlowCompleteStep3 =>
      'Pārdevējs atbrīvos kriptovalūtu pēc maksājuma apstiprināšanas';

  @override
  String get buyFlowBackButton => 'Atpakaļ';

  @override
  String get buyFlowNextButton => 'Tālāk';

  @override
  String get buyFlowErrorTitle => 'Kļūda';

  @override
  String get buyFlowErrorCancel => 'Atcelt';

  @override
  String get buyFlowStepPrice => 'Cena';

  @override
  String get buyFlowStepConfirm => 'Apstiprināt';

  @override
  String get buyFlowStepPayment => 'Maksājums';

  @override
  String get buyFlowStepCompletion => 'Pabeigt';

  @override
  String get buyFlowRefreshButton => 'Atjaunot';

  @override
  String get buyFlowExchangeRate => 'Mainīgais kurss';

  @override
  String get buyFlowPriceStaleWarning =>
      'Cena var būt novecojusi. Pieskarieties, lai atjauninātu.';

  @override
  String get buyFlowLastUpdated => 'Pēdējoreiz atjaunināts';
}
