#import "@preview/typslides:1.2.4": *
#import "@preview/mannot:0.2.1": *
#import "@preview/fletcher:0.5.5": *

#let dd = math.upright("d")
#let corr(body) = $lr(angle.l #body angle.r)$

#let bra(f) = $lr(angle.l #f|)$
#let ket(f) = $lr(|#f angle.r)$

#let overset(a, b) = {
 math.attach(math.limits(a), t: b)
}

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
)

#front-slide(
  title: [Conformal Field Theory],
  subtitle: [Aurélien Vandeweyer],
  authors: [Supervised by Evgeny Skvortsov],
  info: [Service de Physique de l'Univers, Champs et Gravitation]
)

// Custom outline
#table-of-contents()

// Title slides create new sections
#title-slide[
  Introduction
]

#slide(title: "General facts about phase transitions")[
  A #stress[phase transition] is a transformation of a system from one phase to another.

  #figure(
    image("phase.png", width: 70%),
    caption: [Well know example of transition]
  )
]

#slide(title: "General facts about phase transitions")[
  #stress[Critical point] are the end points of a phase equilibrium curve.

  #figure(
    image("cp.jpg", width: 40%),
    caption: [Example of critical point]
  )
]

#slide(title: "General facts about phase transitions")[
  #stress[Critical exponents] describe the behavior of physical quantities near continuous phase transitions. Typical examples: $C ~ abs(T - T_c)^(-alpha)$ and $M ~ abs(T - T_c)^beta$.

  #figure(
    image("table.png", width: 50%),
    caption: [Some critical exponents of the Ising model]
  )
]

#slide(title: "General facts about phase transitions")[
  It is believed (but not proven) that they are #stress[universal]: they do not depend on the details of the physical system, but only on some of its #underline[general features].
]

#slide(title: "General facts about phase transitions")[
  The physics of phase transitions is well understood, but #stress[important questions] remain about critical exponents. How to study them?

  Main approaches:
    - phenomenological (e.g. Landau) ;
    - renormalization group (e.g. Wilson RG) ;
    - numerical simulations (e.g. Monte Carlo, Metropolis).
]

#slide(title: "Conformal Field Theory (CFT) — Internship")[
  Using the idea of #stress[scale invariance] we can formally go further by studying #stress[conformal field theory]. That was the #underline[goal of the internship]:

  - Get an idea of what is scale invariance using the #stress[renormalization group] ;
  - Study of #stress[conformal symmetries] ;
  - Apply these symmetries to fields and #stress[correlation functions] ;
  - Introduction to the #stress[conformal bootstrap] procedure.

  #v(1.5em)
  #text(size: 0.75em)[(_critical exponents were just a pretext for studying conformal field theory_)]

]

#title-slide[
  The renormalization group and the idea of scale invariance
]

#slide[
  - The #stress[renormalisation group] approach makes it possible to study the behaviour of a system at different *scales*.

  - *Wilson*'s idea: remove the *high-energy* degrees of freedom and *zoom out* to see the system on larger scales. The *coupling constants* would *change* accordingly.

  #align(center)[
    #table(
      columns: (1fr, 1fr, 1fr),
    
      image("sq1.png"), image("sq2.png"), image("sq3.png"),
      [Look at the squirrel in all its aspects], [Get rid of all the high frequencies in the image], [Zoom out to see the system on a larger scale and "gain resolution"]
    )
  ]
]

#slide(title: "Summary of the RG method")[
  - #stress[Scale invariance] definitely leads to some interesting result ;
  - The renormalization group approach is a *good first approach* ;
  - *In practice* this is getting very #underline[complicated].

  #linebreak()

  #sym.arrow.long we want to get rid of all the unnecessary details of calculation
]

#title-slide[
  The Conformal Group and Algebra
]

#slide(title: "Conformal transformation")[
  - Since #stress[scale symmetry] seems important, let's study it with a more formal approach ;
  - Introducing the #stress[conformal transformation],

  #framed(title: "Conformal transformation")[
    This is a diffeomorphism $x^mu -> tilde(x)^mu (x^mu)$ leaving the metric invariant up to a function of the position:
    $
      cases(
        x^mu -> tilde(x)^mu (x^mu),
        g_(mu nu)(x) -> tilde(g)_(mu nu)(tilde(x)) = e^(sigma(x)) space g_(mu nu)(x))
    $
    where $e^sigma(x)$ is the function of the position. Its form is somewhat arbitrary.
  ]

  - We will often restrict ourselves to flat metrics, $g^(mu nu) = eta^(mu nu)$.
]

#slide(title: "Conformal transformation")[
  - A conformal transformation leaves the metric invariant up to a function of the position, say $Lambda(x)$. What if $Lambda(x) = 1$ ? $ g_(mu nu)(x) -> tilde(g)_(mu nu)(tilde(x)) =  g_(mu nu)(x) $

  - We know that the set of transformations that leave the metric unchanged form the #stress[Poincaré group] #sym.arrow.long we expect it to be a *subgroup* of the #stress[conformal group].
]

#slide(title: "The conformal group and algebra")[
  #align(center,
    table(
      columns: (auto, auto, auto),
      inset: 15pt,
      align: (left, left, left),
      table.header([*generator*], [*infinitesimal transformation*], [*name*]),
  
      [$hat(P)_mu = -i partial_mu$], [$tilde(x)^mu (x^mu) = x^mu + a^mu$], [translation],
      [$hat(L)_(mu nu) = i(x_mu partial_nu - x_nu partial_mu)$], [$tilde(x)^mu (x^mu) = (delta^mu_nu + beta^mu_nu)x^nu$], [rotation],
      [$hat(D) = -i x^mu partial_mu$], [$tilde(x)^mu (x^mu) = (1 + alpha)x^mu$], [dilatation],
      [$hat(K)_mu = -i(2 x_mu x^nu partial_nu - (x^2) partial_mu)$], [$tilde(x)^mu (x^mu) = x^mu + 2(x dot b)x^mu - b^mu x^2$], [S.C.T],
    )
  )
  
  #v(2.5em)
  $
    epsilon^mu = space
                 mark(a^mu_(), tag: #<translation>, color: #red, padding: #.4em, radius: #10%) space.en
      + space.en mark(b^mu_(space.en nu) x^nu, tag: #<lorentz>, color: #blue, padding: #.4em, radius: #10%) space.en
      + space.en mark(c x^mu_(), tag: #<scale>, color: #green, padding: #.4em, radius: #10%) space.en
      + space.en mark(d_nu (eta^(mu nu) x^2 - 2 x^mu x^nu), tag: #<sc>, color: #purple, padding: #.4em, radius: #10%)
  
    #annot(<translation>, pos: top, yshift: 2em)[translation]
    #annot(<lorentz>, pos: bottom, yshift: 2em)[lorentz]
    #annot(<scale>, pos: top, yshift: 2em)[dilation]
    #annot(<sc>, pos: bottom, yshift: 2em)[special conform]
  $
  #v(2.5em)
]

#slide(title: "The conformal group and algebra")[
  The non-zero commutators are as follows:
  $
    & [hat(D), hat(P)_mu] = i hat(P)_mu \
    & [hat(D), hat(K)_mu] = -i hat(K)_mu \
    & [hat(K)_mu, hat(P)_nu] = 2 i (eta_(mu nu) hat(D) - hat(L)_(mu nu)) \
    & [hat(K)_rho, hat(L)_(mu nu)] = i (eta_(rho mu) hat(K)_nu - eta_(rho nu) hat(K)_mu) \
    & [hat(P)_rho, hat(L)_(mu nu)] = i (eta_(rho mu) hat(P)_nu - eta_(rho nu) hat(P)_mu) \
    & [hat(L)_(mu nu), L_(rho sigma)] = i (eta_(nu rho) hat(L)_(mu sigma) + eta_(mu sigma) hat(L)_(nu rho) - eta_(mu rho) hat(L)_(nu sigma) - eta_(nu sigma) hat(L)_(mu rho))
  $
]

#title-slide[Operators, Correlation Functions, and Operator Product Expansion]

#slide(title: "Primary and descendants operators")[
  - In a conformal theory, we can _classify_ operators as #stress[primaries] and #stress[descendants].
  
  - Basically, a #stress[primary operator] transforms as
  
    #v(0.5em)
    $
      hat(tilde(cal(O)))^A_Delta (tilde(x)^mu) = mark(abs(frac(partial x^mu, partial tilde(x)^nu)), tag: #<j>, color: #red)^(Delta \/ D) mark(L^A_(space.en B), tag: #<l>, color: #blue) hat(cal(O))^B_Delta (x^mu)
    
      #annot(<j>, pos: right, yshift: 0.5em)[Jacobian]
      #annot(<l>, pos: top + right, yshift: 0.5em)[Lorentz representation]
    $
    #v(1em)

    where $Delta$ is the *operator's dimension* and $D$ is the space dimension,

  - and any #stress[descendant operator] is obtained from a given primary operator by applying the $hat(P)_mu$ generator to it, $n$ times.

    #align(center)[#framed[#sym.arrow.long Only #stress[primary operators] matter]]
]

#slide(title: "Correlation functions")[
  In broad terms, a #stress[correlation function], in CFT, is a statistical measure that quantifies the interactions between different local operators at different points in space-time.

  - We denote them by

  #align(center)[#framed[ $ G_n (x_1, x_2, ..., x_n) equiv corr(cal(O)_1 (x_1) cal(O)_2 (x_2) space ... space cal(O)_n (x_n)) $ ]]

  - In QFT, they are related to path integrals and functional derivatives.
  - Correlation functions homogeneous function.
]

#slide(title: "Correlation functions")[
  #stress[Correlation functions] are the *observables* of the theory, so they #underline[must] be invariant under _any_ coordinate transformation:

  #align(center)[#framed[$ corr(tilde(cal(O))_1 (x_1^mu) tilde(cal(O))_2 (x_2^mu) space ... space tilde(cal(O))_n (x_n^mu)) overset(=, !) corr(cal(O)_1 (x_1^mu) cal(O)_2 (x_2^mu) space ... space cal(O)_n (x_n^mu)) space.quad forall x^mu_i $]]

  #sym.arrow.long let's apply #stress[conformal transformations] to them under this constraint!

  #v(2em)
  
  #underline[Note]: we will only use _scalar operators_ to get ride of indices. This means that

  $
    hat(tilde(cal(O)))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial tilde(x)^nu))^(Delta \/ D) hat(cal(O))_Delta (x^mu)
  $
]

#slide(title: "1, 2, 3-point correlation functions under conformal symmetries")[
  By applying the conformal symmetries for 1, 2 and 3-point functions, we obtain

  #align(center)[
      #framed[
      #math.equation(block: true, numbering: none)[$
        corr(cal(O)_Delta (x^mu)) &= 0 && "(1 point)" \
        corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) &= frac(C delta_(Delta_1 Delta_2), abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2)) && "(2 points)" \
        corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) &= frac(C_(123), abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k) space.quad && "(3 points)" \
      $]
    ]
  ]

  where $x_(i j)^mu := x_i^mu - x_j^mu$ and where $delta_(k l)$ is the Kronecker delta.
  
  #sym.arrow.long.r These correlation functions are *fully determined*.
]

#slide(title: "Cross-sections")[
  - For the *4-point* correlation function, and above, this will not work anymore. //#emoji.face.sad

  - At this point, we can form some quantities called #stress[cross-sections] that are invariant under all conformal transformations:

    #v(0.5em)
    $
      u := frac(abs(x^mu_(12)) abs(x^mu_(34)), abs(x^mu_(13)) abs(x^mu_(24))) space.quad " and " space.quad v := frac(abs(x^mu_(12)) abs(x^mu_(34)), abs(x^mu_(23)) abs(x^mu_(14)))
    $
    #v(0.5em)

  #sym.arrow.long The $n >= 4$-points correlation functions are therefore no longer fully determined, we should make *approximations* to go further...
]

#slide(title: "Operator Product Expansion")[
  In a #stress[correlation function], when two operators are "close", we can combine them into a single operator using a series expansion. The big picture is the following:

#v(0.5em)
#figure(
  cetz.canvas({
    import cetz.draw: *

    // <

    line((-1.5, 0), (0, 1.5))
    line((-1.5, 0), (0, -1.5))

    // thrilled

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

    // thrilled

    circle((1.2 + 8.4, 0.8), radius: 2pt, fill: gray)
    circle((0.5 + 8.4, -0.3), radius: 2pt, fill: gray)
    circle((2.7 + 8.4, 0.4), radius: 2pt, fill: gray)
    circle((0.9 + 8.4, -1.1), radius: 2pt, fill: gray)
    circle((2.3 + 8.4, 1.0), radius: 2pt, fill: gray)
    circle((1.5 + 8.4, -0.8), radius: 2pt, fill: gray)
    circle((0.3 + 8.4, 0.4), radius: 2pt, fill: gray)
    circle((-0.3 + 8.4, -0.6), radius: 2pt, fill: gray)
    circle((-0.4 + 8.4, 0.6), radius: 2pt, fill: gray)
    circle((1.6 + 8.4, -0.1), radius: 2pt, fill: gray)
    circle((10.85, -0.4), radius: 3pt, fill: red)

    // >

    line((1.5 + 2.5 + 8.4, 0), (0 + 2.5 + 8.4, 1.5))
    line((1.5 + 2.5 + 8.4, 0), (0 + 2.5 + 8.4, -1.5))

  })
)
#v(0.5em)

  and mathematically (simplified), this means...

  #align(center)[#framed[$ cal(O)_1(x) cal(O)_2(0) = sum_(cal(O)_I) C_(Delta, I) (x, partial) cal(O)_I (0) $]]
]

#slide(title: "Operator Product Expansion")[
  This is called #stress[Operator Product Expansion] (OPE). Some warnings:
  
  - the OPE is _valid_ only in a correlation function;
  - the other operators that are in the correlation function must be "sufficiently far away" from the product considered.

  #v(1em)
  
  #align(center)[#framed[#sym.arrow.long.r #stress[OPE] gives us a $(n-1)$-point correlation function from a $n$-point one!]]
]

#title-slide[The bootstrap equation]

#slide(title: "The bootstrap equation")[
  Using together the *crossing symmetries*, the *OPE*, and the associativity of the *correlation functions*, this gives, after calculations, the #stress[bootstrap equation]:
  
  #align(center)[#framed[$ sum_cal(O) lambda^2_cal(O) [ (v/u)^Delta g_(Delta)(u, v) - g_(Delta)(v, u) ] = 0 $]]

  where

  - $u$ and $v$ are the cross sections ;
  - $g_(Delta)$ is a *conformal block* ;
]

#slide(title: "The bootstrap algorithm")[
  Using the previous result, we can establish an algorithm that gives us precise values of the parameters of interest (particularly *critical exponents*):

  1. Start with *initial parameters* ;
  2. Apply the equation adapted to the *physical constraints* of the system ;
  3. *Eliminate* the parameter region *incompatible* with the gotten solution ;
  4. Select *new parameters* in non-eliminated regions ;
  5. *Repeat* steps #stress[2]-#stress[4] as many times as required ;
  6. At the end, we find have a *solution space* small enough to draw conclusions.

  This procedure is known as the #stress[bootstrap algorithm].
]

#slide(title: "Results — back to the Ising model")[
  #align(center)[#image("15.png")]
]

#slide(title: "Results — back to the Ising model")[
  The space of solutions is reduced to a region that is smaller than the error bars:
  #align(center)[#image("16.png", width: 65%)]
]

#slide(title: "Results — back to the Ising model")[
  This method far #stress[outperforms] all previous simulations (e.g. with Monte Carlo).
  #align(center)[#image("17.png", width: 65%)]
]

#slide(title: "Summary")[
  To summarize, the #stress[bootstrap procedure] offers the following advantages:

  - There is *no need* to use Lagrangians, Hamiltonians, partition function, action, ...
  - The method is *rapidly convergent* ;
  - The method is *more accurate* than alternative numerical simulations.
]

#title-slide[
  Conclusion
]

#slide(title: "Conclusion")[
  - Conformal field theory is a *powerful* theory for studying phase transitions ;

  - It is *naturally adapted* to the problem ;

  - An *efficient algorithm* has been established to compute critical exponents ;

  - Conformal field theory is *simpler* than traditional QFT.

  #v(1.5em)

  #underline[Note]: The bootstrap approach is still relatively new, and few results have been calculated so far. The Ising model is one of the few.

  #v(2.5em)
  #h(20.5em) --- _Thank you for your attention._
]

#slide(title: "References")[
  *Slide figures*

  - Figure 1: _Unacademy -- phase transition_ ;
  - Figure 2: _labxchange -- Phase Diagram for Water_ ;
  - Figure 3: _Wikipedia -- Ising Model Critical Exponents_ ;
  - Conformal bootstrap figures: @qualls2016lectures

  *Internship*
  
  #bibliography("bibliography.bib", full: true, title: none)
]

