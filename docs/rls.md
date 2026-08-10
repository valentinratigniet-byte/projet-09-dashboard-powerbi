# Sécurité au niveau des lignes (RLS)

Objectif : un responsable pays ne voit **que les ventes de son pays**. Démontre
que tu sais sécuriser un rapport partagé.

## Mise en place dans Power BI Desktop

1. **Modélisation → Gérer les rôles → Créer**.
2. Rôle `Responsable_FR`, table `dim_customer`, filtre DAX :

```dax
[country] = "FR"
```

3. Le filtre se propage automatiquement de `dim_customer` vers `fct_sales`
   (relation 1 → *), donc toutes les mesures se restreignent à la France.

## Version dynamique (un seul rôle pour tous les pays)

Au lieu d'un rôle par pays, un rôle unique qui lit le pays de l'utilisateur
connecté via une table de correspondance `sec_users(email, country)` :

```dax
[country] =
LOOKUPVALUE (
    sec_users[country],
    sec_users[email], USERPRINCIPALNAME ()
)
```

`USERPRINCIPALNAME()` = l'email de la personne connectée sur Power BI Service.

## Tester

- **Modélisation → Afficher en tant que** → coche `Responsable_FR` → vérifie que
  seules les ventes FR apparaissent.
- Après publication : gérer les membres du rôle dans Power BI Service
  (*Sécurité* sur le jeu de données).

## Piège classique

La RLS filtre les **dimensions**, jamais la table de faits directement. Le sens
de filtre doit aller dimension → faits (déjà le cas ici). Un filtre bidirectionnel
casserait l'isolation.
