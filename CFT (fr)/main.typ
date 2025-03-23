#import "@preview/lovelace:0.3.0": *
#import "@preview/ilm:1.2.1": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/simplebnf:0.1.1": *
#import "@preview/syntree:0.2.0": *
#import "@preview/mannot:0.2.1": *
//#import "@preview/physica:0.9.4": *
#import "@preview/hane:0.1.0": board, stone
#import "@preview/fletcher:0.5.5": *
#import "@preview/cetz:0.3.2"
#import "@preview/wicked:0.1.1": wick

#let dd = math.upright("d")
#let corr(body) = $lr(angle.l #body angle.r)$

#let bra(f) = $lr(angle.l #f|)$
#let ket(f) = $lr(|#f angle.r)$

#let colMath(x, color) = text(fill: color)[$#x$]

#set text(
  lang: "fr"
)



#set math.equation(
  numbering: "1",
  supplement: none,
)

#show ref: it => {
  // provide custom reference for equations
  if it.element != none and it.element.func() == math.equation {
    // optional: wrap inside link, so whole label is linked
    link(it.target)[eq.~(#it)]
  } else {
    it
  }
}

// -- List and enumeration configuration --

#set list(indent: 1em)
#set enum(indent: 1em)

// -- Math boxes configuration --

#show: thmrules.with(qed-symbol: $square$)
#let colMath(x, color) = text(fill: color)[$#x$]

#let theorem = thmbox("theorem", "Théorème", fill: rgb("#eeffee")).with(numbering: none)
#let definition = thmbox("definition", "Définition", fill: rgb("#eeeeff")).with(numbering: none)
#let example = thmbox("example", "Exemple", titlefmt: strong, fill: rgb("eeffee")).with(numbering: none)
#let proof = thmbox("proof", "Preuve", titlefmt: strong).with(numbering: none)
#let remark = thmbox("remark", "Remarque", titlefmt: strong, fill: rgb(gray)).with(numbering: none)

// -- Paragraph configuration --

#set par(
  first-line-indent: 0em,
  justify: true
)



// -- other --

#let overset(a, b) = {
 math.attach(math.limits(a), t: b)
}

// -- Heading page --

#show: ilm.with(
  title: [Conformal Field Theory],
  author: "Aurélien Vandeweyer",
  date: datetime(year: 2025, month: 02, day: 13),
  abstract: [Ce rapport de stage consiste à la présentation du sujet de la théorie conforme des champs, sujet qui a été étudié durant le stage de première année de master à l'université de Mons, dans le département de Physique de l'Univers, Champs et Gravitation, supervisé par Evgeny Skvortsov. Le sujet est présenté d'une façon, je l'espère, pédagogique tel que j'aurais pu apprécier l'apprendre.],
  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false)
)

// -- Content of the document --

= Introduction et remerciments
Ce rapport de stage présente les connaissances acquises lors de mon stage de première année de Master de physique à l’UMons. L’objectif était de découvrir un nouveau domaine en physique, à savoir la théorie conforme des champs, avec un accent particulier sur les transitions de phase dans la finalité. Puisque le sujet était entièrement nouveau pour moi, ce document a été rédigé sous une forme pédagogique afin de synthétiser l’ensemble des apprentissages réalisés durant le stage. Les grands points couvert sont

 1. Première approche sur les transitions de phase ;
 2. Introduction à l'approche du groupe de renormalisation ;
 3. Étude des symétries conformes et leur application aux fonctions de corrélation ;
 4. L'_Operator Product Expansion_ et l'introduction à l'approche du bootstrap.

De nombreuses sources ont été utilisées pour étudier le sujet, elles sont reprises en fin de document. Le document en lui-même est majoritairement originale dans le sens où il s'agit d'expliquer ce qui a été appris de façon personnelle.

Je tiens à remercier M. Skvortsov pour son encadrement, ses explications et sa disponibilité !

#linebreak()

/*

*Plan de lecture du rapport de stage*

Je suis conscient que ce rapport de stage présente un nombre de page qui pourrait être considéré comme élevé. Les parties qui sont considérés comme étant les plus importantes du stage et de la théorie conforme des champs dans ce document sont les sections $(3.1)$, $(3.2)$, $(3.4)$, $(3.5)$, $(3.7)$, $(3.8)$, $(3.9)$ et $(3.10)$ (c'est-à-dire environs 40 pages). Le reste est présenté car le but du rapport est rendre compte de ce que j'ai fait durant le stage (et cela a pris du temps et demandé du travail, également).

#linebreak()

*/

== Faits généraux sur les transitions de phase
Les transitions de phase représentent des changements importants dans l’état d’un système, qui se traduisent par une modification qualitative de ses propriétés macroscopiques. Ces phénomènes, que l’on rencontre dans divers domaines allant de la physique des solides à la thermodynamique des fluides, offrent un terrain d’étude plutôt large et, même si étudié depuis longtemps, présentent encore un certain nombre de questions de grand intérêt pour la science, en particulier lorsqu’on s’intéresse aux points critiques et aux phénomènes d’universalité.

À l’approche d’un point critique, le système affiche des comportements singuliers : certaines quantités, comme la longueur de corrélation ou la susceptibilité, divergent ou présentent des variations non analytiques. Par exemple, dans une transition continue (ou du second ordre), la divergence de la longueur de corrélation implique que le système devient _scale invariant_ : aucune longueur ou ordre de grandeur caractéristique ne domine, et les fluctuations locales se propagent à toutes les échelles. Ces "absence d’échelle" conduisent à des lois de puissance décrivant le comportement près du point critique, et dont les coefficients – les exposants critiques – se révèlent être identiques pour des systèmes très différents.

Ce phénomène d’universalité signifie que des systèmes physiquement distincts, possédant des symétries et dimensions identiques, partagent les mêmes exposants critiques et fonctions de corrélation. Par exemple, un liquide en équilibre près de son point critique et un aimant proche de sa température de Curie présentent des comportements similaires à grande échelle, malgré leurs différences microscopiques. Cette propriété a grandement contribué à la compréhension de la physique statistique (et de la théorie (quantique) des champs !), en permettant de regrouper les systèmes en classes d’universalité qui dépendent principalement de quelques paramètres essentiels (la dimension spatiale, la symétrie du paramètre d’ordre, etc.) plutôt que des détails microscopiques du système.

L’explication théorique de cette universalité est encore un sujet de recherche, traditionnellement passant par l’approche du groupe de renormalisation, qui permet d’étudier comment les interactions à différentes échelles s’agrègent, des méthodes numériques ou analytiques plus modernes ont vue le jour pour essayer d'en apprendre plus sur les exposants critiques, comme l'approche par théorie des champs conforme par le "bootstrap", comme cela sera abordé.

Enfin, et comme c'est souvent le cas en science, et particulièrement en physique, l’étude des points critiques a des répercussions bien au-delà de la physique des systèmes macroscopiques. Les idées d’échelle, d’invariance et de renormalisation trouvent des applications en physique des particules, en cosmologie et même dans certains modèles de phénomènes complexes dans les systèmes biologiques et sociaux. Ainsi, la compréhension des transitions de phase, et en particulier des points critiques et de l’universalité, représente un pont entre des phénomènes apparemment disparates, mettant en lumière des régularités fondamentales qui s’imposent à travers une multitude de systèmes.

En conclusion de cette première section, le sujet des points critiques et des transitions de phase est important et n'est pas encore entièrement compris. Son étude est donc d'intérêt.

= Le groupe de renormalisation

L'invariance d'échelle est un concept très puissant en physique. Cela consiste à analyser un système à partir d'une échelle microscopique, puis à "dézoomer" progressivement pour observer le comportement du système à des échelles plus grandes. Le _groupe de renormalisation_ (RG) est la procédure mathématique qui permet d'effectuer ce changement d'échelle de manière progressive et contrôlée, en éliminant graduellement les détails trop fins pour être pertinents à des échelles plus larges.

#example[
  Dans un morceau de métal, on ne se préoccupe pas du comportement individuel de chaque électron (si tant est que cela ait un sens), mais plutôt de propriétés globales comme sa conductivité ou son magnétisme.
]

Avant d'aller plus loin, précisons que le "groupe" de renormalisation n'a rien à voir avec la théorie des groupes. On parle de groupe car cela reflète bien l'idée de "regrouper" comme nous le verrons juste après. Précisons aussi que la "méthode" du groupe de renormalisation n'est pas une recette à appliquer génériquement (il faut d'ailleurs l'appliquer avec précaution pour ne pas changer la nature ou la géométrie du système considéré).

Nous allons introduire le concept au travers de divers exemples, discrets et continus.

== Chaîne de spins de Ising en 1D
Considérons une chaîne unidimensionnelle composée de $N$ spins avec une constante de couplage $J$ entre chaque voisin.

#v(1em)
#figure(
  board("
    +
    . X . X . X . X . X . X . X . X . X . X . X .
    +
  "),
  caption: [Chaîne de spins unidimensionnelle]
)
#v(1em)

Le Hamiltonien associé est $ H = -sum_i J sigma_i sigma_(i + 1). $ Plutôt que de conserver tout les $N$ spins, nous pourrions, par exemple, uniquement considérer la moitié de ces spins sur la chaîne et (pour un large $N$) toujours avoir une description du système raisonnablement précise en décrivant les spins restant en terme d'une nouvelle constante de couplage, $J'$, qui tient compte du fait que nous avons retirer une partie des spins. On parlera de "décimation" : en générale nous allons sommer (ou intégrer) une certaine fraction de spins à chaque étape, laissant derrière nous un système avec moins de spins qu'au départ mais compensé avec une constante de couplage "mise à jour" :

#v(1em)
#figure(
  board("
    +
    . X . X . X . X . X . X . X . X . X . X . X . X . X . 
    +
  "),
  caption: [$H = -sum_i J sigma_i sigma_(i + 1)$],
  numbering: none
)
#v(1em)

#v(1em)
#figure(
  board("
    +
    . X . O . X . O . X . O . X . O . X . O . X . O . X .
    +
  "),
  caption: [$H = -sum_i J' sigma_(2i) sigma_(2(i + 1))$],
  numbering: none
)
#v(1em)

#v(1em)
#figure(
  board("
    +
    . X . O . O . O . X . O . O . O . X . O . O . O . X .
    +
  "),
  caption: [$H = -sum_i J'' sigma_(4i) sigma_(4(i + 1))$],
  numbering: none
)
#v(1em)

Et ainsi de suite...

Soyons plus concret et utilisons une chaîne de spin à une température non-nulle, avec le Hamiltonien d'origine, la fonction de partition prend donc la forme suivante :

$
  z = sum_(markul({sigma_i = plus.minus 1}, padding: #.15em, tag: #<µetat>, color: #red)) e^(-beta H) = sum_({sigma_i = plus.minus 1}) exp(beta J sum_i sigma_i sigma_(i + 1)).

  #annot(<µetat>, yshift: 1.5em, pos: right)[Un micro-état correspond à un spin up ou down]
$
#v(1.5em)

Le but est de prendre la somme sur la moitié des spins du système. Pour se faire, on peut simplement considérer sauter un spin sur deux, comme cela a été suggéré plus haut (ce qui pourrait se faire mathématiquement en associant un numéro à chaque spin et en sommant par exemple uniquement sur les spins de numéro impaire). La fonction de partition _attendue_ doit donc être de la forme suivante :

$
  z = sum_({sigma_i = plus.minus 1}) exp(beta J' sum_(2i) sigma_(2i) sigma_(2(i + 1))).
$ <expected1>

En effet il s'agit simplement de la fonction de partition de départ, mais où l'on a explicitement sauté une étape sur deux dans la somme et avons modifié la constante de couplage en conséquence. Voyons explicitement ce que cela nous donnerait pour une chaîne de trois spins si l'on procédait à cette décimation :

$
  z &= sum_({sigma_i = plus.minus 1})^(i = 0, 2) sum_({sigma_1}) exp(beta J (sigma_0 sigma_1 + sigma_1 sigma_2)) \
    &= sum_({sigma_i = plus.minus 1})^(i = 0, 2) [ e^(beta J (sigma_0 + sigma_2)) + e^(-beta J (sigma_0 sigma_2)) ] \
    &= sum_({sigma_i = plus.minus 1})^(i = 0, 2) 2 cosh[beta J (sigma_0 + sigma_2)].
$ <z1>

En comparant avec #ref(<expected1>), nous ne sommes manifestement pas arrivé au résultat souhaité, mais en revanche, par comparaison, cela nous donnerait une relation entre la constante de couplage $J$ et $J'$, et c'est ce que l'on cherche au final ! Pour $N$ spins à la place de trois, #ref(<z1>) se réécrit simplement comme

$
  z = sum_({sigma_i = plus.minus 1}) product_i 2 cos[beta J (sigma_(2i) + sigma_(2(i + 1)))].
$

Comparons alors cette expression avec #ref(<expected1>),

$
  sum_({sigma_i}) product_i 2 & cosh[beta J (sigma_(2i) + sigma_(2(i + 1)))] \

          &overset(=, !) sum_({sigma_i}) e^(beta J' sum_i sigma_(2i) sigma_(2(i + 1))) \
          &equiv sum_({sigma_i}) product_i e^(beta J' sigma_(2i) sigma_(2(i + 1))).
$

Pour comparer le membre de gauche et le membre de droite, une façon de faire consiste à étudier les pondérations pour chaque paire $(sigma_i, sigma_(i + 1))$. Les spins $sigma_i$ et $sigma_(i + 1)$ peuvent prendre les valeurs $plus.minus 1$. Si $sigma_i = sigma_(i + 1)$, alors $sigma_i + sigma_(i + 1) = plus.minus 2$ et la contribution du terme en $cosh$ devient $ 2 cosh(beta J (plus.minus 2)) = 2 cosh(2 beta J). $ Si $sigma_i = -sigma_(i + 1)$, alors $sigma_i + sigma_(i + 1) = 0$ et la contribution du terme en $cosh$ devient $ 2cosh(beta J dot 0) = 2 cosh(0) = 2. $ Du côté droit de l'égalité maintenant, si $sigma_i = sigma_(i + 1)$, alors $sigma_i sigma_(i + 1) = +1$ et la contribution dans l'exponentielle devient $ exp(beta J' sigma_i sigma_(i + 1)) = exp(beta J'). $ Si $sigma_i = -sigma_(i + 1)$, alors $sigma_i sigma_(i + 1) = -1$ et la contribution dans l'exponentielle devient $ exp(beta J' sigma_i sigma_(i + 1)) = exp(-beta J'). $ Pour que les deux expressions soient identiques configuration par configuration, on compare alors les rapports de poids entre la configuration parallèle et la configuration antiparallèle :

 - *Côté gauche* $ frac("poids"(+1), "poids"(-1)) = frac(2 cosh(2 beta J), 2) = cosh(2 beta J) $
 - *Côté droit* $ frac("poids"(+1), "poids"(-1)) = frac(exp(beta J'), exp(-beta J')) = exp(2 beta J') $

on déduit donc la condition suivante :

$
  cosh(2 beta J) = exp(2 beta J') space <==> space 2 beta J' = log[cosh(2 beta J)]
$

autrement dit,

$
  markrect(J' = 1/(2 beta) log[cosh(2 beta J)], padding: #.5em)
$

Nous avons donc obtenu une expression pour la constante de couplage mise à échelle, $J'$, qui décrit physiquement les interactions entre les spins restants après une étape de décimation. Dès lors, pour un $J$ initial donné (qui correspond au système encore non re-normalisé), nous avons une relation récursive que nous pouvons appliquer un certain nombre de fois et qui correspondra, par construction, à cette procédure de renormalisation où, à chaque étape, nous dézoomons un peu plus et nous nous débarrassons des détails microscopiques du système !

Que se passe-t-il lorsqu'on itère suffisamment de fois ? Supposons que le système initial est tel que $J = 1$ et que la température, constante, est élevée (c'est-à-dire que $beta$ est très petit). Alors, $ cosh(x) = 1 + x^2/2! + x^4/4! + cal(O)(x^6) $ ce qui, dans notre cas, nous donne $ cosh(2 beta J) approx 1 + 2 (beta J)^2. $ Ensuite, $ log[cosh(2 beta J)] approx log(1 + 2 (beta J)^2) approx 2 (beta J)^2 $ où on a utilisé $log(1 + x) approx x$ pour $x$ suffisamment petit. Nous substituons ce résultat dans notre formule pour $J'$ et trouvons alors la nouvelle relation $ J' = 1/(2 beta) log[cosh(2 beta J)] approx 1/(2 beta) [2 (beta J)^2] = beta J^2. $ Donc, quand la température est suffisamment élevée, et donc que $beta$ est suffisamment petit, on obtient un nouveau couplage $J' approx beta J^2$ qui est _plus petit_ que $J$ (rappelons que $0 < J <= 1$ et que $beta < 1$). Autrement dit, plus on "dézoome" plus la constante de couplage tend vers zéro, nous pouvons en conclure que $J$ est une variable inutile à la description des propriétés à grande échelle du système ! Nous pouvons aussi implémenter numériquement la fonction récursive précédente, après quelques itérations on obtient le tableau suivant :

#align(center)[
  #table(
      columns: (auto, auto),
      align: (left, left),
      table.header([$n$], [$J_n$]),
  
      [`0`], [`1`],
      [`1`], [`0.433781`],
      [`2`], [`0.0912725`],
      [`3`], [`0.00415956`],
      [`4`], [`8.65094e-06`],
      [`5`], [`3.74194e-11`]
  )
]

Il ne suffit que de quelques itérations pour se rendre compte que, effectivement, la constante de couplage devient irrelevante aux échelles plus grandes du système. Physiquement, cela signifie que les fluctuations thermiques dominent et que les interactions spin-spin ne contribuent pas aux propriétés magnétiques du système. Pour une température plus petite, la tendance est la même mais la convergence est plus lente. Dans cet exemple particulier, cela signifie que le système est un paramagnétique et qu'il n'y a pas de transition de phase possible.

== Chaîne de spins en 1D avec un champs magnétique externe
Nous n'allons pas autant entrer ici dans les détails que précédemment mais allons illustrer une configuration légèrement différente qui présente une transition de phase que l'on va pouvoir identifier grâce au groupe de renormalisation. Considérons la même chaîne de spins qu'avant, avec la même constante de couplage $J$ entre chaque spin, mais cette fois on ajoute un champs magnétique externe $h$ transverse. Le Hamiltonien précédent s'exprime alors ici comme

$
  H = -sum_(angle.l i, j angle.r) J sigma^x_i sigma^x_j - sum_i h sigma^z_i
$

Nous allons appliquer la méthode du RG avec, cette fois-ci, une forme de décimation similaire mais qui capture mieux la physique du système et qui est plus simple à mettre en place étant donné la situation. Au lieu de compter la contribution d'un spin sur deux, nous allons compter la contribution de paires de spins, autrement dit nous formons un "gros spin" à partir de deux spins voisins et choisissons d'attribuer à ce dernier la plus faible énergie des deux spins composites afin de conserver l'aspect d'un système à faible énergie (si l'on faisait l'inverse, à chaque étape de la décimation, le système gagnerait potentiellement en énergie, ce qui n'est pas représentatif du système). Cette méthode de décimation porte le nom de "blocs de spins". Nous n'allons pas donner la dérivation de la formule récursive mais uniquement donné le résultat final, qui se compose en fait d'une relation pour la constante de couplage et d'une relation pour le champs magnétique externe :

$
  & J' = frac(J^2, sqrt(J^2 + h^2)), \
  & h' = 2h sqrt(1/2 + frac(J, 2sqrt(J^2 + h^2))) sqrt(1/2 - frac(J, 2sqrt(J^2 + h^2))).
$

Nous pouvons exprimer le ratio $h\/J$ et étudier numériquement ce qu'il se passe :

 - Pour un ratio initial $h\/J > 1$, après itérations, le ratio diverge et devient infini. Cela nous apprend que $J$ est une variable moins relevante que $h$. Physiquement, le matériau se trouve dans une phase paramagnétique ;
 - Pour un ratio initial $h\/J < 1$, on trouve que le ratio converge vers zéro, ce qui indique que $J$ est une variable plus relevant que $h$. Le matériau est dans une phase ferromagnétique.
 - Pour un ratio initial $h\/J = 1$, on constante que le ratio n'évolue pas et reste à $1$.

Autrement dit, cela signifie que le système présente une transition de phase ! Le fait qu'un paramètre du groupe de renormalisation (ici, le ratio $h\/J$) reste constant tout au long de la procédure reflète l'invariance sous changement d'échelle du système proche d'un point critique, et nous remarquons de plus qu'il existe deux tendances distinctes de ce paramètre "avant" et "après" ce point critique, ce qui illustre bien l'existence de différentes phases pour ce système en particulier.

== Modèle de Ising en 2D (idée)
Comment appliquer le groupe de renormalisation dans un modèle en 2d, plus réaliste ? L'idée ne change pas : on veut trouver un moyen de "dézoomer". Nous n'allons ici entrer dans aucun détail, mais seulement illustrer qu'un choix mal avisé de décimation conduit à changer la géométrie du système physique, ce que l'on veut éviter.

#v(1em)
#figure(
  board("
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
    . X . X . X . X . X . X . X . X . X .
    . . . . . . . . . . . . . . . . . . .
  "),
  caption: [Configuration bidimensionnelle]
)
#v(1em)

Si nous appliquons la même méthode de décimation que pour la chaîne unidimensionnelle où l'on saute un spin sur deux, alors on se retrouve avec une configuration qui ne respecte plus la géométrie du système, en effet nous nous retrouverions avec une collection de chaînes quasiment découplées, comme illustré ci-dessous :

#v(1em)
#figure(
  board("
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
  "),
  caption: [Configuration où l'on retire un spin sur deux : on se retrouve avec des chaînes et les couplages entre les spins ne sont plus très claires]
)
#v(1em)

Nous pourrions essayer une variante de cette méthode de décimation, où on enlève un spin sur deux sur une rangée, puis de même sur la rangée suivante mais de façon décalée :

#v(1em)
#figure(
  board("
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . O . X . O . X . O . X . O . X . O .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . O . X . O . X . O . X . O . X . O .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . O . X . O . X . O . X . O . X . O .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .
    . O . X . O . X . O . X . O . X . O .
    . . . . . . . . . . . . . . . . . . .
    . X . O . X . O . X . O . X . O . X .
    . . . . . . . . . . . . . . . . . . .

  "),
  caption: [Configuration où l'on décale la décimation à chaque rangée]
)
#v(1em)

Cette configuration semble préserver la géométrie du système ! Cependant, un œil attentif se rendra compte que cette configuration revient à effectuer une rotation du système initiale où chaque spin est distant d'un facteur $r -> sqrt(2) r$, autrement dit, cette méthode de décimation change encore une fois la géométrie du réseau de spins.

La conclusion à cela est la suivante : choisir une méthode de décimation en $d >= 2$ doit se faire avec soin afin de ne pas altérer la géométrie du réseau.

== Groupe de renormalisation pour un système continu -- méthode de Wilson
Jusqu'à présent, nous avons présenté les idées du groupe de renormalisation (et avons complètement déterminé l'équation pour le cas le plus simple) dans des systèmes en réseaux, discrets. Nous allons maintenant nous intéressé au cas continu. La méthode est essentiellement la même qu'avant, mais à la place de se mettre dans un espace réel on démarre avec un espace d'impulsions (c'est la procédure de renormalisation de _Wilson_). Cette façon de procéder requière une description en champs du système, en particulier la fonction de partition s'exprime

$
  z = alpha integral [cal(D) phi] space e^(-S[phi])
$

où $alpha$ est un facteur de normalisation.

#remark[
  La mesure fonctionnelle, souvent notée $[cal(D) phi]$, signifie en gros, que

  $
    integral [cal(D) phi] space F[phi] equiv integral_RR ... integral_RR product_x dd phi(x) space F[phi].
  $
]

L'idée dans l'approche de Wilson est la suivante : nous "intégrons la physique à haute énergie" (c'est-à-dire que l'on se "débarrasse" des "modes rapides", c'est-à-dire des fonctions à courte longueur d'onde) et nous gardons uniquement le comportement à large longueur d'onde ("modes lents"), qui décrivent donc le comportement du système aux échelles plus larges. Pour se faire, une approche standard consiste à exprimer $phi$ comme une somme de modes lents et de modes rapides ou, de façon équivalente, comme une somme de modes à haute ou basse énergie. On rencontrera les notations suivantes :

#v(1em)
$
  phi = mark(phi_<, tag: #<l>, padding: #.2em, color: #red) space + space mark(phi_>, tag: #<h>, padding: #.2em, color: #blue) space.en " ou " space.en phi = phi_"low" + phi_"high"

  #annot(<l>, pos: left, yshift: 1em)[Mode à courte longueur d'onde]
  #annot(<h>, pos: right + top, yshift: 1em)[Mode à grande longueur d'onde]
$
#v(1em)

qui est souvent abrégé par $phi_l$ et $phi_h$. Cela nous donnera la fonction de partition suivante :

$
  z = integral [cal(D) phi_<] [cal(D) phi_>] space e^(-S[phi_<, phi_>]).
$

L'action $S$ prend également une forme adaptée :

$
  S[phi_<, phi_>] = S_0[phi_<] + S_1[phi_>] + delta S[phi_<, phi_>]
$

où le dernier terme correspond aux modes mixtes (qui dépendant à la fois des modes faibles et des modes rapides). La procédure de Wilson peut être visualisée comme suit : on commence avec un système sans aucune altération, ensuite, on retire les modes à haute fréquence, puis enfin on "dézoome" en remettant à l'échelle les impulsions, comme illustré très schématiquement avec l'image de l'écureuil ci-dessous :

#align(center)[
  #table(
    columns: (1fr, 1fr, 1fr),
  
    image("sq1.png"), image("sq2.png"), image("sq3.png"),
    [On considère l'écureuil dans tout ses aspects], [On se débarrasse des hautes fréquences de l'image
    
    (image flou)], [on dézoome pour voir le système sous une échelle plus large]
  )
]

Comme cette vision imagée le suggère, cette méthode nous permettra d’établir comment les paramètres évoluent sous rescaling après avoir enlevé les informations microscopiques. Remarquons que l'écureuil garde _la même forme_ tout au long du processus.

=== Action gaussienne
Nous allons illustrer la procédure de renormalisation de Wilson via un exemple simple où l'on va considérer une action quadratique (aussi parfois dite "gaussienne") pour un champs scalaire libre $phi(k)$ dans l'espace $k$. L'action s'exprime

$
  S[phi] = 1/2 integral_(abs(k) < Lambda) dd^d k space (k^2 + r) abs(phi(k))^2
$

où $r$ est le terme de masse et $Lambda$ borne la région de l'espace $k$ intégrée. En terme physiques, cette action peut être vue comme l’approximation quadratique d’un modèle de Ginzburg-Landau pour une transition de phase, mais on la retrouve aussi dans d'autres modèles. On commence par séparer $phi(k)$ en "modes lents" $phi_<$ et en "modes rapides" $phi_>$, plus spécifiquement,

 - les *modes lents* $phi_<$ sont tels que $abs(k) < Lambda\/b$ ;
 - les *modes rapides* $phi_>$ sont tels que $Lambda\/b < abs(k) < Lambda$

où $b$ est un facteur de mise à l'échelle (nous y reviendrons après). Nous pouvons alors exprimer le champs $phi$ comme une fonction définie par morceaux, 

$
  phi(k) =
    cases(
      phi_<(k) & " si " abs(k) < Lambda\/b,
      phi_>(k) & " si " Lambda\/b < abs(k) < Lambda.
    )
$

Dans ce cas, l'action prend la forme suivante :

$
  S[phi] &= 1/2 (integral_(abs(k) < Lambda\/b) dd^d k space (k^2 + r) abs(phi_<(k))^2 + integral_(Lambda\/b < abs(k) < Lambda) dd^d k space (k^2 + r) abs(phi_>(k))^2) \
         &approx 1/2 (integral_(abs(k) < Lambda\/b) dd^d k space (k^2 + r) abs(phi_<(k))^2 + cancel(integral_(Lambda\/b < abs(k) < Lambda) dd^d k space (k^2 + r) abs(phi_>(k))^2)) \
         &approx 1/2 (integral_(abs(k) < Lambda\/b) dd^d k space (k^2 + r) abs(phi_<(k))^2 \
         &=: S_"eff"[phi_<]
$

où nous avons donc "éliminé" les modes rapides.

#remark[
  En réalité, bien que le résultat soit le même (à une constante près), simplement "barrer" le second terme n'est pas très rigoureux. Lorsque l'on considère la fonction de partition, $ z = integral [cal(D) phi] space e^(-S[phi]), $ l'intégrale sur $phi_>$ est une gaussienne indépendante de $phi_<$ et se factorise en produisant simplement une constante multiplicative (un facteur $exp(-1\/2 tr(k^2 + r))$ pour être précis), mais afin de ne pas entrer dans des détails de calculs nous empruntons un chemin plus court.
]

En se souvenant de l'image de l'écureuil, nous voulons revenir à une action qui reprend une forme similaire à l'originale. Pour s'en sortir, et cela introduit naturellement un _rescaling_, on pose $tilde(k) := b k$ et donc la borne $abs(k) < Lambda\/b$ devient $abs(tilde(k)) < Lambda$. Le mode lent $phi_<$ doit également être rescale pour "regagner en résolution" (comme la troisième image de l'écureuil), on doit donc poser un $tilde(phi)$ de la forme suivante :

$
  tilde(phi)(tilde(k)) := b^(-Delta) phi_<(k = tilde(k)\/b)
$<z2>

où $Delta := (d - 2)\/2$ est un terme introduit pour des raisons de dimensionnalités (selon la convention on prend un signe différent devant $Delta$). Maintenant, l'action effective se réécrit

$
  S_"eff"[phi_<] &= integral_(abs(tilde(k)) < Lambda) (b^(-d) dd^d tilde(k)) space (frac(tilde(k)^2, b^2) + r) abs(phi_<(tilde(k) \/ b))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space b^(-d + 2) (tilde(k)^2 + b^2 r) abs(phi_<(tilde(k) \/ b))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space b^(-d + 2) (tilde(k)^2 + b^2 r) abs(b^(+Delta) phi(tilde(k)))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space b^(-d + 2 + 2 Delta) (tilde(k)^2 + b^2 r) abs(phi(tilde(k)))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space (tilde(k)^2 + r') abs(tilde(phi)(tilde(k)))^2
$

où on passe de la première à la seconde ligne en factorisant $b$, de la seconde à la troisième en introduisant #ref(<z2>) et où, à la dernière ligne, $ -d + 2 + 2 Delta = -d + 2 + cancel(2)((d - 2)/cancel(2)) = 0, $ et où nous avons posé $ r' := b^2 r. $<r> Nous avons donc effectivement réécrit $S_"eff"$ sous la même forme que l'action d'origine. Récapitulons ce que nous avons fait :

 1. Nous sommes parti d'une action pour le champs $phi$ ;
 2. Nous avons décomposé $phi$ selon des "modes lents" et des "modes rapides" ;
 3. Nous nous sommes débarrassé des modes rapides ;
 4. Nous sommes revenu à une action ayant la même forme qu'à l'origine en "dézoomant".

L'image que nous avons donné avec l'écureuil n'était donc vraiment pas trompeuse, nous avons fait exactement la même chose ici. Que nous restes-t-il désormais ? Le point important qui a émergé de cette procédure est la redéfinition (la _renormalisation_) du paramètre de masse #ref(<r>). Comme nous l'avons vu précédemment avec les modèles de Ising discrets, ces paramètres qui apparaissent durant la renormalisation caractérisent à quel point le système y est sensible aux grandes échelles. Dans le cas présent, puisque nous sommes dans un cas continu, nous pouvons aller plus loin : ces équations récursives s'apparentent à des équations différentielles étant donné une procédure de décimation infinitésimale. Généralement, on pose

$
  b = e^(dd l) approx 1 + dd l
$

où $dd l$ est une "étape infinitésimale de décimation". On écrit alors

$
  r' = b^2 r space.quad <==> space.quad r' = e^(2 dd l) r approx (1 + 2 dd l) r
$

et, après quelques manipulations, on arrive à l'_équation de flux de groupe de renormalisation_

#v(0.5em)
$
  markrect(frac(dd r, dd l) = 2r, padding: #.5em)
$
#v(0.5em)

Cette équation, comme pour les cas discrets, nous indique comment le terme de masse $r$ change au fur et à mesure que l'on "dézoome" pour regarder le système à des échelles plus grandes. Cette équation présente le flux associé à la figure #ref(<flux>).

#figure(
  image("RG_wilson.png"),
  caption: [Graphe du flux de l'équation dérivée par la procédure de renormalisation de Wilson]
)<flux>

Analytiquement (mais on le voit aussi sur le graphe #ref(<flux>)), si $r_"initial" > 0$ alors $r(l) -> infinity$, si $r_"initial" < 0$ alors $r(l) -> -infinity$ et si $r_"initial" = 0$ alors c'est un point fixe, mais instable (la moindre perturbation fait diverger $r(l)$), ce qui n'indique pas l'existence de transition de phase (les fluctuations aléatoires du systèmes ne permettraient pas au point fixe de rester fixe et le ferraient diverger). Dans une théorie avec interaction (typiquement $phi^4$) alors la procédure nous amènerait effectivement un point fixe stable, signe d'une transition de phase.

#line()
#v(1.5em)

Pour conclure sur l'introduction donnée sur la méthode du groupe de renormalisation, nous avons vu qu'il s'agit d'une procédure puissante basée sur l'idée importante qu'un système doit être _invariant sous remise à l'échelle_. En appliquant ce principe au travers de quelques exemples discrets et continus avec des procédures adaptées, nous avons mis en évidence comment les propriétés des systèmes évoluent lorsqu'on les regarde sous des échelles plus grandes, ce qui nous a d'ailleurs permis d'étudier l'existence de transitions de phases. Il y a bien sûr beaucoup plus à en dire, mais cela sort du cadre de ce document.





#pagebreak()





= Théorie conforme des champs
Comme nous l'avons mentionné et vu plus tôt, il semble que les symétries sous dilatation, ou remise à l'échelle, jouent un rôle plutôt important. Comme toujours en physique, lorsqu'il est question de symétries, il convient de s'y intéresser plus formellement avec l’œil de la théorie des groupes. La prochaine section est ainsi consacrée au groupe conforme et à son algèbre, qui fournissent le cadre mathématique approprié pour comprendre ces symétries. Nous commencerons par définir clairement ce qu'il est entendu par "transformation conforme", et à partir de là nous pourrons développer le reste.

#remark[
  Les symétries conforment incluent la symétrie sous dilatation : l'invariance conforme implique l'invariance d'échelle, mais l'inverse n'est pas vrai en général.
]

Notons également un élément important : l'étude d'une théorie conforme est différente selon la dimension de la théorie, en particulier il est commode de distinguer le cas en dimension $d = 2$ du cas plus général $d >= 3$, en effet, comme nous allons le voir, une théorie conforme en deux dimension (comme la théorie des cordes) possède une algèbre de dimension infinie, tandis que, comme nous le verrons, une CFT en $d >= 3$ présente une algèbre de dimension finie. Il s'en suit que l'étude des théories conformes en $d >= 3$ dimensions est plus simple et c'est celles-ci qui nous intéresserons dans la suite. Il existe également des CFT unidimensionnelles, mais nous ne ferrons que les mentionner.

Dans la plupart des cas qui vont nous intéresser, nous considérerons également un espace-temps plat, donc $g_(mu nu) = eta_(mu nu)$. L'étude d'une CFT où la métrique n'est pas plate ou n'est pas suffisamment simple ne semble en effet pas pertinente : les cas physiques dont les symétries conformes sont d'intérêt standard et principale ne font pas intervenir de gravité (un contre exemple important est la correspondance AdS/CFT) et, si c'était le cas, les solutions analytiques seraient probablement trop difficiles à trouver, pour autant qu'il en existe.

== Transformation conforme
Nous définirons une _transformation conforme_ comme un certain changement de coordonnées, un difféomorphisme, $x^mu -> x'^mu (x^mu)$ laissant la métrique invariante à une fonction de la position près que nous appellerons _le facteur d'échelle_. Afin que la nouvelle métrique soit bien définie, positive et non nulle, la façon la plus naturelle de formuler cela consiste à écrire

#v(1em)
$
  cases(
    x^mu -> x'^mu (x^mu),
    g_(mu nu)(x) -> g'_(mu nu)(x') = markrect(e^(sigma(x)), tag: #<scale1>, color: #red, padding: #.2em) space g_(mu nu)(x)\,
  )

  #annot(<scale1>, pos: top, yshift: 1em)[facteur d'échelle explicitement #linebreak() positif et non nul]
$

mais il est courant de voir d'autres conventions d'écriture, comme

#v(1em)
$
  cases(
    x^mu -> x'^mu (x^mu),
    g_(mu nu)(x) -> g'_(mu nu)(x') = markrect(Omega(x)^2, tag: #<scale1>, color: #red, padding: #.2em) space g_(mu nu)(x)\,
  )

  #annot(<scale1>, pos: top, yshift: 1em)[facteur d'échelle explicitement #linebreak() positif]
$

ou encore

$
  cases(
    x^mu -> x'^mu (x^mu),
    g_(mu nu)(x) -> g'_(mu nu)(x') = markrect(Lambda(x), tag: #<scale1>, color: #red, padding: #.2em) space g_(mu nu)(x).
  )

  #annot(<scale1>, pos: top, yshift: 1em)[facteur d'échelle]
$

En fonction de ce qui est plus commode, nous utiliserons l'une ou l'autre de ses conventions. Notons que si le facteur d'échelle se réduit à la constante $1$, alors cela signifie que la transformation conserve intégralement la structure de la métrique de l'espace-temps, hors nous savons que l'ensemble des transformations qui laissent la métrique de Minkowski invariante forment le _groupe de Poincaré_, qui inclus les transformations de Lorentz. Autrement dit, nous pouvons déjà constater que le groupe des transformations conformes, le _groupe conforme_, contient le groupe de Poincaré. Nous utiliserons ce fait dans la suite, nous nous attendons en effet à revoir émerger les générateurs associés que nous connaissons déjà.

#remark[
  Une transformation conforme et une transformation de Weyl sont deux transformations différentes : une transformation de Weyl n'est pas un changement de coordonnées, mais simplement un rescaling de la métrique.
]

Il découle de la définition qu'une transformation conforme ne préserve pas forcément les distances, mais préservera toujours localement les angles : si deux courbes s'intersectent à un angle $alpha$ alors, après transformation conforme, elles s’intersecteront toujours à un angle $alpha$. Le terme "conforme" est issu du latin "conformalis" qui signifie "de même forme", en effet une transformation conforme préserve la "forme" locale des figures, dans le sens où elle préserve les angles entre les courbes qui se croisent. Même si les distances et les aires peuvent être modifiées, la "conformité" des angles est maintenue.

#example[
  Un exemple simple de transformation conforme est une _dilatation_ (changement d'échelle) dans un espace plat de dimension 2. Considérons la métrique $ dd s^2 = dd x^2 + dd y^2 $ et appliquons la transformation $ x -> x' = lambda x, space.quad y -> y' = lambda y $ où $lambda > 0$ est une constante. On trouve alors que
  $
    dd s'^2 &= (dd x')^2 + (dd y')^2 \
            &= lambda^2 dd x^2 + lambda^2 dd y^2 \
            &= lambda^2 (dd x^2 + dd y^2)
  $
  autrement dit, $ g'_(mu nu)(x') = lambda^2 g_(mu nu)(x). $ Il s'agit bien d'une transformation conforme, c'est un exemple simple mais important.
]

Trouver un exemple qui reste relativement simple n'est pas évident, mais cela ne signifie pas qu'il n'en existe pas, en réalité ce sont surtout les résultats qui découleront par la suite des propriétés de ces transformations qui seront d'intérêt. En attendant, nous pouvons quand même fournir un exemple moins trivial qui illustre la définition de transformation conforme.

#example[
  Considérons toujours une métrique euclidienne $ dd s^2 = dd x^2 + dd y^2 $ et considérons la transformation de coordonnées suivante :
  $
    x' = x^2 - y^2, space.quad y' = 2 x y.
  $
  Pour calculer $dd s' = dd x'^2 + dd y'^2$, on calcul les différentielles suivantes :
  $
    dd x' = 2x dd x - 2y dd y, space.quad dd y' = 2x dd y + 2y dd x
  $
  et donc
  $
    & (dd x')^2 = (2x dd x - 2y dd y)^2 = 4(x dd x - y dd y)^2 \
    & (dd y')^2 = (2x dd y + 2y dd x)^2 = 4(x dd y + y dd x)^2
  $
  ce qui donne, après calcul et réarrangement des termes,
  $
    dd s'^2 &= (dd x')^2 + (dd y')^2 \
            &= 4(x^2 + y^2)(dd x^2 + dd y^2).
  $
  Autrement dit, on a bien une transformation des coordonnées qui est telle que la nouvelle métrique soit proportionnelle à l'ancienne à une fonction des coordonnées près. Plus explicitement,
  $
    dd s'^2 = Omega(x, y)^2 dd s^2 space.quad " avec " space.quad Omega(x, y) = 2 sqrt(x^2 + y^2).
  $
]

== Dérivation du groupe et de l'algèbre conformes
Dans un premier temps, nous allons travailler avec une transformation infinitésimale arbitraire que l'on va ensuite contraindre à être conforme de façon à obtenir les relations utiles pour la suite. Notre démarche est inspirée par. Considérons donc une transformation infinitésimale au premier ordre d'une coordonnée $x^mu$, $ x'^mu = x^mu + epsilon^mu (x) + cal(O)(epsilon^2) $<arb1> et rappelons que pour un changement de coordonnée $x -> x'$ arbitraire, la métrique se transforme suivant

$
  eta'_(mu nu)(x') = eta_(rho sigma) frac(partial x'^rho, partial x^mu)frac(partial x'^sigma, partial x^nu).
$<arb2>

En insérant #ref(<arb1>) dans #ref(<arb2>) et gardant tout au premier ordre, on trouve

$
  eta_(rho sigma)frac(partial x'^rho, partial x^mu)frac(partial x'^sigma, partial x^nu)
      &= eta_(rho sigma)frac(partial, partial x^mu)(x^rho + epsilon^rho (x) + cal(O)(epsilon^2))frac(partial, partial x^nu)(x^sigma + epsilon^sigma (x) + cal(O)(epsilon^2)) \
      &= eta_(rho sigma)(delta^rho_mu delta^sigma_nu + delta^rho_mu frac(partial epsilon^sigma, partial x^nu) + delta^sigma_nu frac(partial epsilon^rho, partial x^nu)) + cal(O)(epsilon^2) \
      &= eta_(mu nu) + (frac(partial epsilon_mu, partial x^nu) + frac(partial epsilon_nu, partial x^mu)) + cal(O)(epsilon^2) \
      &= eta_(mu nu) + (partial_nu epsilon_mu + partial_mu epsilon_nu) + cal(O)(epsilon^2)
$ <f1>

où, à la dernière ligne, on a simplement utilisé la notation $partial\/(partial x^mu) equiv partial_mu$. Pour qu'une telle transformation soit conforme, on voit qu'on doit avoir $partial_mu epsilon_nu + partial_nu epsilon_mu &overset(=, !) f(x) eta_(mu nu)$ où $f(x)$ est une fonction quelconque. Nous pouvons appliquer la métrique inverse des deux côtés de cette égalité de sorte à déterminer une expression pour $f(x)$ :

$
       & space partial_mu epsilon_nu + partial_nu epsilon_mu overset(=, !) f(x) eta_(mu nu) \
  <==> & space eta^(mu nu)partial_nu epsilon_nu + eta^(mu nu)partial_nu epsilon_mu = f(x) eta^(mu nu)eta_(mu nu) equiv f(x) d \
  <==> & space f(x) = 2/d partial^mu epsilon_mu.
$

Nous noterons parfois la divergence $partial^mu epsilon_mu =: (partial dot epsilon)$ afin de ne pas s'encombrer d'indices muets. En substituant cette expression pour $f(x)$ dans l'expression d'origine, on trouve une première expression intermédiaire :

$
  markrect(partial_mu epsilon_nu + partial_nu epsilon_mu = 2/d (partial dot epsilon)eta_(mu nu), padding: #.25em)
$ <temp1>

Cette équation est _l'équation conforme de Killing_, que l'on peut encore écrire comme

$
  markrect(partial_(\(mu)epsilon_(nu\)) = 1/d (partial dot epsilon) eta_(mu nu), padding: #.25em)
$

Pour dériver une autre relation utile, nous allons appliquer $partial^nu$ sur #ref(<temp1>) :

$
        & space partial^nu partial_mu epsilon_nu + partial^nu partial_nu epsilon_mu + 2/d partial^nu [ (partial dot epsilon) eta_(mu nu) ] \
  <==>  & space partial^nu partial_mu epsilon_nu + square epsilon_mu = 2/d partial^nu (partial dot epsilon) eta_(mu nu) \
  <==>  & space partial_mu (partial dot epsilon) + square epsilon_mu = 2/d partial_mu (partial dot epsilon)
$

où on a utilisé la commutativité des dérivées partielles et $square := partial_mu partial^mu$. On applique à ce résultat encore une fois $partial_nu$ pour trouver

$
  space partial_mu partial_nu (partial dot epsilon) + square partial_nu epsilon_mu = 2/d partial_mu partial_nu (partial dot epsilon)
$ <f2>

on permute les indices :

$
  space partial_nu partial_mu (partial dot epsilon) + square partial_mu epsilon_nu = 2/d partial_nu partial_mu (partial dot epsilon)
$ <f3>

et on additionne #ref(<f2>) avec #ref(<f3>), ce qui nous donne

$
  & space partial_mu partial_nu (partial dot epsilon) + square partial_nu epsilon_mu + space partial_nu partial_mu (partial dot epsilon) + square partial_mu epsilon_nu \
  & space = 2/d partial_mu partial_nu (partial dot epsilon) + 2/d partial_nu partial_mu (partial dot epsilon)
$

Après réarrangement des termes et mise en évidence, on trouve

$
  partial_mu partial_nu (partial dot epsilon) [1 - 2/d] + (square partial_nu epsilon_mu + square partial_mu epsilon_nu) = 0.
$

On peut utiliser l'équation de Killing conforme, #ref(<temp1>), afin d'écrire

$
  partial_mu partial_nu (partial dot epsilon) [1 - 2/d] + 2/d square (partial dot epsilon) eta_(mu nu) = 0.
$

Nous pouvons mettre $(partial dot epsilon)$ en évidence,

$
  [eta_(mu nu) square + (d - 2) partial_mu partial_nu](partial dot epsilon) = 0
$<f4>

puis contracter cette équation avec la métrique $eta^(mu nu)$ de sorte à trouver, au final et après réarrangement des termes, notre second résultat intermédiaire :

$
  (d - 1) square (partial dot epsilon) = 0
$ <temp2>

où, pour rappel, $d > 0$ est la dimension de notre espace-temps obtenu par contraction de la métrique avec elle-même. Notez que si $d$ était égale à 2 dans #ref(<f4>), nous n'aurions pas obtenu ce résultat, tandis que pour tout autre $d > 0$ ce résultat tient.

#remark[
  Nous profitons également du fait de parler des dimensions de l'espace-temps pour mentionner que nous appellerons une théorie conforme en dimension $d = 1$ une _mécanique quantique conforme_, en effet si l'on considère que la dimension est le temps, la théorie quantique des champs unidimensionnelle décrit l'évolution temporelle d'un système vivant dans zéro dimension spatiale, c'est-à-dire en un seul point, de sorte qu'il ne s'agit pas vraiment d'une théorie des champs, mais d'une mécanique quantique.
]

Désormais, nous pouvons chercher à construire l'algèbre des transformations conformes. Comme nous l'avons déjà intuité précédemment, certains générateurs devraient être plutôt familiers étant donné que le groupe de Poincaré est un sous-groupe du groupe conforme. Pour commencer, remarquons que l'équation #ref(<temp2>) implique que $(partial dot epsilon)$ doit être au plus linéaire en $x^mu$ (en effet, rappelons qu'au départ le paramètre $epsilon$ provient de la transformation infinitésimale $x'^mu = x^mu + epsilon^mu (x) + cal(O)(epsilon^2)$), ce qui implique à son tour que $epsilon_mu$ doit être au plus quadratique en $x^nu$, autrement dit on doit avoir "$epsilon = a + b x + c x^2$" :

$
  epsilon_mu = a_mu + b_(mu nu) x^nu + c_(mu nu rho)x^nu x^rho,
$<quad>

où $a_mu$, $b_(mu nu)$ et $c_(mu nu rho)$ sont des paramètres à déduire. Remarquons que $c_(mu nu rho)$ est symétrique sous l'échange de $nu$ et $rho$. Résumons ce que nous avons fait jusqu'à présent :

 1. Nous avons considéré un changement de coordonnées infinitésimale tout à fait générale ;
 2. Nous avons contraint cette transformation à être conforme ;
 3. Après manipulations, nous sommes arrivé à une expression quadratique pour $epsilon$.

Puisque $epsilon$ est contraint par la définition de la transformation conforme, et ce de façon indépendante de la position, nous sommes en mesure d'étudier chaque terme de #ref(<quad>) individuellement. Le premier est le plus simple à comprendre : $a_mu$ correspond à une _translation_, il s'en suit que le générateur associé est déjà connu (il faut se souvenir des générateurs du groupe de Lorentz), c'est $hat(P)_mu = -i partial_mu$, l'opérateur d'impulsion. Le terme linéaire en $x^nu$, $b_(mu nu)$, correspond, lui, à un _rescaling_. Pour trouver (ou identifier !) le générateur associé, nous allons utiliser l'équation de Killing conforme #ref(<temp1>) et y insérer un terme linéaire $epsilon_mu = b_(mu nu) x^nu$,

$
      & space partial_mu epsilon_nu + partial_nu epsilon_mu = 2/d (partial dot epsilon) eta_(mu nu) \
 <==> & space partial_mu (b_(nu rho) x^rho) + partial_nu (b_(mu rho) x^rho) = 2/d (partial^rho (b_(rho sigma) x^sigma)) eta_(mu nu) \
 <==> & space b_(nu rho) delta^rho_mu + b_(mu rho) delta^rho_nu = space b_(nu mu) + b_(mu nu) = 2/d (eta^(rho sigma) b_(rho sigma)) eta_(mu nu) \
 <==> & space b_((mu nu)) = 1/d (eta^(rho sigma) b_(rho sigma)) eta_(mu nu) \
 <==> & space b_((mu nu)) prop eta_(mu nu),
$

cela nous apprend que la partie symétrique de $b_(mu nu)$ est proportionnelle à la métrique, autrement dit $b_(mu nu)$ doit s'écrire de la manière suivante :

$
  b_(mu nu) = alpha eta_(mu nu) + beta_(mu nu)
$

où $alpha$ est un facteur de proportionnalité et où $beta_(mu nu)$ est la partie antisymétrique de $b_(mu nu)$. Commençons par quelque chose que nous connaissons : l'objet antisymétrique $beta_(mu nu)$, dans ce contexte, doit être identifié à une _rotation de Lorentz_ :

$
  x'^mu &= delta^mu_nu x^nu + beta^mu_nu x^nu \
        &= (delta^mu_nu + beta^mu_nu)x^nu,
$

et nous savons que le générateur de ces rotations de Lorentz est l'opérateur de moment angulaire $hat(L)_(mu nu) = i(x_mu partial_nu - x_nu partial_mu)$ ! Ensuite, concernant la partie symétrique de $b_(mu nu)$, on voit qu'il ne s'agit de rien d'autre qu'une _dilatation_ infinitésimale

$
  x'^mu &= x^mu + alpha x^mu \
        &= (1 + alpha) x^mu
$

dont le générateur associé s'écrit $hat(D) = -i x^mu partial_mu$. Maintenant, intéressons-nous au terme quadratique $c_(mu nu rho)$, ici la transformation et le générateur associée sont moins évidents. Nous allons commencer par développer un résultat intermédiaire qui nous permettra d'étudier une expression avec trois indices (en effet si on veut étudier $c_(mu nu rho)$ qui est de rang 3 alors c'est la moindre des choses). Considérons l'application de $partial_rho$ sur l'équation de Killing conforme #ref(<temp1>) et permutons les indices de façon cyclique :

$
  partial_rho partial_mu epsilon_nu + partial_rho partial_nu epsilon_mu &= 2\/d space eta_(mu nu) partial_rho (partial dot epsilon) space.quad "(a)" \
  partial_nu partial_rho epsilon_mu + partial_mu partial_rho epsilon_nu &= 2\/d space eta_(rho mu) partial_nu (partial dot epsilon) space.quad "(b)" \
  partial_mu partial_nu epsilon_rho + partial_nu partial_mu epsilon_rho &= 2\/d space eta_(nu rho) partial_mu (partial dot epsilon) space.quad "(c)" \
$

on exprime ensuite, par exemple, $"-(a) + (b) + (c)"$ afin de trouver une expression simplifiée (on pourrait mettre la négation sur n'importe laquelle des autres équations, étant donné que les dérivées commutent), ce qui nous donne, après calculs, l'expression suivante :

$
  2 partial_mu partial_nu epsilon_rho = 2/d (-eta_(mu nu) partial_rho + eta_(rho mu) partial_nu + eta_(nu rho) partial_mu) (partial dot epsilon).
$<f5>

Comme précédemment, pour trouver $c_(mu nu rho)$, on utilise la même astuce : on insert insert le terme quadratique $epsilon_mu = c_(mu nu rho)x^nu x^rho$ dans l'équation précédente et on développe. On exprime d'abord la divergence explicitement,

$
  (partial dot epsilon) equiv partial_mu epsilon^mu &= eta^(mu alpha) partial_mu epsilon_alpha \
                                                &= eta^(mu alpha) partial_mu (c_(alpha nu rho) x^nu x^rho) \
                                                &= eta^(mu alpha) c_(alpha nu rho) partial_mu (x^nu x^rho) \
                                                &= eta^(mu alpha) c_(alpha nu rho) (delta^nu_mu x^rho + delta^rho_mu x^nu) \
                                                &= c^mu_(space.en nu rho) (delta^nu_mu x^rho + delta^rho_mu x^nu),
$

ce qui nous donne ensuite dans l'équation #ref(<f5>) en passant quelques détails simples :

$
       space & 2 partial_mu partial_nu epsilon_rho = 2/d (-eta_(mu nu) partial_rho + eta_(rho mu) partial_nu + eta_(nu rho) partial_mu) (partial dot epsilon) \
  <==> space & 2 c_(mu nu rho) delta^rho_mu = 2/d (-eta_(mu nu) partial_rho + eta_(rho mu) partial_nu + eta_(nu rho) partial_mu) c^mu_(space.en nu rho) (delta^nu_mu x^rho + delta^rho_mu x^nu) \
  <==> space & ... \
  <==> space & c_(mu nu rho) = eta_(mu rho) b_nu + eta_(mu nu) b_rho - eta_(nu rho) b_mu space.quad "où" space.quad b_alpha := 1/d c^nu_(space.en nu alpha)
$

où nous avons basiquement contracté, distribué et dérivé les termes linéaires restant. Nous avons donc bien une expression pour le coefficient $c_(mu nu rho)$, et nous pouvons alors calculer la transformation infinitésimale associée $x'^mu = x^mu + epsilon^mu$. On peut commencer par écrire

$
  c^mu_(space.en nu rho) = eta^(mu alpha) c_(alpha nu rho) = delta^mu_rho b_nu + delta^mu_nu b_rho - eta_(nu rho) b^mu
$

pour ensuite avoir :

$
  epsilon^mu &= c^mu_(space.en nu rho) x^nu x^rho \
             &= delta^mu_rho b_nu x^nu x^rho + delta^mu_nu b_rho x^nu x^rho - eta_(nu rho)b^mu x^nu x^rho \
             &= b_nu x^nu x^mu + b_rho x^mu x^rho - b^mu x^2 \
             &= (x dot b) x^mu + (x dot b) x^mu - b^mu x^2 \
             &= 2(x dot b)x^mu - b^mu x^2,
$

et donc

$
  x'^mu &= x^mu + epsilon^mu \
        &= x^mu + 2(x dot b)x^mu - b^mu x^2.
$

Cette transformation infinitésimale est dite "spéciale conforme". On déduit que le générateur qui lui est associé est

$
  hat(K)_mu = -i(2 x_mu x^nu partial_nu - (x^2) partial_mu).
$

Pour résumer, nous avons déterminer quatre générateurs infinitésimaux, que nous reprenons ici résumé dans le tableau suivant :

#align(center,
  table(
    columns: (auto, auto),
    align: (left, left),
    table.header([*générateur*], [*transformation infinitésimale*]),
  
    [$hat(P)_mu = -i partial_mu$], [$x'^mu (x^mu) = x^mu + a^mu$],
    [$hat(L)_(mu nu) = i(x_mu partial_nu - x_nu partial_mu)$], [$x'^mu (x^mu) = (delta^mu_nu + beta^mu_nu)x^nu$],
    [$hat(D) = -i x^mu partial_mu$], [$x'^mu (x^mu) = (1 + alpha)x^mu$],
    [$hat(K)_mu = -i(2 x_mu x^nu partial_nu - (x^2) partial_mu)$], [$x'^mu (x^mu) =  x^mu + 2(x dot b)x^mu - b^mu x^2$],
  )
)

Les deux premiers générateurs sont donc associés au groupe de Poincaré tandis que les deux seconds sont induits par les symétries conformes (dilatation et transformation conforme spéciale respectivement). Nous pouvons explicitement réécrire tout les termes de $epsilon^mu$ développés :

#v(2.5em)
$
  epsilon^mu = space
               mark(a^mu_(), tag: #<translation>, color: #red, padding: #.4em, radius: #10%) space.en
    + space.en mark(b^mu_(space.en nu) x^nu, tag: #<lorentz>, color: #blue, padding: #.4em, radius: #10%) space.en
    + space.en mark(c x^mu_(), tag: #<scale>, color: #green, padding: #.4em, radius: #10%) space.en
    + space.en mark(d_nu (eta^(mu nu) x^2 - 2 x^mu x^nu), tag: #<sc>, color: #purple, padding: #.4em, radius: #10%)

  #annot(<translation>, pos: top, yshift: 2em)[translation]
  #annot(<lorentz>, pos: bottom, yshift: 2em)[lorentz]
  #annot(<scale>, pos: top, yshift: 2em)[dilatation]
  #annot(<sc>, pos: bottom, yshift: 2em)[spéciale conforme]
$
#v(2.5em)

Les translations, dilatations, et transformations de Lorentz sont plutôt intuitives à comprendre, mais la transformation conforme spéciale l'est un peu moins. La transformation non-infinitésimale générale associée peu s'écrire comme

$
  x'^mu &= frac(x^mu - (x dot x) b^mu,  1 - 2(b dot x) + (b dot b)(x dot x)) \
        &= frac(x^mu - b^mu x^2, 1 - 2 b dot x + b^2 x^2).
$

Nous pouvons constater que c'est une transformation présentant des points singuliers (mais sous forme infinitésimale ça n'est pas le cas, comme on peut le constater dans le tableau plus haut et de toute façon en physique on s'intéresse aux transformations infinitésimales dans le cadre des algèbres de Lie). Le dénominateur s'annule en effet en $x^mu = b^(-2) b^mu$. Cette transformation peut se comprendre comme la composition d'une inversion, d'une translation et d'une autre inversion. Si l'on veut définir une transformation spéciale conforme finie qui soit globalement définie alors il faut considérer la _compactification_, mais cela ne sera pas abordé.

#remark[
  Les groupes sont des objets non-linéaires et compliqués, c'est pourquoi en physique on préfère travailler avec les espaces qui leur sont tangents (on choisi souvent tangent à l'identité par commodité), ce qui correspond aux algèbres de Lie, où toute transformation est bien définie partout.
]

Maintenant que nous avons les générateurs, nous pouvons calculer les différents commutateurs afin de déduire l'algèbre de Lie du groupe conforme. Les relations de commutations entre les générateurs du groupe de Poincaré sont déjà connu, et les autres se calculent donc plus ou moins laborieusement. Nous pouvons donc trouver les relations suivantes :

$
  & [hat(D), hat(P)_mu] = i hat(P)_mu \
  & [hat(D), hat(K)_mu] = -i hat(K)_mu \
  & [hat(K)_mu, hat(P)_nu] = 2 i (eta_(mu nu) hat(D) - hat(L)_(mu nu)) \
  & [hat(K)_rho, hat(L)_(mu nu)] = i (eta_(rho mu) hat(K)_nu - eta_(rho nu) hat(K)_mu) \
  & [hat(P)_rho, hat(L)_(mu nu)] = i (eta_(rho mu) hat(P)_nu - eta_(rho nu) hat(P)_mu) \
  & [hat(L)_(mu nu), L_(rho sigma)] = i (eta_(nu rho) hat(L)_(mu sigma) + eta_(mu sigma) hat(L)_(nu rho) - eta_(mu rho) hat(L)_(nu sigma) - eta_(nu sigma) hat(L)_(mu rho))
$

où tout les autres commutateurs sont nuls. Cela défini donc l'algèbre de Lie du groupe conforme. Il est possible de montrer que les objets suivant :

$
  C_2 := 1/2 hat(L)^(mu nu)hat(L)_(mu nu), space.quad C_3 := 1/2 hat(L)^(mu nu)hat(L)_(nu rho)hat(L)^rho_(space.en mu), space.quad C_4 := hat(L)^(mu nu)hat(L)_(nu rho)hat(L)^(rho sigma)hat(L)_(sigma mu)
$

commutent avec tout les générateurs, et sont donc des _casimirs_ de l'algèbre du groupe conforme, mais nous n'allons pas entrer davantage dans les détails. De plus, dans la suite, nous limiterons l'utilisation d'un petit chapeau "$hat$" sur les opérateurs.

=== Remarque sur le cas $d = 2$ : l'algèbre de Virasoro
Nous n'allons pas entrer dans les détails d'une théorie conforme en $d = 2$ car il s'agit d'un sujet à part entier mais allons simplement faire quelques remarques sur pourquoi ce cas est distingué du cas $d >= 3$, nous avons en effet maintenant les outils suffisant pour comprendre en quoi les choses diffèrent. En $d = 2$, il est commode d'employer un système de coordonnées complexes, avec $z = x^1 + i x^2$ et $overline(z) = x^1 - i x^2$. En faisant ça, l'équation de Killing conforme #ref(<temp1>) prend la forme suivante (après quelques manipulations) :

$
  cases(
    partial_1 epsilon_1 = partial_2 epsilon_1,
    partial_1 epsilon_2 = -partial_2 epsilon_1,
  )
$

autrement dit, on reconnaît les _équations de Cauchy-Riemann_ de l'analyse complexe ! Précédemment, nous cherchions les $epsilon$ satisfaisant à l'équation de Killing conforme et avions trouvé qu'il en existait un nombre fini à des constantes près, mais dans le cas présent il existe une _infinité_ de solutions à ces équations. Plus précisément, les solutions sont toute fonction analytique $z |-> f(z)$ et $overline(z) |-> f(overline(z))$. Si nous voulions classer cet ensemble de transformations en générateurs, alors, au lieu d'en avoir quatre, nous en aurions une infinité : nous devons pouvoir générer toute fonction analytique (au sens complexe), d'où ce nombre de générateurs infini nécessaire. Si l'on continue dans cette direction, nous arriverions à une théorie conforme plus "générale", et en particulier on arriverait à l'algèbre de Virasoro, une algèbre de Lie complexe de dimension infinie notamment utilisée en théorie des cordes. C'est pourquoi nous n'irons pas plus loin dans le cadre de ce document.

=== Dimension du groupe conforme et isomorphisme avec $"SO(d + 1, 1)"$
Il existe un lien entre le groupe conforme, que nous avons étudié à travers son algèbre, comme cela est fréquemment le cas, et le groupe $"SO"(d + 1, 1)$. Commençons par nous intéresser à la dimension de l'algèbre (c'est-à-dire le nombre de générateurs) pour $d >= 3$ :

 - *Translation* : il existe $d$ paramètres indépendants pour la translation, un pour chaque direction de l'espace-temps de dimension $d$ ;
 - *Rotations de Lorentz* : nous savons déjà que le groupe orthogonal en dimension $d$ (càd $"SO"(d - 1, 1)$ en relativité) possède $d(d-1)\/2$ générateurs ;
 - *Dilatations* : il n'y a qu'un seul facteur de dilatation commun (un facteur constant), donc cela contribue pour un seul générateur ;
 - *Transformation conformes spéciales* : sachant que la S.C.T. se résume à une inversion, puis à une translation, puis encore une inversion, alors on déduit qu'il y a autant de générateurs que pour la translation, autrement dit $d$.

Le tout mis ensemble nous donne la somme suivante :

$
  d "translations" + d(d-1)/2 "rotations" + 1 "dilatation" + d "S.C.T.'s" \
          = ((d + 2)(d + 1))/2 "générateurs"
$

et il s'agit donc de la dimension de l'algèbre conforme à $d >= 3$. Notons que cela correspond au nombres de générateurs du groupe $"SO"(d + 1, 1)$ (selon la signature adoptée), en effet le groupe $"SO"(d + 1, 1)$ est l'ensemble des matrices orthogonales dans un espace de dimension $d+2$ (où l'on emprunte la signature $(d + 1, 1)$ si l'on est dans un espace de Minkowski ou $(d + 2, 0)$ si l'on est dans un espace euclidien selon les conventions) et, de façon générale, la dimension de $"SO"(n)$ est $(n(n - 1))\/2$ ou, en signature mixte $"SO"(p, q)$, la dimension s'exprime de façon analogue comme $((p + q)(p+q-1))\/2$. Si l'on spécifie au cas présent, càd $"SO"(d + 1, 1)$, alors on a $ dim("SO"(d + 1, 1)) = ((d + 2)(d + 1))/2 $ et l'on retrouve donc bien la même dimension que pour le groupe conforme.

#remark[
  En dimension $d$, les rotations (ou plus généralement les transformations orthogonales) se font dans des plans bidimensionnelles. Un tel "plan de rotation" est défini par le choix de deux axes parmi $d$ possibles, le nombre de façons de choisir $2$ axes parmi $d$ est $ binom(d, 2) = (d(d - 1))/2 $ d'où le résultat obtenu pour les rotations si l'on ne se souvient plus du nombre de générateurs du groupe orthogonal.
]

Dire que deux groupes ont la même dimension est nécessaire pour dire qu'ils sont isomorphes, mais pas suffisant. Si l'on pose

$
  & J_(mu nu) := L_(mu nu) \
  & J_(-1, mu) := 1/2 (P_mu - K_mu) \
  & J_(0, mu) := 1/2 (P_mu + K_mu) \
  & J_(-1, 0) := D,
$

alors il est possible de montrer que les générateurs $J_(alpha beta)$, avec $a, b = -1, 0, ..., n = p + q$ obéissent à l'algèbre de Lorentz avec la métrique $tilde(eta)_(alpha beta) = "diag"(-1, +1, -1, ..., -1, +1, ..., +1)$ mais nous n'allons pas le montrer ici.

== Remarque sur la matrice S en théorie conforme des champs
Cette sous-section n'est pas dédiée à l'établissement de la matrice S étant donné les symétries conformes car la matrice S ne _peut pas_ être construite dans une théorie conforme des champs. C'est ce que nous allons rapidement discuter dans cette mini section.

#remark[
  Parler de la matrice S dans un contexte autre que celui des particules, comme c'est le cas dans l'étude des transitions de phase par exemple, n'est pas très utile, mais nous prenons tout de même une petite parenthèse pour discuter de cet aspect qui sort légèrement du cadre de ce document.
]

Notons avant tout que ça n'est pas parce que la théorie conforme des champs n'admet pas de matrice S que la matrice S, dans une autre théorie, n'admet pas de symétries conformes. Rappelons que la matrice S est définie comme la matrice (unitaire) reliant des états de particules _asymptotiquement_ libres $ket("in")$ et $ket("out")$ dans un espace de Hilbert. Maintenant, rappelons qu'une théorie conforme des champs est invariante sous les symétries conformes, et plus particulièrement sous la _dilatation_. Autrement dit, à cause de l'invariance sous dilatation, le concept même d'être "asymptotiquement éloigné" n'a plus vraiment de sens : en CFT, il n'existe pas d'états asymptotiques, donc _pas_ de matrice S à proprement parler.

== Fonctions de corrélations
Dans une théorie conforme des champs, les _fonctions de corrélations_ jouent en quelque sorte le rôle des observables de la théorie, il s'agit d'un objet central en CFT. Les fonctions de corrélations en physique sont assez similaires à celles que l'on retrouve en statistiques, elles mesures, comme on peut s'y attendre, le degré de corrélation entre deux variables aléatoires. C'est-à-dire la fréquence à laquelle deux variables aléatoires ont des valeurs similaires. Dans un contexte de théorie des champs, le lien est moins claire. Dans la théorie des champs, la fonction de corrélation à $n$ points est définie comme le produit fonctionnel moyen de $n$ champs à différentes positions,

$
  G_n (x_1, x_2, ..., x_n) &:= corr(phi(x_1) phi(x_2) ... phi(x_3)) \
                           &:= frac(integral [cal(D) phi] e^(-S[phi]) phi(x_1) ... phi(x_n), integral [cal(D) phi] e^(-S[phi])) \
                           &=: frac(1, z_0) integral [cal(D) phi] e^(-S[phi]) phi(x_1) ... phi(x_n)
$

et pour les fonctions de corrélation dépendant du temps, l'opérateur d'ordre temporel $T$ doit être inclus. La fonction de corrélation à deux points $G_2 (x, y)$ peut être interprétée physiquement comme l'amplitude de propagation d'une particule entre $y$ et $x$. Dans une théorie libre, il s'agit simplement du propagateur de Feynman. Le terme "fonction de Green" est parfois utilisé pour désigner toute fonction de corrélation et pas seulement les fonctions de corrélation à deux points.

Pour la suite, dans le cadre de la théorie conforme des champs, nous allons définir une fonction de corrélation comme étant une fonction de la forme $corr(phi_1 (x_1) phi_2 (x_2) ... phi_n (x_n))$ contenant un nombre fini d'objets (plus particulièrement des opérateurs) et renvoyant un nombre réel. Nous allons supposer que les objets entre $corr(...)$ peuvent commuter sans en changer la valeur de la fonction de corrélation et que les fonctions de corrélations sont linéaires, c'est-à-dire que

$
  corr(A_1 phi_1 (x_1) A_2 phi_2 (x_2) ... A_n phi_n (x_n)) = (A_1 A_2 ... A_n) corr(phi_1 (x_1) phi_2 (x_2) ... phi_n (x_n))
$

où $A_k$ est une constante ou un opérateur des positions $x^mu$. La notion de fonction de corrélation dans le cadre de la CFT devrait devenir plus claire au fur et à mesure de son utilisation.

== Dimension d'échelle (_scaling dimension_) d'un opérateur
Dans la suite, nous aurons besoin d'un concept important qui est directement lié aux dilatations : la dimension d'échelle d'un opérateur. La dimension d'échelle est un nombre associé à un opérateur qui indique comment se dernier se comporte sous dilatation $x -> lambda x$. Cette notion est liée aux dimensions au sens de l'analyse dimensionnelle. Étant donné un opérateur quelconque $cal(O)(x)$, l'invariance sous dilatation $x -> lambda x$ implique que

$
  cal(O)(x) -> cal(O)(lambda x) = lambda^(-Delta) cal(O)(x)
$<dim1>

où $Delta in RR$ est la _dimension d'échelle_ de l’opérateur $cal(O)$. Le nombre $Delta$ doit exister afin que les dimensions (donc à comprendre comme "les unités") soient respectées. Dans une théorie qui n'est pas invariance sous dilatation, les $Delta$ ne sont plus de simples nombres mais fonctions des échelles de distance. Ce concept n'est pas propre à la théorie conforme des champs.

Souvent, on voudra déterminer quelle est la dimension d'échelle d'un opérateur ou d'un champs $phi(x)$, nous pouvons établir l'expression générale de cette dimension pour une théorie des champs. En se plaçant dans le système d'unités naturelles $ħ = 1 = c$, la distance est l'inverse de la masse, $[L] = [M]^(-1)$, et lorsque l'on étudie les unités d'échelle ce sont les exposants qui nous intéresses, donc on aura que si $m$ est un terme de masse et que $x$ est un terme de position, alors on prendra la convention selon laquelle $Delta_m = 1$ et $Delta_x = -1$. Pour déterminer la dimension d'échelle d'un champs $phi(x)$, considérons l'action

$
  S = 1/2 integral dd^d x space (partial_mu phi)^2.
$

Dans les unités naturelles, l'action est sans dimension (puisque $ħ = 1$, un simple scalaire), donc on déduit que $Delta_S = 0$. On déduit également que la dimension d'échelle de la mesure est

$
  Delta_(dd^d x) = -d
$

puisque $Delta_x = -1$. Nous pouvons alors essayer trouver la dimension d'échelle de $phi$ :

$
       & space Delta_S = Delta_(dd^d x) + 2 (Delta_(partial_mu) + Delta_phi) \
  <==> & space 0 = -d + 2 Delta_(partial_mu) + 2 Delta_phi
$

où la dérivée partielle $partial_mu equiv partial\/partial x^mu$, ce qui implique que $Delta_(partial_mu) = +1$, donc au final nous avons

$
       & space.quad 0 = -d + 2 + 2 Delta_phi \
  <==> & space.quad markrect(Delta_phi = d/2 - 1, padding: #.5em)
$
#v(0.5em)

Par exemple, en quatre dimensions $Delta_phi = 1$ et en trois dimensions $Delta_phi = 1\/2$.

#example[
  Maintenant que nous savons quelle est la forme générale de $Delta_phi$, nous pouvons déduire la dimension d'échelle d'autres paramètres, considérons par exemple l'action avec interaction suivante :
  $
    S = integral dd^d x space lambda phi^n
  $
  alors,
  $
         & space Delta_S = Delta_(dd^d x) + Delta_lambda + n Delta_phi \
    <==> & space 0 = -d + Delta_lambda + n (d/2 - 1) \
    <==> & space Delta_lambda = d - n (d/2 - 1)
  $
]

La dimension d'échelle sera un paramètre important, en fait il fait partie des informations nécessaires pour caractériser un opérateur, comme nous le verrons plus tard.

#example[
  Nous pouvons prendre un autre exemple plus compliqué, il se réduira en fait à un cas très simple (il s'agit d'une action pour le modèle de Ising) :
  $
    S = 1/2 integral dd^3 x space [ -partial_mu phi partial^mu phi - m^2 phi^2 - g/4! phi^4 ].
  $
  Ici, la seule dimension d'échelle inconnue est $Delta_g$, donc on peut se concentrer uniquement sur le troisième terme de la somme (sachant que $d = 3$ dans cet exemple) :
  $
         & space Delta_S = Delta_(dd^3 x) + (Delta_g + 4 Delta_phi) \
    <==> & space 0 = -3 + Delta_g + 4 (3/2 - 1) \
    <==> & space Delta_g = 1.
  $
]

La relation #ref(<dim1>), $cal(O)(x) -> cal(O)(lambda x) = lambda^(-Delta) cal(O)(x)$, implique que les fonctions de corrélations, sous l'invariance d'échelle, doivent être telles que

$
  corr(cal(O)_1(lambda x_1) cal(O)_2(lambda x_2) ...) = lambda^(-Delta_1 - Delta_2 - ...) corr(cal(O)_1(x_1) cal(O)_2(x_2) ...).
$

#example[
  Prenons par exemple la fonction de corrélation à 2 points $corr(cal(O)(x) cal(O)(0))$, alors
  $
    corr(cal(O)(x) cal(O)(0)) -> & corr(cal(O)(lambda x) cal(O)(lambda 0)) \
                                 & = lambda^(-(Delta + Delta)) corr(cal(O)(x) cal(O)(0)) \
                                 & = lambda^(-2 Delta) corr(cal(O)(x) cal(O)(0)).
  $
]

L'invariance d'échelle des fonctions de corrélations sera le point de départ pour développer, par la suite, une équation importante (voir la section sur le bootstrap), nous y reviendrons plus tard.

== Courants conservés et tenseur énergie-impulsion
Par simplicité, considérons un champs scalaire $phi(x)$. Nous allons supposer que ce champs se transforme (sous une transformation de symétrie) suivant

$
  cases(
    x^mu -> x'^mu (x),
    phi'(x') = cal(F)(phi(x))
  )
$

où $cal(F)$ est simplement la fonction de transformation du champs scalaire. En conséquence, nous avons les transformations infinitésimale associées suivantes :

$
  & x^mu -> x'^mu (x) = x^mu + space mark(omega^A frac(delta, delta omega^A), padding: #.2em, radius: #10%, color: #red) space x^mu, \
  & phi(x) -> phi'(x) = phi(x) + space mark(omega^A frac(delta, delta omega^A), padding: #.2em, radius: #10%, color: #red) space cal(F)(phi(x))
$

où $omega^A << 1$ sont infinitésimaux (l'indice majuscule $A$ indique que plusieurs indices peuvent être présents, par exemple $omega^(i j k)$, mais on note $omega^A$ par généralité et facilité). Nous introduisons également la notation suivante :

$
  mark(omega^A frac(delta, delta omega^A), padding: #.2em, radius: #10%, color: #red) space =: delta_omega
$

où le $omega$ ne doit pas être confondu avec un indice mais sert à identifier la variation par rapport à ces paramètres infinitésimaux $omega^A$. Si cette transformation infinitésimale est une symétrie de l'action alors on doit avoir $delta_omega S = S' - S approx 0$ par le théorème de Noether (ici le symbole "$approx$" indique une égalité modulo les équations d'Euler-Lagrange). L'action transformée est donc

$
  & space S[phi, partial_mu phi] = integral dd^d x space cal(L)(phi, partial_mu phi)

  \ -->

  & space S[phi', partial'_mu phi'] = integral dd^d x space abs(frac(partial x'^mu, partial x^nu)) cal(L)(phi + delta_omega cal(F), frac(partial x^nu, partial x'^mu) partial_nu [phi + delta_omega cal(F)])
$

où, sachant que $det(bb(1) + epsilon) approx 1 + tr(epsilon)$, on a

$
  abs(frac(partial x'^mu, partial x^nu)) &= abs(frac(partial, partial x^nu) (x^mu + delta_omega x^mu)) \
                                         &= abs(delta^mu_nu + partial_nu delta_omega x^mu) \
                                         &approx 1 + partial_mu delta_omega x^mu.
$

En remplaçant cette expression dans l'action transformée, en développant et en intégrant par partie et en négligeant les termes aux bords comme il en est d'usage habituel, nous arrivons à l'expression suivante :

$
  delta_omega S &= -integral dd^d x space j^mu_A partial_mu omega^A (x) \
                &overset(=, "(IPP)") ... \
                &=  integral dd^d x space partial_mu j^mu_A omega^A (x)
$<deltaomegaint>

où $j^mu_A$ est le _courant de Noether_, définis par

$
  j^mu_A (x) := space mark([frac(partial cal(L), partial (partial_mu phi)) partial_nu phi - eta^mu_(space.en nu) cal(L)], tag: #<set>, color: #red, padding: #.2em, radius: #10%) space frac(delta x^nu, delta omega^A) - frac(partial cal(L), partial (partial_mu phi)) frac(delta F, delta omega^A).

  #annot(<set>, pos: bottom + right, yshift: 2em)[tenseur énergie-impulsion (canonique)]
$<courrant>
#v(2em)

Si les équations de Euler-Lagrange sont satisfaites par le champs $phi(x)$, $ frac(partial cal(L), partial phi) - partial_mu (frac(partial cal(L), partial (partial_mu phi))) approx 0, $ alors l'action est invariante sous toute variation arbitraire du champs : $delta S = 0$ pour tout $omega^A$, ce qui mène à la loi de conservation du courant de Noether : $ partial_mu j^mu_A = 0 $ et on définira la _charge de Noether_ associé comme $ Q := integral dd^(d - 1) x space j^0_a. $ Autrement dit, une symétrie continue de l'action  implique l'existence d'un courant conservé. Notons que l'ajout de la divergence d'un tenseur antisymétrique au courant $j^mu_A$ n'affecte pas sa conservation, autrement dit il sera toujours possible de trouver un $A^(mu nu)$ antisymétrique tel que

$
  partial_mu j^mu_A = 0,
$

en effet,

$
  & j^mu_A --> j^mu_A + partial_nu A^(mu nu) space.quad "où" space.quad A^(mu nu) = -A^(nu mu) \
  partial_mu & j^mu_A --> markul(partial_mu j^mu_A, tag: #<original>) + partial_(text(fill: #red, mu)) partial_(text(fill: #red, nu)) A^(text(fill: #red, mu nu)) = 0

  #annot(<original>, pos: bottom + right, yshift: 1em)[vaut 0 par conservation du courrant]
$
#v(1.5em)

où le second terme vaut zéro par contraction d'objets symétriques et antisymétriques. Nous avons donc la liberté de (re)définir le courant $j^mu_A$. Nous pouvons désormais nous intéresser à ces courants étant donné des symétries conformes.

*Translation et trace nulle*

Considérons une translation infinitésimale $x^mu -> x'^mu = x^mu + epsilon^mu$, d'où l'on tire que

$
  frac(delta x^mu, delta epsilon^nu) = delta^mu_nu space.quad "et" space.quad frac(partial cal(F), delta epsilon^nu) = 0
$

et il s'en suit directement, en insérant ça dans #ref(<courrant>), que

$
  j^mu_A &= T^mu_(space.en nu) frac(delta x^nu, delta epsilon^A) - frac(partial cal(L), partial(partial_mu phi)) frac(delta cal(F), delta epsilon^A) \
         &= T^mu_(space.en nu) delta^nu_A.
$

Autrement dit, étant donné une symétrie sous translation, le courant conservé _est_ le tenseur énergie-impulsion (canonique) :

$
  T^(mu nu) = -eta^(mu nu)cal(L) + frac(partial cal(L), partial(partial_mu phi))partial_mu phi.
$

Ce _courant_ n'est pas manifestement symétrique, mais nous pouvons par exemple utiliser la liberté sur l'ajout d'un $partial_mu A^(mu nu)$, où $A^(mu nu) = -A^(nu mu)$, afin de déterminer une expression manifestement symétrique et qui reste conservée, mais cela n'est pas très important pour la suite.

Un fait particulier sur le tenseur énergie-impulsion peut être déduit de la conservation du courant associé à la symétrie sous translation que nous venons de développer :

$
  0 = partial_mu j^mu &= partial_mu (T^(mu nu) epsilon_nu) \
                      &= T^(mu nu) partial_mu epsilon_nu + epsilon_nu partial_mu T^(mu nu) \
                      &= 1/2 T^(mu nu) (partial_mu epsilon_nu + partial_nu epsilon)
$

et, en utilisant l'équation de Killing conforme #ref(<temp1>), on trouve

$
                  & 0 = 1/d (partial dot epsilon) T^mu_(space.en mu) \
  <==> space.quad & markrect(T^mu_(space.en mu) = 0, padding: #.25em) space.
$

Autrement dit, sous symétries conformes, le tenseur énergie-impulsion est à trace nulle. Il s'agit d'un fait spécifique aux théories conforme des champs : toute CFT a un tenseur énergie-impulsion à trace nulle ! Dans une théorie conforme des champs, le fait que le tenseur énergie‑impulsion soit à trace nulle traduit l’invariance du système sous les dilatations. Concrètement, cela signifie que la dynamique du système ne fait intervenir aucun paramètre dimensionnel qui fixerait une échelle particulière, ce qui est au cœur de l’invariance conforme.

Les autres transformations de symétrie (rotation, dilatation et spéciale conforme) peuvent aussi être associées à un courant par une procédure similaire, nous n'allons cependant pas entrer dans les détails des calculs car cela n'est pas très utile pour la suite et c'est un travail qui n'est pas spécifique à la théorie conforme des champs.

*Rotation*

De façon analogue à l'étude des transformations de Poincaré, les rotations de Lorentz sont associés au tenseur moment angulaire, la variation $delta x^mu = omega^mu_(space.en nu) x^nu$ donne lieue au courant $ M^mu_(space.en rho sigma) = x_rho T^mu_(space.en sigma) - x_sigma T^mu_(space.en rho) $<noether_r> où $T^(mu nu)$ est le tenseur énergie-impulsion (celui qui émerge des symétries sous translations).

*Dilatation*

Considérons une transformation $x^mu -> x'^mu = x^mu + epsilon x^mu$, autrement dit $delta x^mu = epsilon x^mu$, on montre alors que le courant de Noether associé est $ J^mu_"dilatation" = x_nu T^(mu nu). $<noether_d>

*Spéciale conforme*

Pour la S.C.T, à l'ordre infinitésimale, on a $delta x^mu = 2(b dot x) x^mu - x^2 b^mu$, d'où l'on tire le courant de Noether suivant : $ J^mu_"S.C.T." = (2 x^rho x_nu - x^2 delta^rho_nu) T^(mu nu). $<noether_sct>

#linebreak()

Pour chacun de ces courants, la forme n'est pas unique, en particulier il est commun de tout exprimer en terme du tenseur énergie-impulsion $T^(mu nu)$ manifestement symétrique et, donc, d'ajouter des termes correctifs.

=== L'identité de Ward-Takahashi
Au niveau classique, l'invariance de l'action sous des symétries continues implique l'existence d'un courant conservé. Cependant, au niveau quantique, les symétries classiques entraînent des contraintes sur la fonction de corrélation, connus sous le nom des _identités de Ward Takahashi_. On dira que la symétrie est "anomale" si la mesure fonctionnelle dans l'intégrale de chemin ne présente pas la symétrie de l'action, càd $[cal(D) phi'] != [cal(D) phi]$. Dans la suite, nous supposerons toujours que cette contrainte est vérifiée. Supposons que l'action classique est invariante sous la transformation générale $ phi'(x') = cal(F)(phi(x)) $ et que la symétrie n'est pas anomale, c'est-à-dire que $[cal(D) phi'] = [cal(D) phi]$. Alors

$
  corr(phi(x'_1)  ...  phi(x'_n)) &equiv alpha integral [cal(D) phi] space phi(x'_1)  ...  phi(x'_n) space e^(-S[phi]) \
                                            &=     alpha integral [cal(D) phi'] space phi'(x'_1)  ...  phi'(x'_n) space e^(-S[phi']) \
                                            &=     alpha integral [cal(D) phi] space cal(F)(phi(x'_1))  ...  cal(F)(phi(x'_n)) space e^(-S[phi]) \
                                            &equiv corr(cal(F)(phi(x'_1))  ...  cal(F)(phi(x'_n)))
$<w1>

où nous sommes passé de la première ligne à la seconde ligne en renommant $phi -> phi'$ et où $alpha$ est simplement un facteur de proportionnalité. Nous voulons trouver une version infinitésimale de ce résultat. Rappelons qu'une transformation infinitésimale peut être écrite en terme de ses générateurs $G_A$ comme

$
  phi'_cal(A) (x) = phi_cal(A) (x) - i omega^A (G_A)_cal(A)^(space.en cal(B)) phi_cal(B) (x),
$

où $omega^A$ sont, encore une fois, un ensemble de paramètres infinitésimaux tous regroupés sous un même gros indice $A$. En posant $omega^A -> omega^A (x)$, la variation de l'action $delta_omega S[phi]$ est donnée par #ref(<deltaomegaint>),

$
  delta_omega S[phi] = integral dd^d x space partial_mu j^mu_A (x) omega^A (x).
$

Posons le produit $X := phi(x_1)  ...  phi(x_n)$ et notons sa variation $delta_omega X$, donnée explicitement par

$
  delta_omega X &= omega^A frac(delta, delta omega^A) [phi(x_1) phi(x_2) ... phi(x_n)] \
                &= omega^A [frac(delta, delta omega^A) phi(x_1) phi(x_2) ... phi(x_n) + phi(x_1) frac(delta, delta omega^A) phi(x_2) ... phi(x_n) + ... \
                &"        " + phi(x_1) phi(x_2) ... frac(delta, delta omega^A) phi(x_n) ] \
                &= omega^A sum_(k = 1)^n [ phi(x_1) phi(x_2) ... frac(delta, delta omega^A) phi(x_i) ... phi(x_n) ]
$

où l'on se contente juste d'appliquer la règle du produit des dérivées. Avec $delta \/ delta omega^A = -i G_A$ on obtient donc

$
  delta_omega X = -i omega^A sum_(k = 1)^n [ phi(x_1) phi(x_2) ... G_A phi(x_k) ... phi(x_n) ].
$

Maintenant, en prenant l'intégrale de cette expression multipliée par un $d$-delta de Dirac (de sorte à ce qu'expression obtenue se réduise identiquement à l'expression précédente), on a

$
  delta_omega X = -i integral dd^d x space sum_(k = 1)^n delta^((d))(x - x_k) [ phi(x_1) ... G_A phi(x_k) ... phi(x_n) ] omega^A,
$

ce que l'on peut insérer dans un $corr(...)$ pour trouver une première expression intermédiaire :

$
  corr(delta_omega X) = -i integral dd^d x space sum_(k = 1)^n delta^((d))(x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) omega^A.
$ <deltaomegacorr1>

Le fait de vouloir exprimer notre résultat dans une intégrale sera utile pour la suite. Utilisons maintenant une autre écriture équivalente pour exprimer $corr(delta_omega X)$ en utilisant la forme fonctionnelle précédente. Pour se faire, nous considérons la variation introduite précédemment sur $phi$ et exprimons explicitement $corr(X)$, ce qui devrait naturellement introduire un $corr(delta_omega X)$ :

$
  corr(X) &= alpha integral [cal(D) phi'] space X' e^(-S[phi']) \
          &= alpha integral [cal(D) phi'] space (X + delta_omega X) e^(- (S[phi] + delta_omega S[phi])) \
          &= alpha integral [cal(D) phi'] space (X + delta_omega X) e^(-S[phi] - integral dd^d x space partial_mu j^mu_A (x) omega^A (x))
$

où, comme avant, on suppose que la mesure fonctionnelle est invariante sous la transformation. Nous pouvons maintenant développer l'expression précédente au premier ordre en $omega^A$ pour l'exponentielle :

$
  corr(X) &= alpha integral [cal(D) phi'] space (X + delta_omega X) e^(-S[phi] - integral dd^d x partial_mu j^mu_A (x) omega^A (x)) \
          &= alpha integral [cal(D) phi'] space (X + delta_omega X) [ 1 - integral dd^d x space partial_mu j^mu_A (x) omega^A (x) + ... ] e^(-S[phi]) \
          &= corr(X) + corr(delta_omega X) - integral dd^d x space partial_mu [ alpha integral [cal(D) phi] space j^mu_A (x) X e^(-S[phi]) ] omega^A + ... \
          &= corr(X) + corr(delta_omega X) - integral dd^d x space partial_mu corr(j^mu_A (x) X) omega^A + mark(cal(O)(omega^2), tag: #<cancel>, color: #red, padding: #0.2em) \

  <==> space corr(delta_omega X) &= integral dd^d x space partial_mu corr(j^mu_A (x) X) omega^A
          
  #annot(<cancel>, yshift: 1em)[on néglige ces termes d'ordre suppérieur]
$<deltaomegacorr2>

Maintenant que nous avons deux expressions pour $corr(delta_omega X)$, il ne nous reste plus qu'à les égaler. On utilise donc #ref(<deltaomegacorr1>) et #ref(<deltaomegacorr2>) pour former l'équation suivante :

$
  integral dd^d x space partial_mu corr(j^mu_A (x) X) omega^A = \ -i integral dd^d x space sum_(k = 1)^n & delta^((d))(x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) omega^A,
$<temp3>

et puisque les $omega^A$ sont arbitraires, on peut réécrire #ref(<temp3>) comme

#v(0.5em)
$
  markrect(partial_mu corr(j^mu_A (x) phi(x_1) ... phi(x_n)) + i sum_(k = 1)^n delta^((d))(x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) = 0, padding: #0.5em)
$<ward>
#v(0.5em)

où nous avons ré-exprimé $X = phi(x_1) phi(x_2) ... phi(x_n)$. L'équation #ref(<ward>) est l'_identité de Ward-Takahashi_ pour le courant $j^mu_A (x)$ et est une version infinitésimale de #ref(<w1>) (on peut le voir par intégration de #ref(<ward>) et quelques manipulations algébriques).

#remark[
  Dans la littérature, on rencontre parfois les termes "identité de Ward" et "identité de Ward-Takahashi", les deux sont reliés et parfois interchangés. En fait la distinction est souvent faite lorsque l'on applique spécifiquement l'identité de Ward-Takahashi aux éléments de la matrice $S$ en théorie quantique des champs, où l'on parlera alors simplement de l'identité de Ward.
]

De façon très générale, les identités de Ward traduisent les contraintes imposées par une symétrie (interne ou de jauge par exemple) sur les fonctions de corrélation.

=== Identité de Ward-Takahashi et symétries conformes
Appliquons l'équation développée à la section précédente, #ref(<ward>), à une théorie conforme des champs. On parle parfois au pluriel des identités de Ward car la formule précédente nous en donne une pour chaque courant de Noether. Rappelons les courants de Noether associés aux symétries conformes :

#align(center,
  table(
    columns: (auto, auto),
    align: (left, left),
    table.header([*Courant*], [*Symétrie associée*]),

    [$T^(mu nu) = T_cal(C)^(space.en mu nu) + partial_rho B^(rho mu nu) + 1/2 partial_lambda partial_rho X^(lambda rho mu nu) $], [translation],
    [$J^(mu nu rho) = T^(mu nu) x^rho - T^(mu rho) x^nu$], [Lorentz],
    [$j^mu_D = T^mu_(space.en nu) x^nu$], [dilatation],
    [$j^(mu nu)_K = -T^mu_(space.en rho) I^(rho nu)(x)$], [spéciale conforme]
  )
)

Établissons maintenant les identités de Ward pour chacune de ces symétries.

*Symétrie sous translation*

Le générateur des translations est $P_mu = -i partial_mu$ et le courant associé est donné par $T^(mu nu)$, donc, en remplaçant dans #ref(<ward>), on obtient

$
  0 &= partial_mu corr(j^mu_A (x) phi(x_1) ... phi(x_n)) + i sum^n_(k = 1) delta^((d)) (x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) \
    &= partial_mu corr(T^(mu nu) phi(x_1) ... phi(x_n)) + sum^n delta^((d)) (x - x_k) partial_k^nu corr(phi(x_1) ... phi(x_k) ... phi(x_n))
$

où on a utilisé la "linéarité" des fonctions de corrélation. Il s'agit de l'identité de Ward associée aux translations. De façon plus compacte, on écrit

$
  markrect(partial_mu corr(T^mu_(space.en nu) X) = -sum_k delta^((d)) (x - x_k) frac(partial, partial x^nu_(space.en k)) corr(X), padding: #.5em)
$

#linebreak()
De façon similaire, mais avec un peu plus d'effort, nous pouvons obtenir les autres identités de Ward associes aux courants #ref(<noether_r>), #ref(<noether_d>) et #ref(<noether_sct>), les résultats sont moins intéressant, plus compliqué, et nous n'allons donc pas les présenter puisqu'ils ne nous serviront pas après.


/*

*Symétrie de Lorentz*

Le générateur des transformations de Lorentz est $ L_(mu nu) = -i (x_mu partial_nu - x_nu partial_mu) $ et le courant de Noether associé est donné par $J^(mu nu rho)$. En remplaçant dans #ref(<ward>), on obtient

$
             & 0 = partial_mu corr(j^mu_A (x) phi(x_1) ... phi(x_n)) + i sum^n_(k = 1) delta^((d)) (x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) \
  space <==> & space partial_mu corr(J^(mu nu rho) phi(x_1) ... phi(x_n)) = sum_k delta^((d)) (x - x_k) [-i (x_mu partial_nu - x_nu partial_mu)] corr(phi(x_1) ... phi(x_k) ... phi(x_n)).
$

Dans le côté gauche de l'égalité, la dérivée partielle agit sur $ J^(mu nu rho) = T^(mu nu) x^rho - T^(mu rho) x^nu, $ c'est-à-dire sur $T^(mu nu)$ et $x^rho$, donc on peut utiliser l'identité de Ward précédente pour au final obtenir l'identité de Ward associé aux transformations de Lorentz :

$
  corr(T^([mu nu]) phi(x_1) ... phi(x_2)) = 1/2 sum_k delta^((d)) (x - x_k) corr(phi(x_1) ... phi(x_k) ... phi(x_n)),
$

ou, de façon plus compacte,

#v(0.5em)
$
  markrect(corr(T^([mu nu]) X) = 1/2 sum_k delta^((d)) (x - x_k) corr(X), padding: #.5em)
$
#v(0.5em)

*Symétrie sous dilatation*

Le générateur des dilatations est $D = -i(x^mu partial_mu)$ et le courant de Noether associé est donné par $j^mu_D$, En remplaçant dans #ref(<ward>), on trouve

$
  partial_mu corr(T^mu_(space.en nu) & x^nu phi(x_1) ... phi(x_n)) \
        &= -sum_k delta^((d)) (x - x_k) [x_k^n frac(partial, partial x_(n, k))] corr(phi(x_1) ... phi(x_k) ... phi(x_n)).
$

Comme précédemment, nous utilisons l'identité de Ward associé aux translations et trouvons

$
  corr(T^mu_(space.en mu) phi(x_1) ... phi(x_n)) = -sum_k delta^((d)) (x - x_k) corr(phi(x_1) ... phi(x_k) ... phi(x_n)),
$

ou encore, de façon plus compacte,

#v(0.5em)
$
  markrect(corr(T^mu_(space.en mu) X) = -sum_k delta^((d)) (x - x_k) corr(X), padding: #0.5em)
$
#v(0.5em)

*Symétrie sous transformations conformes spéciales*

TODO


Pour résumer, nous avons déterminé trois équations, trois _contraintes_, rappellées ci-dessous :
 
$
  &partial_mu corr(T^mu_(space.en nu) X) = -sum_k delta^((d)) (x - x_k) frac(partial, partial x^nu_(space.en k)) corr(X) && space.quad "(Translations)" \
  &corr(T^([mu nu]) X) = 1/2 sum_k delta^((d)) (x - x_k) corr(X)                                                         && space.quad "(Lorentz)" \
  &corr(T^mu_(space.en mu) X) = -sum_k delta^((d)) (x - x_k) corr(X)                                                     && space.quad "(Dilatations)"
$

Notons que pour des points de l'espace-temps distincts, $x != x_k$, ces identités se réduisent à

$
  &partial_mu corr(T^mu_(space.en nu) X) = 0 && space.quad "(Translations)" \
  &corr(T^([mu nu]) X) = 0                   && space.quad "(Lorentz)" \
  &corr(T^mu_(space.en mu) X) = 0            && space.quad "(Dilatations)"
$

Où, pour rappel, $X := corr(phi(x_1) phi(x_2) ... phi(x_n))$. Les contributions pour lesquelles $x = x_k$ sont connues sous le nom de "termes de contacte".

*/

== Opérateurs primaires et descendants
Les symétries conforment imposent des contraintes aux fonctions de corrélations. Une façon de classifier les opérateurs d'une théorie conforme des champs est directement issue de la représentation des générateurs du groupe conforme et est analogue aux opérateurs de créations de d'annihilation de l'oscillateur harmonique en mécanique quantique. Pour rendre cela manifeste, il est utile de se placer dans une autre convention que celle utilisée lors de la dérivation des générateurs associés aux transformations conformes. Nous allons utiliser

#align(center,
  table(
    columns: (auto, auto),
    align: (left, left),
    table.header([*générateur*], [*transformation*]),
  
    [$hat(P)_mu = partial_mu$], [Translation],
    [$hat(L)_(mu nu) = x_nu partial_mu - x_mu partial_nu$], [Lorentz],
    [$hat(D) = x^mu partial_mu$], [Dilatation],
    [$hat(K)_mu = 2 x_mu x^nu partial_nu - (x^2) partial_mu)$], [Spéciale conforme],
  )
)

Dans cette nouvelle convention, le $-i$ "disparaît" par rapport à ce que nous avions dérivé plus tôt. Il s'en suit que l'algèbre associée change, mais nous n'allons pas tout réécrire, uniquement

$
  & [hat(D), hat(P)_mu] = hat(P)_mu \
  & [hat(D), hat(K)_mu] = -hat(K)_mu.
$

Avec cette convention, il est plus facile de se rendre compte de l'analogie avec les opérateurs de création et de destruction en mécanique quantique :

$
  & [hat(D), hat(P)_mu] = hat(P)_mu  space.quad && <--> && space.quad [hat(N), hat(a)^dagger] = hat(a)^dagger \
  & [hat(D), hat(K)_mu] = -hat(K)_mu space.quad && <--> && space.quad [hat(N), hat(a)] = -hat(a)
$

où $hat(a)^dagger$ et $hat(a)$ sont les opérateurs de montée et de descente pour l'oscillateur harmonique, respectivement, et $hat(N)$ est l'opérateur de dénombrement ("number operator"). Cette similitude suggère que $hat(P)_mu$ et $hat(K)_mu$ peuvent être également compris comme des opérateurs de monter et de descente de $hat(D)$, ce qui est effectivement le cas. Nous allons choisir de travailler dans une base où nos états possèdent une valeur propre bien définie, $Delta$, sous dilatation (cela reviendra d'ailleurs un peu plus tard !) On note

$
  ket(Delta) = "état avec dimension" Delta.
$

Ces états vont être créés en agissant avec un opérateur $hat(O)_Delta (0)$ à l'origine, sur le vide

$
  hat(O)_Delta (0) ket(0) equiv ket(Delta).
$

#remark[
  Dans nos discussions, nous pouvons nous restreindre aux opérateurs insérés en $x = 0$, à l'origine, puisque les propriétés de transformation en tout autre point peuvent être obtenues en appliquant une translation,

  $
    hat(O)(x) = e^(x^mu hat(P)_mu) hat(O)(0) e^(-x^mu hat(P)_mu),
  $

  et en utilisant la formule de Baker–Campbell–Hausdorff ainsi que les relations de commutation de l'algèbre conforme. Il est juste plus pratique d'utiliser $hat(O)(0)$.
]

Par la correspondance état-opérateur, il est possible de générer tous les états de notre espace de Hilbert en agissant avec un opérateur local à l'origine. Ces opérateurs, $hat(O)_Delta$, vont satisfaire la relation de commutation suivante :

$
  hat(D) hat(O)_Delta (0) - hat(O)_Delta (0) hat(D) equiv [hat(D), hat(O)_Delta (0)] = Delta hat(O)_Delta (0).
$

Nous pouvons voir que tout cela est cohérent en agissant sur notre état avec $hat(D)$ :

$
  hat(D) ket(Delta) &= hat(D) hat(O)_Delta (0) ket(0) \
                    &= ([hat(D), hat(O)_Delta (0)] + hat(O)_Delta (0) hat(D)) ket(0) \
                    &= Delta hat(O)_Delta (0) ket(0) + 0 \
                    &= Delta ket(Delta)
$

où on a utilisé le fait que $hat(D)$ est associé à une symétrie du système, et donc il annule l'état du vide (car $ket(0)$ est invariant sous les symétries d'un système physique quelconque). Cela montre que $ket(Delta)$ est un état propre de $hat(D)$ avec une valeur propre $Delta$.

Pour revenir à la discussion initiale, de la même manière que l'opérateur de descente abaisse la valeur propre de l'opérateur de dénombrement $hat(N)$ pour les états de l'oscillateur harmonique, l'opérateur $hat(K)_mu$ agira comme un opérateur d'abaissement de l'opérateur de dilatation $hat(D)$. Comme dans l'oscillateur harmonique, nous aurons donc un état de plus faible poids pour nos états de dimension donnée. Nous appellerons ces états les "états primaires" et les opérateurs qui agiront sur le vide pour les générer sont appelés _opérateurs primaires_ et nous utiliserons la notation calligraphique $hat(cal(O))_Delta$ pour y faire référence spécifiquement. Contrairement à l'oscillateur harmonique, maintenant, où il n'existe qu'un seul opérateur d'abaissement, dans les théories conformes des champs, nous aurons en général plusieurs (parfois même une infinité) d'états primaires (souvenons-nous que l'oscillateur harmonique ne peut en effet avoir qu'un seul état fondamental). Nous voulons que ces états soient annihilés par $hat(K)_mu$. A cette fin, on impose que les opérateurs primaires commutent avec $hat(K)_mu$,

$
  [hat(K)_mu, hat(cal(O))_Delta (0)] = 0,
$

c'est d'ailleurs souvent uniquement cette relation qui est donnée pour définir les _opérateurs primaires_. Nous pouvons voir explicitement ce que cela implique que les états primaires soient annihilés par $hat(K)_mu$ :

$
  hat(K)_mu ket(Delta) &= hat(K)_mu hat(cal(O))_Delta (0) ket(0) \
                       &= hat(cal(O))_Delta (0) hat(K)_mu) ket(0) && space.quad "(commutent)" \
                       &= 0
$

où, à la dernière ligne, nous avons utilisé le fait que $hat(K)_mu$ est associé à une symétrie du système, et donc qu'il annihile le vide, comme avant. Autrement dit, cette relation de commutation rend bien compte de l'annihilation souhaitée.

Qu'en est-t-il de $hat(P)_mu$ maintenant ? Les états que nous avons discutés précédemment sont ceux de plus "faibles poids" (si l'on garde la similitude avec l'oscillateur harmonique), on voudrait donc voir ce qu'il se passe si l'on agit dessus avec $hat(P)_mu$, qui est censé se comporter comme un opérateur de montée. Considérons un nouvel état $ket(psi)$ qui est créé en faisant agir $hat(P)_mu$ sur un état propre de l'opérateur de dilatation,

$
  hat(P)_mu ket(Delta) = ket(psi)
$

Est-ce toujours un état propre de $hat(D)$ ? Nous pouvons le vérifier en calculant explicitement :

$
  hat(D) ket(psi) &= hat(D) hat(P)_mu ket(Delta) \
                  &= ([hat(D), hat(P)_mu] + hat(P)_(mu) hat(D)) ket(Delta) \
                  &= (hat(P)_mu + hat(P)_mu hat(D)) ket(Delta) \
                  &= hat(P)_mu ket(Delta) + hat(P)_mu hat(D) ket(Delta) \
                  &= hat(P)_mu ket(Delta) + hat(P)_mu Delta ket(Delta) \
                  &= (1 + Delta) hat(P)_mu ket(Delta) \
                  &= (1 + Delta) ket(psi).
$

Nous voyons ainsi que $ket(psi)$ est bien un état propre de $hat(D)$, avec une valeur $Delta + 1$. Concrètement, si nous partons d’un état créé par l’action d’un opérateur primaire $ket(Delta)$, puis que nous appliquons $hat(K)_mu$​, nous obtenons un nouvel état, appelé "descendant". De manière générale, à partir d’un opérateur primaire, les opérateurs $hat(K)_mu$ génèrent un ensemble d’opérateurs descendants, chacun correspondant à un nouvel état dont la dimension augmente de $1$ à chaque fois :

$
  hat(cal(O))_Delta                                 &= "opérateur primaire de dimension" Delta \
  hat(P)_mu hat(cal(O))_Delta                       &= "opérateur descendant de dimension" Delta + 1 \
                                                    &.\
                                                    &.\
                                                    &.\
  hat(P)_(mu_1) ... hat(P)_(mu_n) hat(cal(O))_Delta &= "opérateur descendant de dimension" Delta + n
$

Dès lors, étant donné un opérateur primaire, il lui sera toujours associé un ensemble (souvent infini) d'opérateurs descendants, on dira qu'ils forment une "famille". Autrement dit, étant donné que les opérateurs primaires génèrent les descendants par l'action de $hat(P)_mu$, il ne sera jamais nécessaire de spécifier d'autres opérateurs que les primaires, ce qui simplifiera grandement les discussions à l'avenir.

Il s'avère, de plus, que les propriétés de transformations des opérateurs primaires sont simples, il est possible de montrer qu'ils se transforment comme des densités tensorielles (ça n'est pas _aussi bien_ que de se transformer comme un tenseur, mais c'est tout de même une bonne chose) :

#v(0.5em)
$
  hat(tilde(cal(O)))^A_Delta (tilde(x)^mu) = mark(abs(frac(partial x^mu, partial tilde(x)^nu)), tag: #<j>, color: #red)^(Delta \/ D) mark(L^A_(space.en B), tag: #<l>, color: #blue) hat(cal(O))^B_Delta (x^mu)

  #annot(<j>, pos: right, yshift: 0.5em)[jacobien]
  #annot(<l>, pos: top + right, yshift: 0.5em)[représentation de Lorentz]
$<density>
#v(1em)

Les opérateurs descendants ne se transforment pas aussi bien et nous les invoquerons donc qu'implicitement, au travers des opérateurs primaires d'où ils sont issus par l'action de $hat(P)_mu$. Nous n'utiliserons pas cette formule par la suite, nous ne l'a prenons que comme remarque.






== L'operator product expansion (OPE)
Nous arrivons maintenant à un concept important (encore un !), l'_Operator Product Expansion_. Nous allons introduire le concept en utilisant des états afin d'avoir un point d'accroche sur quelque chose de déjà connu, mais nous nous en débarrasserons rapidement étant donné qu'ils ne sont pas nécessaires et que ça sera plutôt une aide qu'autre chose. Le but est d'écrire le produit d'opérateurs $phi(x) phi(0)$ comme une somme d'opérateurs insérés en un unique point (nous reviendrons sur le _pourquoi_ juste après). Considérons l'état $ket(psi)$ donné par

$
  ket(psi) = phi_1(x) phi_2(0) ket(0)
$

où $phi_1$ et $phi_2$ sont deux opérateurs primaires arbitraires (par simplicité, on considère des scalaires, mais la discussion reste valide pour des opérateurs indicés). Dans le cadre d'une théorie conforme, nous avons à notre disposition l'opérateur de dilatation $hat(D)$ et, de la même façon qu'en mécanique quantique nous pouvons diagonaliser l'opérateur hamiltonien et obtenir une base d'états propres, nous allons diagonaliser cet opérateur de dilatation : nous réécrivons $ket(phi)$ comme une somme dans une base d'états propres de $hat(D)$,

$
  ket(psi) = sum_k C_k ket(Delta_k)
$

où l'état $ket(Delta_k)$ inclus un opérateur primaire et tout ses descendants (en effet pour avoir une base complète on doit sommer sur tout les opérateurs). Réorganisons cette expression : 

$
  ket(psi) &= phi_1(x) phi_2(0) ket(0) \
           &= sum_k C_k ket(Delta_k) \
           &= sum_(phi_I) C_(Delta, I) (x, partial) phi_I (0) ket(0)
$

où cette fois nous rendons explicite le fait que nous sommons sur les opérateurs primaires, les opérateurs descendants de $phi$ ayant été pris en compte dans le coefficient $C$ par l'action de la dérivée partielle (rappelons en effet qu'un opérateur descendant est défini à une constante près comme une $n$-dérivée partielle d'un opérateur primaire). Chaque terme de la somme inclus donc un opérateur primaire et tout ses descendants. Nous avons également inclus un indice $Delta$ pour la dimension d'échelle de l'opérateur primaire et un indice $I$ pour la représentation de Lorentz associée à cet opérateur. Nous avons tout exprimé en termes d'états, mais cela n'était que pour partir d'une analogie de quelque chose de connu et nous pouvons oublié le fait que nous parlions d'états,

$
  cancel(ket(psi), stroke: #(paint: red, dash: "dashed", thickness: 0.7pt), cross: #true)
            &= phi_1(x) phi_2(0) cancel(ket(0), stroke: #(paint: red, dash: "dashed", thickness: 0.7pt), cross: #true) \
            &= sum_(phi_I) C_(Delta, I) (x, partial) phi_I (0) cancel(ket(0), stroke: #(paint: red, dash: "dashed", thickness: 0.7pt), cross: #true)
$

et "promouvoir" la discussion en terme d'opérateurs uniquement, ce qui nous donne alors simplement une égalité entre opérateurs,

#v(0.5em)
$
  markrect(phi_1(x) phi_2(0) = sum_(phi_I) C_(Delta, I) (x, partial) phi_I (0), padding: #0.5em)
$<OPE>
#v(0.5em)

C'est ce qu'on appelle l'_Operator Product Expansion_ (abrégé OPE); et cela ne fonctionne pas uniquement que par magie, il y a aussi un contexte à prendre en compte :

 1. l'OPE n'est _vraie_ que dans une fonction de corrélation ;
 2. les autres opérateurs qui se trouvent dans la fonction de corrélation doivent être "suffisamment éloignés" du produit considéré.

#remark[
  Si l'on tente d'être formel, le second point peut s'interpréter de la sorte : les autres opérateurs qui se trouvent dans la fonction de corrélation doivent se situés à l'extérieur d'une sphère de rayon $abs(x)$, autrement il y a des problèmes de convergence et l'OPE n'est pas assurée de converger.
]

En fait, selon le point de vue adopté, la discussion précédente est soit postulée pour la théorie conforme des champs, soit démontrable. En CFT pure, sans réel autre préalable qui n'ait été présenté dans ce document, nous ne pouvons pas faire mieux que de prendre comme axiome les points précédents et allons, de plus, supposer que l'OPE converge dans le cadre de la CFT.

#v(1.5em)
#figure(
  cetz.canvas({
    import cetz.draw: *

    // <
    
    line((-1.5, 0), (0, 1.5))
    line((-1.5, 0), (0, -1.5))

    // content
    
    circle((1.2, 0.8), radius: 2pt, fill: gray)  
    circle((0.5, -0.3), radius: 2pt, fill: gray)  
    circle((2.7, 0.4), radius: 2pt, fill: gray)  
    circle((0.9, -1.1), radius: 2pt, fill: gray)  
    circle((2.3, 1.0), radius: 2pt, fill: gray)  
    circle((1.5, -0.8), radius: 2pt, fill: gray)  
    circle((0.3, 0.4), radius: 2pt, fill: gray)  
    circle((-0.3, -0.6), radius: 2pt, fill: gray)  
    circle((2.4, -0.3), radius: 2pt, fill: gray)  
    circle((-0.4, 0.6), radius: 2pt, fill: gray)  
    circle((1.6, -0.1), radius: 2pt, fill: gray)  
    circle((2.5, -0.5), radius: 2pt, fill: gray)  

    // >
    
    line((1.5 + 2.5, 0), (0 + 2.5, 1.5))  
    line((1.5 + 2.5, 0), (0 + 2.5, -1.5))

    // circle close points
    
    circle((2.45, -0.4), radius: (10pt))

    // =
    
    line((1 + 5, 0.1), (0 + 5, 0.1))
    line((1 + 5, -0.1), (0 + 5, -0.1))

    // <

    line((-1.5 + 8.4, 0), (0 + 8.4, 1.5))
    line((-1.5 + 8.4, 0), (0 + 8.4, -1.5))

    // content
    
    circle((1.2 + 8.4, 0.8), radius: 2pt, fill: gray)  
    circle((0.5 + 8.4, -0.3), radius: 2pt, fill: gray)  
    circle((2.7 + 8.4, 0.4), radius: 2pt, fill: gray)  
    circle((0.9 + 8.4, -1.1), radius: 2pt, fill: gray)  
    circle((2.3 + 8.4, 1.0), radius: 2pt, fill: gray)  
    circle((1.5 + 8.4, -0.8), radius: 2pt, fill: gray)  
    circle((0.3 + 8.4, 0.4), radius: 2pt, fill: gray)  
    circle((-0.3 + 8.4, -0.6), radius: 2pt, fill: gray)  
    //circle((2.4 + 8.4, -0.3), radius: 2pt, fill: gray)  
    circle((-0.4 + 8.4, 0.6), radius: 2pt, fill: gray)  
    circle((1.6 + 8.4, -0.1), radius: 2pt, fill: gray)  
    //circle((2.5 + 8.4, -0.5), radius: 2pt, fill: gray)  
    circle((10.85, -0.4), radius: 3pt, fill: red)

    // >
    
    line((1.5 + 2.5 + 8.4, 0), (0 + 2.5 + 8.4, 1.5))  
    line((1.5 + 2.5 + 8.4, 0), (0 + 2.5 + 8.4, -1.5))

  }),
  caption: [Visualisation d'une OPE]
)<OPE_fig>
#v(1.5em)

La figure #ref(<OPE_fig>) illustre schématiquement cette nouvelle notion d'_Operator Product Expansion_, où l'on voit que deux opérateurs "suffisamment proches" l'un de l'autre dans une fonction de corrélation sont remplacés par un nouveau et unique opérateur au moyen de l'OPE. Dès lors, toute fonction de corrélation à $n > 2$ points peut se réduire à une fonction de corrélation à $(n-1)$ points au moyen de l'OPE.

#remark[
  Il s'avère que, numériquement, l'OPE est une opération qui converge rapidement. Cela sera particulièrement intéressant pour le bootstrap.
]

On pourrait se poser la question suivante : étant donné que nous avons dit à plusieurs reprises qu'une théorie invariante sous dilatation ne possède plus vraiment de notion d'être "proche" ou "éloigné" (souvenons nous par exemple de l'argument donné pour la matrice S), pourquoi dit-t-on que l'OPE entre deux opérateurs ne se fait que si ces derniers sont "suffisamment proches" ? La réponse est simple : ici, on compare des distances _relatives_, ce qui élimine donc l'invariance sous dilatation de la discussion, et ce qui nous permet donc de bien établir l'OPE.

Comme cela a été fait remarqué, l'OPE est définie vis-à-vis de la distance relative, d'où le choix arbitraire du produit $phi(x) phi(0)$ dans la définition #ref(<OPE>), nous pourrions imaginer une définition tout à fait équivalente où l'on prend le produit $phi(x_1)phi(x_2)$ :

$
  phi(x_1)phi(x_2) = sum_(phi_I) C_(Delta, I) (x_1 - x_2, partial) phi_I ((x_1 + x_2) / 2)
$

et si l'on considère un produit $phi_i (x_1) phi_j (x_2)$, alors on adapte la définition pour écrire

$
  phi_i (x_1) phi_j (x_2) = sum_k markul(C_(i j k)^(Delta, I), color: #red, tag: #<sm>) phi_k^I ((x_1 + x_2) / 2).

  #annot(<sm>, yshift: 0.7em, pos: bottom + right)[Simple sommation, pas de notation d'Einstein]
$
#v(0.7em)

Les notations peuvent varier selon la convention ou l'usage, mais l'idée reste la même. Dans ces notations, il peut être plus facile d'exprimer la seconde condition mentionnée plus tôt, on aura une OPE valide ssi $abs(x_1 - x_2) << abs(x_1 - x_l)$ pour tout $l eq.not 2$.

#remark[
  Sachant qu'il existe une infinité d'opérateurs descendants étant donné un opérateur primaire, cette somme doit être comprise comme un développement en série.
]

Il est possible, uniquement par analyse dimensionnelle, de déterminer la première contribution de l'OPE entre deux scalaires. Pour simplifier, prenons $phi_1(x) phi_2(0)$ où $phi_1$ a une scaling dimension $Delta_1$ et $phi_2$ a une scaling dimension $Delta_2$. Alors, il vient que

$
  phi_1(x) phi_2(0) ~ frac(1, abs(x)^(Delta_1 + Delta_2))
$<jsp6>
#v(0.7em)

L'expression #ref(<jsp6>) découle du principe d'invariance conforme: pour que le produit d'opérateurs $phi_1(x) phi_2(0)$ respecte les transformations d'échelle, sa dépendance en $|x|$ doit compenser la dimension totale $Delta_1+Delta_2$ des deux opérateurs, d'où la forme $1 \/ abs(x)^(Delta_1 + Delta_2)$. Nous verrons un peu plus tard en détail, au #ref(<sec_conf>), comment les symétries conformes influencent la forme des fonctions de corrélation.

=== Exemple -- boson libre et sans masse
Considérons l'action d'un boson libre, donné par

$
  S = 1/2 g integral dd^2 x space (partial_mu phi partial^mu phi + m^2 phi^2)
$

où $g in RR$ est simplement un paramètre de normalisation. Cette action donne lieue à l'équation de Klein-Gordon, en effet avec $cal(L)(phi, partial_mu phi) = g\/2 (partial_mu phi partial^mu phi + m^2 phi^2)$ on a

$
       space & frac(partial cal(L), partial cal(phi)) - partial_mu frac(partial cal(L), partial (partial_mu phi)) approx 0 \
  <==> space & g/2 [ 2m^2 phi - partial_mu frac(partial cal(L), partial (partial_mu phi)) (partial_mu phi partial^mu phi) ] approx 0 \
  <==> space & g/2 [ 2m^2 phi - eta^(mu nu) partial_mu frac(partial cal(L), partial (partial_mu phi)) (partial_mu phi partial_nu phi) ] approx 0 \
  <==> space & g/2 [ 2m^2 phi - eta^(mu nu) partial_mu (partial_nu phi + delta^(mu nu) partial_mu) ] approx 0 \
  <==> space & g/2 [ 2m^2 phi - 2 partial_mu partial^mu phi ] approx 0 \
  <==> space & g(-square + m^2) phi(x) approx 0 space.quad "(Klein Gordon)".
$

où $square equiv partial_mu partial^mu$ est le d'Alembertien. Nous pouvons définir la fonction de corrélation suivante :

$
  K(x, y) := corr(phi(x) phi(y))
$

bien dans le cadre d'une théorie quantique des champs, on préférera parler de _propagateur_, dans ce qui nous intéresse ces termes sont interchangeables. Puisque l'action mène à l'équation de Klein-Gordon, on sait que ce propagateur doit satisfaire

$
  g(-square + m^2) K(x, y) = delta^((2))(x - y)
$<kg1>

autrement dit, le propagateur pour $phi$ est une fonction de Green de l'équation de Klein-Gordon. En utilisant ce fait, nous sommes en mesure de trouver l'expression de $K(x, y)$. Pour se faire, faisons le changement de coordonnées $r := abs(x - y)$ de façon à ce que

$
  square = partial^2_x = 1/r frac(partial, partial r) (r frac(partial, partial r)).
$

En ne considérant pas d'interaction de masse, $m = 0$, #ref(<kg1>) s'écrit alors

$
       space & g(-square + m^2) K(x, y) = delta^((2))(x - y) \
  <==> space & g[-1/r frac(partial, partial r) (r frac(partial, partial r)) + 0] K(r) = delta^((2))(r) \
  <==> space & -g frac(1, r) frac(partial, partial r) (r frac(partial K, partial r)) = delta^((2))(r).
$

En coordonnées polaires, on peut montrer que le delta de Dirac s'exprime comme $ delta^((2))(r) = frac(delta(r), 2 pi r), $ nous nous retrouvons alors avec

$
  -frac(g, r) frac(partial, partial r) (r frac(partial K, partial r)) = frac(delta(r), 2 pi r)
$

et il ne nous reste plus qu'à résoudre cette équation différentielle :

$
       space.quad & -frac(g, r) frac(partial, partial r) (r frac(partial K, partial r)) = frac(delta(r), 2 pi r) \
  <==> space.quad & -2 pi g frac(dd, dd r) (r frac(dd K, dd r)) = delta(r) \
  <==> space.quad & -2 pi g integral frac(dd, dd r) (r frac(dd K, dd r)) space dd r = integral delta(r) space dd r \
  <==> space.quad & -2 pi g (r frac(dd K, dd r)) = 1 \
  <==> space.quad & frac(dd K, dd r) = -frac(1, 2 pi g r) \ \
  <==> space.quad & markrect(K(r) = -frac(1, 2 pi g) log(r) + C, padding: #.5em)
$<s1>
#v(0.5em)

Donc, nous avons explicitement calculé la fonction de corrélation du champs scalaire libre réel. Selon les auteurs (voir par exemple _Di Francesco_), cette solution prend également la forme

$
  K(r) = -frac(1, 4 pi g) log(r^2) + C
$<s2>

mais #ref(<s1>) et #ref(<s2>) sont bien-sûr totalement équivalent puisque $log(a^b) equiv b log(a)$, cette dernière notation est en fait plus utile lorsque l'on veut passer à des coordonnées complexes. En ré-exprimant $r$ dans les coordonnées cartésiennes, on a finalement trouvé

$
  K(bold(x), bold(y)) := corr(phi(bold(x)) phi(bold(y))) &= -frac(1, 2 pi g) log(abs(bold(x) - bold(y))) + C \
                                                         &equiv -frac(1, 4 pi g) log(abs(bold(x) - bold(y))^2) + C.
$

*L'OPE de $partial phi$ et $partial phi$*

En passant aux coordonnées complexes, justement, avec $bold(x) = (x, y)$ que l'on ré-exprime en définissant $z := x + i y$ et $bold(y) = (u, v)$ que l'on ré-exprime avec $omega := y + i v$ et en connaissant l'identité $abs(z - omega)^2 equiv (z - omega)(macron(z) - macron(omega))$, le résultat précédent peut se réécrire comme

$
  corr(phi(z, macron(z)) phi(omega, macron(omega))) = -frac(1, 4 pi g) [ log(z - omega) + log(macron(z) - macron(omega)) ] + C.
$<bo1>

Prenons maintenant la dérivée des deux côtés de #ref(<bo1>),

$
  & corr(partial_z phi(z, macron(z)) partial_omega phi(omega, macron(omega))) = frac(1, 4 pi g) frac(1, (z - omega)^2) \
  & corr(partial_(macron(z)) phi(z, macron(z)) partial_(macron(omega)) phi(omega, macron(omega))) = frac(1, 4 pi g) frac(1, (macron(z) - macron(omega))^2) 
$

et de là il est maintenant manifeste que nous avons les OPE suivante :

#v(0.5em)
$
  & markrect(partial_z phi(z, macron(z)) partial_omega phi(omega, macron(omega)) ~ frac(1, 4 pi g) frac(1, (z - omega)^2), padding: #.5em) \
  #v(4.5em)
  & markrect(partial_(macron(z)) phi(z, macron(z)) partial_(macron(omega)) phi(omega, macron(omega)) ~ frac(1, 4 pi g) frac(1, (macron(z) - macron(omega))^2), padding: #.5em)
$<bo2>
#v(0.5em)

*L'OPE de $T$ et $partial phi$*

Le tenseur énergie-impulsion classique pour le boson libre et sans masse est donné par

$
  T_(mu nu) = g (partial_mu phi partial nu phi - 1/2 eta_(mu nu) partial_rho phi partial^rho phi)
$

et en coordonnées complexes,

$
  & T(z, macron(z)) equiv -2 pi T_(z z) = -2 pi g [ (partial phi)^2 - 1/2 eta_(z z) partial_rho phi partial^rho phi ] = -2 pi g (partial phi)^2 \
  & macron(T)(z, macron(z)) equiv -2 pi macron(T)_(z z) = -2 pi g [ (macron(partial) phi)^2 - 1/2 eta_(macron(z) macron(z)) partial_rho phi partial^rho phi ] = -2 pi g (macron(partial) phi)^2
$

#remark[
  La "version quantique" de ce tenseur énergie-impulsion est généralement présenté avec l'ordre normal et le théorème de Wick, mais cela sort du cadre de ce document et nous allons simplement nous contenter des résultats sans aller trop en profondeur, le but est de voir à quoi ressemble l'OPE sur des cas concrets après tout.
]

On peut donc montrer qu'après quantification,

$
  T(z, macron(z)) &= - 2 pi g :partial phi partial phi: \
                  &= - 2 pi g lim_(omega -> z) lim_(macron(omega) -> macron(z)) [ partial phi(z, macron(z)) partial phi(omega, macron(omega)) - corr(partial phi(z, macron(z)) partial phi(omega, macron(omega))) ]
$

L'OPE de $T$ et $partial phi$ peut être calculer en utilisant le théorème de Wick :

$
T(z, macron(z)) partial phi(w, macron(w)) 
  &= - 2 pi g lim_(z_1 -> z) lim_(macron(z_1) -> macron(z)) 
    ( partial phi(z, macron(z)) partial phi(z_1, macron(z_1)) 
    - corr(partial phi(z, macron(z)) partial phi(z_1, macron(z_1))) ) 
    partial phi(w, macron(w)) \

  &~ - 2 pi g lim_(z_1 -> z) lim_(macron(z_1) -> macron(z))
    [ ( corr( partial phi(z, macron(z)) partial phi(w, macron(w)) ) partial phi(z_1, macron(z_1)) ) \
    & "                      " + corr( partial phi(z, macron(z)) partial phi(z_1, macron(z_1)) ) partial phi(w, macron(w)) \
    & "                      " + corr( partial phi(z_1, macron(z_1)) partial phi(w, macron(w)) ) partial phi(z, macron(z)) \
    & "                      " - corr( partial phi(z, macron(z)) partial phi(z_1, macron(z_1)) ) partial phi(w, macron(w)) ] \

  &~ - 2 pi g lim_(z_1 -> z) lim_(macron(z_1) -> macron(z)) ( corr( partial phi(z, macron(z)) partial phi(w, macron(w)) ) partial phi(z_1, macron(z_1)) \
    & "                      " + corr( partial phi(z_1, macron(z_1)) partial phi(w, macron(w)) ) partial phi(z, macron(z)) ) \

 &~ - 4 pi g corr( partial phi(z, macron(z)) partial phi(w, macron(w)) ) partial phi(z, macron(z)) \

 &~ (partial phi(z, macron(z))) / (z - w)^2
$

où, à la dernière ligne, nous avons utilisé le résultat #ref(<bo2>). On peut ensuite développer $partial phi$ autour de $(omega, macron(omega))$,

$
  partial phi(z, macron(z)) approx partial phi(omega, macron(omega)) + partial^2 phi(omega, macron(omega)) (z - omega) + 1/2! partial^3 phi(omega, macron(omega)) (z - omega)^2 + ...
$

ce qui nous donne au final l'OPE suivante :

#v(0.5em)
$
  markrect(padding: #.5em,
    T(z) partial phi(omega, macron(omega)) ~ frac(partial phi(omega, macron(omega)), (z - omega)^2) + frac(partial^2 phi(omega, macron(omega)), (z - w))
  )
$
#v(0.5em)

*L'OPE de $T$ et $T$*

Une dérivation similaire à la précédente peut être faite pour calculer $T(z) T(omega)$, mais le calcul est beaucoup plus lourd, nous allons donc sauter la grosse étape de calcul par commodité. On a

#v(0.5em)
$
  markrect(padding: #.5em,
    T(z) T(omega) ~ frac(1\/2, (z - omega)^4) + frac(2 T(omega), (z - omega)^2) + frac(partial T(omega), (z - omega))
  )
$<bo3>
#v(0.5em)

où, en gros, il y a deux façons d'effectuer une contraction de Wick $partial phi partial phi$ et il y a quatre façons d'effectuer une seule contraction de Wick, et après avoir développé on trouve bien #ref(<bo3>).

#remark[
  Dans le cadre d'une CFT en $d = 2$, il sera souvent indiqué que la _charge centrale_ associée à cette OPE est ici égale à $1$. De façon plus générale, l'OPE du tenseur énergie-impulsion s'écrit

  $
    T(z) T(omega) ~ frac(c\/2, (z - omega)^4) + frac(2 T(omega), (z - omega)^2) + frac(partial T(omega), (z - omega))
  $

  où $c in RR$ est une constante que l'on appelle parfois la "charge centrale". Dans le cadre d'une CFT en $d >= 3$, cette notion est assez arbitraire et n'est en fait pas utile (en effet, on donne juste un nom à une constante...) En fait, la charge centrale est utile dans une CFT en deux dimensions, où elle correspond à une valeur propre d'un casimir (d'où le nom).

  Dans le cas présent, il est claire que $c = 1$.
]

#remark[
  Si l'on veut aller un peu plus loin et comprendre _en surface_ comment nous avons calculé les résultats précédents, nous présentons ici une très brève description des concepts invoqués plus haut. Pour deux opérateurs $hat(A)$ et $hat(B)$ on définit leur _contraction_ comme étant

  $
    hat(A)^bullet hat(B)^bullet equiv hat(A) hat(B) - :hat(A)hat(B):
  $

  où $:hat(A)hat(B):$ indique que les opérateurs $hat(A)$ et $hat(B)$ sont placés dans l'_ordre normal_ : tout les opérateurs de création (ou apparenté) sont placés à gauche de tout les opérateurs de destruction (ou apparenté). La contraction est donc définie comme la différence entre leur produit ordinaire et leur produit en ordre normal, ce qui "mesure" à quel point le produit ordinaire n'est pas déjà normalement ordonné.

  #example[
    Prenons par exemple $ :hat(b)^dagger hat(b): "" = "" hat(b)^dagger hat(b). $ Puisque les deux opérateurs sont déjà dans l'ordre souhaité, la notation de Wick ne donne rien de particulier. Un exemple plus intéressant est $ :hat(b)hat(b)^dagger: "" = "" hat(b)^dagger hat(b) $ où ici on voit que les opérateurs ont été explicitement ordonné. Un exemple avec plus de deux opérateur pourrait être $ :hat(b)^dagger hat(b) hat(b) hat(b)^dagger hat(b) hat(b)^dagger hat(b): "" = "" hat(b)^dagger hat(b)^dagger hat(b)^dagger hat(b)hat(b)hat(b)hat(b) = (hat(b)^dagger)^3 hat(b)^4. $
  ]

  Le _théorème de Wick_ énonce que le produit $hat(A)hat(B)hat(C)hat(D)hat(E)hat(F)...$ d'opérateurs de création et d'opérateurs de destruction peut s'exprimer comme la somme

  $
    hat(A)hat(B)hat(C)hat(D)hat(E)hat(F)... = "" :hat(A)hat(B)hat(C)hat(D)hat(E)hat(F)...: &+ sum_"simple" :hat(A)^bullet hat(B)^bullet hat(C)hat(D)hat(E)hat(F)...: \
                                                                                        &+ sum_"double" :hat(A)^(bullet) hat(B)^(bullet bullet) hat(C)^(bullet bullet) hat(D)^bullet hat(E)hat(F)...: \
                                                                                        &+ space ...
  $

  Nous n'allons pas entrer dans les détails, ni maintenant ni dans les calculs utilisant les contractions de Wick, mais allons simplement y faire mentions lorsque cela sera utile pour savoir d'où un résultat sort.
]



/*

=== Le système fantôme
Considérons l'action suivante :

$
  S = 1/2 g integral dd^2 x space b_(mu nu) partial^mu c^nu
$

où $b_(mu nu) = b_(nu mu)$ avec $b^mu_(space.en mu) = 0$ et $c^nu$ sont des champs qui anti-commutent (donc dans le cadre d'une QFT on dirait qu'on est fasse à un système décrivant des fermions). Commençons par trouvons les équations du mouvement, une façon de faire autre qu'avec les équations de Euler-Lagrange et qui sera plus directe ici est de faire varier l'action par rapport aux deux champs respectivement :

 - *champs $c^nu$* -- on fait varier $S$ par rapport à $c^nu$, on intègre par parties et on suppose que les termes aux bords s'annulent,
 
 $
         & space.quad delta_c S = 1/2 g integral dd^2 x space b_(mu nu) partial^mu (delta_c c^nu) approx 0 \
         #v(1.5em)
    <==> & space.quad markrect(partial^mu b_(mu nu) approx 0, padding: #.5em)
 $

 - *champs $b_(mu nu)$* -- on suit les mêmes étapes, ce qui nous donne, sachant que $b$ est symétrique,

 $
         & space.quad delta_b S = 1/2 g integral dd^2 x space delta b_(mark(mu nu)) partial^(mark(mu)) c^(mark(nu)) approx 0 \
         #v(1.5em)
    <==> & space.quad markrect(partial^mu c^nu + partial^nu c^mu approx 0, padding: #.5em)
 $

On passe aux coordonnées complexes, et on pose $c := c^z$ et $macron(c) = c^(macron(z))$. La première équation du  mouvement, $partial^mu b_(mu nu) = 0$, se réécrit sous forme complexe avec $mu, nu in {z, macron(z)}$, donc on écrira en conséquence que $partial^z = 2 partial_(macron(z)) equiv 2 macron(partial)$ et $partial^(macron(z)) = 2 partial_z equiv 2 partial$. Pour $nu = z$,

$
  partial^mu b_(mu nu) = 0 space.quad &<==> space.quad partial^z b_(z z) + cancel(partial^(macron(z)) b_(macron(z) z)) = 0 \
                                      #v(1.5em)
                                      &<==> space.quad markrect(macron(partial) b = 0, padding: #.5em)
$

et pour $nu = macron(z)$,

$
  partial^mu b_(mu macron(z)) = 0 space.quad &<==> space.quad cancel(partial^z b_(z macron(z))) + partial^(macron(z)) b_(macron(z) macron(z)) = 0 \
                                      #v(1.5em)
                                      &<==> space.quad markrect(partial macron(b) = 0, padding: #.5em)
$

La seconde équation du mouvement, $partial^mu c^nu + partial^nu c^mu = 0$, sous forme complexe s'écrit

$
  & partial^z c^(macron(z)) - partial^(macron(z)) c^z = 0 \
  & partial^z macron(c) - partial^(macron(z)) = 0 \
  & partial macron(c) - macron(partial) c = 0
$

*/

== Symétries conformes et fonctions de corrélations<sec_conf>
Nous avons déjà vu à quelques reprises que les symétries conforment contraignent les fonctions de corrélation, cette section est dédiée à une étude plus approfondie de ce fait. Nous allons orienter la discussion aux opérateurs scalaires étant donné qu'il est plus simple de raisonner sur ces derniers, mais bien-entendu cela se généralise à toute sorte d'opérateur, à la seule différence près que d'autres objets devront apparaître pour gérer les indices. Pour rester simple, nous ne voulons pas nous encombrer de tels objets (qui ne sont en réalité rien d'autre que des constantes). Nous noterons ces opérateurs scalaires par $cal(O)_Delta$, où $Delta$ est leur dimension, et considérerons qu'il s'agit d'opérateurs primaires.

Souvenons-nous que les fonctions de corrélation jouent le rôle des observables dans une théorie conforme des champs, autrement dit les fonctions de corrélations _doivent être indépendantes_ du choix de la configuration. Dès lors, en CFT, toute fonction de corrélation doit être invariante sous les transformations conformes. On impose donc que

#v(0.5em)
$
  markrect(
      corr(tilde(cal(O))_1 (x_1^mu) tilde(cal(O))_2 (x_2^mu) space ... space tilde(cal(O))_n (x_n^mu)) overset(=, !) corr(cal(O)_1 (x_1^mu) cal(O)_2 (x_2^mu) space ... space cal(O)_n (x_n^mu)) space.quad forall x^mu_i ,
      padding: #.5em
  )
$<indp>
#v(0.5em)

C'est en appliquant cette règle (qui _doit_ exister pour que la théorie soit physique) que nous allons pouvoir déduire la forme des fonctions de corrélations scalaires à un, deux et trois points, comme nous le verrons juste après.

#remark[
  Dans #ref(<indp>), nous avons changé les opérateurs "$tilde(cal(O))_i -> cal(O)_i$" mais les avons gardés évalués aux mêmes points, en effet cela ne ferrait pas beaucoup de sens de comparer des fonctions de corrélations évaluées en des points différents ! Dans la suite, il sera en fait plus pratique d'évaluer les fonctions de corrélations en les points transformés, $tilde(x)^mu$ plutôt qu'en les points d'origines, $x^mu$.
]

Rappelons également que les opérateurs primaires se transforment comme des densités (voir #ref(<density>)), autrement dit, pour des opérateurs scalaires,

$
       space & tilde(cal(O))^A_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial x^nu))^(Delta\/D) L^A_(space.en B) cal(O)^B_Delta (x^mu) \
  <==> space & tilde(cal(O))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial x^nu))^(Delta\/D) cal(O)_Delta (x^mu)
$

où, comme annoncé nous nous débarrassons ainsi du $L^A_(space.en B)$ qui n'apporte rien à la discussion.

=== Fonctions de corrélation scalaire à un point
Appliquons la contrainte #ref(<indp>) à la fonction de corrélation scalaire à un point,

$
  corr(cal(O)_Delta (tilde(x)^mu)) overset(=, !) corr(tilde(cal(O))_Delta (tilde(x)^mu))
$

où, comme cela a été fait remarqué juste avant, nous l'évaluons en le point $tilde(x)^mu$ plutôt qu'en $x^mu$ par commodité. Cette contrainte doit être vérifiée pour toute les transformations conformes.

*Translation*

Pour les translations, $tilde(x)^mu = x^mu + a^mu$, le jacobien s'écrit

$
  abs(frac(partial tilde(x)^mu, partial x^nu)) = abs(frac(partial x^mu, partial x^nu) + frac(partial a^mu, partial x^nu)) = abs(delta^mu_(space.en nu)) = 1.
$

Donc notre opérateur ne change pas sous la translation, $tilde(cal(O))_Delta (tilde(x)^mu) = cal(O)_Delta (x^mu)$, d'où

$
  corr(cal(O)_Delta (tilde(x)^mu)) = corr(cal(O)_Delta (x^mu)).
$

Sachant que cela doit être vrai pour tout $x^mu$, on peut en conclure que la fonction de corrélation à un point est en fait une constante sous translation. Vérifions que les autres transformations de symétrie conforme sont en accord avec cette affirmation.

*Dilatation*

Pour les dilatations, $tilde(x)^mu = lambda x^mu$ ou encore $x^mu = tilde(x)^mu \/ lambda$. Le jacobien s'écrit alors

$
  abs(frac(partial x^mu, partial tilde(x)^mu)) = abs(frac(delta^mu_nu, lambda)) = abs(1/lambda) = lambda^(-D),
$

un opérateur scalaire se transforme donc comme

$
  tilde(cal(O))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial tilde(x)^nu))^(Delta\/D) cal(O)_Delta (x^mu) = lambda^(-Delta) cal(O)_Delta (x^mu).
$

Remarquons que nous avions déjà intuité ce résultat plus tôt. Dans une fonction de corrélation à un point, nous avons alors

$
  corr(cal(O)_Delta (tilde(x)^mu)) &= corr(tilde(O)_Delta (tilde(x)^mu)) \
                                   &= corr(lambda^(-Delta) cal(O)_Delta (x^mu)) \
                                   &= lambda^(-Delta) corr(cal(O)_Delta (x^mu)) space.quad forall x^mu
$

mais, précédemment pour les translations, nous avions trouvé que

$
  corr(cal(O)_Delta (tilde(x)^mu)) = "const." =: C space.quad forall x^mu,
$

ce qui indique que

$
  space C = lambda^(-Delta) C.
$

Cette équation _doit_ être vraie pour tout facteur de dilatation $lambda$, ce qui est vérifié si $Delta = 0$ ou si $C = 0$. Puisque le cas $Delta = 0$ correspond à un opérateur de dimension nulle, il ne peut s'agir que d'une constante et est donc non-intéressant. Dès lors, nous pouvons conclure que toute les fonctions de corrélation à un point doivent s'annuler :

#v(0.5em)
$
  markrect(corr(cal(O)_Delta (x^mu)) = 0 space.quad forall x^mu " et pour " Delta != 0, padding: #.5em)
$
#v(0.5em)

Les autres transformations conformes suivent trivialement (ça donnera $0$ à chaque fois).

=== Fonctions de corrélation scalaire à deux points
Nous faisons pareil pour la fonction scalaire à deux points, on impose donc que

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) overset(=, !) corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu))
$<t11>

et nous étudions les symétries conformes selon cette contrainte.

*Translation*

Remarquons, pour commencer, que $corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu))$ est une fonction des positions renvoyant un nombre, il sera plus facile, dans ce cas, d'écrire que

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) =: f(tilde(x)_1^mu, tilde(x)_2^mu).
$

Nous savons également du point précédent que, sous les translations, les opérateurs scalaires primaires se transforment suivant $tilde(cal(O))_Delta (tilde(x)^mu) = cal(O)_Delta (x^mu)$, donc en insérant ce résultat dans le membre de droite de #ref(<t11>) on trouve

$
       space & corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) = corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) \
  <==> space & f(tilde(x)_1^mu, tilde(x)_2^mu) = f(x_1^mu, x_2^mu).
$

De plus, on a que $tilde(x)^mu = x^mu + a^mu$, ce qui nous permet d'écrire que

$
       space & f(tilde(x)_1^mu, tilde(x)_2^mu) = f(x_1^mu, x_2^mu) \
  <==> space & f(x_1^mu + a^mu, x_2^mu + a^mu) = f(x_1^mu, x_2^mu) space.quad forall a^mu.
$

Ce résultat doit être vrai peu importe la valeur de $a^mu$, ce qui suggère que le terme $a^mu$ doit s'annuler à un moment (sinon l'égalité ne tiendrait jamais). La seule façon pour que $a^mu$ soit annulé est en ayant une fonction dépendante uniquement de $x_1^mu - x_2^mu$,

$
  f(x_1^mu, x_2^mu) = f(x_1^mu - x_2^mu),
$

autrement dit, la fonction de corrélation à deux points doit être une fonction non pas de deux positions, mais plutôt du déplacement entre ces deux positions :

$
  corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = f(x_1^mu - x_2^mu).
$

Nous ne pouvons pas en dire beaucoup plus pour le moment.

*Rotation*

Pour les transformations de Lorentz, on a $tilde(x)^mu = Lambda^mu_(space.en nu) x^nu$, le jacobien s'exprime alors

$
  abs(frac(partial x^mu, partial tilde(x)^nu)) = abs((Lambda^(-1))^mu_(space.en nu) delta^nu_mu) = 1
$

puisque le déterminant de la matrice de transformation de Lorentz est égale à $1$. Les opérateurs scalaires primaires se transforment donc de la même façon sous les translations et sous les rotations :

$
       & space corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) = corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) \
  <==> & space f(tilde(x)_1^mu, tilde(x)_2^mu) = f(x_1^mu, x_2^mu),
$

et en utilisant notre résultat trouvé pour les translations, on trouve que

$
  f(tilde(x)_1^mu - tilde(x)_2^mu) = f(x_1^mu - x_2^mu),
$

ou encore

$
  f(Lambda^mu_(space.en nu)(x_1^nu - x_2^nu)) = f(x_1^mu - x_2^mu).
$

Autrement dit, appliquer une rotation n'a aucun effet sur le résultat. Puisque les rotations n'ont pas d'effet sur $x_1^mu - x_2^mu$, cela nous apprend que la fonction $f$ doit dépendre non plus du déplacement mais uniquement de la magnitude de ce dernier :

$
  corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = f(abs(x_1^mu - x_2^mu)).
$

*Dilatation*

Sous dilatation, $tilde(cal(O))_Delta (tilde(x)^mu) = lambda^(-Delta)cal(O)_Delta (x^mu)$. Nous substituons cela dans #ref(<t11>) :

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu))
                          &= corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu)) \
                          &= corr(lambda^(-Delta_1)cal(O)_(Delta_1)(x_1^mu) lambda^(-Delta_2)cal(O)_(Delta_2)(x_2^mu)) \
                          &= lambda^(-Delta_1) lambda^(-Delta_2) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) \
                          &= lambda^(-(Delta_1 + Delta_2)) f(abs(x_1^mu - x_2^mu))
$

où nous avons combiné tout les résultats obtenu jusqu'à présent pour la fonction de corrélation à deux points. En utilisant la notation de fonctions $f$, nous avons donc actuellement trouvé que

$
  f(abs(tilde(x)_1^mu - tilde(x)_2^mu)) = lambda^(-(Delta_1 + Delta_2)) f(abs(x_1^mu - x_2^mu)),
$

ou encore

$
  f(lambda abs(x_1^mu - x_2^mu)) = lambda^(-(Delta_1 + Delta_2)) f(abs(x_1^mu - x_2^mu)).
$

Sous un ensemble de conditions qui sont toujours rencontrées en physique (#emoji.face.wink), nous pouvons toujours développer $f$ en série de puissance :

$
  f(abs(x_1^mu - x_2^mu)) = sum_k^infinity c_k abs(x^mu_1 - x^mu_2)^k,
$

on peut ensuite substituer cette série dans le résultat précédent pour trouver

$
  sum_k^infinity c_k lambda^k abs(x^mu_1 - x^mu_2)^k = lambda^(-(Delta_1 + Delta_2)) sum_k^infinity c_k abs(x^mu_1 - x_2^mu)^k,
$<jsp1>

ce qui nous permet de mieux comparer les facteurs de dilatation : pour que l'égalité soit vérifiée pour toutes les valeurs de $lambda$, chaque puissance de $lambda$ du côté gauche doit correspondre à la même puissance du côté droit; cela n'est possible que si tout les termes sont nuls sauf celui dont l'exposant vaut $k = -(Delta_1 + Delta_2)$, ce qui nous amène alors simplement à

$
  corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = C abs(x_1^mu - x_2^mu)^(-(Delta_1 + Delta_2)) space.quad C in RR
$<dil1>

où la $C$ est la constante du développement en puissance associé au $k = -(Delta_1 + Delta_2)$.

*Transformation spéciale conforme*

Nous arrivons à la dernière transformation de symétrie avec laquelle la fonction de corrélation scalaire à deux points sera contrainte. Rappelons que $tilde(x)^mu = x^mu + 2(x dot b)x^mu - b^mu x^2$, nous pourrions calculer le jacobien et essayer de s'en sortir comme on peut, mais en fait il est plus simple de se rappeler que la transformation conforme spéciale est composée d'une inversion, puis d'une translation, puis d'une inversion et comme nous connaissons déjà le résultat de la symétrie sous translation, il suffit de s'attaquer à la "sous-symétrie" sous inversion. Comme cela a été présenté plus tôt, l'inversion considérée est donnée par

$
  x^mu = frac(tilde(x)^mu, tilde(x)^2)
$

d'où

$
  abs(frac(partial x^mu, partial tilde(x)^nu)) = abs(frac(delta^mu_(space.en nu), tilde(x)^2)) = 1/(tilde(x)^(2 D))
$

car $tilde(x)^2 equiv tilde(x)^alpha tilde(x)_alpha in RR$ est un scalaire. Sous inversion, un opérateur primaire scalaire se transforme donc comme

$
  cal(tilde(O))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial tilde(x)^nu))^(Delta\/D) cal(O)_Delta (x^mu) = (frac(1, tilde(x)^(2 D)))^(Delta \/ D) cal(O)_Delta (x^mu) = frac(1, tilde(x)^(2 Delta)) cal(O)_Delta (x^mu)
$

ce que l'on remplace dans #ref(<t11>),

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu))
                          &= corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu)) \
                          &= corr(frac(1, tilde(x)_1^(2 Delta_1))cal(O)_(Delta_1)(x_1^mu) frac(1, tilde(x)_2^(2 Delta_2))cal(O)_(Delta_2)(x_2^mu)) \
                          &= frac(1, tilde(x)_1^(2 Delta_1)) frac(1, tilde(x)_2^(2 Delta_2)) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)).
$

Nous utilisons maintenant #ref(<dil1>) à gauche et à droite de cette égalité, afin d'obtenir

$
       space & C abs(tilde(x)_1^mu - tilde(x)_2^mu)^(-(Delta_1 + Delta_2)) = frac(1, tilde(x)_1^(2 Delta_1)) frac(1, tilde(x)_2^(2 Delta_2)) C abs(x_1^mu - x_2^mu)^(-(Delta_1 + Delta_2)) \
  <==> space & frac(tilde(x)_1^(2 Delta_1) tilde(x)_2^(2 Delta_2), abs(tilde(x)_1^mu - tilde(x)_2^mu)^(Delta_1 + Delta_2)) = frac(1, abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2))
$

ce que l'on peut encore mettre sous la forme suivante :

$
  frac(tilde(x)_1^(2 Delta_1) tilde(x)_2^(2 Delta_2), abs(tilde(x)_1^mu - tilde(x)_2^mu)^(Delta_1 + Delta_2)) = (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^(frac(Delta_1 + Delta_2, 2)).
$<jsp2>

On peut remarquer que, si $Delta_1 = Delta_2 =: Delta$, alors l'égalité précédente prend la forme suivante :

$
             & space frac(tilde(x)_1^(2 Delta) tilde(x)_2^(2 Delta), abs(tilde(x)_1^mu - tilde(x)_2^mu)^(Delta + Delta)) = (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^Delta \
  <==> space & (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^Delta = (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^Delta \
  <==> space & 0 = 0,
$

autrement dit, #ref(<jsp2>) n'est satisfait que lorsque $Delta_1 = Delta_2$. La symétrie sous la transformation spéciale conforme nous apprend donc que la fonction de corrélation scalaire à deux points est en fait nulle si $Delta_1 != Delta_2$ (sinon #ref(<jsp2>) ne connaît pas de solution). Dès lors, #ref(<dil1>) peut en toute généralité être écrite comme

#v(0.5em)
$
  markrect(corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = frac(C delta_(Delta_1 Delta_2), abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2)), padding: #.5em)
$
#v(0.5em)

où $delta_(Delta_1 Delta_2)$ est un delta de Kronecker,

$
  delta_(Delta_1 Delta_2) = cases(1 " si " Delta_1 = Delta_2, 0 " sinon"),
$

ce qui conclus notre analyse des symétries conformes pour la fonction de corrélation scalaire à deux points. Pour résumer ce que nous avons fait pour en arriver là,

 1. Sous translations, on arrive à la conclusion suivant laquelle la fonction de corrélation doit être une fonction du déplacement $x_1^mu - x_2^mu$ ;
 2. Sous rotations, on montre en fait que la fonction de corrélation est plutôt fonction de la magnitude du déplacement, $abs(x_1^mu - x_2^mu)$ ;
 3. Sous dilatations, on trouve la forme générale de cette fonction de corrélation ;
 4. Sous transformation spéciale conforme, on conclus que la forme générale est plus stricte et présente un delta de Kronecker.
 
=== Fonctions de corrélation scalaire à trois points
Continuons avec la fonction de corrélation scalaire à trois points. Comme avant, on doit avoir

$
  corr(cal(O)_1 (x^mu_1) cal(O)_2 (x^mu_2) cal(O)_3 (x^mu_3)) overset(=, !) corr(tilde(cal(O))_1 (x^mu_1) tilde(cal(O))_2 (x^mu_2) tilde(cal(O))_3 (x^mu_3)).
$

Les étapes de calculs seront assez similaires que pour les cas précédents, mais plus fastidieux si l'on veut refaire les mêmes étapes de calculs.

*Translation & rotation*

Nous avons vu plus haut que les translations et les rotations ont un jacobien similaire et, donc, peuvent être regroupés dans une même discussion (cela ne devrait pas être trop étonnant étant donné qu'il s'agit justement des composantes d'une transformation de Poincaré). En suivant le même résultat que nous avons réussi à tirer pour la fonction de corrélation scalaire à deux points, on déduit qu'ici aussi il s'agira d'une fonction dépendante de la magnitude des déplacements $x_i^mu - x_j^mu$, c'est-à-dire

$
  corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3))
                    &= f(abs(x_1^mu - x_2^mu), abs(x_2^mu - x_3^mu), abs(x_3^mu - x_1^mu)) \
                    &equiv f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)).
$

*Dilatation*

Pour la dilatation, on aura comme avant

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu) cal(O)_(Delta_3)(tilde(x)_3^mu))
                  &= corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu) tilde(cal(O))_(Delta_3)(tilde(x)_3^mu)) \
                  &= corr(lambda^(-Delta_1)cal(O)_(Delta_1)(x_1^mu) lambda^(-Delta_2)cal(O)_(Delta_2)(x_2^mu) lambda^(-Delta_3)cal(O)_(Delta_3)(x_3^mu)) \
                  &= lambda^(-Delta_1) lambda^(-Delta_2) lambda^(-Delta_3) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu) cal(O)_(Delta_3)(x_3^mu)) \
                  &= lambda^(-(Delta_1 + Delta_2 + Delta_3)) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu) cal(O)_(Delta_3)(x_3^mu)),
$

ce qui, combiné avec le résultat pour les transformations de Poincaré, nous donne

$
       space & f(abs(tilde(x)_(12)^mu), abs(tilde(x)_(23)^mu), abs(tilde(x)_(31)^mu)) = lambda^(-(Delta_1 + Delta_2 + Delta_3)) f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)) \
  <==> space & f(lambda abs(x_(12)^mu), lambda abs(x_(23)^mu), lambda abs(x_(31)^mu)) = lambda^(-(Delta_1 + Delta_2 + Delta_3)) f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)).
$

Afin de comparer les facteurs de dilatations, nous développons la fonction de corrélation scalaire à trois points comme une série de puissance afin d'obtenir

$
  f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)) = sum_i^infinity sum_j^infinity sum_k^infinity c_(i j k) abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k.
$

Nous substituons cela dans le résultat précédent,

$
  sum_i^infinity sum_j^infinity sum_k^infinity c_(i j k) & lambda^i abs(x^mu_(12))^i lambda^j abs(x_(23)^mu)^j lambda^k abs(x_(31)^mu)^k \
              &= lambda^(-(Delta_1 + Delta_2 + Delta_3)) sum_i^infinity sum_j^infinity sum_k^infinity c_(i j k) abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k
$

et, avec une analyse similaire à ce qui a été fait dans le cas précédent, on en déduit que cette égalité n'est vraie que si tout les termes sont nulles, sauf ceux pour lesquels

$
  i + j + k = -(Delta_1 + Delta_2 + Delta_3),
$<jsp3>

ce qui conduit à

$
  corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) =
           markul(sum_(i + j + k = -(Delta_1 + Delta_2 + Delta_3)), tag: #<sm>, color: #red) c_(i j k) abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k

  #annot(<sm>, yshift: 1.5em, pos: left)[Triple somme sur les $i, j, k$ tel que leur somme donne $-(Delta_1 + Delta_2 + Delta_3)$]
$
#v(1.5em)

car, en effet, la condition #ref(<jsp3>) peut être vérifiée pour plusieurs termes à priori.

*Transformation spéciale conforme*

Comme avant, nous n'avons besoin que d'imposer la transformation sous inversion. Dans le cas de la fonction de corrélation scalaire à deux points, nous étions arrivé à la contrainte selon laquelle "$Delta_1 = Delta_2$". Ici, puisqu'il y a trois points, nous aurons trois contraintes sur les $i, j, k$ dont nous donnons le résultat directement et sans développement (c'est un calcul long et sans beaucoup d'intérêt) :

$
  cases(
    i &= Delta_1 + Delta_2 - Delta_3 \
    j &= Delta_1 + Delta_3 - Delta_2 \
    k &= Delta_2 + Delta_3 - Delta_1.)
$<jsp4>

En combinant le tout, nous arrivons finalement à un résultat ressemblant à ce que nous avions trouvé précédemment (mais contraint différemment) :

#v(0.5em)
$
  markrect(corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) = frac(C_(123), abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k), padding: #.5em)
$
#v(0.5em)

où les puissances $i, j, k in {(i, j, k) | #ref(<jsp4>) " est respecté"}$ et où les constantes $C_(123)$ sont issus du développement en puissance associé à la contrainte #ref(<jsp4>).

=== Résumé
Nous avons donc montré que les fonctions de corrélations scalaires à un, deux et trois points sont complètement déterminées à un ensemble de constantes près,

#align(center)[
  #rect()[
    #v(0.5em)
    #math.equation(block: true, numbering: none)[$
      corr(cal(O)_Delta (x^mu)) &= 0 && "(1 point)" \
      corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) &= frac(C delta_(Delta_1 Delta_2), abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2)) && "(2 points)" \
      corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) &= frac(C_(123), abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k) space.quad && "(3 points)" \
    $]
    #v(0.5em)
  ]
]

Cet ensemble de constantes est important pour définir une théorie conforme des champs spécifique, on dit parfois qu'elles "déterminent le degré d'interaction des opérateurs" et sera aussi connu sous le nom des "données CFT" (_CFT data_), auxquelles on ajoute les dimensions.

== Le bootstrap conforme
Dans la sous-section précédente, nous n'avons pas été au delà des fonctions de corrélations scalaires à trois points. Nous allons maintenant discuter des fonctions de corrélations scalaires à quatre points et voir que cette discussion nous mènera vers l'état de l'art de la recherche en CFT (ou en tout cas d'un gros pendant de recherche en CFT).

#remark[
  Comme cela a déjà été annoncé plus tôt, nous restons avec des opérateurs scalaires car ils sont les plus simples à considérer : aucune matrice de transformation ne doit intervenir pour savoir comment les indices se transforment, et nous ne voulons pas complexifier au nom de la généralité et de la complétude.
]

=== Fonction de corrélation scalaire à quatre points
Pour une fonction de corrélation scalaire à quatre points, on voudrait que

$
  corr(cal(O)_1 (x^mu_1) cal(O)_2 (x^mu_2) cal(O)_3 (x^mu_3) (x^mu_4)) overset(=, !) corr(tilde(cal(O))_1 (x^mu_1) tilde(cal(O))_2 (x^mu_2) tilde(cal(O))_3 (x^mu_3) tilde(cal(O))_4 (x^mu_4)).
$

Si nous suivons les mêmes étapes qu'avant pour les transformations de Poincaré (translations + rotations), alors nous arrivons à

$
  corr(cal(O)_1 (x^mu_1) cal(O)_2 (x^mu_2) cal(O)_3 (x^mu_3) (x^mu_4)) = f(abs(x^mu_(12)), abs(x^mu_(23)), abs(x^mu_(34)), abs(x^mu_(41))),
$

autrement dit, il existe quatre quantités $abs(x^mu_(i j))$. Il s'avère que certaines combinaisons de ces quatre quantités forme des fonctions qui sont en fait invariantes sous toutes transformations conformes, on peut en former deux et on parlera alors de _cross sections_ :

#v(0.5em)
$
  u := frac(abs(x^mu_(12)) abs(x^mu_(34)), abs(x^mu_(13)) abs(x^mu_(24))) space.quad " et " space.quad v := frac(abs(x^mu_(12)) abs(x^mu_(34)), abs(x^mu_(23)) abs(x^mu_(14)))
$
#v(0.5em)

*Invariance sous Poincaré*

Puisque $u$ et $v$ sont fonctions uniquement des magnitudes de la séparation entre les points, l'invariance sous translation et sous rotation est automatiquement satisfaite.

*Invariance sous dilatation*

L'invariance sous dilatation est trivialement satisfaite également :

$
  tilde(u) = frac(abs(tilde(x)^mu_(12)) abs(tilde(x)^mu_(34)), abs(tilde(x)^mu_(13)) abs(tilde(x)^mu_(24)))
           = frac(lambda abs(x^mu_(12)) lambda abs(x^mu_(34)), lambda abs(x^mu_(13)) lambda abs(x^mu_(24)))
           = u.
$

*Invariance sous transformation spéciale conforme*

Comme avant, nous n'avons pas besoin de regarder à la S.C.T. complètement mais uniquement à l'inversion $tilde(x)^mu = x^mu \/ x^2$. Pour simplifier les calculs, on peut regarder au carrés $x_(i j)^2$ plutôt qu'aux normes $abs(x_(i j))$, ce qui facilite la discussion sans changer le résultat puisque $abs(x) equiv sqrt(x^2)$. Appliquons alors l'inversion aux points $x_i$ et $x_j$ (on notera $I$ pour l'inversion) :

$
  I(x_i) = x_i / x_i^2, quad I(x_j) = x_j / x_j^2,
$

donc

$
  I(x_i) - I(x_j) = x_i / x_i^2 - x_j / x_j^2 = frac(x_j^2 x_i - x_i^2 x_j, x_i^2 x_j^2),
$

et on peut prendre le carrée :

$
  [I(x_i) - I(x_j)]^2 = frac((x_j^2 x_i - x_i^2 x_j)^2, x_i^4 x_j^4).
$

Or,

$
  (x_j^2 x_i - x_i^2 x_j)^2 = x_i^2 x_j^2 (x_i - x_j)^2 equiv x_i^2 x_j^2 x_(i j)^2,
$

d'où

$
  [I(x_i) - I(x_j)]^2 = frac(x_i^2 x_j^2 x_(i j)^2, x_i^4 x_j^4) = frac(x^2_(i j), x_i^2 x_j^2).
$

Autrement dit, sous inversion,

$
  x^2_(i j) |-> frac(x^2_(i j), x_i^2 x_j^2).
$

En appliquant cela à $u$, on aura

$
  & x^2_(12) |-> frac(x^2_(12), x^2_1 x^2_2), quad  &&  x^2_(34) |-> frac(x^2_(34), x^2_3 x^2_4), \
  & x^2_(13) |-> frac(x^2_(13), x^2_1 x_3^2), quad  &&  x^2_(24) |-> frac(x^2_(24), x_2^2 x_4^2)
$

ce qui donne lieu à

$
  tilde(u) = frac(tilde(x)^2_(12) tilde(x)^2_(34), tilde(x)^2_(13) tilde(x)^2_(24)) = frac(frac(x^2_(12), x^2_1 x^2_2) frac(x^2_(34), x^2_3 x^2_4), frac(x^2_(13), x^2_1 x_3^2) frac(x^2_(24), x_2^2 x_4^2)) = frac(x^2_(12) x^2_(34), x^2_(13) x^2_(24)) = u.
$

Ce qui montre bien que $u$ est invariant sous toutes les transformations conformes. Les mêmes raisonnements s'appliquent également à $v$.

L'invariance des fonctions $u$ et $v$ sous les transformations conformes implique que la fonction de corrélation scalaire à quatre point n'est plus complètement déterminée à un ensemble de constantes près, et cette conclusion se généralise aux fonctions de corrélation à $n >= 4$ points, ainsi que pour les opérateurs non-scalaires.

=== Crossing symmetry

/*
Afin d'introduire le sujet de façon plus simple, nous allons encore simplifier le problème en considérant une fonction de corrélation scalaire à quatre points où chaque opérateur est en fait le même et de dimension $Delta$. Des points précédents, on déduit donc que cette fonction doit être de la forme suivante :

$
  corr(cal(O)(x_1) cal(O)(x_2) cal(O)(x_3) cal(O)(x_4)) = frac(G(u, v), abs(x_(12))^(2 Delta) abs(x_(34))^(2 Delta))
$

où, comme annoncé, elle n'est plus entièrement déterminée par un ensemble de constantes mais par une fonction des cross-sections $u$ et $v$ introduits précédemment, notée $G(u, v)$. Le choix des dénominateurs $x_(12)$ et $x_(24)$ est arbitraire, toute autre $x_(i j)$ est possible mais il faudra modifier $G(u, v)$ en conséquence. Cette fonction $G(u, v)$ porte souvent le nom de _bloc conforme_ (ou "conformal block").

*/

Puisque nous sommes en quelque sorte "bloqué" avec les fonctions de corrélations scalaires à $n >= 4$ points, nous allons devoir faire appel à une approximation pour avancer, mais il s'avère que nous la connaissons déjà : l'Operator Product Expansion (OPE). L'OPE nous permet en effet d'obtenir une fonction de corrélation à $n-1$ points à partir d'une fonction de corrélation à $n$ points, et puisque nous avons vu que les fonctions de corrélations à un, deux et trois points sont entièrement déterminées à un ensemble de constantes près, il suffira d'effectuer l'OPE de façon répétée jusqu'à atteindre une de ces formes fixées, ce qui, pour rappel, nous produira également un autre ensemble de constantes, et c'est l'ensemble de ces constantes réunies qu'il est préférable d’appeler "données CFT". Ce sont toutes ces contraintes apportées par la CFT qui vont faire naître l'algorithme du bootstrap, comme nous le verrons un peu plus loin.

Considérons une fonction de corrélation scalaire à quatre points que l'on développe par deux OPE successives, ce qui peut s'écrire en toute généralité comme

#v(1em)
$
  corr(wick(id: #0, pos: #top, cal(O))_1 (x_1) wick(id: #0, pos: #top, cal(O))_2 (x_2) & wick(id: #0, pos: #top, cal(O))_3 (x_4) wick(id: #0, pos: #top, cal(O))_4 (x_4)) \
          &= sum_(m, m') lambda_(12 m) lambda_(34 m') C_a (x_(12), partial_2) C_b (x_(34), partial_4) corr(cal(O)^a_m (x_2) cal(O)^b_m' (x_4))
$<c1>

où l'on a indiqué avec des petites barres sur quels opérateurs l'OPE considérée s'effectue (on parle parfois de _canaux de contractions_). Le côté droit de cette égalité est complètement déterminé puisque nous connaissons la forme de la fonction de corrélation à deux points. Par propriétés des fonctions de corrélation, il est également possible de contracter différents opérateurs par OPE sans que le résultat ne soit différent :

#v(1em)
$
  corr(wick(id: #1, pos: #top, cal(O))_1 (x_1) wick(id: #0, pos: #top, cal(O))_2 (x_2) & wick(id: #0, pos: #top, cal(O))_3 (x_4) wick(id: #1, pos: #top, cal(O))_4 (x_4)) \
          &= sum_(m, m') lambda_(14 m) lambda_(23 m') C_a (x_(14), partial_4) C_b (x_(23), partial_3) corr(cal(O)^a_m (x_4) cal(O)^b_m' (x_3))
$<c2>

autrement dit, on "change de canal de contraction". Les deux fonctions de corrélations devant être les mêmes, #ref(<c1>) et #ref(<c2>) doivent être égaux peu importe le canal de contraction. On parlera de "symétrie de croisement" ou _crossing symmetry_ en anglais.

#remark[
  Nous modifions légèrement les notations que nous avions utilisées pour introduire l'Operator Product Expansion, afin de les rendre plus adaptées au contexte actuel. Toutefois, il ne s'agit que d'un changement de notation, l'idée restant inchangée.
]

=== Équation du bootstrap
Afin d'arriver à l'équation que nous voulons présenter pour le bootsrap, nous allons considérer le cas le plus simple possible et allons, pour se faire, considérer une fonction de corrélation scalaire à quatre points pour laquelle les opérateurs sont tous similaires (et de dimension $Delta$, disons) et réécrire #ref(<c1>) et #ref(<c2>) sous une forme beaucoup plus simple où les coefficients seront tous absorbés dans certaines fonctions :

#v(1em)
$
  & corr(wick(id: #0, pos: #top, cal(O))(x_1) wick(id: #0, pos: #top, cal(O))(x_2) wick(id: #0, pos: #top, cal(O))(x_3) wick(id: #0, pos: #top, cal(O))(x_4))
            = frac(G(u, v), x_(12)^(2 Delta) x_(34)^(2 Delta)), \ \

  & corr(wick(id: #1, pos: #top, cal(O))(x_1) wick(id: #0, pos: #top, cal(O))(x_2) wick(id: #0, pos: #top, cal(O))(x_3) wick(id: #1, pos: #top, cal(O))(x_4))
            = frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta))
$<jsp5>

où $G$ est une fonction des cross-sections $u$ et $v$ introduits plus hauts et contenant également les constantes qui apparaissent dans #ref(<c1>) et #ref(<c2>). L'OPE est "cachée" dans cette fonction $G$, mais remarquons que la forme de cette fonction de corrélation scalaire à quatre points est également attendue d'après les développements que nous avons fait plus haut afin de déterminer la forme des fonctions de corrélations scalaires à un, deux et trois points : on s'attend en effet à ce que la fonction de corrélation scalaire à quatre point prenne une forme semblable mais où "l'ensemble de constantes la déterminant" est remplacé par "une fonction des cross-sections $u$ et $v$" (et quelques constantes). Avec un petit abus de notation (car ça n'est pas totalement le cas mais ça sera suffisant pour nous), on parlera de _blocs conformes_ pour ces fonctions $G$. Maintenant, comme cela a été fait remarqué à la sous-section précédente, ces deux fonctions de corrélations doivent être égales, donc on doit avoir que

$
  frac(G(u, v), x_(12)^(2 Delta) x_(34)^(2 Delta)) overset(=, !) frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta)).
$

Nous pouvons développer les calculs pour trouver une expression plus appréciable :

$
       space & frac(G(u, v), x_(12)^(2 Delta) x_(34)^(2 Delta)) = frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta)) \
  <==> space & frac(x_(14)^(2 Delta) x_(23)^(2 Delta), x_(12)^(2 Delta) x_(34)^(2 Delta))G(u, v) = G(v, u) \
  <==> space & (frac(x_(14)^2 x_(23)^2, x_(12)^2 x_(34)^2))^Delta G(u, v) = G(v, u) \
  <==> space & (v/u)^Delta G(u, v) = G(v, u)
$

ou encore

#v(0.5em)
$
  markrect((v/u)^Delta G(u, v) - G(v, u) = 0, padding: #.5em)
$<bootsrap1>
#v(0.5em)

Cette petite équation est l'équation fondamentale de l'algorithme du bootstrap ! Elle porte divers noms, parfois on parlera de la _conformal bootstrap equation_ ou encore de la _crossing equation_ puisqu'elle est directement issue des symétries de contraction de l'OPE.


#remark[
  Nous avons en effet

  $
    frac(x_(14)^2 x_(23)^2, x_(12)^2 x_(34)^2) equiv frac((frac(x_(14)^2 x_(23)^2, x^2_(13) x^2_(24))), (frac(x_(12)^2 x_(34)^2, x^2_(13) x^2_(24)))) = v/u
  $

  où nous avons, comme cela a déjà été fait une fois, utilisé la convention en carré plutôt qu'en magnitude (de sorte à ne pas traîner une racine tout le temps...)
]

//Une égalité similaire à #ref(<bootsrap1>) aurait été obtenue si nous n'avions pas appliqué toutes les simplifications que nous avons proposé et en partant directement de #ref(<c1>) et #ref(<c2>), mais la stratégie adoptée ici permet sans doute de mieux appréhender le résultat. Si l'on souhaite être plus complet, #ref(<bootsrap1>) devrait s'écrire sous une forme légèrement plus compliquée, que nous ne démontrerons pas en détail (mais qui ne devrait pas être trop difficile à mettre en relation avec le résultat auquel nous somme explicitement arrivé) :

Si nous voulons être un peu plus explicite, #ref(<bootsrap1>) prendrait la forme d'une somme sur les opérateurs primaires et ferrait apparaître explicitement les indices et les coefficients constants. En explicitant ainsi le contenu de $G$ dans #ref(<jsp5>), on a une expression de la forme suivante :

#v(1.5em)
$
  corr(wick(id: #1, pos: #top, cal(O))(x_1) wick(id: #0, pos: #top, cal(O))(x_2) wick(id: #0, pos: #top, cal(O))(x_3) wick(id: #1, pos: #top, cal(O))(x_4)) = frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta)) = frac(1, x_(14)^(2 Delta) x_(23)^(2 Delta)) marktc(sum_(cal(O)), tag: #<sum>, color: #red) marktc(lambda^2_(cal(O)), tag: #<lambda>, color: #blue) space g_(Delta, l) (v, u)

  #annot(<sum>, yshift: 1.5em, pos: left)[Somme sur les opérateurs primaires]
  #annot(<lambda>, yshift: 1.5em, pos: top + right)[coefficients de l'OPE]
$
#v(1.5em)

et, en appliquant la symétrie de croisement de façon très similaire à ce que nous avons fait pour un autre canal de contraction OPE, on arrive finalement à l'équation suivante :

#v(0.5em)
$
  markrect(sum_cal(O) lambda^2_cal(O) [ (v/u)^Delta g_(Delta, l)(u, v) - g_(Delta, l)(v, u) ] = 0, padding: #.5em)
$<bootsrap2>
#v(0.5em)

où les $g_(Delta, l)$ sont, eux, bien ce que l'on appelle "blocs conformes". Cette forme est en fait #ref(<bootsrap1>) mise sour une forme un peu plus explicite, faisant apparaître les coefficients constants, les indices ainsi que la somme sur les opérateurs primaires.

//Rappelons que #ref(<bootsrap1>) et #ref(<bootsrap2>) sont issus des considérations suivantes : des opérateurs scalaires tous identiques. Cela semble être une contrainte tellement forte qu'on pourrait penser qu'il ne s'agit que d'un modèle jouet, mais en réalité c'est _suffisant_ pour décrire les exposants critiques du modèle de Ising 3D, comme nous le mentionnerons un peu plus loin.

=== Idée et illustration de l'algorithme du bootstrap
Nous ne détaillerons pas l'ensemble du sujet, car cela nécessiterait probablement un document entier. Nous nous contenterons donc d'offrir un aperçu de l'algorithme du bootstrap, mais commençons par expliquer ce que signifie "bootstrap" et ce qu'on entend par là. L'expression anglaise "_to bootstrap [...]_" est toujours employée pour dire "_auto - quelque chose_", ce qui laisse sous-entendre une approche qui s'amorce et "s'auto-entretient". Dans le cas du bootstrap conforme, cette expression insiste sur l'idée de résoudre une théorie en imposant, par ses propres contraintes (symétries, observables, ...), une consistance interne, c'est-à-dire sans avoir besoin d'utiliser autre chose que ce qui a été présenté jusqu'à présent : nous résolvons un problème physique _sans_ lagrangien ni hamiltonien, la théorie se suffit à elle-même.

Les "données CFT", qui sont présentes dans les coefficients de #ref(<bootsrap2>), sont les paramètres que l'on cherche à déterminer lorsque l'on évoque la procédure du bootstrap. Ces paramètres, comme annoncé plus tôt, sont reliés à la physique que l'on essaye de décrire (bien-sûr, il faut d'abord se donner un modèle). L'algorithme procède alors comme suit dans les grandes lignes :

 1. On commence avec un ensemble initial de paramètres $(Delta, l)$ (si l'on reprend nos notations précédentes) ;
 2. On applique l'équation #ref(<bootsrap2>) sur ces paramètres et les contraintes du systèmes physique étudié déterminent également une forme altérée de #ref(<bootsrap2>) (par exemple on sait que le modèle de Ising a une symétrie $ZZ_2$ et cela doit être pris en compte) ;
 3. Le résultat cette itération va nous fournir l'information suivante : une région de l'espace des paramètres est éliminée : "elle ne contient pas de solution au problème" ;
 4. On choisi alors un nouvel ensemble de paramètres $(Delta, l)$ issu de la ou les régions non éliminées par la dernière itération ;
 5. On recommence à l'étape 2 et on s'arrête à l'itération souhaitée ;
 6. A l'arrêt de la procédure, nous nous retrouvons avec un espace des solutions suffisamment petit pour apporter des conclusions.

Cet algorithme fonctionne donc par élimination de régions à chaque étape et il a été montré dans les articles fondateurs que la convergence est rapide. En très peu d'itérations, il est possible d'arriver à une région de l'espace des paramètres qui est plus petite que les erreurs d'incertitudes et qui est plus précise que les méthodes numérique de Monte-Carlo (qui étaient jusqu'alors les meilleurs disponibles en ce qui concerne le modèle de Ising par exemple).

Il s'agit de l'idée derrière l'algorithme du bootstrap; aller dans les détails et montrer explicitement son fonctionnement sort du cadre de ce document, mais nous référons par exemple vers _Lectures on Conformal Field Theory_ de Joshua D. Qualls pour une présentation plus détaillée. Les figures #ref(<im14>), #ref(<im15>) et #ref(<im16>) illustrent graphiquement la méthode que nous avons expliqué dans le cas du modèle de Ising tridimensionnel.

#v(1.5em)

#figure(
  image("images/14.png", width: 45%),
  caption: [Première itération de l'algorithme du bootstrap (source: @qualls2016lectures)]
)<im14>

#v(1.5em)

#figure(
  image("images/15.png", width: 60%),
  caption: [Plusieurs itérations de l'algorithme du bootstrap (source: @qualls2016lectures). #linebreak() La lecture se fait columns par columns.]
)<im15>

#v(1.5em)

#figure(
  image("images/16.png", width: 60%),
  caption: [Isolation d'une région après multiples itérations (source: @qualls2016lectures)]
)<im16>

#v(1.5em)

Après avoir itéré un certain nombre de fois, la figure #ref(<im16>) illustre bien qu'il existe une région de l'espace des paramètres (ici "$Delta_epsilon$" et "$Delta_sigma$") qui tient bon et qui ne se fait pas éliminer de l'espace des possibilités, des barres d'erreurs ont été ajoutées au graphique pour que l'on voit bien que cette région semble contenir la solution au problème et que le nombre d'itérations a pu les isoler de façon suffisamment précise. La figure #ref(<im16>) est elle-même reprise de l'article originale @Kos:2014bka, où les auteurs on trouvés $Delta_σ = 0.51820(14)$ et $Delta_epsilon = 1.4127(11)$, qui sont des exposants critiques du modèle de Ising tridimensionnel (qui sont communément exprimés en terme de _scaling dimension_ en théorie des champs). Les mêmes auteurs ont donnés une comparaison de la méthode du bootstrap avec les simulations de Monte-Carlo, leur résultat est présenté à la figure #ref(<im17>).

#v(1.5em)

#figure(
  image("images/17.png", width: 75%),
  caption: [Comparaison des méthodes de simulation numérique (source: @Kos:2014bka)]
)<im17>

#v(1.5em)

Sur la figure #ref(<im17>), le rectangle gris foncé est la prédiction de Monte-Carlo tandis que le petit triangle gris clair est la prédiction de la procédure du bootstrap. La région bleue est simplement une borne que les auteurs ont préalablement établis.

#line()
#v(1.5em)

Pour résumer, la procédure du bootstrap offre les avantages suivants :

 - Il n'y a nul besoin de directement utiliser de lagrangien, de hamiltonien, de fonction de partition, d'action, ... la CFT est suffisante pour résoudre le problème, ce qui n'est pas le cas de l'approche par groupe de renormalisation : le bootstrap conforme est plus simple ;
 - La méthode est rapidement convergente ;
 - La méthode est plus précise que les simulations numériques alternatives.

L'idée de la méthode n'est pas neuve et date des années 1970, mais elle a connue un regain d'intérêt vers 2008 lorsque la méthode a été appliquée avec succès au cas physique concret du modèle de Ising tridimensionnel dont nous avons présenté des résultats plus récent. Il y a cependant encore beaucoup à faire, et peu d'autres modèles ont pour le moment été étudiés.

= Conclusion
Pour conclure, durant le stage de quatre semaines de $1^"ère"$ année de master de physique théorique à l'UMons, j'ai été introduit à la théorie conforme des champs avec comme ligne directrice principale l'étude des transitions de phase via l'approche du bootstrap et ce document, ce rapport de stage, reflète ma compréhension du sujet.

= Références
Le travail présenté dans ce document est issu des connaissances acquises durant le stage de M1 en physique à l'Université de Mons, les références qui ont été utilisées lors de ce dernier sont listées ci-dessous.

#v(1.5em)
#bibliography("references.bib", full: true, title: none)

#line()
#v(1.5em)

