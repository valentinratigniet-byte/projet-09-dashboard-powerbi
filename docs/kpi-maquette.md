# KPIs exécutifs & maquette

## Les KPIs (ce que la direction regarde en 5 secondes)

| KPI | Mesure DAX | Pourquoi |
|---|---|---|
| Chiffre d'affaires | `CA validé` | la performance, point. |
| Croissance YoY | `Croissance YoY %` | on progresse ou pas vs l'an dernier ? |
| Nb commandes | `Nb commandes` | volume d'activité |
| Panier moyen | `Panier moyen` | valeur par transaction |
| Taux de récurrence | `Taux récurrence %` | fidélisation / santé du portefeuille |

## Maquette — Page 1 « Vue d'ensemble » (exécutif)

```
┌────────────────────────────────────────────────────────────────┐
│  DASHBOARD VENTES            [Année ▾] [Catégorie ▾] [Pays ▾]   │  ← slicers
├────────────┬────────────┬────────────┬────────────┬────────────┤
│   CA        │  YoY ▲     │ Commandes  │  Panier moy │ Récurrence │  ← 5 cartes KPI
│  8,2 M€     │  +12,4 %   │   34 302   │   238 €     │   68 %     │
├────────────┴────────────┴────────────┴────────────┴────────────┤
│  CA mensuel + moyenne glissante 3M        │  CA par catégorie   │
│  (courbe + ligne)                         │  (barres, % total)  │
├───────────────────────────────────────────┼─────────────────────┤
│  Top 10 produits par CA (barres)          │  CA par pays (carte)│
└───────────────────────────────────────────┴─────────────────────┘
```

## Maquette — Page 2 « Détail produit » (drill-down)

- Table matricielle : catégorie → produit, avec `CA`, `Unités`, `% du total`, `Rang produit`.
- Drill-down activé (catégorie → produit).
- Le clic sur une catégorie page 1 renvoie ici via **drillthrough**.

## Interactions à configurer

- **Filtrage croisé** : cliquer une catégorie filtre tous les visuels de la page.
- **Drill-down temporel** : Année → Trimestre → Mois sur la courbe de CA.
- **Drillthrough** page 1 → page 2 sur le champ `category`.
- **Info-bulles** personnalisées : YoY + panier moyen au survol des barres.

## Principes de design (lisible par un non-analyste)

1. **KPIs en haut**, du plus important au moins important, gauche → droite.
2. **Une couleur d'accent** (le CA), le reste en gris → l'œil va à l'essentiel.
3. **Pas plus de 6 visuels par page** : un dashboard n'est pas un data-dump.
4. **Titres = phrases** (« Le CA progresse de 12 % » > « CA par mois »).
5. **Format FR** : €, séparateur milliers, dates localisées.
