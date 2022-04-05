# Entourage - iOS application V8

Ajout concernant la version V8.
Celle-ci est développée en Swift
Concernant les librairies externes, on privilégie Switf Package Manager.
Si l’on n'a pas le choix, on peut utiliser Cocoapods.

## Infos générales
On a différents managers qui vont gérer le network/location.....

Pour le network, on a en plus du network manager, des Services pour les différents appels API en association avec les modèles correspondants.

On a une classe statique ApplicationTheme qui regroupe les fonts et différentes valeurs globales de l'app style les radius.

On a différents assets d'images pour les différentes parties de l'app.

Les strings sont modifiées dans chaque vue/controller avec une extension -> "String".localized

Les storyboards sont découpés en fonctionnalités / écrans


## Infos générales Views

*** Top bar ***
Celle-ci est une view custom - MJNavBackView qui peut avoir un bouton à gauche pour la fermeture.
Elle a un titre, une image pour le bouton, une view bottom pour le trait, et un délégate pour gérer le bouton back.

*** Pop alerte / info ***
MJAlertController
Celui-ci a titre, message 2 boutons gauche / droite et un bouton en haut à droite pour la fermeture.
On a une méthode de config que l'on doit appeler.
Les boutons sont customisables, on peut en passer 1 ou 2.
Si l'on passe qu'un bouton celui-ci est centré et c'est le bouton right qui est utilisé.
Il y a un délégate pour les 3 boutons left/right/close.
On a une méthode show pour l'afficher ;)

** Custom Textview avec placeholder ** -> MJTextviewPlaceholder

*** Extensions ***
Il y a plusieurs extensions utilitaires.

## Infos concernant la création de nouveaux VC

On distingue 2 types de VC et de façon d'affichage dans la nouvelle version de l'app (V8)

-- Les VC fullscreen , on ajoute un navigation controller.
Et par commodité on va le faire hériter de BaseFullScreenNavViewController dans le storyboard pour afficher celui en fullscreen.

##

-- les VC affichés en modale (VC.presentVC ...).
-> par commodité on va les faire hériter de BaseFullscreenNavVC. Ceux-ci ont des borders radius custom, ainsi que la marge haute de l'écran.
Dans ces VC, on a une view container afin de gérer les borders radius + l'ajout de la top bar avec le bouton retour qui est une view custom MJNavBackView + le délégate pour le bouton retour que l'on devra implémenter.

On a un fichier BasePopViewController Xib afin de copier la structure du VC dans un storyboard ;)

Il faudra linker dans le storyboard:
La vue container -> ui_view_container
La vue Top bar MJNavBackView -> ui_top_view
Et la constraint top de la vue container -> ui_constraint_main_view_top

## Pager 
Concernant les pages avec des UIPageViewController, on a une extension qui permet de désactiver le swipe entre les pages. On n'a pas besoin d'utiliser de delegate/datasource.
Pour passer d'un VC à l'autre, on utlise la méthode avec direction qui peut être forward / reverse : setViewControllers([CONTROLLER], direction: ".forward / .reverse", animated: true)
Voir l'exemple dans profile -> detail other profile -> ReportUserPageViewController
+ storyboard.
##
