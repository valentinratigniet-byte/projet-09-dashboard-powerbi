-- =====================================================================
-- Référentiel ISO 3166-1 alpha-2 -> nom de pays (français).
-- Sert à enrichir dim_customer d'une colonne country_name lisible.
-- Pour la carte Power BI : catégoriser country_name en "Pays/Région"
-- (le nom complet + dataCategory lève l'ambiguïté, ex. Géorgie le pays).
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.country_names (code char(2) PRIMARY KEY, name_fr text NOT NULL);
TRUNCATE public.country_names;
INSERT INTO public.country_names (code, name_fr) VALUES
('AD','Andorre'),('AE','Émirats arabes unis'),('AF','Afghanistan'),('AG','Antigua-et-Barbuda'),('AL','Albanie'),('AM','Arménie'),('AO','Angola'),('AR','Argentine'),('AT','Autriche'),('AU','Australie'),('AZ','Azerbaïdjan'),
('BA','Bosnie-Herzégovine'),('BB','Barbade'),('BD','Bangladesh'),('BE','Belgique'),('BF','Burkina Faso'),('BG','Bulgarie'),('BH','Bahreïn'),('BI','Burundi'),('BJ','Bénin'),('BN','Brunei'),('BO','Bolivie'),('BR','Brésil'),('BS','Bahamas'),('BT','Bhoutan'),('BW','Botswana'),('BY','Biélorussie'),('BZ','Belize'),
('CA','Canada'),('CD','République démocratique du Congo'),('CF','République centrafricaine'),('CG','Congo'),('CH','Suisse'),('CI','Côte d''Ivoire'),('CL','Chili'),('CM','Cameroun'),('CN','Chine'),('CO','Colombie'),('CR','Costa Rica'),('CU','Cuba'),('CV','Cap-Vert'),('CY','Chypre'),('CZ','Tchéquie'),
('DE','Allemagne'),('DJ','Djibouti'),('DK','Danemark'),('DM','Dominique'),('DO','République dominicaine'),('DZ','Algérie'),
('EC','Équateur'),('EE','Estonie'),('EG','Égypte'),('ER','Érythrée'),('ES','Espagne'),('ET','Éthiopie'),
('FI','Finlande'),('FJ','Fidji'),('FM','Micronésie'),('FR','France'),
('GA','Gabon'),('GB','Royaume-Uni'),('GD','Grenade'),('GE','Géorgie'),('GH','Ghana'),('GM','Gambie'),('GN','Guinée'),('GQ','Guinée équatoriale'),('GR','Grèce'),('GT','Guatemala'),('GW','Guinée-Bissau'),('GY','Guyana'),
('HN','Honduras'),('HR','Croatie'),('HT','Haïti'),('HU','Hongrie'),
('ID','Indonésie'),('IE','Irlande'),('IL','Israël'),('IN','Inde'),('IQ','Irak'),('IR','Iran'),('IS','Islande'),('IT','Italie'),
('JM','Jamaïque'),('JO','Jordanie'),('JP','Japon'),
('KE','Kenya'),('KG','Kirghizistan'),('KH','Cambodge'),('KI','Kiribati'),('KM','Comores'),('KN','Saint-Christophe-et-Niévès'),('KP','Corée du Nord'),('KR','Corée du Sud'),('KW','Koweït'),('KZ','Kazakhstan'),
('LA','Laos'),('LB','Liban'),('LC','Sainte-Lucie'),('LI','Liechtenstein'),('LK','Sri Lanka'),('LR','Liberia'),('LS','Lesotho'),('LT','Lituanie'),('LU','Luxembourg'),('LV','Lettonie'),('LY','Libye'),
('MA','Maroc'),('MC','Monaco'),('MD','Moldavie'),('ME','Monténégro'),('MG','Madagascar'),('MH','Îles Marshall'),('MK','Macédoine du Nord'),('ML','Mali'),('MM','Birmanie'),('MN','Mongolie'),('MR','Mauritanie'),('MT','Malte'),('MU','Maurice'),('MV','Maldives'),('MW','Malawi'),('MX','Mexique'),('MY','Malaisie'),('MZ','Mozambique'),
('NA','Namibie'),('NE','Niger'),('NG','Nigéria'),('NI','Nicaragua'),('NL','Pays-Bas'),('NO','Norvège'),('NP','Népal'),('NR','Nauru'),('NZ','Nouvelle-Zélande'),
('OM','Oman'),
('PA','Panama'),('PE','Pérou'),('PG','Papouasie-Nouvelle-Guinée'),('PH','Philippines'),('PK','Pakistan'),('PL','Pologne'),('PS','Palestine'),('PT','Portugal'),('PW','Palaos'),('PY','Paraguay'),
('QA','Qatar'),
('RO','Roumanie'),('RS','Serbie'),('RU','Russie'),('RW','Rwanda'),
('SA','Arabie saoudite'),('SB','Îles Salomon'),('SC','Seychelles'),('SD','Soudan'),('SE','Suède'),('SG','Singapour'),('SI','Slovénie'),('SK','Slovaquie'),('SL','Sierra Leone'),('SM','Saint-Marin'),('SN','Sénégal'),('SO','Somalie'),('SR','Suriname'),('ST','Sao Tomé-et-Principe'),('SV','Salvador'),('SY','Syrie'),('SZ','Eswatini'),
('TD','Tchad'),('TG','Togo'),('TH','Thaïlande'),('TJ','Tadjikistan'),('TL','Timor oriental'),('TM','Turkménistan'),('TN','Tunisie'),('TO','Tonga'),('TR','Turquie'),('TT','Trinité-et-Tobago'),('TV','Tuvalu'),('TW','Taïwan'),('TZ','Tanzanie'),
('UA','Ukraine'),('UG','Ouganda'),('US','États-Unis'),('UY','Uruguay'),('UZ','Ouzbékistan'),
('VA','Vatican'),('VC','Saint-Vincent-et-les-Grenadines'),('VE','Venezuela'),('VN','Viêt Nam'),('VU','Vanuatu'),
('WS','Samoa'),('YE','Yémen'),
('ZA','Afrique du Sud'),('ZM','Zambie'),('ZW','Zimbabwe');
