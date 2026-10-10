SELECT 
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT order_id) AS total_commandes_uniques,
    COUNT(DISTINCT customer_id) AS total_clients_uniques,
    MIN(order_date_dateorders) AS premiere_commande,
    MAX(order_date_dateorders) AS derniere_commande
FROM dataco_orders;


SELECT 
    delivery_status,
    COUNT(*) AS nombre_expeditions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS part_pourcentage,
    ROUND(AVG(days_for_shipping_real), 2) AS delai_moyen_reel_jours,
    ROUND(AVG(days_for_shipment_scheduled), 2) AS delai_moyen_prevu_jours
FROM dataco_orders
GROUP BY delivery_status
ORDER BY nombre_expeditions DESC;


SELECT 
    shipping_mode,
    COUNT(*) AS total_commandes,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS nb_retards,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS taux_retard_pct
FROM dataco_orders
GROUP BY shipping_mode
ORDER BY taux_retard_pct DESC;


SELECT 
    order_region,
    ROUND(SUM(sales)::numeric, 2) AS ca_total,
    ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN sales ELSE 0 END)::numeric, 2) AS ca_en_retard,
    ROUND(SUM(benefit_per_order)::numeric, 2) AS profit_net,
    ROUND(
        (SUM(CASE WHEN delivery_status = 'Late delivery' THEN sales ELSE 0 END) * 100.0 / SUM(sales))::numeric, 
        2
    ) AS pct_ca_retard
FROM dataco_orders
GROUP BY order_region
ORDER BY ca_en_retard DESC
LIMIT 10;




SELECT 
    category_name,
    COUNT(*) AS total_lignes,
    SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END) AS nb_commandes_a_perte,
    ROUND(
        ABS(SUM(CASE WHEN benefit_per_order < 0 THEN benefit_per_order ELSE 0 END))::numeric, 
        2
    ) AS montant_total_pertes_usd,
    ROUND(
        (SUM(CASE WHEN benefit_per_order < 0 AND delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / 
         NULLIF(SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END), 0))::numeric,
        2
    ) AS pct_pertes_avec_retard
FROM dataco_orders
GROUP BY category_name
HAVING SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END) > 0
ORDER BY montant_total_pertes_usd DESC
LIMIT 10;



SELECT 
    type AS type_paiement,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN order_status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) AS nb_fraudes_suspectees,
    ROUND(
        (SUM(CASE WHEN order_status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric, 
        2
    ) AS taux_fraude_pct,
    ROUND(
        SUM(CASE WHEN order_status = 'SUSPECTED_FRAUD' THEN sales ELSE 0 END)::numeric, 
        2
    ) AS ca_expose_fraude_usd
FROM dataco_orders
GROUP BY type
ORDER BY taux_fraude_pct DESC;




-- Vue KPI 1 : Statuts de livraison
CREATE OR REPLACE VIEW v_kpi1_delivery_status AS
SELECT 
    delivery_status,
    COUNT(*) AS nombre_expeditions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS part_pourcentage,
    ROUND(AVG(days_for_shipping_real), 2) AS delai_moyen_reel_jours,
    ROUND(AVG(days_for_shipment_scheduled), 2) AS delai_moyen_prevu_jours
FROM dataco_orders
GROUP BY delivery_status;

--  Vue KPI 2 : Performance par mode de livraison
CREATE OR REPLACE VIEW v_kpi2_shipping_mode AS
SELECT 
    shipping_mode,
    COUNT(*) AS total_commandes,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS nb_retards,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS taux_retard_pct
FROM dataco_orders
GROUP BY shipping_mode;

--  Vue KPI 3 : Risque financier par région
CREATE OR REPLACE VIEW v_kpi3_regional_risk AS
SELECT 
    order_region,
    ROUND(SUM(sales)::numeric, 2) AS ca_total,
    ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN sales ELSE 0 END)::numeric, 2) AS ca_en_retard,
    ROUND(SUM(benefit_per_order)::numeric, 2) AS profit_net,
    ROUND(
        (SUM(CASE WHEN delivery_status = 'Late delivery' THEN sales ELSE 0 END) * 100.0 / SUM(sales))::numeric, 
        2
    ) AS pct_ca_retard
FROM dataco_orders
GROUP BY order_region;

--  Vue KPI 4 : Catégories à pertes
CREATE OR REPLACE VIEW v_kpi4_category_losses AS
SELECT 
    category_name,
    COUNT(*) AS total_lignes,
    SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END) AS nb_commandes_a_perte,
    ROUND(
        ABS(SUM(CASE WHEN benefit_per_order < 0 THEN benefit_per_order ELSE 0 END))::numeric, 
        2
    ) AS montant_total_pertes_usd,
    ROUND(
        (SUM(CASE WHEN benefit_per_order < 0 AND delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / 
         NULLIF(SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END), 0))::numeric,
        2
    ) AS pct_pertes_avec_retard
FROM dataco_orders
GROUP BY category_name
HAVING SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END) > 0;

--  Vue KPI 5 : Fraudes par canal de paiement
CREATE OR REPLACE VIEW v_kpi5_fraud_risk AS
SELECT 
    type AS type_paiement,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN order_status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) AS nb_fraudes_suspectees,
    ROUND(
        (SUM(CASE WHEN order_status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric, 
        2
    ) AS taux_fraude_pct,
    ROUND(
        SUM(CASE WHEN order_status = 'SUSPECTED_FRAUD' THEN sales ELSE 0 END)::numeric, 
        2
    ) AS ca_expose_fraude_usd
FROM dataco_orders
GROUP BY type;





-- KPI 1 : Statuts de livraison
CREATE OR REPLACE VIEW v_kpi1_delivery_status AS
SELECT 
    delivery_status,
    COUNT(*) AS nombre_expeditions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS part_pourcentage,
    ROUND(AVG(days_for_shipping_real), 2) AS delai_moyen_reel_jours,
    ROUND(AVG(days_for_shipment_scheduled), 2) AS delai_moyen_prevu_jours
FROM dataco_orders
GROUP BY delivery_status;

-- KPI 2 : Performance par mode d'expédition
CREATE OR REPLACE VIEW v_kpi2_shipping_mode AS
SELECT 
    shipping_mode,
    COUNT(*) AS total_commandes,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS nb_retards,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS taux_retard_pct
FROM dataco_orders
GROUP BY shipping_mode;

-- KPI 3 : Risque financier par région
CREATE OR REPLACE VIEW v_kpi3_regional_risk AS
SELECT 
    order_region,
    ROUND(SUM(sales)::numeric, 2) AS ca_total,
    ROUND(SUM(CASE WHEN delivery_status = 'Late delivery' THEN sales ELSE 0 END)::numeric, 2) AS ca_en_retard,
    ROUND(SUM(benefit_per_order)::numeric, 2) AS profit_net,
    ROUND(
        (SUM(CASE WHEN delivery_status = 'Late delivery' THEN sales ELSE 0 END) * 100.0 / SUM(sales))::numeric, 
        2
    ) AS pct_ca_retard
FROM dataco_orders
GROUP BY order_region;

-- KPI 4 : Catégories générant des pertes
CREATE OR REPLACE VIEW v_kpi4_category_losses AS
SELECT 
    category_name,
    COUNT(*) AS total_lignes,
    SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END) AS nb_commandes_a_perte,
    ROUND(
        ABS(SUM(CASE WHEN benefit_per_order < 0 THEN benefit_per_order ELSE 0 END))::numeric, 
        2
    ) AS montant_total_pertes_usd,
    ROUND(
        (SUM(CASE WHEN benefit_per_order < 0 AND delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / 
         NULLIF(SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END), 0))::numeric,
        2
    ) AS pct_pertes_avec_retard
FROM dataco_orders
GROUP BY category_name
HAVING SUM(CASE WHEN benefit_per_order < 0 THEN 1 ELSE 0 END) > 0;