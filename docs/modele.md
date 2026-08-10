# Modèle en étoile

Une table de faits au centre, trois dimensions autour. **Aucune relation entre
dimensions** (sinon = flocon ou ambiguïté) : tout passe par `fct_sales`.

```mermaid
erDiagram
    dim_date     ||--o{ fct_sales : date_key
    dim_customer ||--o{ fct_sales : customer_key
    dim_product  ||--o{ fct_sales : product_key

    fct_sales {
        int order_id
        int customer_key FK
        int product_key FK
        int date_key FK
        text status
        int quantity
        numeric unit_price
        numeric line_amount
    }
    dim_date {
        int date_key PK
        date date
        int annee
        int trimestre
        text mois_nom
        text annee_mois
        bool est_weekend
    }
    dim_customer {
        int customer_key PK
        text full_name
        text country
    }
    dim_product {
        int product_key PK
        text product_name
        text category
        numeric price
    }
```

## Relations à créer dans Power BI

| De (dimension) | Vers (faits) | Cardinalité | Sens du filtre |
|---|---|---|---|
| `dim_date[date_key]` | `fct_sales[date_key]` | 1 → * | simple (dim → faits) |
| `dim_customer[customer_key]` | `fct_sales[customer_key]` | 1 → * | simple |
| `dim_product[product_key]` | `fct_sales[product_key]` | 1 → * | simple |

## Règles respectées

- **Filtre à sens unique** (dimension → faits) : évite les ambiguïtés de calcul.
- **Grain unique** de `fct_sales` = une ligne de commande (jamais mélanger deux grains).
- **`dim_date` marquée comme table de dates** → débloque la time intelligence.
- **Dimensions dénormalisées** (catégorie dans `dim_product`, pas de table
  séparée) = étoile, pas flocon → moins de relations, requêtes plus simples.
