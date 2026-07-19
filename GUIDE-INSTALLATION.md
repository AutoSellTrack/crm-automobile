# CRM Garage — Guide d'installation

## 1. Tester tout de suite (mode démo)

Ouvrez `index.html` dans un navigateur et choisissez **Essayer en mode démo**. Trois comptes d'exemple sont fournis (1 gérant, 2 vendeurs) avec des données fictives. Les données démo restent sur l'appareil.

## 2. Passer en base partagée (accès multi-appareils)

Pour que chaque vendeur accède à la même base depuis son téléphone ou son ordinateur, il faut deux choses gratuites : une base **Supabase** et un hébergement du fichier.

### a) Créer la base Supabase (~10 min)

1. Créez un compte sur [supabase.com](https://supabase.com) (plan gratuit suffisant).
2. Créez un projet (nom : `crm-garage`, région : Europe West).
3. Ouvrez **SQL Editor** → **New query**, collez tout le contenu du fichier `supabase-setup.sql`, puis **Run**.
4. (Recommandé) Dans **Authentication → Sign In / Up → Email**, désactivez « Confirm email » pour que les vendeurs se connectent sans validation d'email.
5. Dans **Settings → API**, notez :
   - **Project URL** (ex. `https://xxxx.supabase.co`)
   - la clé **anon public**

### b) Mettre l'application en ligne (~5 min)

Le fichier doit être accessible par une adresse web (obligatoire pour l'installation sur téléphone) :

1. Créez un compte sur
