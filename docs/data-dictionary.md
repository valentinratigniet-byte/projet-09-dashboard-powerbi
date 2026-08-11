# Dictionnaire de données — dashboard-ventes

> **Instantané publié** (au sens *Living Documentation*, ch. 3 « Single-Source Publishing »).
> La **source de vérité** reste le modèle du fichier `dashboard-ventes.pbix` : ces
> descriptions y vivent en info-bulle (volet Données / vue Modèle). Ce document en est
> une copie lisible sur GitHub — **régénérée depuis le modèle**, à ne pas éditer à la main.
>
> Généré le 2026-08-11 · 4 tables · 25 colonnes documentées · 17 mesures.

## Vue d'ensemble

Modèle en **étoile** : une table de faits (`fct_sales`) entourée de 3 dimensions.
Toutes les données proviennent de la base OLTP du **Projet 07** (e-commerce PostgreSQL).

| Table | Type | Grain | Lignes |
|---|---|---|---|
| `fct_sales` | Faits | une ligne de commande | 120 089 |
| `dim_customer` | Dimension | un client | 5 000 |
| `dim_product` | Dimension | un produit | 2 000 |
| `dim_date` | Dimension (calendrier) | un jour | 731 |

### Relations (1 → *, filtre à sens unique)

| De (dimension) | Vers (faits) | Clé |
|---|---|---|
| `dim_customer[customer_key]` | `fct_sales[customer_key]` | client |
| `dim_product[product_key]` | `fct_sales[product_key]` | produit |
| `dim_date[date_key]` | `fct_sales[date_key]` | date (AAAAMMJJ) |

### Hiérarchie · `dim_date[Calendrier]`
Année → Trimestre → Mois (drill-down temporel).

### Sécurité au niveau des lignes (RLS)
Rôle **`Responsable_FR`** : filtre `dim_customer[country] = "FR"`, propagé aux ventes.

---

## `fct_sales` — table de faits

*Grain : une ligne de commande (un produit dans une commande). Source : jointure orders × order_item du Projet 07. Porte les mesures additives ; c'est ici que se calcule tout le CA. Reliée aux 3 dimensions par des relations 1→* à sens unique.*

| Colonne | Type | Description |
|---|---|---|
| `order_id` | Entier | Identifiant de la commande. Un même order_id apparaît sur plusieurs lignes (une par produit) → pour COMPTER les commandes, utiliser `[Nb commandes]` (DISTINCTCOUNT), jamais un COUNT de lignes. |
| `customer_key` | Entier | Clé étrangère vers `dim_customer`. Ne pas agréger. |
| `product_key` | Entier | Clé étrangère vers `dim_product`. Ne pas agréger. |
| `date_key` | Entier | Clé étrangère (AAAAMMJJ) vers `dim_date`. Relie chaque vente au calendrier. |
| `status` | Texte | Statut : pending / paid / shipped / delivered / cancelled. Sert à isoler `[CA validé]`. |
| `quantity` | Entier | Quantité vendue sur la ligne. Additif (= `[Unités vendues]`). |
| `unit_price` | Décimal | Prix unitaire **figé au moment de l'achat** — distinct de `dim_product[price]` (catalogue), qui peut évoluer sans réécrire l'historique. |
| `line_amount` | Décimal | Montant de la ligne = quantity × unit_price. Base du CA (`[CA]` = SUM de cette colonne). |

## `dim_customer` — dimension client

*Un client = une ligne. Axe d'analyse (pays) et point d'application de la RLS. Source : table customer du Projet 07.*

| Colonne | Type | Description |
|---|---|---|
| `customer_key` | Entier | Clé primaire. Côté '1' de la relation vers `fct_sales`. |
| `email` | Texte | Email du client (unique dans la source). Identifiant métier. |
| `full_name` | Texte | Nom complet (prénom + nom), dénormalisé pour l'affichage. |
| `country` | Texte | Pays (ISO 3166-1 alpha-2). Double usage : axe géographique **et** filtre de la RLS (`Responsable_FR` → country = 'FR'). |

## `dim_product` — dimension produit

*Catégorie dénormalisée dans la table (étoile, pas flocon). Axe d'analyse produit/catégorie. Source : product × category du Projet 07.*

| Colonne | Type | Description |
|---|---|---|
| `product_key` | Entier | Clé primaire. Côté '1' de la relation vers `fct_sales`. |
| `sku` | Texte | Référence produit (identifiant métier, unique). |
| `product_name` | Texte | Libellé commercial du produit. |
| `category` | Texte | Catégorie, dénormalisée dans la dimension. Axe d'analyse principal. |
| `price` | Décimal | Prix catalogue **actuel**. ⚠ Pour le CA, utiliser `fct_sales[unit_price]` (prix à l'achat). |
| `is_active` | Texte | Produit actif au catalogue (t/f). Repère le stock dormant. |

## `dim_date` — table calendrier

*Un jour par ligne (continue, sans trou), marquée comme Table de dates → socle de la time intelligence. Générée sur l'amplitude des dates de commande.*

| Colonne | Type | Description |
|---|---|---|
| `date_key` | Entier | Clé (AAAAMMJJ) reliant à `fct_sales[date_key]`. |
| `date` | Date | Date du jour. Clé de la Table de dates → socle de toute la time intelligence (YoY, YTD, MoM). |
| `annee` | Entier | Année civile. Niveau haut de la hiérarchie Calendrier. |
| `trimestre` | Entier | Numéro de trimestre (1-4). Niveau intermédiaire. |
| `mois_num` | Entier | Numéro du mois (1-12). Clé de tri de `mois_nom` + niveau bas de la hiérarchie. |
| `mois_nom` | Texte | Nom du mois. Trié par `mois_num` (ordre chronologique). |
| `annee_mois` | Date | Clé AAAA-MM. Axe temporel recommandé pour les courbes mensuelles. |
| `jour` | Entier | Jour du mois (1-31). |
| `jour_semaine_num` | Entier | Numéro ISO du jour de semaine (1 = lundi … 7 = dimanche). Clé de tri. |
| `jour_semaine_nom` | Texte | Nom du jour. Trié par `jour_semaine_num` (lundi → dimanche). |
| `est_weekend` | Texte | Vrai si samedi ou dimanche. Pour analyses jours ouvrés vs week-end. |

---

## Mesures (17)

Toutes rattachées à `fct_sales`, rangées par dossier d'affichage.

### 1 Base

| Mesure | Format | Expression DAX | Description |
|---|---|---|---|
| `CA` | € | `SUM ( fct_sales[line_amount] )` | Chiffre d'affaires total. Mesure **socle** réutilisée par la plupart des autres. Inclut tous les statuts (pour le CA réel, voir `[CA validé]`). |
| `Unités vendues` | # | `SUM ( fct_sales[quantity] )` | Nombre total d'articles vendus. |
| `Nb commandes` | # | `DISTINCTCOUNT ( fct_sales[order_id] )` | Nombre de commandes **distinctes** (une commande = plusieurs lignes). Ne jamais compter les lignes. |
| `Nb clients` | # | `DISTINCTCOUNT ( fct_sales[customer_key] )` | Nombre de clients distincts ayant commandé dans le contexte filtré. |
| `CA validé` | € | `CALCULATE ( [CA], fct_sales[status] IN { "paid", "shipped", "delivered" } )` | CA hors annulées et en attente. **KPI principal** à présenter à la direction. |
| `Panier moyen` | € | `DIVIDE ( [CA], [Nb commandes] )` | Valeur moyenne d'une commande (AOV). DIVIDE gère la division par zéro. |

### 2 Temps *(nécessitent `dim_date` marquée Table de dates)*

| Mesure | Format | Expression DAX | Description |
|---|---|---|---|
| `CA YTD` | € | `TOTALYTD ( [CA], dim_date[date] )` | CA cumulé depuis le 1er janvier (Year-To-Date). |
| `CA N-1` | € | `CALCULATE ( [CA], SAMEPERIODLASTYEAR ( dim_date[date] ) )` | CA de la même période l'an dernier. Base des comparaisons annuelles. |
| `CA mois -1` | € | `CALCULATE ( [CA], DATEADD ( dim_date[date], -1, MONTH ) )` | CA du mois précédent. Base du MoM. |
| `CA moyenne 3M` | € | `AVERAGEX ( DATESINPERIOD ( dim_date[date], MAX ( dim_date[date] ), -3, MONTH ), [CA] )` | Moyenne glissante sur 3 mois. Lisse la tendance. |
| `Croissance YoY %` | % | `VAR courant = [CA] VAR precedent = [CA N-1] RETURN DIVIDE ( courant - precedent, precedent )` | Variation vs l'an dernier. Vide sans année précédente. ⚠ comparer des périodes complètes. |
| `Croissance MoM %` | % | `DIVIDE ( [CA] - [CA mois -1], [CA mois -1] )` | Variation vs le mois précédent. |
| `Tendance YoY` | ▲▼▬ | `VAR g = [Croissance YoY %] RETURN SWITCH ( TRUE (), g > 0.02, "▲", g < -0.02, "▼", "▬" )` | Indicateur visuel selon le signe du YoY (seuil ±2 %). |

### 3 Clients

| Mesure | Format | Expression DAX | Description |
|---|---|---|---|
| `Clients récurrents` | # | `VAR parClient = ADDCOLUMNS ( VALUES ( fct_sales[customer_key] ), "@n", CALCULATE ( DISTINCTCOUNT ( fct_sales[order_id] ) ) ) RETURN COUNTROWS ( FILTER ( parClient, [@n] > 1 ) )` | Clients ayant passé strictement plus d'une commande. |
| `Taux récurrence %` | % | `DIVIDE ( [Clients récurrents], [Nb clients] )` | Part de clients fidèles. |

### 4 Ratios

| Mesure | Format | Expression DAX | Description |
|---|---|---|---|
| `% du total catégorie` | % | `DIVIDE ( [CA], CALCULATE ( [CA], ALL ( dim_product[category] ) ) )` | Part du CA dans le total toutes catégories (ALL ignore le filtre catégorie). |
| `Rang produit` | # | `RANKX ( ALL ( dim_product[product_name] ), [CA],, DESC, DENSE )` | Classement du produit par CA décroissant (ex æquo denses). |

---

## Régénérer ce document

La source de vérité = les descriptions dans le `.pbix`. Pour rafraîchir cet
instantané après modification du modèle : relire les métadonnées via le MCP
`powerbi-modeling` (tables, colonnes, mesures) et réécrire ce fichier. Ne pas
éditer les descriptions ici — les éditer dans le modèle.
