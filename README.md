# Projet 09 — Dashboard exécutif Power BI

> **Une seule vue fiable de la performance commerciale.** Modèle en étoile propre,
> mesures DAX (YoY, cumuls, moyennes glissantes), drill-down et sécurité au niveau
> des lignes (RLS) — construit sur les données du
> [Projet 07](https://github.com/valentinratigniet-byte/projet-07-base-ecommerce).
>
> Ce repo contient **tout le travail de données et de conception** (modèle, DAX,
> maquette, RLS) + les données prêtes à importer. Le fichier `.pbix` s'assemble
> dans Power BI Desktop en suivant le guide ci-dessous.

## 📦 Contenu du repo

```
projet-09-dashboard-powerbi/
├── README.md
├── sql/
│   └── star_schema.sql       ← vues dim_/fct_ (marts) sur la base du projet 07
├── data/                     ← export CSV prêt pour Power BI (pas besoin de Docker)
│   ├── dim_customer.csv       (5 000 lignes)
│   ├── dim_product.csv        (2 000 lignes)
│   ├── dim_date.csv           (731 jours)
│   └── fct_sales.csv          (120 089 lignes)
├── dax/
│   └── measures.md           ← bibliothèque de mesures DAX commentées
└── docs/
    ├── modele.md             ← schéma en étoile + relations à créer
    ├── kpi-maquette.md       ← KPIs exécutifs + maquette des 2 pages
    ├── rls.md                ← sécurité au niveau des lignes
    └── data-dictionary.md    ← dictionnaire de données (généré depuis le .pbix)
```

## 🛠️ Construire le dashboard (Power BI Desktop)

1. **Importer les données** — *Accueil → Obtenir des données → Texte/CSV* → charger
   les 4 fichiers de `data/`.
   *(Alternative « live » : connecteur PostgreSQL sur `localhost:5433`, base
   `ecommerce`, et importer les vues `dim_*` / `fct_sales`.)*
2. **Créer les relations** — voir [docs/modele.md](docs/modele.md) (3 relations
   1 → *, filtre à sens unique).
3. **Marquer `dim_date`** comme table de dates (colonne `date`).
4. **Ajouter les mesures** — copier depuis [dax/measures.md](dax/measures.md) dans
   une table `_Mesures`.
5. **Construire les pages** — suivre [docs/kpi-maquette.md](docs/kpi-maquette.md)
   (vue d'ensemble + détail, drill-down, drillthrough).
6. **Configurer la RLS** — [docs/rls.md](docs/rls.md), puis *Publier* sur Power BI
   Service.
7. **Ajouter au repo** le `.pbix` final + captures dans `outputs/`.

## 🌟 Ce que le projet démontre

- **Modélisation** : étoile sans ambiguïté (1 faits + 3 dimensions dénormalisées).
- **DAX** : time intelligence correcte (YoY, YTD, MoM, moyenne glissante), ratios,
  classements — voir la bibliothèque commentée.
- **Storytelling** : KPIs hiérarchisés, titres-phrases, une couleur d'accent.
- **Gouvernance** : RLS statique et dynamique (`USERPRINCIPALNAME`).

## 🔄 Régénérer les données

Si tu modifies la base du projet 07 :

```bash
# base 07 lancée (docker compose up -d + python seed/seed.py)
docker exec -i p07_ecommerce_db psql -U portfolio -d ecommerce < sql/star_schema.sql
for v in dim_customer dim_product dim_date fct_sales; do
  docker exec p07_ecommerce_db psql -U portfolio -d ecommerce \
    -c "COPY (SELECT * FROM $v) TO STDOUT WITH CSV HEADER" > data/$v.csv
done
```

---

*Projet 09 du [Portfolio Data](../). Consomme le modèle en étoile issu du Projet 07.
Prochaine brique : Projet 10 — pipeline ELT qui automatise cette chaîne
PostgreSQL → Power BI.*
