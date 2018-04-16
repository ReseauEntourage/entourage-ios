//
//  OTCountryCodePickerViewDataSource.m
//  entourage
//
//  Created by veronica.gliga on 19/06/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCountryCodePickerViewDataSource.h"

@interface OTCountryCodePickerViewDataSource ()

@property (nonatomic, strong) NSArray *source;

@end

@implementation OTCountryCodePickerViewDataSource

+ (OTCountryCodePickerViewDataSource *)sharedInstance {
    
    static OTCountryCodePickerViewDataSource* countryCodePickerViewDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        countryCodePickerViewDataSource = [[OTCountryCodePickerViewDataSource alloc] init];
        
    });
    return countryCodePickerViewDataSource;
}

- (OTCountryCodePickerViewDataSource*) init {
    self = [super init];
    if (self) {
        self.source = @[
                        @{
                            @"Code 2 char" : @"FR",
                            @"Final list" : @"France",
                            @"Number" : @"+33",
                            },
                        @{
                            @"Code 2 char": @"BE",
                            @"Final list": @"Belgique",
                            @"Number": @"+32"
                            },
                        @{
                            @"Code 2 char" : @"CA",
                            @"Final list" : @"Canada",
                            @"Number" : @"+1",
                            },
                        @{
                            @"Code 2 char" : @"GP",
                            @"Final list" : @"Guadeloupe",
                            @"Number" : @"+590",
                            },
                        @{
                            @"Code 2 char" : @"GF",
                            @"Final list" : @"Guyane française",
                            @"Number" : @"+594",
                            },
                        @{
                            @"Code 2 char" : @"MQ",
                            @"Final list" : @"Martinique",
                            @"Number" : @"+596",
                            },
                        @{
                            @"Code 2 char" : @"MU",
                            @"Final list" : @"Maurice",
                            @"Number" : @"+230",
                            },
                        @{
                            @"Code 2 char" : @"YT",
                            @"Final list" : @"Mayotte",
                            @"Number" : @"+262",
                            },
                        @{
                            @"Code 2 char" : @"PF",
                            @"Final list" : @"Polynésie française",
                            @"Number" : @"+689",
                            },
                        @{
                            @"Code 2 char" : @"RE",
                            @"Final list" : @"Réunion",
                            @"Number" : @"+262",
                            },
                        @{
                            @"Code 2 char" : @"AF",
                            @"Final list" : @"Afghanistan",
                            @"Number" : @"+93",
                            },
                        @{
                            @"Code 2 char" : @"ZA",
                            @"Final list" : @"Afrique du Sud",
                            @"Number" : @"+27",
                            },
                        @{
                            @"Code 2 char" : @"AL",
                            @"Final list" : @"Albanie",
                            @"Number" : @"+355",
                            },
                        @{
                            @"Code 2 char" : @"DZ",
                            @"Final list" : @"Algérie",
                            @"Number" : @"+213"
                            },
                        @{
                            @"Code 2 char" : @"DE",
                            @"Final list" : @"Allemagne",
                            @"Number" : @"+49",
                            },
                        @{
                            @"Code 2 char" : @"AD",
                            @"Final list" : @"Andorre",
                            @"Number" : @"+376",
                            },
                        @{
                            @"Code 2 char" : @"AO",
                            @"Final list" : @"Angola",
                            @"Number" : @"+244",
                            },
                        @{
                            @"Code 2 char" : @"SA",
                            @"Final list" : @"Arabie Saoudite",
                            @"Number" : @"+966",
                            },
                        @{
                            @"Code 2 char" : @"AR",
                            @"Final list" : @"Argentine",
                            @"Number" : @"+54",
                            },
                        @{
                            @"Code 2 char" : @"AM",
                            @"Final list" : @"Arménie",
                            @"Number" : @"+374",
                            },
                        @{
                            @"Code 2 char" : @"AU",
                            @"Final list" : @"Australie",
                            @"Number" : @"+61",
                            },
                        @{
                            @"Code 2 char" : @"AT",
                            @"Final list" : @"Autriche",
                            @"Number" : @"+43",
                            },
                        @{
                            @"Code 2 char" : @"AZ",
                            @"Final list" : @"Azerbaïdjan",
                            @"Number" : @"+994"
                            },
                        @{
                            @"Code 2 char" : @"BH",
                            @"Final list" : @"Bahrein",
                            @"Number" : @"+973"
                            },
                        @{
                            @"Code 2 char" : @"BD",
                            @"Final list" : @"Bangladesh",
                            @"Number" : @"+880"
                            },
                        @{
                            @"Code 2 char" : @"BY",
                            @"Final list" : @"Bélarus",
                            @"Number" : @"+375"
                            },
                        @{
                            @"Code 2 char" : @"BZ",
                            @"Final list" : @"Bélize",
                            @"Number" : @"+501"
                            },
                        @{
                            @"Code 2 char" : @"BJ",
                            @"Final list" : @"Bénin",
                            @"Number" : @"+229"
                            },
                        @{
                            @"Code 2 char" : @"BT",
                            @"Final list" : @"Bhoutan",
                            @"Number" : @"+975"
                            },
                        @{
                            @"Code 2 char" : @"BO",
                            @"Final list" : @"Bolivie",
                            @"Number" : @"+591"
                            },
                        @{
                            @"Code 2 char" : @"BA",
                            @"Final list" : @"Bosnie-Herzégovine",
                            @"Number" : @"+387"
                            },
                        @{
                            @"Code 2 char" : @"BW",
                            @"Final list" : @"Botswana",
                            @"Number" : @"+267"
                            },
                        @{
                            @"Code 2 char" : @"BR",
                            @"Final list" : @"Brésil",
                            @"Number" : @"+55"
                            },
                        @{
                            @"Code 2 char" : @"BN",
                            @"Final list" : @"Brunéi",
                            @"Number" : @"+673"
                            },
                        @{
                            @"Code 2 char" : @"BG",
                            @"Final list" : @"Bulgarie",
                            @"Number" : @"+359"
                            },
                        @{
                            @"Code 2 char" : @"BF",
                            @"Final list" : @"Burkina Faso",
                            @"Number" : @"+226"
                            },
                        @{
                            @"Code 2 char" : @"BI",
                            @"Final list" : @"Burundi",
                            @"Number" : @"+257"
                            },
                        @{
                            @"Code 2 char" : @"KH",
                            @"Final list" : @"Cambodge",
                            @"Number" : @"+855"
                            },
                        @{
                            @"Code 2 char" : @"CM",
                            @"Final list" : @"Cameroun",
                            @"Number" : @"+237"
                            },
                        @{
                            @"Code 2 char" : @"CA",
                            @"Final list" : @"Canada",
                            @"Number" : @"+1"
                            },
                        @{
                            @"Code 2 char" : @"CV",
                            @"Final list" : @"Cap Vert",
                            @"Number" : @"+238"
                            },
                        @{
                            @"Code 2 char" : @"CL",
                            @"Final list" : @"Chili",
                            @"Number" : @"+56"
                            },
                        @{
                            @"Code 2 char" : @"CN",
                            @"Final list" : @"Chine",
                            @"Number" : @"+86"
                            },
                        @{
                            @"Code 2 char" : @"CY",
                            @"Final list" : @"Chypre",
                            @"Number" : @"+357"
                            },
                        @{
                            @"Code 2 char" : @"CO",
                            @"Final list" : @"Colombie",
                            @"Number" : @"+57"
                            },
                        @{
                            @"Code 2 char" : @"CG",
                            @"Final list" : @"Congo",
                            @"Number" : @"+242"
                            },
                        @{
                            @"Code 2 char" : @"KR",
                            @"Final list" : @"Corée du Sud",
                            @"Number" : @"+82"
                            },
                        @{
                            @"Code 2 char" : @"CR",
                            @"Final list" : @"Costa Rica",
                            @"Number" : @"+506"
                            },
                        @{
                            @"Code 2 char" : @"CI",
                            @"Final list" : @"Côte d'Ivoire",
                            @"Number" : @"+225"
                            },
                        @{
                            @"Code 2 char" : @"HR",
                            @"Final list" : @"Croatie",
                            @"Number" : @"+385"
                            },
                        @{
                            @"Code 2 char" : @"CU",
                            @"Final list" : @"Cuba",
                            @"Number" : @"+53"
                            },
                        @{
                            @"Code 2 char" : @"DK",
                            @"Final list" : @"Danemark",
                            @"Number" : @"+45",
                            },
                        @{
                            @"Code 2 char" : @"DJ",
                            @"Final list" : @"Djibouti",
                            @"Number" : @"+253"
                            },
                        @{
                            @"Code 2 char" : @"DM",
                            @"Final list" : @"Dominique",
                            @"Number" : @"+1767"
                            },
                        @{
                            @"Code 2 char" : @"EG",
                            @"Final list" : @"Egypte",
                            @"Number" : @"+20"
                            },
                        @{
                            @"Code 2 char" : @"SV",
                            @"Final list" : @"El Salvador",
                            @"Number" : @"+503"
                            },
                        @{
                            @"Code 2 char" : @"AE",
                            @"Final list" : @"Emirats arabes unis",
                            @"Number" : @"+971"
                            },
                        @{
                            @"Code 2 char" : @"EC",
                            @"Final list" : @"Equateur",
                            @"Number" : @"+593"
                            },
                        @{
                            @"Code 2 char" : @"ER",
                            @"Final list" : @"Erythrée",
                            @"Number" : @"+291"
                            },
                        @{
                            @"Code 2 char" : @"ES",
                            @"Final list" : @"Espagne",
                            @"Number" : @"+34"
                            },
                        @{
                            @"Code 2 char" : @"EE",
                            @"Final list" : @"Estonie",
                            @"Number" : @"+372"
                            },
                        @{
                            @"Code 2 char" : @"US",
                            @"Final list" : @"Etats-Unis",
                            @"Number" : @"+1"
                            },
                        @{
                            @"Code 2 char" : @"ET",
                            @"Final list" : @"Ethiopie",
                            @"Number" : @"+251"
                            },
                        @{
                            @"Code 2 char" : @"FJ",
                            @"Final list" : @"Fidji",
                            @"Number" : @"+679",
                            },
                        @{
                            @"Code 2 char" : @"FI",
                            @"Final list" : @"Finlande",
                            @"Number" : @"+358",
                            },
                        @{
                            @"Code 2 char" : @"GA",
                            @"Final list" : @"Gabon",
                            @"Number" : @"+241",
                            },
                        @{
                            @"Code 2 char" : @"GM",
                            @"Final list" : @"Gambie",
                            @"Number" : @"+220",
                            },
                        @{
                            @"Code 2 char" : @"GE",
                            @"Final list" : @"Géorgie",
                            @"Number" : @"+995",
                            },
                        @{
                            @"Code 2 char" : @"GH",
                            @"Final list" : @"Ghana",
                            @"Number" : @"+233",
                            },
                        @{
                            @"Code 2 char" : @"GI",
                            @"Final list" : @"Gibraltar",
                            @"Number" : @"+350",
                            },
                        @{
                            @"Code 2 char" : @"GR",
                            @"Final list" : @"Grèce",
                            @"Number" : @"+30",
                            },
                        @{
                            @"Code 2 char" : @"GT",
                            @"Final list" : @"Guatemala",
                            @"Number" : @"+502",
                            },
                        @{
                            @"Code 2 char" : @"GN",
                            @"Final list" : @"Guinée",
                            @"Number" : @"+224",
                            },
                        @{
                            @"Code 2 char" : @"GQ",
                            @"Final list" : @"Guinée équatoriale",
                            @"Number" : @"+240",
                            },
                        @{
                            @"Code 2 char" : @"GW",
                            @"Final list" : @"Guinée-Bissau",
                            @"Number" : @"+245",
                            },
                        @{
                            @"Code 2 char" : @"GY",
                            @"Final list" : @"Guyana",
                            @"Number" : @"+592",
                            },
                        @{
                            @"Code 2 char" : @"HT",
                            @"Final list" : @"Haïti",
                            @"Number" : @"+509",
                            },
                        @{
                            @"Code 2 char" : @"HN",
                            @"Final list" : @"Honduras",
                            @"Number" : @"+504",
                            },
                        @{
                            @"Code 2 char" : @"HK",
                            @"Final list" : @"Hong Kong",
                            @"Number" : @"+852",
                            },
                        @{
                            @"Code 2 char" : @"HU",
                            @"Final list" : @"Hongrie",
                            @"Number" : @"+36",
                            },
                        @{
                            @"Code 2 char" : @"IN",
                            @"Final list" : @"Inde",
                            @"Number" : @"+91"
                            },
                        @{
                            @"Code 2 char" : @"ID",
                            @"Final list" : @"Indonésie",
                            @"Number" : @"+62",
                            },
                        @{
                            @"Code 2 char" : @"IQ",
                            @"Final list" : @"Irak",
                            @"Number" : @"+964",
                            },
                        @{
                            @"Code 2 char" : @"IR",
                            @"Final list" : @"Iran",
                            @"Number" : @"+98",
                            },
                        @{
                            @"Code 2 char" : @"IE",
                            @"Final list" : @"Irlande",
                            @"Number" : @"+353",
                            },
                        @{
                            @"Code 2 char" : @"IS",
                            @"Final list" : @"Islande",
                            @"Number" : @"+354",
                            },
                        @{
                            @"Code 2 char" : @"IL",
                            @"Final list" : @"Israël",
                            @"Number" : @"+972",
                            },
                        @{
                            @"Code 2 char" : @"IT",
                            @"Final list" : @"Italie",
                            @"Number" : @"+39",
                            },
                        @{
                            @"Code 2 char" : @"JM",
                            @"Final list" : @"Jamaïque",
                            @"Number" : @"+1876",
                            },
                        @{
                            @"Code 2 char" : @"JP",
                            @"Final list" : @"Japon",
                            @"Number" : @"+81",
                            },
                        @{
                            @"Code 2 char" : @"JO",
                            @"Final list" : @"Jordanie",
                            @"Number" : @"+962",
                            },
                        @{
                            @"Code 2 char" : @"KZ",
                            @"Final list" : @"Kazakhstan",
                            @"Number" : @"+7",
                            },
                        @{
                            @"Code 2 char" : @"KE",
                            @"Final list" : @"Kenya",
                            @"Number" : @"+254",
                            },
                        @{
                            @"Code 2 char" : @"KG",
                            @"Final list" : @"Kirghizistan",
                            @"Number" : @"+996",
                            },
                        @{
                            @"Code 2 char" : @"XK",
                            @"Final list" : @"Kosovo",
                            @"Number" : @"+383",
                            },
                        @{
                            @"Code 2 char" : @"KW",
                            @"Final list" : @"Koweït",
                            @"Number" : @"+965",
                            },
                        @{
                            @"Code 2 char" : @"LA",
                            @"Final list" : @"Laos",
                            @"Number" : @"+856",
                            },
                        @{
                            @"Code 2 char" : @"LS",
                            @"Final list" : @"Lesotho",
                            @"Number" : @"+266",
                            },
                        @{
                            @"Code 2 char" : @"LV",
                            @"Final list" : @"Lettonie",
                            @"Number" : @"+371",
                            },
                        @{
                            @"Code 2 char" : @"LB",
                            @"Final list" : @"Liban",
                            @"Number" : @"+961",
                            },
                        @{
                            @"Code 2 char" : @"LR",
                            @"Final list" : @"Libéria",
                            @"Number" : @"+231",
                            },
                        @{
                            @"Code 2 char" : @"LY",
                            @"Final list" : @"Libye",
                            @"Number" : @"+218",
                            },
                        @{
                            @"Code 2 char" : @"LI",
                            @"Final list" : @"Liechtenstein",
                            @"Number" : @"+423",
                            },
                        @{
                            @"Code 2 char" : @"LT",
                            @"Final list" : @"Lituanie",
                            @"Number" : @"+370",
                            },
                        @{
                            @"Code 2 char" : @"LU",
                            @"Final list" : @"Luxembourg",
                            @"Number" : @"+352",
                            },
                        @{
                            @"Code 2 char" : @"MK",
                            @"Final list" : @"Macédoine",
                            @"Number" : @"+389",
                            },
                        @{
                            @"Code 2 char" : @"MG",
                            @"Final list" : @"Madagascar",
                            @"Number" : @"+261",
                            },
                        @{
                            @"Code 2 char" : @"MY",
                            @"Final list" : @"Malaisie",
                            @"Number" : @"+60",
                            },
                        @{
                            @"Code 2 char" : @"MW",
                            @"Final list" : @"Malawi",
                            @"Number" : @"+265",
                            },
                        @{
                            @"Code 2 char" : @"MV",
                            @"Final list" : @"Maldives",
                            @"Number" : @"+960",
                            },
                        @{
                            @"Code 2 char" : @"ML",
                            @"Final list" : @"Mali",
                            @"Number" : @"+223",
                            },
                        @{
                            @"Code 2 char" : @"MT",
                            @"Final list" : @"Malte",
                            @"Number" : @"+356",
                            },
                        @{
                            @"Code 2 char" : @"MA",
                            @"Final list" : @"Maroc",
                            @"Number" : @"+212",
                            },
                        @{
                            @"Code 2 char" : @"MQ",
                            @"Final list" : @"Martinique",
                            @"Number" : @"+596",
                            },
                        @{
                            @"Code 2 char" : @"MU",
                            @"Final list" : @"Maurice",
                            @"Number" : @"+230",
                            },
                        @{
                            @"Code 2 char" : @"MR",
                            @"Final list" : @"Mauritanie",
                            @"Number" : @"+222",
                            },
                        @{
                            @"Code 2 char" : @"YT",
                            @"Final list" : @"Mayotte",
                            @"Number" : @"+262",
                            },
                        @{
                            @"Code 2 char" : @"MX",
                            @"Final list" : @"Mexique",
                            @"Number" : @"+52",
                            },
                        @{
                            @"Code 2 char" : @"MD",
                            @"Final list" : @"Moldovie",
                            @"Number" : @"+373",
                            },
                        @{
                            @"Code 2 char" : @"MC",
                            @"Final list" : @"Monaco",
                            @"Number" : @"+377",
                            },
                        @{
                            @"Code 2 char" : @"MN",
                            @"Final list" : @"Mongolie",
                            @"Number" : @"+976",
                            },
                        @{
                            @"Code 2 char" : @"ME",
                            @"Final list" : @"Monténégro",
                            @"Number" : @"+382",
                            },
                        @{
                            @"Code 2 char" : @"MZ",
                            @"Final list" : @"Mozambique",
                            @"Number" : @"+258",
                            },
                        @{
                            @"Code 2 char" : @"MM",
                            @"Final list" : @"Myanmar",
                            @"Number" : @"+95",
                            },
                        @{
                            @"Code 2 char" : @"NA",
                            @"Final list" : @"Namibie",
                            @"Number" : @"+264",
                            },
                        @{
                            @"Code 2 char" : @"NP",
                            @"Final list" : @"Népal",
                            @"Number" : @"+977",
                            },
                        @{
                            @"Code 2 char" : @"NI",
                            @"Final list" : @"Nicaragua",
                            @"Number" : @"+505",
                            },
                        @{
                            @"Code 2 char" : @"NE",
                            @"Final list" : @"Niger",
                            @"Number" : @"+227",
                            },
                        @{
                            @"Code 2 char" : @"NG",
                            @"Final list" : @"Nigéria",
                            @"Number" : @"+234",
                            },
                        @{
                            @"Code 2 char" : @"NO",
                            @"Final list" : @"Norvège",
                            @"Number" : @"+47",
                            },
                        @{
                            @"Code 2 char" : @"NC",
                            @"Final list" : @"Nouvelle-Calédonie",
                            @"Number" : @"+687",
                            },
                        @{
                            @"Code 2 char" : @"NZ",
                            @"Final list" : @"Nouvelle-Zélande",
                            @"Number" : @"+64",
                            },
                        @{
                            @"Code 2 char" : @"OM",
                            @"Final list" : @"Oman",
                            @"Number" : @"+968",
                            },
                        @{
                            @"Code 2 char" : @"UG",
                            @"Final list" : @"Ouganda",
                            @"Number" : @"+256",
                            },
                        @{
                            @"Code 2 char" : @"UZ",
                            @"Final list" : @"Ouzbékistan",
                            @"Number" : @"+998",
                            },
                        @{
                            @"Code 2 char" : @"PK",
                            @"Final list" : @"Pakistan",
                            @"Number" : @"+92",
                            },
                        @{
                            @"Code 2 char" : @"PA",
                            @"Final list" : @"Panama",
                            @"Number" : @"+507",
                            },
                        @{
                            @"Code 2 char" : @"PG",
                            @"Final list" : @"Papouasie-Nouvelle-Guinée",
                            @"Number" : @"+675",
                            },
                        @{
                            @"Code 2 char" : @"PY",
                            @"Final list" : @"Paraguay",
                            @"Number" : @"+595",
                            },
                        @{
                            @"Code 2 char" : @"NL",
                            @"Final list" : @"Pays-Bas",
                            @"Number" : @"+31",
                            },
                        @{
                            @"Code 2 char" : @"PE",
                            @"Final list" : @"Pérou",
                            @"Number" : @"+51",
                            },
                        @{
                            @"Code 2 char" : @"PH",
                            @"Final list" : @"Philippines",
                            @"Number" : @"+63",
                            },
                        @{
                            @"Code 2 char" : @"PL",
                            @"Final list" : @"Pologne",
                            @"Number" : @"+48",
                            },
                        @{
                            @"Code 2 char" : @"PR",
                            @"Final list" : @"Porto Rico",
                            @"Number" : @"+1",
                            },
                        @{
                            @"Code 2 char" : @"PT",
                            @"Final list" : @"Portugal",
                            @"Number" : @"+351",
                            },
                        @{
                            @"Code 2 char" : @"QA",
                            @"Final list" : @"Qatar",
                            @"Number" : @"+974",
                            },
                        @{
                            @"Code 2 char" : @"CF",
                            @"Final list" : @"République Centrafricaine",
                            @"Number" : @"+236",
                            },
                        @{
                            @"Code 2 char" : @"CD",
                            @"Final list" : @"République Démocratique du Congo",
                            @"Number" : @"+243",
                            },
                        @{
                            @"Code 2 char" : @"DO",
                            @"Final list" : @"République Dominicaine",
                            @"Number" : @"+1",
                            },
                        @{
                            @"Code 2 char" : @"CZ",
                            @"Final list" : @"République Tchèque",
                            @"Number" : @"+420",
                            },
                        @{
                            @"Code 2 char" : @"RO",
                            @"Final list" : @"Roumanie",
                            @"Number" : @"+40",
                            },
                        @{
                            @"Code 2 char" : @"GB",
                            @"Final list" : @"Royaume-Uni",
                            @"Number" : @"+44",
                            },
                        @{
                            @"Code 2 char" : @"RU",
                            @"Final list" : @"Russie",
                            @"Number" : @"+7",
                            },
                        @{
                            @"Code 2 char" : @"RW",
                            @"Final list" : @"Rwanda",
                            @"Number" : @"+250",
                            },
                        @{
                            @"Code 2 char" : @"RS",
                            @"Final list" : @"Serbie",
                            @"Number" : @"+381",
                            },
                        @{
                            @"Code 2 char" : @"SC",
                            @"Final list" : @"Seychelles",
                            @"Number" : @"+248",
                            },
                        @{
                            @"Code 2 char" : @"SN",
                            @"Final list" : @"Sénégal",
                            @"Number" : @"+221",
                            },
                        @{
                            @"Code 2 char" : @"SL",
                            @"Final list" : @"Sierra Leone",
                            @"Number" : @"+232",
                            },
                        @{
                            @"Code 2 char" : @"SG",
                            @"Final list" : @"Singapour",
                            @"Number" : @"+65",
                            },
                        @{
                            @"Code 2 char" : @"SK",
                            @"Final list" : @"Slovaquie",
                            @"Number" : @"+421",
                            },
                        @{
                            @"Code 2 char" : @"SI",
                            @"Final list" : @"Slovénie",
                            @"Number" : @"+386",
                            },
                        @{
                            @"Code 2 char" : @"SO",
                            @"Final list" : @"Somalie",
                            @"Number" : @"+252",
                            },
                        @{
                            @"Code 2 char" : @"SD",
                            @"Final list" : @"Soudan",
                            @"Number" : @"+249",
                            },
                        @{
                            @"Code 2 char" : @"SS",
                            @"Final list" : @"Soudan du Sud",
                            @"Number" : @"+211",
                            },
                        @{
                            @"Code 2 char" : @"LK",
                            @"Final list" : @"Sri Lanka",
                            @"Number" : @"+94",
                            },
                        @{
                            @"Code 2 char" : @"SE",
                            @"Final list" : @"Suède",
                            @"Number" : @"+46",
                            },
                        @{
                            @"Code 2 char" : @"CH",
                            @"Final list" : @"Suisse",
                            @"Number" : @"+41",
                            },
                        @{
                            @"Code 2 char" : @"SR",
                            @"Final list" : @"Suriname",
                            @"Number" : @"+597",
                            },
                        @{
                            @"Code 2 char" : @"SZ",
                            @"Final list" : @"Swaziland",
                            @"Number" : @"+268",
                            },
                        @{
                            @"Code 2 char" : @"SY",
                            @"Final list" : @"Syrie",
                            @"Number" : @"+963",
                            },
                        @{
                            @"Code 2 char" : @"TJ",
                            @"Final list" : @"Tadjikistan",
                            @"Number" : @"+992",
                            },
                        @{
                            @"Code 2 char" : @"TW",
                            @"Final list" : @"Taïwan",
                            @"Number" : @"+886",
                            },
                        @{
                            @"Code 2 char" : @"TZ",
                            @"Final list" : @"Tanzanie",
                            @"Number" : @"+255",
                            },
                        @{
                            @"Code 2 char" : @"TD",
                            @"Final list" : @"Tchad",
                            @"Number" : @"+235",
                            },
                        @{
                            @"Code 2 char" : @"TH",
                            @"Final list" : @"Thaïlande",
                            @"Number" : @"+66",
                            },
                        @{
                            @"Code 2 char" : @"TL",
                            @"Final list" : @"Timor-Leste",
                            @"Number" : @"+670",
                            },
                        @{
                            @"Code 2 char" : @"TG",
                            @"Final list" : @"Togo",
                            @"Number" : @"+228",
                            },
                        @{
                            @"Code 2 char" : @"TN",
                            @"Final list" : @"Tunisie",
                            @"Number" : @"+216",
                            },
                        @{
                            @"Code 2 char" : @"TM",
                            @"Final list" : @"Turkménistan",
                            @"Number" : @"+993"
                            },
                        @{
                            @"Code 2 char" : @"TR",
                            @"Final list" : @"Turquie",
                            @"Number" : @"+90"
                            },
                        @{
                            @"Code 2 char" : @"UA",
                            @"Final list" : @"Ukraine",
                            @"Number" : @"+380"
                            },
                        @{
                            @"Code 2 char" : @"UY",
                            @"Final list" : @"Uruguay",
                            @"Number" : @"+598"
                            },
                        @{
                            @"Code 2 char" : @"VE",
                            @"Final list" : @"Venezuela",
                            @"Number" : @"+58"
                            },
                        @{
                            @"Code 2 char" : @"VN",
                            @"Final list" : @"Vietnam",
                            @"Number" : @"+84"
                            },
                        @{
                            @"Code 2 char" : @"YE",
                            @"Final list" : @"Yémen",
                            @"Number" : @"+967"
                            },
                        @{
                            @"Code 2 char" : @"ZM",
                            @"Final list" : @"Zambie",
                            @"Number" : @"+260"
                            }
                        ];
    }
    return self;
}

- (NSInteger)count {
    return [self.source count];
}

- (NSString *)getTitleForRow:(NSInteger)row {
    NSDictionary *country = self.source[row];
    
    return [NSString stringWithFormat:@"%@ %@", [country objectForKey:@"Final list"], [country objectForKey:@"Number"]];
}

- (NSString *)getCountryFullNameForRow:(NSInteger)row {
    NSDictionary *country = self.source[row];
    return [country objectForKey:@"Final list"];
}

- (NSString *)getCountryShortNameForRow:(NSInteger)row {
    NSDictionary *country = self.source[row];
    return [country objectForKey:@"Code 2 char"];
}

- (NSString *)getCountryCodeForRow:(NSInteger)row {
    NSDictionary *country = self.source[row];
    return [country objectForKey:@"Number"];
}

@end

