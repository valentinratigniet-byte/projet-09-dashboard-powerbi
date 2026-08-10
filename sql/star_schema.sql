-- =====================================================================
-- Projet 09 — Modèle en étoile (marts) construit sur la base OLTP du projet 07.
-- On expose des VUES dim_/fct_ : Power BI (ou l'export CSV) consomme un schéma
-- dénormalisé, prêt à modéliser, sans toucher aux tables sources.
--   1 table de faits (fct_sales) + 3 dimensions (customer, product, date).
-- =====================================================================

-- ---------------------------------------------------------------------
-- dim_customer : une ligne par client. On dénormalise le nom complet.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW dim_customer AS
SELECT c.id                                   AS customer_key,
       c.email,
       c.first_name || ' ' || c.last_name     AS full_name,
       c.country
FROM customer c;

-- ---------------------------------------------------------------------
-- dim_product : une ligne par produit, catégorie dénormalisée (étoile, pas flocon).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW dim_product AS
SELECT p.id            AS product_key,
       p.sku,
       p.name          AS product_name,
       cat.name        AS category,
       p.price,
       p.is_active
FROM product p
JOIN category cat ON cat.id = p.category_id;

-- ---------------------------------------------------------------------
-- dim_date : table calendrier, une ligne par jour couvrant l'historique.
-- Indispensable pour la time intelligence DAX (YoY, cumuls, etc.).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW dim_date AS
WITH bornes AS (
    SELECT date_trunc('day', min(order_date))::date AS d_min,
           date_trunc('day', max(order_date))::date AS d_max
    FROM orders
),
jours AS (
    SELECT generate_series(d_min, d_max, interval '1 day')::date AS d
    FROM bornes
)
SELECT to_char(d, 'YYYYMMDD')::int          AS date_key,
       d                                    AS date,
       extract(year   FROM d)::int          AS annee,
       extract(quarter FROM d)::int         AS trimestre,
       extract(month  FROM d)::int          AS mois_num,
       to_char(d, 'TMMonth')                AS mois_nom,
       to_char(d, 'YYYY-MM')                AS annee_mois,
       extract(day    FROM d)::int          AS jour,
       extract(isodow FROM d)::int          AS jour_semaine_num,
       to_char(d, 'TMDay')                  AS jour_semaine_nom,
       (extract(isodow FROM d) >= 6)        AS est_weekend
FROM jours;

-- ---------------------------------------------------------------------
-- fct_sales : table de faits, grain = une ligne de commande.
-- Clés étrangères vers les 3 dimensions + mesures additives.
--   line_amount = montant de la ligne (mesure de base du CA).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW fct_sales AS
SELECT o.id                              AS order_id,
       o.customer_id                     AS customer_key,
       oi.product_id                     AS product_key,
       to_char(o.order_date, 'YYYYMMDD')::int AS date_key,
       o.status,
       oi.quantity,
       oi.unit_price,
       (oi.quantity * oi.unit_price)     AS line_amount
FROM orders o
JOIN order_item oi ON oi.order_id = o.id;
