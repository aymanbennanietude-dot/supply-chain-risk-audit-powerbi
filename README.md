# Audit de Performance Opérationnelle et Gestion des Risques Supply Chain

## 1. Contexte et Objectifs Métier
Ce projet d'analytique décisionnelle porte sur l'audit opérationnel et financier d'un réseau de distribution mondial (DataCo Global Supply Chain).

L'approche vise à cartographier les vulnérabilités de la chaîne logistique à travers trois axes critiques :
* La ponctualité des flux de transport et les dérives de délais d'acheminement.
* L'exposition financière des revenus face aux retards d'expédition géographiques et aux marges déficitaires.
* La détection des risques de fraude transactionnelle selon les canaux de paiement.

---

## 2. Aperçu du Tableau de Bord
![Dashboard Preview](https://raw.githubusercontent.com/aymanbennanietude-dot/supply-chain-risk-audit-powerbi/main/dashboard_preview.png)

---

## 3. Architecture Technique et Méthodologie
* **Entrepôt de données & Requêtage** : PostgreSQL / pgAdmin 4.
* **Pipeline Analytique** : Implémentation de 5 vues SQL matérialisant les règles métier, le calcul des écarts de livraison réels vs prévus, et les segmentations de risque.
* **Modélisation & Dataviz** : Microsoft Power BI (modélisation dimensionnelle, mesures DAX et conception visuelle exécutive).

---

## 4. Analyse et Résultats de l'Audit

### A. Performance Transport et Défaillance de Service
* **Taux de retard global** : Établi à **54,83 %** sur l'ensemble des 180k+ expéditions auditées.
* **Rupture de niveau de service (SLA)** : Le mode premium **First Class** affiche un taux de retard critique de **95,32 %**, signalant une inadéquation structurelle entre les promesses contractuelles et les capacités logistiques réelles.

### B. Exposition Financière et Risque Géographique
* Le chiffre d'affaires impacté par les retards se concentre massivement sur deux zones prioritaires : l'Europe de l'Ouest (**Western Europe**, > 3,2 M$) et l'Amérique Centrale (**Central America**, > 3,1 M$).

### C. Dégradation des Marges par Catégorie
* L'analyse de rentabilité isole le Top 10 des catégories génératrices de pertes nettes. Le segment **Fishing** représente à lui seul plus de **0,7 M$** de pertes cumulées, pointant un besoin de révision des coûts d'approvisionnement ou de la tarification.

### D. Vulnérabilité aux Risques de Fraude
* L'exposition aux fraudes de paiement atteint **825,93 K$**. La totalité de ce montant à risque est corrélée aux règlements par virement bancaire (**TRANSFER**), désignant ce mode comme vecteur prioritaire de contrôle et de sécurisation financière.

---

## 5. Structure du Répertoire
* `kpi1_to_kpi5.sql` : Requêtes d'extraction, de nettoyage et création des vues SQL sous PostgreSQL.
* `supply_chain_audit.pbix` : Rapport Power BI Desktop (modèle de données et visualisations).
* `dashboard_preview.png` : Capture haute définition du livrable final.
