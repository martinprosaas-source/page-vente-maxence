# À compléter avant la mise en ligne

Chaque trou est repérable dans la page (cadre pointillé doré ou fond hachuré)
et dans `index.html` par un commentaire `[À COMPLÉTER]`.

## Bloquant

| Quoi | Où dans `index.html` | Format attendu |
|---|---|---|
| URL du projet Supabase | `var SUPABASE_URL = ''` (premier grand script) | `https://xxxx.supabase.co` |
| Clé anon Supabase | `var SUPABASE_ANON_KEY = ''` | Settings → API → anon public. Sans les deux, le formulaire refuse l'envoi |
| VSL de vente (Vimeo) | `VIMEO_ID_VENTE` dans l'iframe `#vslVente` | identifiant numérique Vimeo, vidéo 9:16 de préférence |
| VSL de confirmation (Vimeo) | `VIMEO_ID_CONFIRMATION` dans l'iframe `#vslConfirm` | idem |
| Nom de l'offre Starter | section 3 (titre de la carte offre) et section 10 (au-dessus de « Ton accès au programme ») | ex. « [Marque] Starter » |
| Prix du programme complet | section 3, deux fois : « Une partie de mon programme complet à [X €] » (vente) et « Une partie de mon programme à [X €]. Offert. » (confirmation) | montant en euros |
| Modules inclus | section 3, `<ul class="offer-list">` : 6 lignes provisoires | une ligne par module, autant que nécessaire |

## Contenu

| Quoi | Où | Remarque |
|---|---|---|
| Note moyenne des membres | section 5, sous le CTA : « Note de [À COMPLÉTER]/5 » | le visuel de charte indique 4,8/5 : à confirmer avant de l'écrire |
| Nom de la société | footer : copyright et paragraphe « Ta responsabilité » | raison sociale exacte |
| Liens légaux | footer : confidentialité, CGU, remboursement, contact | pointent vers `#` |
| Coût de l'outil d'IA | FAQ « Où est le piège ? » : « quelques dizaines d'euros » | repris de la page d'un autre client (même partenaire) ; à confirmer pour Maxence |

## Écarté volontairement

- **Témoignage vidéo de Théo** (`Témoigangne 4.mp4`) : il parle de deepfakes et
  d'une modèle réelle. Écarté le 14/10/2026.
- **`Screen résultat 3.png`** : doublon exact de `Screen résultats 1.png`.
  5 captures publiées au lieu de 6 ; en fournir une sixième pour compléter.

## Ce qui a été vérifié dans les sources

- Chiffres du hero, des stats et du ticker : +550 élèves (programme payant) et
  +12 000 membres (communauté gratuite), validés par Martin.
- Montants des captures : lus sur les captures elles-mêmes.
- Citations des vidéos : transcription des fichiers fournis.
- Légendes des interviews : titres des vidéos YouTube de la chaîne Maxence Delmas.
