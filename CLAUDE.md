# CLAUDE.md — CRM Garage

## Contexte projet

CRM pour garages automobiles (vente de véhicules d'occasion). Utilisateurs : vendeurs (saisissent leurs échanges clients depuis leur téléphone) et employeur (voit tout + statistiques de conversion). PWA sans Play Store : installation via raccourci écran d'accueil. Langue de l'UI et du code : français.

## Architecture actuelle (prototype)

- **`index.html`** : toute l'application en un seul fichier — CSS, HTML, JS vanilla, sans framework ni build. Servie en statique (Vercel).
- **Couche données** : deux stores interchangeables avec la même interface (`chargerTout`, `creer`, `modifier`, `supprimer`, `utilisateur`) :
  - `DemoStore` : localStorage, données d'exemple, choix d'utilisateur sans mot de passe
  - `SupaStore` : Supabase (supabase-js v2 via CDN jsdelivr), auth email/mot de passe
- **`supabase-setup.sql`** : schéma complet. Tables : `profiles` (id = auth.users.id, nom, role vendeur|employeur), `clients`, `vehicules` (statut stock|vendu), `interactions` (vendeur_id, client_id, vehicule_id, canal, interet 1–5, statut en_cours|vendu|perdu, date_interaction). Trigger : création auto du profil à l'inscription ; le **premier compte créé devient employeur**.
- **RLS** : les vendeurs ne peuvent créer/modifier/supprimer que leurs propres interactions ; lecture ouverte à tous les authentifiés (nécessaire aux stats). L'employeur peut tout modifier.

## Règles métier

- Un client = plusieurs interactions possibles. Conversion = ventes ÷ clients distincts contactés.
- La date d'un échange est pré-remplie à maintenant mais modifiable (saisie a posteriori).
- Quand un échange passe à « vendu », proposer de marquer le véhicule vendu dans le parc.
- Côté client, le filtrage vendeur/employeur est dans `App.mesInteractions()` ; la vraie barrière est la RLS.

## Conventions

- Code et identifiants en français (`vueStats`, `sauverInteraction`, `ouvrirFormClient`…)
- Échapper toute donnée utilisateur avec `App.esc()` avant insertion dans le HTML
- Mobile-first : navigation par onglets en bas, modals en bottom-sheet, FAB pour la saisie rapide
- Canaux définis dans la constante `CANAUX`, statuts dans `STATUTS`

## Pistes d'évolution envisagées

- Passage à une structure multi-fichiers ou framework léger si le fichier devient ingérable
- Vrai manifest PWA + service worker (mode hors-ligne)
- Gestion des comptes vendeurs par l'employeur (nécessite une API côté serveur : la clé service_role ne doit jamais être dans le client)
- Multi-garages (colonne garage_id + RLS par garage) si le produit est commercialisé
- Export CSV des stats, objectifs mensuels par vendeur

## Commandes

Aucun build. Tester en ouvrant `index.html` (mode démo) ou `npx serve` pour un serveur local. Vercel déploie automatiquement à chaque push sur `main`.
