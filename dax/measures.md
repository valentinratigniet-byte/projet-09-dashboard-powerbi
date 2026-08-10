# Bibliothèque de mesures DAX

À coller dans Power BI (onglet *Modélisation → Nouvelle mesure*). Ranger dans une
table dédiée `_Mesures`.

> **Prérequis time intelligence** : marquer `dim_date` comme *table de dates*
> (clic droit sur la table → *Marquer comme table de dates* → colonne `date`).
> Sans ça, `TOTALYTD`, `SAMEPERIODLASTYEAR`, `DATEADD` renvoient des résultats faux.

## 1. Mesures de base

```dax
CA = SUM ( fct_sales[line_amount] )

Unités vendues = SUM ( fct_sales[quantity] )

Nb commandes = DISTINCTCOUNT ( fct_sales[order_id] )

Nb clients = DISTINCTCOUNT ( fct_sales[customer_key] )

Panier moyen = DIVIDE ( [CA], [Nb commandes] )

-- CA réellement validé (exclut annulées / en attente)
CA validé =
CALCULATE ( [CA], fct_sales[status] IN { "paid", "shipped", "delivered" } )
```

## 2. Time intelligence (dépendent de `dim_date`)

```dax
-- Cumul annuel (Year-To-Date)
CA YTD = TOTALYTD ( [CA], dim_date[date] )

-- Même période l'an dernier
CA N-1 = CALCULATE ( [CA], SAMEPERIODLASTYEAR ( dim_date[date] ) )

-- Croissance annuelle (Year-over-Year)
Croissance YoY % =
VAR courant = [CA]
VAR precedent = [CA N-1]
RETURN DIVIDE ( courant - precedent, precedent )

-- CA du mois précédent
CA mois -1 = CALCULATE ( [CA], DATEADD ( dim_date[date], -1, MONTH ) )

-- Croissance mensuelle (Month-over-Month)
Croissance MoM % = DIVIDE ( [CA] - [CA mois -1], [CA mois -1] )

-- Moyenne glissante 3 mois (lissage de tendance)
CA moyenne 3M =
AVERAGEX (
    DATESINPERIOD ( dim_date[date], MAX ( dim_date[date] ), -3, MONTH ),
    [CA]
)
```

## 3. Ratios & classements

```dax
-- Part du CA dans le total (ignore le filtre catégorie pour avoir le dénominateur global)
% du total catégorie =
DIVIDE ( [CA], CALCULATE ( [CA], ALL ( dim_product[category] ) ) )

-- Rang du produit par CA
Rang produit =
RANKX ( ALL ( dim_product[product_name] ), [CA], , DESC, DENSE )

-- Taux de clients récurrents (plus d'une commande)
Clients récurrents =
VAR parClient =
    ADDCOLUMNS (
        VALUES ( fct_sales[customer_key] ),
        "@n", CALCULATE ( DISTINCTCOUNT ( fct_sales[order_id] ) )
    )
RETURN COUNTROWS ( FILTER ( parClient, [@n] > 1 ) )

Taux récurrence % = DIVIDE ( [Clients récurrents], [Nb clients] )
```

## 4. Mise en forme conditionnelle (indicateur ▲▼)

```dax
Tendance YoY =
VAR g = [Croissance YoY %]
RETURN
    SWITCH ( TRUE (),
        g > 0.02,  "▲",
        g < -0.02, "▼",
        "▬"
    )
```

## Notes

- **`DIVIDE` plutôt que `/`** : gère la division par zéro sans erreur.
- **`ALL` vs `ALLSELECTED`** : `ALL` ignore tous les filtres ; utiliser
  `ALLSELECTED` pour respecter les filtres de page dans un « % du visible ».
- Toutes les mesures temporelles supposent `dim_date` continue (pas de trou) —
  c'est garanti par `generate_series` dans `star_schema.sql`.
