# Page de vente — Maxence Delmas (influenceuses IA)

Landing page autonome (HTML/CSS/JS, sans build). Le formulaire de réservation
enregistre chaque lead dans Supabase, où les setters le reprennent.

```
index.html                  la page (styles et scripts inline)
img/                        captures de résultats et miniatures d'interviews (WebP)
videos/                     témoignages vidéo (MP4 H.264 9:16) et leurs posters (WebP)
supabase/schema.sql         table leads + règles de sécurité
vercel.json                 URLs propres
A-COMPLETER.md              tout ce qui manque avant la mise en ligne
```

Les médias bruts (`Screen résultats/`, `Vidéo témoignagne/`, `charte/`) restent
en local : ils sont dans `.gitignore`, seuls les fichiers optimisés partent en
ligne.

## Comment circule un lead

```
Formulaire de la page
        │  insert (clé anon publique)
        ▼
Table public.leads  ──►  le back-office des setters lit directement cette table
        │
        └──►  historique, statut de rappel, notes
```

Après l'envoi, la page recharge sur `?confirmation=1` : même fichier, hero et
bandeau différents, CTA retirés (voir plus bas).

## 1. Créer la table

Sur le **projet Supabase de Maxence** : **SQL Editor** → *New query* → colle
le contenu de `supabase/schema.sql` → **Run**.

Ça crée la table `leads`, les index, le statut de traitement
(`nouveau`, `a_rappeler`, `appele`, `rdv_pris`, `perdu`), la vue
`leads_a_rappeler` et surtout les règles RLS.

## 2. Brancher la page

Dans `index.html`, en haut du premier grand script :

```js
var SUPABASE_URL      = '';   // Settings → API → Project URL
var SUPABASE_ANON_KEY = '';   // Settings → API → anon public
```

Tant que ces deux valeurs sont vides, le formulaire refuse l'envoi et affiche
un message d'erreur : aucun lead ne se perd en silence.

### Sur la sécurité

La clé `anon` est **publique par conception** : tout visiteur peut la lire
dans le code source. Ce qui protège les données, ce sont les règles du schéma :

- le public peut **insérer** un lead, et rien d'autre ;
- aucune policy `select` / `update` / `delete` n'existe pour `anon`, et les
  droits par défaut de Supabase sur la table sont retirés ;
- la vue `leads_a_rappeler` est en `security_invoker` : sans ça, une vue créée
  par `postgres` contourne la RLS et la clé anon suffirait à lire la liste ;
- un formulaire ne peut pas préremplir les champs de suivi interne
  (`status`, `called_at`, `notes`).

La lecture se fait depuis le dashboard Supabase, ou avec la clé `service_role`
— qui ne doit **jamais** apparaître dans le code de la page.

Pour vérifier après installation (doit renvoyer une erreur ou une liste vide) :

```
curl "$SUPABASE_URL/rest/v1/leads_a_rappeler?select=id" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"
```

## 3. Suivre les rappels

Dans **Table Editor**, les setters passent le `status` de `nouveau` à
`appele` / `rdv_pris` / `perdu`, remplissent `called_at` et `notes`.
La vue `leads_a_rappeler` liste ce qui reste à traiter.

## Anti-spam

Le formulaire contient un champ leurre (`company`) masqué aux humains. S'il est
rempli, la soumission est ignorée sans rien enregistrer.

## Tracking

- Vercel Web Analytics (`/_vercel/insights/script.js`, actif une fois déployé
  sur Vercel) : *Formulaire ouvert*, *Formulaire envoyé*, *Son de la VSL
  activé*, *Témoignage vidéo lu*, *Interview YouTube lue*.
- Un lien `?src=nom-du-canal` est retenu trente jours et envoyé avec le lead
  dans la colonne `source`.

## Les deux modes de la page

| Adresse | Ce qu'on voit |
|---|---|
| `/` | page de vente |
| `/?confirmation=1` | bandeau d'alerte, hero de confirmation avec la VSL d'avant-appel, « quoi faire maintenant », les trois étapes débloquées ; tous les CTA sont retirés |

Les blocs portent la classe `default-only` ou `confirm-only`.

## Les VSL (Vimeo)

Remplacer `VIMEO_ID_VENTE` et `VIMEO_ID_CONFIRMATION` dans `index.html`. Tant
qu'ils ne sont pas renseignés, le cadre affiche un emplacement à compléter.

- Vente : démarrage automatique en sourdine, calque « Clique pour activer le
  son », bouton de rattrapage du son sur mobile.
- Confirmation : la barre de progression est masquée et tout saut en avant est
  ramené à la position réellement atteinte. Revenir en arrière reste possible.
  Un clic sur la vidéo met en pause ou reprend. C'est un verrou d'usage, pas un
  verrou technique.

Le cadre est en 9:16. Si les vidéos fournies ont un autre format, corriger
`aspect-ratio` dans la règle `.vsl`.

## Les preuves

- **Captures** (`img/resultat-*.webp`) : recadrées sur la bulle du message
  (les avatars des membres sortent du cadre), nom de créatrice flouté sur
  `resultat-15421e-quatre-creatrices`. Un clic les agrandit.
- **Témoignages vidéo** (`videos/temoignage-*.mp4`) : recadrés en 9:16 depuis
  les fichiers 16:9 à bords floutés, H.264 + AAC, 2,7 à 3,6 Mo, lus au clic
  (`preload="none"`), une seule vidéo à la fois.
- **Interviews YouTube** : miniature servie par le site, lecteur
  `youtube-nocookie` chargé seulement au clic.

Pour ajouter une vidéo, la commande utilisée (ffmpeg) :

```
ffmpeg -i source.mp4 -vf "crop=ih*9/16:ih,scale=540:960" -c:v libx264 -preset slow -b:v 450k \
  -c:a aac -b:a 80k -movflags +faststart videos/temoignage-xxx.mp4
ffmpeg -ss 3 -i videos/temoignage-xxx.mp4 -frames:v 1 -c:v libwebp -quality 72 videos/temoignage-xxx.webp
```

## Direction artistique

Toutes les couleurs et polices sont des variables dans `:root` :
fond `#050505`, texte `#F3F0E8`, gris chaud `#A39D90`, or `#F6C944`
(surligneur, chiffres), or pâle `#ECD086` (boutons) ; Montserrat 800 en
capitales pour les titres, Hanken Grotesk pour le texte.

Trois signatures, à garder rares : le mot surligné incliné (`.hl`), le
dégradé noir → or (`.fondu-or`, hero et CTA final), la carte à contour
lumineux (`.halo`, offre et 3 étapes).

## À compléter avant mise en ligne

Voir `A-COMPLETER.md`. Les trous visibles dans la page portent un cadre
pointillé doré (`.ac`) ou un fond hachuré (`.ph`).
