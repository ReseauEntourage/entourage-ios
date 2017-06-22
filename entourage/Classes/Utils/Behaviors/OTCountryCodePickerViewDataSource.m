//
//  OTCountryCodePickerViewDataSource.m
//  entourage
//
//  Created by veronica.gliga on 19/06/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCountryCodePickerViewDataSource.h"

@implementation OTCountryCodePickerViewDataSource

+(NSDictionary*)getConstDictionary {
    static NSDictionary *source = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        source = @{
                   @"Belgique" :
                       @{
                           @"Code 2 char": @"BE",
                           @"Final list": @"Belgique",
                           @"Number": @"+32"
                       },
                   @"Canada" :
                       @{
                           @"Code 2 char" : @"CA",
                           @"Final list" : @"Canada",
                           @"Number" : @"+1",
                        },
                   @"France" :
                       @{
                           @"Code 2 char" : @"FR",
                           @"Final list" : @"France",
                           @"Number" : @"+33",
                           },
                   @"Guadeloupe" :
                       @{
                           @"Code 2 char" : @"GP",
                           @"Final list" : @"CanaGuadeloupeda",
                           @"Number" : @"+590",
                           },
                   @"Guyane française" :
                       @{
                           @"Code 2 char" : @"GF",
                           @"Final list" : @"Guyane française",
                           @"Number" : @"+594",
                           },
                   @"Martinique" :
                       @{
                           @"Code 2 char" : @"MQ",
                           @"Final list" : @"Martinique",
                           @"Number" : @"+596",
                           },
                   @"Maurice" :
                       @{
                           @"Code 2 char" : @"MU",
                           @"Final list" : @"Maurice",
                           @"Number" : @"+230",
                           },
                   @"Mayotte" :
                       @{
                           @"Code 2 char" : @"YT",
                           @"Final list" : @"Mayotte",
                           @"Number" : @"+262",
                           },
                   @"Polynésie française" :
                       @{
                           @"Code 2 char" : @"PF",
                           @"Final list" : @"Polynésie française",
                           @"Number" : @"+689",
                           },
                   @"Réunion" :
                       @{
                           @"Code 2 char" : @"RE",
                           @"Final list" : @"Réunion",
                           @"Number" : @"+262",
                           },
                   @"Afghanistan" :
                       @{
                           @"Code 2 char" : @"AF",
                           @"Final list" : @"Afghanistan",
                           @"Number" : @"+93",
                           },
                   @"Afrique du Sud" :
                       @{
                           @"Code 2 char" : @"ZA",
                           @"Final list" : @"Afrique du Sud",
                           @"Number" : @"+27",
                           },
                   @"Albanie" :
                       @{
                           @"Code 2 char" : @"AL",
                           @"Final list" : @"Albanie",
                           @"Number" : @"+355",
                           },
                   @"Albanie" :
                       @{
                           @"Code 2 char" : @"AL",
                           @"Final list" : @"Albanie",
                           @"Number" : @"+355",
                           },
                   @"Algérie" :
                       @{
                           @"Code 2 char" : @"DZ",
                           @"Final list" : @"Algérie",
                           @"Number" : @"+213"
                           },
                   @"Allemagne" :
                       @{
                           @"Code 2 char" : @"DE",
                           @"Final list" : @"Allemagne",
                           @"Number" : @"+49",
                           },
                   @"Andorre" :
                       @{
                           @"Code 2 char" : @"AD",
                           @"Final list" : @"Andorre",
                           @"Number" : @"+376",
                           },
                   @"Angola" :
                       @{
                           @"Code 2 char" : @"AO",
                           @"Final list" : @"Angola",
                           @"Number" : @"+244",
                           },
                   @"Arabie Saoudite" :
                       @{
                           @"Code 2 char" : @"SA",
                           @"Final list" : @"Arabie Saoudite",
                           @"Number" : @"+966",
                           },
                   @"Argentine" :
                       @{
                           @"Code 2 char" : @"AR",
                           @"Final list" : @"Argentine",
                           @"Number" : @"+54",
                           },
                   @"Arménie" :
                       @{
                           @"Code 2 char" : @"AM",
                           @"Final list" : @"Arménie",
                           @"Number" : @"+374",
                           },
                   @"Australie" :
                       @{
                           @"Code 2 char" : @"AU",
                           @"Final list" : @"Australie",
                           @"Number" : @"+61",
                           },
                   @"Autriche" :
                       @{
                           @"Code 2 char" : @"AT",
                           @"Final list" : @"Autriche",
                           @"Number" : @"+43",
                           },
                   @"Azerbaïdjan" :
                    @{
                       @"Code 2 char" : @"AZ",
                       @"Final list" : @"Azerbaïdjan",
                       @"Number" : @"+994"
                       },
                   @"Bahrein" :
                   @{
                           @"Code 2 char" : @"BH",
                           @"Final list" : @"Bahrein",
                           @"Number" : @"+973"
                       },
                   @"Bangladesh" :
                    @{
                           @"Code 2 char" : @"BD",
                           @"Final list" : @"Bangladesh",
                           @"Number" : @"+880"
                           },
                   @"Bélarus" :
                    @{
                           @"Code 2 char" : @"BY",
                           @"Final list" : @"Bélarus",
                           @"Number" : @"+375"
                       },
                   @"Bélize" :
                   @{
                           @"Code 2 char" : @"BZ",
                           @"Final list" : @"Bélize",
                           @"Number" : @"+501"
                       },
                   @"Bénin" :
                   @{
                           @"Code 2 char" : @"BJ",
                           @"Final list" : @"Bénin",
                           @"Number" : @"+229"
                       },
                   @"Bhoutan" :
                    @{
                       @"Code 2 char" : @"BT",
                       @"Final list" : @"Bhoutan",
                       @"Number" : @"+975"
                   },
                   @"Bolivie" :
                       @{
                       @"Code 2 char" : @"BO",
                       @"Final list" : @"Bolivie",
                       @"Number" : @"+591"
                   },
                   @"Bosnie-Herzégovine" :
                       @{
                       @"Code 2 char" : @"BA",
                       @"Final list" : @"Bosnie-Herzégovine",
                       @"Number" : @"+387"
                   },
                   @"Botswana" :
                       @{
                       @"Code 2 char" : @"BW",
                       @"Final list" : @"Botswana",
                       @"Number" : @"+267"
                   },
                   @"Brésil" :
                       @{
                       @"Code 2 char" : @"BR",
                       @"Final list" : @"Brésil",
                       @"Number" : @"+55"
                   },
                   @"Brunéi" :
                       @{
                       @"Code 2 char" : @"BN",
                       @"Final list" : @"Brunéi",
                       @"Number" : @"+673"
                   },
                   @"Bulgarie" :
                       @{
                       @"Code 2 char" : @"BG",
                       @"Final list" : @"Bulgarie",
                       @"Number" : @"+359"
                   },
                   @"Burkina Faso" :
                       @{
                       @"Code 2 char" : @"BF",
                       @"Final list" : @"Burkina Faso",
                       @"Number" : @"+226"
                   },
                   @"Burundi" :
                       @{
                       @"Code 2 char" : @"BI",
                       @"Final list" : @"Burundi",
                       @"Number" : @"+257"
                   },
                   @"Cambodge" :
                       @{
                       @"Code 2 char" : @"KH",
                       @"Final list" : @"Cambodge",
                       @"Number" : @"+855"
                   },
                   @"Cameroun" :
                       @{
                       @"Code 2 char" : @"CM",
                       @"Final list" : @"Cameroun",
                       @"Number" : @"+237"
                   },
                   @"Canada" :
                       @{
                       @"Code 2 char" : @"CA",
                       @"Final list" : @"Canada",
                       @"Number" : @"+1"
                   },
                   @"Cap Vert" :
                       @{
                       @"Code 2 char" : @"CV",
                       @"Final list" : @"Cap Vert",
                       @"Number" : @"+238"
                   },
                   @"Chili" :
                       @{
                       @"Code 2 char" : @"CL",
                       @"Final list" : @"Chili",
                       @"Number" : @"+56"
                   },
                   @"Chine" :
                       @{
                       @"Code 2 char" : @"CN",
                       @"Final list" : @"Chine",
                       @"Number" : @"+86"
                   },
                   @"Chypre" :
                       @{
                       @"Code 2 char" : @"CY",
                       @"Final list" : @"Chypre",
                       @"Number" : @"+357"
                   },
                   @"Colombie" :
                       @{
                       @"Code 2 char" : @"CO",
                       @"Final list" : @"Colombie",
                       @"Number" : @"+57"
                   },
                   @"Congo" :
                       @{
                       @"Code 2 char" : @"CG",
                       @"Final list" : @"Congo",
                       @"Number" : @"+242"
                   },
                   @"Corée du Sud" :
                       @{
                       @"Code 2 char" : @"KR",
                       @"Final list" : @"Corée du Sud",
                       @"Number" : @"+82"
                   },
                   @"Costa Rica" :
                       @{
                       @"Code 2 char" : @"CR",
                       @"Final list" : @"Costa Rica",
                       @"Number" : @"+506"
                   },
                   @"Côte d'Ivoire" :
                       @{
                       @"Code 2 char" : @"CI",
                       @"Final list" : @"Côte d'Ivoire",
                       @"Number" : @"+225"
                   },
                   @"Croatie" :
                       @{
                       @"Code 2 char" : @"HR",
                       @"Final list" : @"Croatie",
                       @"Number" : @"+385"
                   },
                   @"Cuba" :
                       @{
                       @"Code 2 char" : @"CU",
                       @"Final list" : @"Cuba",
                       @"Number" : @"+53"
                   },
                   @"Danemark" :
                       @{
                       @"Code 2 char" : @"DK",
                       @"Final list" : @"Danemark",
                       @"Number" : @"+45",
                   },
                   @"Djibouti" :
                       @{
                       @"Code 2 char" : @"DJ",
                       @"Final list" : @"Djibouti",
                       @"Number" : @"+253"
                   },
                   @"Dominique" :
                       @{
                       @"Code 2 char" : @"DM",
                       @"Final list" : @"Dominique",
                       @"Number" : @"+1767"
                   },
                   @"Egypte" :
                       @{
                       @"Code 2 char" : @"EG",
                       @"Final list" : @"Egypte",
                       @"Number" : @"+20"
                   },
                   @"El Salvador" :
                       @{
                       @"Code 2 char" : @"SV",
                       @"Final list" : @"El Salvador",
                       @"Number" : @"+503"
                   },
                   @"Emirats arabes unis" :
                       @{
                       @"Code 2 char" : @"AE",
                       @"Final list" : @"Emirats arabes unis",
                       @"Number" : @"+971"
                   },
                   @"Equateur" :
                       @{
                       @"Code 2 char" : @"EC",
                       @"Final list" : @"Equateur",
                       @"Number" : @"+593"
                   },
                   @"Erythrée" :
                       @{
                       @"Code 2 char" : @"ER",
                       @"Final list" : @"Erythrée",
                       @"Number" : @"+291"
                   },
                   @"Espagne" :
                       @{
                       @"Code 2 char" : @"ES",
                       @"Final list" : @"Espagne",
                       @"Number" : @"+34"
                   },
                   @"Estonie" :
                       @{
                       @"Code 2 char" : @"EE",
                       @"Final list" : @"Estonie",
                       @"Number" : @"+372"
                   },
                   @"Etats-Unis" :
                       @{
                       @"Code 2 char" : @"US",
                       @"Final list" : @"Etats-Unis",
                       @"Number" : @"+1"
                   },
                   @"Ethiopie" :
                       @{
                       @"Code 2 char" : @"ET",
                       @"Final list" : @"Ethiopie",
                       @"Number" : @"+251"
                   },
                   @"Fidji" :     @{
                       @"Code 2 char" : @"FJ",
                       @"Final list" : @"Fidji",
                       @"Number" : @"+679",
                   },
                   @"Finlande" :     @{
                       @"Code 2 char" : @"FI",
                       @"Final list" : @"Finlande",
                       @"Number" : @"+358",
                   },
                   @"Gabon" :     @{
                       @"Code 2 char" : @"GA",
                       @"Final list" : @"Gabon",
                       @"Number" : @"+241",
                   },
                   @"Gambie" :     @{
                       @"Code 2 char" : @"GM",
                       @"Final list" : @"Gambie",
                       @"Number" : @"+220",
                   },
                   @"Géorgie" :     @{
                       @"Code 2 char" : @"GE",
                       @"Final list" : @"Géorgie",
                       @"Number" : @"+995",
                   },
                   @"Ghana" :     @{
                       @"Code 2 char" : @"GH",
                       @"Final list" : @"Ghana",
                       @"Number" : @"+233",
                   },
                   @"Gibraltar" :     @{
                       @"Code 2 char" : @"GI",
                       @"Final list" : @"Gibraltar",
                       @"Number" : @"+350",
                   },
                   @"Grèce" :     @{
                       @"Code 2 char" : @"GR",
                       @"Final list" : @"Grèce",
                       @"Number" : @"+30",
                   },
                   @"Guadeloupe" :     @{
                       @"Code 2 char" : @"GP",
                       @"Final list" : @"Guadeloupe",
                       @"Number" : @"+590",
                   },
                   @"Guatemala" :     @{
                       @"Code 2 char" : @"GT",
                       @"Final list" : @"Guatemala",
                       @"Number" : @"+502",
                   },
                   @"Guinée" :     @{
                       @"Code 2 char" : @"GN",
                       @"Final list" : @"Guinée",
                       @"Number" : @"+224",
                   },
                   @"Guinée équatoriale" :     @{
                       @"Code 2 char" : @"GQ",
                       @"Final list" : @"Guinée équatoriale",
                       @"Number" : @"+240",
                   },
                   @"Guinée-Bissau" :     @{
                       @"Code 2 char" : @"GW",
                       @"Final list" : @"Guinée-Bissau",
                       @"Number" : @"+245",
                   },
                   @"Guyana" :     @{
                       @"Code 2 char" : @"GY",
                       @"Final list" : @"Guyana",
                       @"Number" : @"+592",
                   },
                   @"Haïti" :     @{
                       @"Code 2 char" : @"HT",
                       @"Final list" : @"Haïti",
                       @"Number" : @"+509",
                   },
                   @"Honduras" :     @{
                       @"Code 2 char" : @"HN",
                       @"Final list" : @"Honduras",
                       @"Number" : @"+504",
                   },
                   @"Hong Kong" :     @{
                       @"Code 2 char" : @"HK",
                       @"Final list" : @"Hong Kong",
                       @"Number" : @"+852",
                   },
                   @"Hongrie" :     @{
                       @"Code 2 char" : @"HU",
                       @"Final list" : @"Hongrie",
                       @"Number" : @"+36",
                   },
                   @"Inde" :
                   @{
                       @"Code 2 char" : @"IN",
                       @"Final list" : @"Inde",
                       @"Number" : @"+91"
                   },
                   @"Indonésie" :
                       @{
                       @"Code 2 char" : @"ID",
                       @"Final list" : @"Indonésie",
                       @"Number" : @"+62",
                   },
                   @"Irak" :     @{
                       @"Code 2 char" : @"IQ",
                       @"Final list" : @"Irak",
                       @"Number" : @"+964",
                   },
                   @"Iran" :     @{
                       @"Code 2 char" : @"IR",
                       @"Final list" : @"Iran",
                       @"Number" : @"+98",
                   },
                   @"Irlande" :     @{
                       @"Code 2 char" : @"IE",
                       @"Final list" : @"Irlande",
                       @"Number" : @"+353",
                   },
                   @"Islande" :     @{
                       @"Code 2 char" : @"IS",
                       @"Final list" : @"Islande",
                       @"Number" : @"+354",
                   },
                   @"Israël" :     @{
                       @"Code 2 char" : @"IL",
                       @"Final list" : @"Israël",
                       @"Number" : @"+972",
                   },
                   @"Italie" :     @{
                       @"Code 2 char" : @"IT",
                       @"Final list" : @"Italie",
                       @"Number" : @"+39",
                   },
                   @"Jamaïque" :     @{
                       @"Code 2 char" : @"JM",
                       @"Final list" : @"Jamaïque",
                       @"Number" : @"+1876",
                   },
                   @"Japon" :     @{
                       @"Code 2 char" : @"JP",
                       @"Final list" : @"Japon",
                       @"Number" : @"+81",
                   },
                   @"Jordanie" :     @{
                       @"Code 2 char" : @"JO",
                       @"Final list" : @"Jordanie",
                       @"Number" : @"+962",
                   },
                   @"Kazakhstan" :     @{
                       @"Code 2 char" : @"KZ",
                       @"Final list" : @"Kazakhstan",
                       @"Number" : @"+7",
                   },
                   @"Kenya" :     @{
                       @"Code 2 char" : @"KE",
                       @"Final list" : @"Kenya",
                       @"Number" : @"+254",
                   },
                   @"Kirghizistan" :     @{
                       @"Code 2 char" : @"KG",
                       @"Final list" : @"Kirghizistan",
                       @"Number" : @"+996",
                   },
                   @"Kosovo" :     @{
                       @"Code 2 char" : @"XK",
                       @"Final list" : @"Kosovo",
                       @"Number" : @"+383",
                   },
                   @"Koweït" :     @{
                       @"Code 2 char" : @"KW",
                       @"Final list" : @"Koweït",
                       @"Number" : @"+965",
                   },
                   @"Laos" :     @{
                       @"Code 2 char" : @"LA",
                       @"Final list" : @"Laos",
                       @"Number" : @"+856",
                   },
                   @"Lesotho" :     @{
                       @"Code 2 char" : @"LS",
                       @"Final list" : @"Lesotho",
                       @"Number" : @"+266",
                   },
                   @"Lettonie" :     @{
                       @"Code 2 char" : @"LV",
                       @"Final list" : @"Lettonie",
                       @"Number" : @"+371",
                   },
                   @"Liban" :     @{
                       @"Code 2 char" : @"LB",
                       @"Final list" : @"Liban",
                       @"Number" : @"+961",
                   },
                   @"Libéria" :     @{
                       @"Code 2 char" : @"LR",
                       @"Final list" : @"Libéria",
                       @"Number" : @"+231",
                   },
                   @"Libye" :     @{
                       @"Code 2 char" : @"LY",
                       @"Final list" : @"Libye",
                       @"Number" : @"+218",
                   },
                   @"Liechtenstein" :     @{
                       @"Code 2 char" : @"LI",
                       @"Final list" : @"Liechtenstein",
                       @"Number" : @"+423",
                   },
                   @"Lituanie" :     @{
                       @"Code 2 char" : @"LT",
                       @"Final list" : @"Lituanie",
                       @"Number" : @"+370",
                   },
                   @"Luxembourg" :     @{
                       @"Code 2 char" : @"LU",
                       @"Final list" : @"Luxembourg",
                       @"Number" : @"+352",
                   },
                   @"Macédoine" :     @{
                       @"Code 2 char" : @"MK",
                       @"Final list" : @"Macédoine",
                       @"Number" : @"+389",
                   },
                   @"Madagascar" :     @{
                       @"Code 2 char" : @"MG",
                       @"Final list" : @"Madagascar",
                       @"Number" : @"+261",
                   },
                   @"Malaisie" :     @{
                       @"Code 2 char" : @"MY",
                       @"Final list" : @"Malaisie",
                       @"Number" : @"+60",
                   },
                   @"Malawi" :     @{
                       @"Code 2 char" : @"MW",
                       @"Final list" : @"Malawi",
                       @"Number" : @"+265",
                   },
                   @"Maldives" :     @{
                       @"Code 2 char" : @"MV",
                       @"Final list" : @"Maldives",
                       @"Number" : @"+960",
                   },
                   @"Mali" :     @{
                       @"Code 2 char" : @"ML",
                       @"Final list" : @"Mali",
                       @"Number" : @"+223",
                   },
                   @"Malte" :     @{
                       @"Code 2 char" : @"MT",
                       @"Final list" : @"Malte",
                       @"Number" : @"+356",
                   },
                   @"Maroc" :     @{
                       @"Code 2 char" : @"MA",
                       @"Final list" : @"Maroc",
                       @"Number" : @"+212",
                   },
                   @"Martinique" :     @{
                       @"Code 2 char" : @"MQ",
                       @"Final list" : @"Martinique",
                       @"Number" : @"+596",
                   },
                   @"Maurice" :     @{
                       @"Code 2 char" : @"MU",
                       @"Final list" : @"Maurice",
                       @"Number" : @"+230",
                   },
                   @"Mauritanie" :     @{
                       @"Code 2 char" : @"MR",
                       @"Final list" : @"Mauritanie",
                       @"Number" : @"+222",
                   },
                   @"Mayotte" :     @{
                       @"Code 2 char" : @"YT",
                       @"Final list" : @"Mayotte",
                       @"Number" : @"+262",
                   },
                   @"Mexique" :     @{
                       @"Code 2 char" : @"MX",
                       @"Final list" : @"Mexique",
                       @"Number" : @"+52",
                   },
                   @"Moldovie" :     @{
                       @"Code 2 char" : @"MD",
                       @"Final list" : @"Moldovie",
                       @"Number" : @"+373",
                   },
                   @"Monaco" :     @{
                       @"Code 2 char" : @"MC",
                       @"Final list" : @"Monaco",
                       @"Number" : @"+377",
                   },
                   @"Mongolie" :     @{
                       @"Code 2 char" : @"MN",
                       @"Final list" : @"Mongolie",
                       @"Number" : @"+976",
                   },
                   @"Monténégro" :     @{
                       @"Code 2 char" : @"ME",
                       @"Final list" : @"Monténégro",
                       @"Number" : @"+382",
                   },
                   @"Mozambique" :     @{
                       @"Code 2 char" : @"MZ",
                       @"Final list" : @"Mozambique",
                       @"Number" : @"+258",
                   },
                   @"Myanmar" :     @{
                       @"Code 2 char" : @"MM",
                       @"Final list" : @"Myanmar",
                       @"Number" : @"+95",
                   },
                   @"Namibie" :     @{
                       @"Code 2 char" : @"NA",
                       @"Final list" : @"Namibie",
                       @"Number" : @"+264",
                   },
                   @"Népal" :     @{
                       @"Code 2 char" : @"NP",
                       @"Final list" : @"Népal",
                       @"Number" : @"+977",
                   },
                   @"Nicaragua" :     @{
                       @"Code 2 char" : @"NI",
                       @"Final list" : @"Nicaragua",
                       @"Number" : @"+505",
                   },
                   @"Niger" :     @{
                       @"Code 2 char" : @"NE",
                       @"Final list" : @"Niger",
                       @"Number" : @"+227",
                   },
                   @"Nigéria" :     @{
                       @"Code 2 char" : @"NG",
                       @"Final list" : @"Nigéria",
                       @"Number" : @"+234",
                   },
                   @"Norvège" :     @{
                       @"Code 2 char" : @"NO",
                       @"Final list" : @"Norvège",
                       @"Number" : @"+47",
                   },
                   @"Nouvelle-Calédonie" :     @{
                       @"Code 2 char" : @"NC",
                       @"Final list" : @"Nouvelle-Calédonie",
                       @"Number" : @"+687",
                   },
                   @"Nouvelle-Zélande" :     @{
                       @"Code 2 char" : @"NZ",
                       @"Final list" : @"Nouvelle-Zélande",
                       @"Number" : @"+64",
                   },
                   @"Oman" :     @{
                       @"Code 2 char" : @"OM",
                       @"Final list" : @"Oman",
                       @"Number" : @"+968",
                   },
                   @"Ouganda" :     @{
                       @"Code 2 char" : @"UG",
                       @"Final list" : @"Ouganda",
                       @"Number" : @"+256",
                   },
                   @"Ouzbékistan" :     @{
                       @"Code 2 char" : @"Ouzbékistan",
                       @"Number" : @"+998",
                   },
                   @"Pakistan" :     @{
                       @"Code 2 char" : @"PK",
                       @"Final list" : @"Pakistan",
                       @"Number" : @"+92",
                   },
                   @"Panama" :     @{
                       @"Code 2 char" : @"PA",
                       @"Final list" : @"Panama",
                       @"Number" : @"+507",
                   },
                   @"Papouasie-Nouvelle-Guinée" :     @{
                       @"Code 2 char" : @"PG",
                       @"Final list" : @"Papouasie-Nouvelle-Guinée",
                       @"Number" : @"+675",
                   },
                   @"Paraguay" :     @{
                       @"Code 2 char" : @"PY",
                       @"Final list" : @"Paraguay",
                       @"Number" : @"+595",
                   },
                   @"Pays-Bas" :     @{
                       @"Code 2 char" : @"NL",
                       @"Final list" : @"Pays-Bas",
                       @"Number" : @"+31",
                   },
                   @"Pérou" :     @{
                       @"Code 2 char" : @"PE",
                       @"Final list" : @"Pérou",
                       @"Number" : @"+51",
                   },
                   @"Philippines" :     @{
                       @"Code 2 char" : @"PH",
                       @"Final list" : @"Philippines",
                       @"Number" : @"+63",
                   },
                   @"Pologne" :     @{
                       @"Code 2 char" : @"PL",
                       @"Final list" : @"Pologne",
                       @"Number" : @"+48",
                   },
                   @"Porto Rico" :     @{
                       @"Code 2 char" : @"PR",
                       @"Final list" : @"Porto Rico",
                       @"Number" : @"+1",
                   },
                   @"Portugal" :     @{
                       @"Code 2 char" : @"PT",
                       @"Final list" : @"Portugal",
                       @"Number" : @"+351",
                   },
                   @"Qatar" :     @{
                       @"Code 2 char" : @"QA",
                       @"Final list" : @"Qatar",
                       @"Number" : @"+974",
                   },
                   @"République Centrafricaine" :     @{
                       @"Code 2 char" : @"CF",
                       @"Final list" : @"République Centrafricaine",
                       @"Number" : @"+236",
                   },
                   @"République Démocratique du Congo" :     @{
                       @"Code 2 char" : @"CD",
                       @"Final list" : @"République Démocratique du Congo",
                       @"Number" : @"+243",
                   },
                   @"République Dominicaine" :     @{
                       @"Code 2 char" : @"DO",
                       @"Final list" : @"République Dominicaine",
                       @"Number" : @"+1",
                   },
                   @"République Tchèque" :     @{
                       @"Code 2 char" : @"CZ",
                       @"Final list" : @"République Tchèque",
                       @"Number" : @"+420",
                   },
                   @"Roumanie" :     @{
                       @"Code 2 char" : @"RO",
                       @"Final list" : @"Roumanie",
                       @"Number" : @"+40",
                   },
                   @"Royaume-Uni" :     @{
                       @"Code 2 char" : @"GB",
                       @"Final list" : @"Royaume-Uni",
                       @"Number" : @"+44",
                   },
                   @"Russie" :     @{
                       @"Code 2 char" : @"RU",
                       @"Final list" : @"Russie",
                       @"Number" : @"+7",
                   },
                   @"Rwanda" :     @{
                       @"Code 2 char" : @"RW",
                       @"Final list" : @"Rwanda",
                       @"Number" : @"+250",
                   },
                   @"Serbie" :     @{
                       @"Code 2 char" : @"RS",
                       @"Final list" : @"Serbie",
                       @"Number" : @"+381",
                   },
                   @"Seychelles" :     @{
                       @"Code 2 char" : @"SC",
                       @"Final list" : @"Seychelles",
                       @"Number" : @"+248",
                   },
                   @"Sénégal" :     @{
                       @"Code 2 char" : @"SN",
                       @"Final list" : @"Sénégal",
                       @"Number" : @"+221",
                   },
                   @"Sierra Leone" :     @{
                       @"Code 2 char" : @"SL",
                       @"Final list" : @"Sierra Leone",
                       @"Number" : @"+232",
                   },
                   @"Singapour" :     @{
                       @"Code 2 char" : @"SG",
                       @"Final list" : @"Singapour",
                       @"Number" : @"+65",
                   },
                   @"Slovaquie" :     @{
                       @"Code 2 char" : @"SK",
                       @"Final list" : @"Slovaquie",
                       @"Number" : @"+421",
                   },
                   @"Slovénie" :     @{
                       @"Code 2 char" : @"SI",
                       @"Final list" : @"Slovénie",
                       @"Number" : @"+386",
                   },
                   @"Somalie" :     @{
                       @"Code 2 char" : @"SO",
                       @"Final list" : @"Somalie",
                       @"Number" : @"+252",
                   },
                   @"Soudan" :     @{
                       @"Code 2 char" : @"SD",
                       @"Final list" : @"Soudan",
                       @"Number" : @"+249",
                   },
                   @"Soudan du Sud" :     @{
                       @"Code 2 char" : @"SS",
                       @"Final list" : @"Soudan du Sud",
                       @"Number" : @"+211",
                   },
                   @"Sri Lanka" :     @{
                       @"Code 2 char" : @"LK",
                       @"Final list" : @"Sri Lanka",
                       @"Number" : @"+94",
                   },
                   @"Suède" :     @{
                       @"Code 2 char" : @"SE",
                       @"Final list" : @"Suède",
                       @"Number" : @"+46",
                   },
                   @"Suisse" :     @{
                       @"Code 2 char" : @"CH",
                       @"Final list" : @"Suisse",
                       @"Number" : @"+41",
                   },
                   @"Suriname" :     @{
                       @"Code 2 char" : @"SR",
                       @"Final list" : @"Suriname",
                       @"Number" : @"+597",
                   },
                   @"Swaziland" :     @{
                       @"Code 2 char" : @"SZ",
                       @"Final list" : @"Swaziland",
                       @"Number" : @"+268",
                   },
                   @"Syrie" :     @{
                       @"Code 2 char" : @"SY",
                       @"Final list" : @"Syrie",
                       @"Number" : @"+963",
                   },
                   @"Tadjikistan" :     @{
                       @"Code 2 char" : @"TJ",
                       @"Final list" : @"Tadjikistan",
                       @"Number" : @"+992",
                   },
                   @"Taïwan" :     @{
                       @"Code 2 char" : @"TW",
                       @"Final list" : @"Taïwan",
                       @"Number" : @"+886",
                   },
                   @"Tanzanie" :     @{
                       @"Code 2 char" : @"TZ",
                       @"Final list" : @"Tanzanie",
                       @"Number" : @"+255",
                   },
                   @"Tchad" :     @{
                       @"Code 2 char" : @"TD",
                       @"Final list" : @"Tchad",
                       @"Number" : @"+235",
                   },
                   @"Thaïlande" :     @{
                       @"Code 2 char" : @"TH",
                       @"Final list" : @"Thaïlande",
                       @"Number" : @"+66",
                   },
                   @"Timor-Leste" :     @{
                       @"Code 2 char" : @"TL",
                       @"Final list" : @"Timor-Leste",
                       @"Number" : @"+670",
                   },
                   @"Togo" :     @{
                       @"Code 2 char" : @"TG",
                       @"Final list" : @"Togo",
                       @"Number" : @"+228",
                   },
                   @"Tunisie" :     @{
                       @"Code 2 char" : @"TN",
                       @"Final list" : @"Tunisie",
                       @"Number" : @"+216",
                   },
                   @"Turkménistan" :     @{
                       @"Code 2 char" : @"TM",
                       @"Final list" : @"Turkménistan",
                       @"Number" : @"+993"
                   },
                   @"Turquie" :     @{
                       @"Code 2 char" : @"TR",
                       @"Final list" : @"Turquie",
                       @"Number" : @"+90"
                   },
                   @"Ukraine" :     @{
                       @"Code 2 char" : @"UA",
                       @"Final list" : @"Ukraine",
                       @"Number" : @"+380"
                   },
                   @"Uruguay" :     @{
                       @"Code 2 char" : @"UY",
                       @"Final list" : @"Uruguay",
                       @"Number" : @"+598"
                   },
                   @"Venezuela" :     @{
                       @"Code 2 char" : @"VE",
                       @"Final list" : @"Venezuela",
                       @"Number" : @"+58"
                   },
                   @"Vietnam" :     @{
                       @"Code 2 char" : @"VN",
                       @"Final list" : @"Vietnam",
                       @"Number" : @"+84"
                   },
                   @"Yémen" :     @{
                       @"Code 2 char" : @"YE",
                       @"Final list" : @"Yémen",
                       @"Number" : @"+967"
                   },
                   @"Zambie" :     @{
                       @"Code 2 char" : @"ZM",
                       @"Final list" : @"Zambie",
                       @"Number" : @"+260"
                   }
        };
    });
    return source;
}

@end

