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
  lang: "en"
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
  title: [Conformal Field Theory #text(size: 15pt)[_English version_]],
  author: "Aurélien Vandeweyer",
  date: datetime(year: 2025, month: 02, day: 13),
  abstract: [This internship report consists of a presentation of the subject of conformal field theory, a subject that was studied during the first-year master's internship at the University of Mons, in the Department of Physics of the Universe, Fields and Gravitation, supervised by Evgeny Skvortsov. The subject is presented in what I hope is a pedagogical way that I would have enjoyed learning about it.],
  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false)
)

// -- Content of the document --

= Introduction and Acknowledgments
This internship report presents the knowledge acquired during my first-year Master's internship in Physics at UMONS. The objective was to discover a new field in physics, namely conformal field theory, with a particular focus on phase transitions in the finality. Since the subject was entirely new to me, this document was written in a pedagogical format in order to synthesize all the learning acquired during the internship. The main points covered are:

1. First approach to phase transitions;
2. Introduction to the renormalization group approach;
3. Study of conformal symmetries and their application to correlation functions;
4. The _Operator Product Expansion_ and introduction to the bootstrap approach.

Many sources were used to study the subject, and they are listed at the end of the document. The document itself is mostly original in the sense that it aims to explain what was learned in a personal way.

I would like to thank Mr. Skvortsov for his guidance, his explanations and his availability!

#linebreak()

/*

*Internship report reading plan*

I am aware that this internship report has a page count that could be considered high. The parts that are considered to be the most important of the internship and conformal field theory in this document are sections $(3.1)$, $(3.2)$, $(3.4)$, $(3.5)$, $(3.7)$, $(3.8)$, $(3.9)$ and $(3.10)$ (i.e., about 40 pages). The rest is presented because the purpose of the report is to report what I did during the internship (and that took time and work, too).

#linebreak()

*/

== General Facts About Phase Transitions
Phase transitions represent significant changes in the state of a system, resulting in a qualitative change in its macroscopic properties. These phenomena, which are encountered in various fields ranging from solid-state physics to fluid thermodynamics, offer a rather broad field of study and, even though they have been studied for a long time, still present a number of questions of great interest to science, particularly when we are interested in critical points and universality phenomena.

As a system approaches a critical point, it exhibits peculiar behavior: some quantities, such as the correlation length or the susceptibility, diverge or exhibit non-analytic variations. For example, in a continuous (or second-order) transition, the divergence of the correlation length implies that the system becomes scale-invariant: no characteristic length or order of magnitude dominates, and local fluctuations propagate to all scales. This "scalelessness" leads to power laws describing the behavior near the critical point, and whose coefficients—the critical exponents—turn out to be identical for very different systems.

This universality phenomenon means that physically distinct systems with identical symmetries and dimensions share the same critical exponents and correlation functions. For example, a liquid in equilibrium near its critical point and a magnet near its Curie temperature exhibit similar large-scale behaviors, despite their microscopic differences. This property has greatly contributed to the understanding of statistical physics (and (quantum) field theory!), by allowing systems to be grouped into universality classes that depend mainly on a few essential parameters (the spatial dimension, the symmetry of the order parameter, etc.) rather than on the microscopic details of the system.

The theoretical explanation of this universality is still a subject of research, traditionally through the renormalization group approach, which allows to study how interactions at different scales aggregate, more modern numerical or analytical methods have emerged to try to learn more about critical exponents, such as the conformal field theory approach through the "bootstrap", as will be discussed.

Finally, and as is often the case in science, and particularly in physics, the study of critical points has repercussions well beyond the physics of macroscopic systems. The ideas of scaling, invariance, and renormalization find applications in particle physics, cosmology, and even in some models of complex phenomena in biological and social systems. Thus, understanding phase transitions, and in particular critical points and universality, represents a bridge between seemingly disparate phenomena, illuminating fundamental regularities that prevail across a multitude of systems.

In conclusion to this first section, the subject of critical points and phase transitions is important and not yet fully understood. Its study is therefore of interest.

= The renormalization group

Scale invariance is a very powerful concept in physics. It involves analyzing a system starting at a microscopic scale and then gradually "zooming out" to observe the system's behavior at larger scales. The renormalization group (RG) is the mathematical procedure that allows this scaling to be carried out in a gradual and controlled manner, gradually eliminating details too fine to be relevant at larger scales.

#example[
  In a piece of metal, we are not concerned with the individual behavior of each electron (if that makes any sense), but rather with global properties such as its conductivity or magnetism.
]

Before going any further, let us clarify that the renormalization "group" has nothing to do with group theory. We speak of a group because it reflects the idea of ​​"grouping" as we will see shortly. Let us also clarify that the renormalization group "method" is not a recipe to be applied generically (it must also be applied with caution so as not to change the nature or geometry of the system under consideration).

We will introduce the concept through various examples, both discrete and continuous.

== 1D Ising spin chain
Consider a one-dimensional chain composed of $N$ spins with a coupling constant $J$ between each neighbor.

#v(1em)
#figure(
  board("
    +
    . X. X. X. X. X. X. X. X. X. X. X.
    +
  "),
  caption: [One-dimensional spin chain]
)
#v(1em)

The associated Hamiltonian is $ H = -sum_i J sigma_i sigma_(i + 1). $ Rather than keeping all $N$ spins, we could, for example, only consider half of these spins on the string and (for large $N$) still have a reasonably accurate description of the system by describing the remaining spins in terms of a new coupling constant, $J'$, which takes into account the fact that we have removed some of the spins. This is called "decimation": in general we will sum (or integrate) a certain fraction of spins at each step, leaving behind a system with fewer spins than at the start but compensated with an "updated" coupling constant:

#v(1em)
#figure(
  board("
    +
    . X. X. X. X. X. X. X. X. X. X. X. X. X.
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
    . X. O. X. O. X. O. X. O. X. O. X. O. X.
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
    . X. O. O. O. X. O. O. O. X. O. O. O. X.
    +
  "),
  caption: [$H = -sum_i J'' sigma_(4i) sigma_(4(i + 1))$],
  numbering: none
)
#v(1em)

And so on...

Let's be more concrete and use a spin chain at a non-zero temperature, with the original Hamiltonian, the partition function therefore takes the following form:

$
  z = sum_(markul({sigma_i = plus.minus 1}, padding: #.15em, tag: #<µetat>, color: #red)) e^(-beta H) = sum_({sigma_i = plus.minus 1}) exp(beta J sum_i sigma_i sigma_(i + 1)).

  #annot(<µetat>, yshift: 1.5em, pos: right)[A microstate corresponds to a spin up or down]
$
#v(1.5em)

The goal is to take the sum over half of the spins in the system. To do this, we can simply consider skipping every other spin, as suggested above (which could be done mathematically by associating a number with each spin and summing over, for example, only odd-numbered spins). The _expected_ partition function should therefore be of the following form:

$
  z = sum_({sigma_i = plus.minus 1}) exp(beta J' sum_(2i) sigma_(2i) sigma_(2(i + 1))).
$ <expected1>

In fact, this is simply the original partition function, but where we have explicitly skipped every other step in the sum and modified the coupling constant accordingly. Let's see explicitly what this would give us for a chain of three spins if we carried out this decimation:

$
  z &= sum_({sigma_i = plus.minus 1})^(i = 0, 2) sum_({sigma_1}) exp(beta J (sigma_0 sigma_1 + sigma_1 sigma_2)) \
    &= sum_({sigma_i = plus.minus 1})^(i = 0, 2) [ e^(beta J (sigma_0 + sigma_2)) + e^(-beta J (sigma_0 sigma_2)) ] \
    &= sum_({sigma_i = plus.minus 1})^(i = 0, 2) 2 cosh[beta J (sigma_0 + sigma_2)].
$ <z1>

Comparing with #ref(<expected1>), we clearly haven't arrived at the desired result, but on the other hand, by comparison, it would give us a relationship between the coupling constant $J$ and $J'$, and that's what we're looking for in the end! For $N$ spins instead of three, #ref(<z1>) is simply rewritten as

$
  z = sum_({sigma_i = plus.minus 1}) product_i 2 cos[beta J (sigma_(2i) + sigma_(2(i + 1)))].
$

Let's then compare this expression with #ref(<expected1>),

$
  sum_({sigma_i}) product_i 2 & cosh[beta J (sigma_(2i) + sigma_(2(i + 1)))] \

          &overset(=, !) sum_({sigma_i}) e^(beta J' sum_i sigma_(2i) sigma_(2(i + 1))) \
          &equiv sum_({sigma_i}) product_i e^(beta J' sigma_(2i) sigma_(2(i + 1))).
$

To compare the left-hand side and the right-hand side, one way is to study the weights for each pair $(sigma_i, sigma_(i + 1))$. The spins $sigma_i$ and $sigma_(i + 1)$ can take the values ​​$plus.minus 1$. If $sigma_i = sigma_(i + 1)$, then $sigma_i + sigma_(i + 1) = plus.minus 2$ and the contribution of the $cosh$ term becomes $ 2 cosh(beta J (plus.minus 2)) = 2 cosh(2 beta J). $ If $sigma_i = -sigma_(i + 1)$, then $sigma_i + sigma_(i + 1) = 0$ and the contribution of the term in $cosh$ becomes $ 2cosh(beta J dot 0) = 2 cosh(0) = 2. $ On the right side of the equality now, if $sigma_i = sigma_(i + 1)$, then $sigma_i sigma_(i + 1) = +1$ and the contribution in the exponential becomes $ exp(beta J' sigma_i sigma_(i + 1)) = exp(beta J'). $ If $sigma_i = -sigma_(i + 1)$, then $sigma_i sigma_(i + 1) = -1$ and the contribution in the exponential becomes $ exp(beta J' sigma_i sigma_(i + 1)) = exp(-beta J'). $ To make the two expressions identical configuration by configuration, we then compare the weight ratios between the parallel configuration and the antiparallel configuration:

- *LHS* $ frac("weight"(+1), "weight"(-1)) = frac(2 cosh(2 beta J), 2) = cosh(2 beta J) $
- *RHS* $ frac("weight"(+1), "weight"(-1)) = frac(exp(beta J'), exp(-beta J')) = exp(2 beta J') $

we therefore deduce the following condition:

$
  cosh(2 beta J) = exp(2 beta J') space <==> space 2 beta J' = log[cosh(2 beta J)]
$

in other words,

$
  markrect(J' = 1/(2 beta) log[cosh(2 beta J)], padding: #.5em)
$

So we have obtained an expression for the scaled coupling constant, $J'$, which physically describes the interactions between the remaining spins after a decimation step. Hence, for a given initial $J$ (which corresponds to the still unrenormalized system), we have a recursive relation that we can apply a number of times and which will correspond, by construction, to this renormalization procedure where, at each step, we zoom out a little more and get rid of the microscopic details of the system!

What happens when we iterate enough times? Suppose the initial system is such that $J = 1$ and the temperature, constant, is high (i.e., $beta$ is very small). Then, $ cosh(x) = 1 + x^2/2! + x^4/4! + cal(O)(x^6) $ which, in our case, gives us $ cosh(2 beta J) approx 1 + 2 (beta J)^2. $ Then, $ log[cosh(2 beta J)] approx log(1 + 2 (beta J)^2) approx 2 (beta J)^2 $ where we used $log(1 + x) approx x$ for $x$ to be small enough. We substitute this result into our formula for $J'$ and then find the new relation $ J' = 1/(2 beta) log[cosh(2 beta J)] approx 1/(2 beta) [2 (beta J)^2] = beta J^2. $ So, when the temperature is high enough, and therefore $beta$ is small enough, we get a new coupling $J' approx beta J^2$ which is _smaller_ than $J$ (recall that $0 < J <= 1$ and that $beta < 1$). In other words, the more we "zoom out" the more the coupling constant tends towards zero, we can conclude that $J$ is a useless variable for describing the large-scale properties of the system! We can also implement the previous recursive function numerically, after a few iterations we get the following table:

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

It only takes a few iterations to realize that, indeed, the coupling constant becomes irrelevant at larger scales of the system. Physically, this means that thermal fluctuations dominate and spin-spin interactions do not contribute to the magnetic properties of the system. For a smaller temperature, the trend is the same but the convergence is slower. In this particular example, this means that the system is paramagnetic and there is no phase transition possible.

== 1D spin chain with an external magnetic field
We will not go into as much detail here as before, but will illustrate a slightly different configuration that presents a phase transition that we will be able to identify thanks to the renormalization group. Let us consider the same spin chain as before, with the same coupling constant $J$ between each spin, but this time we add an external transverse magnetic field $h$. The previous Hamiltonian is then expressed here as

$
  H = -sum_(angle.l, j angle.r) J sigma^x_i sigma^x_j - sum_i h sigma^z_i
$

We will apply the RG method, this time using a similar form of decimation, but one that better captures the physics of the system and is simpler to implement given the situation. Instead of counting the contribution of every other spin, we will count the contribution of pairs of spins, in other words, we form a "big spin" from two neighboring spins and choose to assign to the latter the lowest energy of the two composite spins in order to maintain the appearance of a low-energy system (if we did the opposite, at each step of the decimation, the system would potentially gain energy, which is not representative of the system). This decimation method is called "spin blocks". We will not give the derivation of the recursive formula but only give the final result, which actually consists of a relation for the coupling constant and a relation for the external magnetic field:

$
  & J' = frac(J^2, sqrt(J^2 + h^2)), \
  & h' = 2h sqrt(1/2 + frac(J, 2sqrt(J^2 + h^2))) sqrt(1/2 - frac(J, 2sqrt(J^2 + h^2))).
$

We can express the ratio $h\/J$ and study numerically what happens:

- For an initial ratio $h\/J > 1$, after iterations, the ratio diverges and becomes infinite. This tells us that $J$ is a less relevant variable than $h$. Physically, the material is in a paramagnetic phase;
- For an initial ratio $h\/J < 1$, we find that the ratio converges to zero, which indicates that $J$ is a more relevant variable than $h$. The material is in a ferromagnetic phase.
- For an initial ratio $h\/J = 1$, we constant that the ratio does not change and remains at $1$.

In other words, this means that the system is undergoing a phase transition! The fact that a parameter of the renormalization group (here, the ratio $h\/J$) remains constant throughout the procedure reflects the scaling invariance of the system near a critical point, and we further note that there are two distinct trends of this parameter "before" and "after" this critical point, which illustrates well the existence of different phases for this particular system.

== 2D Ising model (idea)
How can we apply the renormalization group in a more realistic 2D model? The idea remains the same: we want to find a way to "zoom out." We won't go into any detail here, but only illustrate that an ill-advised choice of decimation leads to changing the geometry of the physical system, which is exactly what we want to avoid.

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
  caption: [Two-dimensional configuration]
)
#v(1em)

If we apply the same decimation method as for the one-dimensional chain where we skip every other spin, then we end up with a configuration that no longer respects the geometry of the system, in fact we would end up with a collection of almost decoupled chains, as illustrated below:

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
  caption: [Configuration in which every other spin is removed: we end up with chains and the couplings between the spins are no longer very clear.]
)
#v(1em)

We could try a variation of this decimation method, where we remove every other spin on one row, and then the same on the next row but in a staggered manner:

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
  caption: [Configuration where the decimation is shifted for each row]
)
#v(1em)

This configuration seems to preserve the geometry of the system! However, a careful eye will realize that this configuration amounts to performing an initial rotation of the system where each spin is distant by a factor $r -> sqrt(2) r$, in other words, this decimation method once again changes the geometry of the spin network.

The conclusion to this is that choosing a decimation method in $d >= 2$ must be done carefully so as not to alter the geometry of the network.

== Renormalization group for a continuous system -- Wilson's method
So far, we have presented the ideas of the renormalization group (and have completely determined the equation for the simplest case) in discrete, lattice systems. We will now turn our attention to the continuous case. The method is essentially the same as before, but instead of starting in real space, we start with momentum space (this is the Wilson renormalization procedure). This approach requires a field description of the system, in particular the partition function is expressed as

$
  z = alpha integral [cal(D) phi] space e^(-S[phi])
$

where $alpha$ is a normalization factor.

#remark[
  The functional measure, often referred to as $[cal(D) phi]$, basically means that

  $
    integral [cal(D) phi] space F[phi] equiv integral_RR ... integral_RR product_x dd phi(x) space F[phi].
  $
]

The idea in Wilson's approach is that we "integrate the high-energy physics" (i.e., "get rid" of the "fast modes," i.e., short-wavelength functions) and keep only the long-wavelength behavior ("slow modes"), which therefore describe the behavior of the system at larger scales. To do this, a standard approach is to express $phi$ as a sum of slow and fast modes, or equivalently, as a sum of high- or low-energy modes. One will encounter the following notations:

#v(1em)
$
  phi = mark(phi_<, tag: #<l>, padding: #.2em, color: #red) space + space mark(phi_>, tag: #<h>, padding: #.2em, color: #blue) space.en " or " space.en phi = phi_"low" + phi_"high"

  #annot(<l>, pos: left, yshift: 1em)[Shortwavelength mode]
  #annot(<h>, pos: right + top, yshift: 1em)[Longwave Mode]
$
#v(1em)

which is often abbreviate as $phi_l$ and $phi_h$. This will give us the following partition function:

$
  z = integral [cal(D) phi_<] [cal(D) phi_>] space e^(-S[phi_<, phi_>]).
$

The action $S$ also takes an adapted form:

$
  S[phi_<, phi_>] = S_0[phi_<] + S_1[phi_>] + delta S[phi_<, phi_>]
$

where the last term corresponds to the mi xed modes (which depend on both the weak and fast modes). Wilson's procedure can be visualized as follows: we start with a system without any alteration, then we remove the high-frequency modes, and finally we "zoom out" by rescaling the pulses, as illustrated very schematically with the squirrel image below:

#align(center)[
  #table(
    columns: (1fr, 1fr, 1fr),

    image("sq1.png"), image("sq2.png"), image("sq3.png"),
    [We consider the squirrel in all its aspects], [We get rid of the high frequencies of the image

    (blurred image)], [we zoom out to see the system on a larger scale]
  )
]

As this pictorial view suggests, this method will allow us to establish how the parameters evolve under rescaling after removing the microscopic information. Note that the squirrel maintains the same shape throughout the process.

=== Gaussian action
We will illustrate Wilson's renormalization procedure using a simple example where we will consider a quadratic action (also sometimes called "Gaussian") for a free scalar field $phi(k)$ in the space $k$. The action is expressed as

$
  S[phi] = 1/2 integral_(abs(k) < Lambda) dd^d k space (k^2 + r) abs(phi(k))^2
$

where $r$ is the mass term and $Lambda$ bounds the integrated $k$ region of space. In physical terms, this action can be seen as the quadratic approximation of a Ginzburg-Landau model for a phase transition, but it is also found in other models. We start by separating $phi(k)$ into "slow modes" $phi_<$ and "fast modes" $phi_>$, more specifically,

- the *slow modes* $phi_<$ are such that $abs(k) < Lambda\/b$ ;
- the *fast modes* $phi_>$ are such that $Lambda\/b < abs(k) < Lambda$

where $b$ is a scaling factor (we will come back to this later). We can then express the $phi$ field as a piecewise function,

$
  phi(k) =
    cases(
      phi_<(k) & " if " abs(k) < Lambda\/b,
      phi_>(k) & "if" Lambda\/b < abs(k) < Lambda.
    )
$

In this case, the action takes the following form:

$
  S[phi] &= 1/2 (integral_(abs(k) < Lambda\/b) dd^d k space (k^2 + r) abs(phi_<(k))^2 + integral_(Lambda\/b < abs(k) < Lambda) dd^d k space (k^2 + r) abs(phi_>(k))^2) \
         &approx 1/2 (integral_(abs(k) < Lambda\/b) dd^d k space (k^2 + r) abs(phi_<(k))^2 + cancel(integral_(Lambda\/b < abs(k) < Lambda) dd^d k space (k^2 + r) abs(phi_>(k))^2)) \
         &approx 1/2 (integral_(abs(k) < Lambda\/b) dd^d k space (k^2 + r) abs(phi_<(k))^2 \
         &=: S_"eff"[phi_<]
$

where we have therefore "eliminated" the fast modes.

#remark[
  In reality, although the result is the same (up to a constant), simply "crossing out" the second term is not very rigorous. When considering the partition function, $ z = integral [cal(D) phi] space e^(-S[phi]), $ the integral over $phi_>$ is a Gaussian independent of $phi_<$ and factors by simply producing a multiplicative constant (a factor $exp(-1\/2 tr(k^2 + r))$ to be precise), but in order not to go into computational details we take a shorter route.
]

Remembering the squirrel image, we want to return to an action that takes a similar form to the original. To get out of this, and this naturally introduces a _rescaling_, we set $tilde(k) := b k$ and so the bound $abs(k) < Lambda\/b$ becomes $abs(tilde(k)) < Lambda$. The slow mode $phi_<$ must also be rescaled to "regain resolution" (like the third squirrel image), so we must set a $tilde(phi)$ of the following form:

$
  tilde(phi)(tilde(k)) := b^(-Delta) phi_<(k = tilde(k)\/b)
$<z2>

where $Delta := (d - 2)\/2$ is a term introduced for dimensionality reasons (according to convention we take a different sign in front of $Delta$). Now, the effective action is rewritten

$
  S_"eff"[phi_<] &= integral_(abs(tilde(k)) < Lambda) (b^(-d) dd^d tilde(k)) space (frac(tilde(k)^2, b^2) + r) abs(phi_<(tilde(k) \/ b))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space b^(-d + 2) (tilde(k)^2 + b^2 r) abs(phi_<(tilde(k) \/ b))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space b^(-d + 2) (tilde(k)^2 + b^2 r) abs(b^(+Delta) phi(tilde(k)))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space b^(-d + 2 + 2 Delta) (tilde(k)^2 + b^2 r) abs(phi(tilde(k)))^2 \
                 &= integral_(abs(tilde(k)) < Lambda) dd^d tilde(k) space (tilde(k)^2 + r') abs(tilde(phi)(tilde(k)))^2
$

where we go from the first to the second line by factoring $b$, from the second to the third by introducing #ref(<z2>) and where, on the last line, $ -d + 2 + 2 Delta = -d + 2 + cancel(2)((d - 2)/cancel(2)) = 0, $ and where we have set $ r' := b^2 r. $<r> So we have effectively rewritten $S_"eff"$ in the same form as the original action. Let's recap what we have done:

1. We started from an action for the $phi$ field;
2. We decomposed $phi$ into "slow modes" and "fast modes";
3. We got rid of fast fashions;
4. We returned to an action having the same shape as originally by "zooming out".

So the image we gave with the squirrel was really not misleading, we did exactly the same thing here. What do we have left now? The important point that emerged from this procedure is the redefinition (the _renormalization_) of the mass parameter #ref(<r>). As we saw previously with discrete Ising models, these parameters that appear during renormalization characterize how sensitive the system is to it at large scales. In the present case, since we are in a continuous case, we can go further: these recursive equations are similar to differential equations given an infinitesimal decimation procedure. Generally, we set

$
  b = e^(dd l) approx 1 + dd l
$

where $dd l$ is an "infinitesimal decimation step". We then write

$
  r' = b^2 r space.quad <==> space.quad r' = e^(2 dd l) r approx (1 + 2 dd l) r
$

and, after some manipulations, we arrive at the _renormalization group flow equation_

#v(0.5em)
$
  markrect(frac(dd r, dd l) = 2r, padding: #.5em)
$
#v(0.5em)

This equation, as for the discrete cases, tells us how the mass term $r$ changes as we "zoom out" to look at the system at larger scales. This equation presents the flux associated with figure #ref(<flux>).

#figure(
  image("RG_wilson.png"),
  caption: [Flow graph of the equation derived by the Wilson renormalization procedure]
)<flux>

Analytically (but we also see it on the graph #ref(<flux>)), if $r_"initial" > 0$ then $r(l) -> infinity$, if $r_"initial" < 0$ then $r(l) -> -infinity$ and if $r_"initial" = 0$ then it is a fi xed point, but unstable (the slightest perturbation makes $r(l)$ diverge), which does not indicate the existence of a phase transition (the random fluctuations of the system would not allow the fi xed point to remain fi xed and would make it diverge). In a theory with interaction (typically $phi^4$) then the procedure would indeed bring us a stable fi xed point, a sign of a phase transition.

#line()
#v(1.5em)

To conclude the introduction given on the renormalization group method, we have seen that it is a powerful procedure based on the important idea that a system must be _invariant under rescaling_. By applying this principle through some discrete and continuous examples with adapted procedures, we have highlighted how the properties of systems evolve when viewed under larger scales, which has also allowed us to study the existence of phase transitions. There is of course much more to say, but it is beyond the scope of this document.





#pagebreak()






= Conformal field theory
As mentioned and seen earlier, it seems that symmetries under dilation, or rescaling, play a rather important role. As always in physics, when discussing symmetries, it is appropriate to look at them more formally with the eye of group theory. The next section is thus devoted to the conformal group and its algebra, which provide the appropriate mathematical framework for understanding these symmetries. We will begin by clearly defining what is meant by "conformal transformation," and from there we can develop the rest.

#remark[
  Conformal symmetries include symmetry under dilation: conformal invariance implies scale invariance, but the converse is not true in general.
]

Let us also note an important element: the study of a conformal theory is different depending on the dimension of the theory, in particular it is convenient to distinguish the case in dimension $d = 2$ from the more general case $d >= 3$, in fact, as we will see, a conformal theory in two dimensions (like string theory) has an infinite-dimensional algebra, while, as we will see, a CFT in $d >= 3$ has a finite-dimensional algebra. It follows that the study of conformal theories in $d >= 3$ dimensions is simpler and it is these that will interest us in the following. There are also one-dimensional CFTs, ​​but we will only mention them.

In most of the cases that will interest us, we will also consider a flat spacetime, so $g_(mu nu) = eta_(mu nu)$. The study of a CFT where the metric is not flat or is not sufficiently simple does not seem relevant: the physical cases whose conformal symmetries are of standard and principal interest do not involve gravity (an important counterexample is the AdS/CFT correspondence) and, if this were the case, analytical solutions would probably be too difficult to find, if any exist.

== Conformal transformation
We will define a _conformal transformation_ as a certain change of coordinates, a diffeomorphism, $x^mu -> x'^mu (x^mu)$ leaving the metric invariant up to a function of the position that we will call _the scale factor_. In order for the new metric to be well-defined, positive and non-zero, the most natural way to formulate this is to write

#v(1em)
$
  cases(
    x^mu -> x'^mu (x^mu),
    g_(mu nu)(x) -> g'_(mu nu)(x') = markrect(e^(sigma(x)), tag: #<scale1>, color: #red, padding: #.2em) space g_(mu nu)(x)\,
  )

  #annot(<scale1>, pos: top, yshift: 1em)[explicitly positive, non-zero #linebreak() scale factor]
$

but it is common to see other writing conventions, such as

#v(1em)
$
  cases(
    x^mu -> x'^mu (x^mu),
    g_(mu nu)(x) -> g'_(mu nu)(x') = markrect(Omega(x)^2, tag: #<scale1>, color: #red, padding: #.2em) space g_(mu nu)(x)\,
  )

  #annot(<scale1>, pos: top, yshift: 1em)[explicitly positive #linebreak() scale factor]
$

or even

$
  cases(
    x^mu -> x'^mu (x^mu),
    g_(mu nu)(x) -> g'_(mu nu)(x') = markrect(Lambda(x), tag: #<scale1>, color: #red, padding: #.2em) space g_(mu nu)(x).
  )

  #annot(<scale1>, pos: top, yshift: 1em)[scale factor]
$

Depending on what is more convenient, we will use one or the other of these conventions. Note that if the scale factor reduces to the constant $1$, then this means that the transformation fully preserves the structure of the spacetime metric, except that we know that the set of transformations that leave the Minkowski metric invariant form the _Poincaré group_, which includes the Lorentz transformations. In other words, we can already see that the group of conformal transformations, the _conformal group_, contains the Poincaré group. We will use this fact in the following, as we expect to see the associated generators that we already know emerge again.

#remark[
  A conformal transformation and a Weyl transformation are two different transformations: a Weyl transformation is not a change of coordinates, but simply a rescaling of the metric.
]

It follows from the definition that a conformal transformation does not necessarily preserve distances, but will always locally preserve angles: if two curves intersect at an angle $alpha$ then, after conformal transformation, they will always intersect at an angle $alpha$. The term "conformal" comes from the Latin "conformalis" which means "of the same shape", indeed a conformal transformation preserves the local "shape" of the figures, in the sense that it preserves the angles between the intersecting curves. Even if the distances and areas can be modified, the "conformity" of the angles is maintained.

#example[
  A simple example of a conformal transformation is a _dilation_ (change of scale) in a flat 2-dimensional space. Consider the metric $ dd s^2 = dd x^2 + dd y^2 $ and apply the transformation $ x -> x' = lambda x, space.quad y -> y' = lambda y $ where $lambda > 0$ is a constant. We then find that
  $
    dd s'^2 &= (dd x')^2 + (dd y')^2 \
            &= lambda^2 dd x^2 + lambda^2 dd y^2 \
            &= lambda^2 (dd x^2 + dd y^2)
  $
  in other words, $ g'_(mu nu)(x') = lambda^2 g_(mu nu)(x). $ This is indeed a conformal transformation, it is a simple but important example.
]

Finding an example that remains relatively simple is not easy, but that does not mean that they do not exist; in reality, it is mainly the results that will subsequently flow from the properties of these transformations that will be of interest. In the meantime, we can still provide a less trivial example that illustrates the definition of conformal transformation.

#example[
  Let us still consider a Euclidean metric $ dd s^2 = dd x^2 + dd y^2 $ and consider the following coordinate transformation:
  $
    x' = x^2 - y^2, space.quad y' = 2 x y.
  $
  To calculate $dd s' = dd x'^2 + dd y'^2$, we calculate the following differentials:
  $
    dd x' = 2x dd x - 2y dd y, space.quad dd y' = 2x dd y + 2y dd x
  $
  and so
  $
    & (dd x')^2 = (2x dd x - 2y dd y)^2 = 4(x dd x - y dd y)^2 \
    & (dd y')^2 = (2x dd y + 2y dd x)^2 = 4(x dd y + y dd x)^2
  $
  which gives, after calculation and rearrangement of the terms,
  $
    dd s'^2 &= (dd x')^2 + (dd y')^2 \
            &= 4(x^2 + y^2)(dd x^2 + dd y^2).
  $
  In other words, we have a transformation of the coordinates which is such that the new metric is proportional to the old one up to a function of the coordinates. More explicitly,
  $
    dd s'^2 = Omega(x, y)^2 dd s^2 space.quad " with " space.quad Omega(x, y) = 2 sqrt(x^2 + y^2).
  $
]

== Derivation of the conformal group and algebra
First, we will work with an arbitrary infinitesimal transformation that we will then constrain to be conformal in order to obtain the useful relations for the following. Our approach is inspired by. Let us therefore consider a first-order infinitesimal transformation of a coordinate $x^mu$, $ x'^mu = x^mu + epsilon^mu (x) + cal(O)(epsilon^2) $<arb1> and recall that for an arbitrary change of coordinate $x -> x'$, the metric transforms according to

$
  eta'_(mu nu)(x') = eta_(rho sigma) frac(partial x'^rho, partial x^mu)frac(partial x'^sigma, partial x^nu).
$<arb2>

By inserting #ref(<arb1>) into #ref(<arb2>) and keeping everything in first order, we find

$
  eta_(rho sigma)frac(partial x'^rho, partial x^mu)frac(partial x'^sigma, partial x^nu)
      &= eta_(rho sigma)frac(partial, partial x^mu)(x^rho + epsilon^rho (x) + cal(O)(epsilon^2))frac(partial, partial x^nu)(x^sigma + epsilon^sigma (x) + cal(O)(epsilon^2)) \
      &= eta_(rho sigma)(delta^rho_mu delta^sigma_nu + delta^rho_mu frac(partial epsilon^sigma, partial x^nu) + delta^sigma_nu frac(partial epsilon^rho, partial x^nu)) + cal(O)(epsilon^2) \
      &= eta_(mu nu) + (frac(partial epsilon_mu, partial x^nu) + frac(partial epsilon_nu, partial x^mu)) + cal(O)(epsilon^2) \
      &= eta_(mu nu) + (partial_nu epsilon_mu + partial_mu epsilon_nu) + cal(O)(epsilon^2)
$ <f1>

where, in the last line, we simply used the notation $partial\/(partial x^mu) equiv partial_mu$. For such a transformation to be conformal, we see that we must have $partial_mu epsilon_nu + partial_nu epsilon_mu &overset(=, !) f(x) eta_(mu nu)$ where $f(x)$ is any function. We can apply the inverse metric to both sides of this equality so as to determine an expression for $f(x)$:

$
       & space partial_mu epsilon_nu + partial_nu epsilon_mu overset(=, !) f(x) eta_(mu nu) \
  <==> & space eta^(mu nu)partial_nu epsilon_nu + eta^(mu nu)partial_nu epsilon_mu = f(x) eta^(mu nu)eta_(mu nu) equiv f(x) d \
  <==> & space f(x) = 2/d partial^mu epsilon_mu.
$

We will sometimes denote the divergence $partial^mu epsilon_mu =: (partial dot epsilon)$ so as not to be burdened with silent indices. Substituting this expression for $f(x)$ in the original expression, we find a first intermediate expression:

$
  markrect(partial_mu epsilon_nu + partial_nu epsilon_mu = 2/d (partial dot epsilon)eta_(mu nu), padding: #.25em)
$ <temp1>

This equation is the _Killing conformal equation_, which can also be written as

$
  markrect(partial_(\(mu)epsilon_(nu\)) = 1/d (partial dot epsilon) eta_(mu nu), padding: #.25em)
$

To derive another useful relation, we will apply $partial^nu$ on #ref(<temp1>):

$
        & space partial^nu partial_mu epsilon_nu + partial^nu partial_nu epsilon_mu + 2/d partial^nu [ (partial dot epsilon) eta_(mu nu) ] \
  <==> & space partial^nu partial_mu epsilon_nu + square epsilon_mu = 2/d partial^nu (partial dot epsilon) eta_(mu nu) \
  <==> & space partial_mu (partial dot epsilon) + square epsilon_mu = 2/d partial_mu (partial dot epsilon)
$

where we used the commutativity of partial derivatives and $square := partial_mu partial^mu$. We apply $partial_nu$ to this result again to find

$
  space partial_mu partial_nu (partial dot epsilon) + square partial_nu epsilon_mu = 2/d partial_mu partial_nu (partial dot epsilon)
$ <f2>

we swap the indices:

$
  space partial_nu partial_mu (partial dot epsilon) + square partial_mu epsilon_nu = 2/d partial_nu partial_mu (partial dot epsilon)
$ <f3>

and we add #ref(<f2>) with #ref(<f3>), which gives us

$
  & space partial_mu partial_nu (partial dot epsilon) + square partial_nu epsilon_mu + space partial_nu partial_mu (partial dot epsilon) + square partial_mu epsilon_nu \
  & space = 2/d partial_mu partial_nu (partial dot epsilon) + 2/d partial_nu partial_mu (partial dot epsilon)
$

After rearranging the terms and highlighting, we find

$
  partial_mu partial_nu (partial dot epsilon) [1 - 2/d] + (square partial_nu epsilon_mu + square partial_mu epsilon_nu) = 0.
$

We can use the conformal Killing equation, #ref(<temp1>), to write

$
  partial_mu partial_nu (partial dot epsilon) [1 - 2/d] + 2/d square (partial dot epsilon) eta_(mu nu) = 0.
$

We can highlight $(partial dot epsilon)$,

$
  [eta_(mu nu) square + (d - 2) partial_mu partial_nu](partial dot epsilon) = 0
$<f4>

then contract this equation with the metric $eta^(mu nu)$ so as to find, finally and after rearrangement of the terms, our second intermediate result:

$
  (d - 1) square (partial dot epsilon) = 0
$ <temp2>

where, as a reminder, $d > 0$ is the dimension of our spacetime obtained by contraction of the metric with itself. Note that if $d$ were equal to 2 in #ref(<f4>), we would not have obtained this result, while for any other $d > 0$ this result holds.

#remark[
  We also take advantage of talking about the dimensions of space-time to mention that we will call a conformal theory in dimension $d = 1$ a _conformal quantum mechanics_, indeed if we consider that the dimension is time, the one-dimensional quantum field theory describes the temporal evolution of a system living in zero spatial dimensions, that is to say at a single point, so that it is not really a field theory, but a quantum mechanics.
]

Now we can look at constructing the algebra of conformal transformations. As we already intuited earlier, some of the generators should be rather familiar given that the Poincaré group is a subgroup of the conformal group. To begin, note that the equation #ref(<temp2>) implies that $(partial dot epsilon)$ must be at most linear in $x^mu$ (indeed, recall that initially the parameter $epsilon$ comes from the infinitesimal transformation $x'^mu = x^mu + epsilon^mu (x) + cal(O)(epsilon^2)$), which in turn implies that $epsilon_mu$ must be at most quadratic in $x^nu$, in other words we must have "$epsilon = a + b x + c x^2$":

$
  epsilon_mu = a_mu + b_(mu nu) x^nu + c_(mu nu rho)x^nu x^rho,
$<quad>

where $a_mu$, $b_(mu nu)$ and $c_(mu nu rho)$ are parameters to be deduced. Note that $c_(mu nu rho)$ is symmetric under the exchange of $nu$ and $rho$. Let's summarize what we have done so far:

1. We have considered a completely general infinitesimal change of coordinates;
2. We have forced this transformation to be compliant;
3. After some manipulation, we arrived at a quadratic expression for $epsilon$.

Since $epsilon$ is constrained by the definition of the conformal transformation, and this is independent of position, we are able to study each term of #ref(<quad>) individually. The first is the simplest to understand: $a_mu$ corresponds to a _translation_, it follows that the associated generator is already known (we must remember the generators of the Lorentz group), it is $hat(P)_mu = -i partial_mu$, the momentum operator. The linear term in $x^nu$, $b_(mu nu)$, corresponds to a _rescaling_. To find (or identify!) the associated generator, we will use the conformal Killing equation #ref(<temp1>) and insert a linear term $epsilon_mu = b_(mu nu) x^nu$,

$
      & space partial_mu epsilon_nu + partial_nu epsilon_mu = 2/d (partial dot epsilon) eta_(mu nu) \
<==> & space partial_mu (b_(nu rho) x^rho) + partial_nu (b_(mu rho) x^rho) = 2/d (partial^rho (b_(rho sigma) x^sigma)) eta_(mu nu) \
<==> & space b_(nu rho) delta^rho_mu + b_(mu rho) delta^rho_nu = space b_(nu mu) + b_(mu nu) = 2/d (eta^(rho sigma) b_(rho sigma)) eta_(mu nu) \
<==> & space b_((mu nu)) = 1/d (eta^(rho sigma) b_(rho sigma)) eta_(mu nu) \
<==> & space b_((mu nu)) prop eta_(mu nu),
$

this teaches us that the symmetric part of $b_(mu nu)$ is proportional to the metric, in other words $b_(mu nu)$ must be written as follows:

$
  b_(mu nu) = alpha eta_(mu nu) + beta_(mu nu)
$

where $alpha$ is a proportionality factor and $beta_(mu nu)$ is the antisymmetric part of $b_(mu nu)$. Let's start with something we know: the antisymmetric object $beta_(mu nu)$, in this context, must be identified with a _Lorentz rotation_:

$
  x'^mu &= delta^mu_nu x^nu + beta^mu_nu x^nu \
        &= (delta^mu_nu + beta^mu_nu)x^nu,
$

and we know that the generator of these Lorentz rotations is the angular momentum operator $hat(L)_(mu nu) = i(x_mu partial_nu - x_nu partial_mu)$! Then, concerning the symmetric part of $b_(mu nu)$, we see that it is nothing other than an infinitesimal _dilation_

$
  x'^mu &= x^mu + alpha x^mu \
        &= (1 + alpha) x^mu
$

whose associated generator is written $hat(D) = -i x^mu partial_mu$. Now, let's look at the quadratic term $c_(mu nu rho)$, here the transformation and the associated generator are less obvious. We will start by developing an intermediate result that will allow us to study an expression with three indices (indeed, if we want to study $c_(mu nu rho)$ which is of rank 3 then it's the least we can do). Let's consider the application of $partial_rho$ on the conformal Killing equation #ref(<temp1>) and swap the indices cyclically:

$
  partial_rho partial_mu epsilon_nu + partial_rho partial_nu epsilon_mu &= 2\/d space eta_(mu nu) partial_rho (partial dot epsilon) space.quad "(a)" \
  partial_nu partial_rho epsilon_mu + partial_mu partial_rho epsilon_nu &= 2\/d space eta_(rho mu) partial_nu (partial dot epsilon) space.quad "(b)" \
  partial_mu partial_nu epsilon_rho + partial_nu partial_mu epsilon_rho &= 2\/d space eta_(nu rho) partial_mu (partial dot epsilon) space.quad "(c)" \
$

we then express, for example, $"-(a) + (b) + (c)"$ in order to find a simplified expression (we could put the negation on any of the other equations, given that the derivatives commute), which gives us, after calculations, the following expression:

$
  2 partial_mu partial_nu epsilon_rho = 2/d (-eta_(mu nu) partial_rho + eta_(rho mu) partial_nu + eta_(nu rho) partial_mu) (partial dot epsilon).
$<f5>

As before, to find $c_(mu nu rho)$, we use the same trick: we insert the quadratic term $epsilon_mu = c_(mu nu rho)x^nu x^rho$ into the previous equation and expand. We first express the divergence explicitly,

$
  (partial dot epsilon) equiv partial_mu epsilon^mu &= eta^(mu alpha) partial_mu epsilon_alpha \
                                                &= eta^(mu alpha) partial_mu (c_(alpha nu rho) x^nu x^rho) \
                                                &= eta^(mu alpha) c_(alpha nu rho) partial_mu (x^nu x^rho) \
                                                &= eta^(mu alpha) c_(alpha nu rho) (delta^nu_mu x^rho + delta^rho_mu x^nu) \
                                                &= c^mu_(space.en nu rho) (delta^nu_mu x^rho + delta^rho_mu x^nu),
$

which then gives us in the equation #ref(<f5>) by passing a few simple details:

$
       space & 2 partial_mu partial_nu epsilon_rho = 2/d (-eta_(mu nu) partial_rho + eta_(rho mu) partial_nu + eta_(nu rho) partial_mu) (partial dot epsilon) \
  <==> space & 2 c_(mu nu rho) delta^rho_mu = 2/d (-eta_(mu nu) partial_rho + eta_(rho mu) partial_nu + eta_(nu rho) partial_mu) c^mu_(space.en nu rho) (delta^nu_mu x^rho + delta^rho_mu x^nu) \
  <==> space & ... \
  <==> space & c_(mu nu rho) = eta_(mu nu rho) b_nu + eta_(mu nu) b_rho - eta_(nu rho) b_mu space.quad "where" space.quad b_alpha := 1/d c^nu_(space.en nu alpha)
$

where we have basically contracted, distributed and derived the remaining linear terms. So we do have an expression for the coefficient $c_(mu nu rho)$, and we can then calculate the associated infinitesimal transformation $x'^mu = x^mu + epsilon^mu$. We can start by writing

$
  c^mu_(space.en nu rho) = eta^(mu alpha) c_(alpha nu rho) = delta^mu_rho b_nu + delta^mu_nu b_rho - eta_(nu rho) b^mu
$

to then have:

$
  epsilon^mu &= c^mu_(space.en nu rho) x^nu x^rho \
             &= delta^mu_rho b_nu x^nu x^rho + delta^mu_nu b_rho x^nu x^rho - eta_(nu rho)b^mu x^nu x^rho \
             &= b_nu x^nu x^mu + b_rho x^mu x^rho - b^mu x^2 \
             &= (x dot b) x^mu + (x dot b) x^mu - b^mu x^2 \
             &= 2(x dot b)x^mu - b^mu x^2,
$

and so

$
  x'^mu &= x^mu + epsilon^mu \
        &= x^mu + 2(x dot b)x^mu - b^mu x^2.
$

This infinitesimal transformation is called "special conformal". We deduce that the generator associated with it is

$
  hat(K)_mu = -i(2 x_mu x^nu partial_nu - (x^2) partial_mu).
$

To summarize, we have determined four infinitesimal generators, which we summarize here in the following table:

#align(center,
  table(
    columns: (auto, auto),
    align: (left, left),
    table.header([*generator*], [*infinitesimal transformation*]),

    [$hat(P)_mu = -i partial_mu$], [$x'^mu (x^mu) = x^mu + a^mu$],
    [$hat(L)_(mu nu) = i(x_mu partial_nu - x_nu partial_mu)$], [$x'^mu (x^mu) = (delta^mu_nu + beta^mu_nu)x^nu$],
    [$hat(D) = -i x^mu partial_mu$], [$x'^mu (x^mu) = (1 + alpha)x^mu$],
    [$hat(K)_mu = -i(2 x_mu x^nu partial_nu - (x^2) partial_mu)$], [$x'^mu (x^mu) = x^mu + 2(x dot b)x^mu - b^mu x^2$],
  )
)

The first two generators are therefore associated with the Poincaré group while the second two are induced by conformal symmetries (dilation and special conformal transformation respectively). We can explicitly rewrite all the terms of $epsilon^mu$ expanded:

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

Translations, dilations, and Lorentz transformations are fairly intuitive to understand, but the special conformal transformation is a little less so. The associated general non-infinitesimal transformation can be written as

$
  x'^mu &= frac(x^mu - (x dot x) b^mu, 1 - 2(b dot x) + (b dot b)(x dot x)) \
        &= frac(x^mu - b^mu x^2, 1 - 2 b dot x + b^2 x^2).
$

We can see that this is a transformation with singular points (but in infinitesimal form this is not the case, as can be seen in the table above and in any case in physics we are interested in infinitesimal transformations in the framework of Lie algebras). The denominator is indeed zero in $x^mu = b^(-2) b^mu$. This transformation can be understood as the composition of an inversion, a translation and another inversion. If we want to define a finite conformal special transformation that is globally defined then we must consider _compactification_, but this will not be discussed.

#remark[
  Groups are non-linear and complicated objects, which is why in physics we prefer to work with spaces that are tangent to them (we often choose tangent to the identity for convenience), which corresponds to Lie algebras, where any transformation is well defined everywhere.
]

Now that we have the generators, we can calculate the different commutators in order to deduce the Lie algebra of the conformal group. The commutation relations between the generators of the Poincaré group are already known, and the others are therefore calculated more or less laboriously. We can therefore find the following relations:

$
  & [hat(D), hat(P)_mu] = i hat(P)_mu \
  & [hat(D), hat(K)_mu] = -i hat(K)_mu \
  & [hat(K)_mu, hat(P)_nu] = 2 i (eta_(mu nu) hat(D) - hat(L)_(mu nu)) \
  & [hat(K)_rho, hat(L)_(mu nu)] = i (eta_(rho mu) hat(K)_nu - eta_(rho nu) hat(K)_mu) \
  & [hat(P)_rho, hat(L)_(mu nu)] = i (eta_(rho mu) hat(P)_nu - eta_(rho nu) hat(P)_mu) \
  & [hat(L)_(mu nu), L_(rho sigma)] = i (eta_(nu rho) hat(L)_(mu sigma) + eta_(mu sigma) hat(L)_(nu rho) - eta_(mu rho) hat(L)_(nu sigma) - eta_(nu sigma) hat(L)_(mu rho))
$

where all other commutators are zero. This therefore defines the Lie algebra of the conformal group. It is possible to show that the following objects:

$
  C_2 := 1/2 hat(L)^(mu nu)hat(L)_(mu nu), space.quad C_3 := 1/2 hat(L)^(mu nu)hat(L)_(nu rho)hat(L)^rho_(space.en mu), space.quad C_4 := hat(L)^(mu nu)hat(L)_(nu rho)hat(L)^(rho sigma)hat(L)_(sigma mu)
$

commute with all generators, and are therefore _casimirs_ of the algebra of the conformal group, but we will not go into further details. Moreover, in the following, we will limit the use of a small hat "$hat$" on operators.

=== Note on the case $d = 2$: Virasoro algebra
We will not go into the details of a conformal theory at $d = 2$ because that is a separate topic, but will simply make some remarks on why this case is distinguished from the $d >= 3$ case, as we now have sufficient tools to understand how things differ. At $d = 2$, it is convenient to use a complex coordinate system, with $z = x^1 + i x^2$ and $overline(z) = x^1 - i x^2$. By doing this, the conformal Killing equation #ref(<temp1>) takes the following form (after some manipulation):

$
  cases(
    partial_1 epsilon_1 = partial_2 epsilon_1,
    partial_1 epsilon_2 = -partial_2 epsilon_1,
  )
$

in other words, we recognize the _Cauchy-Riemann equations_ of complex analysis! Previously, we were looking for the $epsilon$ satisfying the conformal Killing equation and found that there existed a finite number of them up to constants, but in the present case there are an _infinity_ of solutions to these equations. More precisely, the solutions are any analytic function $z |-> f(z)$ and $overline(z) |-> f(overline(z))$. If we wanted to classify this set of transformations into generators, then, instead of having four, we would have an infinity of them: we must be able to generate any analytic function (in the complex sense), hence this necessary infinite number of generators. If we continue in this direction, we would arrive at a more "general" conformal theory, and in particular we would arrive at the Virasoro algebra, a complex Lie algebra of infinite dimension notably used in string theory. This is why we will not go into this further in this document.

=== Dimension of the conformal group and isomorphism with $"SO(d + 1, 1)"$
There is a connection between the conformal group, which we studied through its algebra, as is often the case, and the group $"SO"(d + 1, 1)$. Let us start by looking at the dimension of the algebra (i.e. the number of generators) for $d >= 3$:

- *Translation*: there are $d$ independent parameters for the translation, one for each direction of the $d$-dimensional spacetime;
- *Lorentz rotations*: we already know that the orthogonal group in dimension $d$ (i.e. $"SO"(d - 1, 1)$ in relativity) has $d(d-1)\/2$ generators;
- *Expansions*: there is only one common expansion factor (a constant factor), so it contributes to only one generator;
- *Special conformal transformations*: knowing that the SCT boils down to an inversion, then a translation, then another inversion, then we deduce that there are as many generators as for the translation, in other words $d$.

All together we get the following sum:

$
  d "translations" + d(d-1)/2 "rotations" + 1 "dilatation" + d "SCT's" \
          = ((d + 2)(d + 1))/2 "generators"
$

and this is therefore the dimension of the conform algebra to $d >= 3$. Note that this corresponds to the number of generators of the group $"SO"(d + 1, 1)$ (depending on the signature adopted), in fact the group $"SO"(d + 1, 1)$ is the set of orthogonal matrices in a space of dimension $d+2$ (where we borrow the signature $(d + 1, 1)$ if we are in a Minkowski space or $(d + 2, 0)$ if we are in a Euclidean space according to the conventions) and, in general, the dimension of $"SO"(n)$ is $(n(n - 1))\/2$ or, in mi xed signature $"SO"(p, q)$, the dimension is expressed analogously as $((p + q)(p+q-1))\/2$. If we specify in the present case, i.e. $"SO"(d + 1, 1)$, then we have $ dim("SO"(d + 1, 1)) = ((d + 2)(d + 1))/2 $ and we therefore find the same dimension as for the conformal group.

#remark[
  In dimension $d$, rotations (or more generally orthogonal transformations) are made in two-dimensional planes. Such a "rotation plane" is defined by the choice of two axes among $d$ possible, the number of ways to choose $2$ axes among $d$ is $ binom(d, 2) = (d(d - 1))/2 $ hence the result obtained for rotations if we no longer remember the number of generators of the orthogonal group.
]

Saying that two groups have the same dimension is necessary to say that they are isomorphic, but not sufficient. If we set

$
  & J_(mu nu) := L_(mu nu) \
  & J_(-1, mu) := 1/2 (P_mu - K_mu) \
  & J_(0, mu) := 1/2 (P_mu + K_mu) \
  & J_(-1, 0) := D,
$

then it is possible to show that the generators $J_(alpha beta)$, with $a, b = -1, 0, ..., n = p + q$ obey the Lorentz algebra with the metric $tilde(eta)_(alpha beta) = "diag"(-1, +1, -1, ..., -1, +1, ..., +1)$ but we are not going to show it here.

== Note on the S matrix in conformal field theory
This subsection is not dedicated to establishing the S-matrix given conformal symmetries because the S-matrix _cannot_ be constructed in a conformal field theory. This is what we will briefly discuss in this mini-section.

#remark[
  Talking about the S matrix in a context other than that of particles, as is the case in the study of phase transitions for example, is not very useful, but we will nevertheless take a small parenthesis to discuss this aspect which is slightly outside the scope of this document.
]

First of all, let us note that just because conformal field theory does not admit an S-matrix does not mean that the S-matrix, in another theory, does not admit conformal symmetries. Recall that the S-matrix is ​​defined as the (unitary) matrix connecting _asymptotically_ free particle states $ket("in")$ and $ket("out")$ in a Hilbert space. Now, let us recall that a conformal field theory is invariant under conformal symmetries, and more particularly under _dilation_. In other words, because of invariance under dilation, the very concept of being "asymptotically distant" no longer really makes sense: in CFT, there are no asymptotic states, and therefore _no_ S-matrix, strictly speaking.

== Correlation functions
In conformal field theory, _correlation functions_ play the role of observables of the theory, a central object in CFT. Correlation functions in physics are quite similar to those found in statistics; they measure, as one might expect, the degree of correlation between two random variables. That is, the frequency with which two random variables have similar values. In a field theory context, the connection is less clear. In field theory, the $n$-point correlation function is defined as the average functional product of $n$ fields at different positions,

$
  G_n (x_1, x_2, ..., x_n) &:= corr(phi(x_1) phi(x_2) ... phi(x_3)) \
                           &:= frac(integral [cal(D) phi] e^(-S[phi]) phi(x_1) ... phi(x_n), integral [cal(D) phi] e^(-S[phi])) \
                           &=: frac(1, z_0) integral [cal(D) phi] e^(-S[phi]) phi(x_1) ... phi(x_n)
$

and for time-dependent correlation functions, the time-order operator $T$ must be included. The two-point correlation function $G_2 (x, y)$ can be physically interpreted as the propagation amplitude of a particle between $y$ and $x$. In a free theory, this is simply the Feynman propagator. The term "Green function" is sometimes used to refer to any correlation function, not just two-point correlation functions.

For the following, in the framework of conformal field theory, we will define a correlation function as a function of the form $corr(phi_1 (x_1) phi_2 (x_2) ... phi_n (x_n))$ containing a finite number of objects (more specifically operators) and returning a real number. We will assume that the objects between $corr(...)$ can commute without changing the value of the correlation function and that the correlation functions are linear, that is to say that

$
  corr(A_1 phi_1 (x_1) A_2 phi_2 (x_2) ... A_n phi_n (x_n)) = (A_1 A_2 ... A_n) corr(phi_1 (x_1) phi_2 (x_2) ... phi_n (x_n))
$

where $A_k$ is a constant or an operator of the positions $x^mu$. The notion of correlation function in the framework of CFT should become clearer as it is used.

== Scaling dimension of an operator
In the following, we will need an important concept that is directly related to dilations: the scaling dimension of an operator. The scaling dimension is a number associated with an operator that indicates how the latter behaves under dilation $x -> lambda x$. This notion is related to dimensions in the sense of dimensional analysis. Given any operator $cal(O)(x)$, the invariance under dilation $x -> lambda x$ implies that

$
  cal(O)(x) -> cal(O)(lambda x) = lambda^(-Delta) cal(O)(x)
$<dim1>

where $Delta in RR$ is the _scale dimension_ of the operator $cal(O)$. The number $Delta$ must exist so that the dimensions (hence to be understood as "the units") are respected. In a theory that is not invariant under dilation, the $Delta$ are no longer simple numbers but functions of the distance scales. This concept is not specific to conformal field theory.

Often, we will want to determine what the scaling dimension of an operator or field $phi(x)$ is, we can establish the general expression of this dimension for a field theory. In the natural unit system $ħ = 1 = c$, the distance is the inverse of the mass, $[L] = [M]^(-1)$, and when we study the scaling units it is the exponents that interest us, so we will have that if $m$ is a mass term and $x$ is a position term, then we will take the convention that $Delta_m = 1$ and $Delta_x = -1$. To determine the scaling dimension of a field $phi(x)$, consider the action

$
  S = 1/2 integral dd^d x space (partial_mu phi)^2.
$

In natural units, the action is dimensionless (since $ħ = 1$, a simple scalar), so we deduce that $Delta_S = 0$. We also deduce that the scale dimension of the measure is

$
  Delta_(dd^d x) = -d
$

since $Delta_x = -1$. We can then try to find the scaling dimension of $phi$:

$
       & space Delta_S = Delta_(dd^d x) + 2 (Delta_(partial_mu) + Delta_phi) \
  <==> & space 0 = -d + 2 Delta_(partial_mu) + 2 Delta_phi
$

where the partial derivative $partial_mu equiv partial\/partial x^mu$, which implies that $Delta_(partial_mu) = +1$, so in the end we have

$
       & space.quad 0 = -d + 2 + 2 Delta_phi \
  <==> & space.quad markrect(Delta_phi = d/2 - 1, padding: #.5em)
$
#v(0.5em)

For example, in four dimensions $Delta_phi = 1$ and in three dimensions $Delta_phi = 1\/2$.

#example[
  Now that we know what the general form of $Delta_phi$ is, we can infer the scaling dimension of other parameters, for example consider the following interacting action:
  $
    S = integral dd^d x space lambda phi^n
  $
  so,
  $
         & space Delta_S = Delta_(dd^d x) + Delta_lambda + n Delta_phi \
    <==> & space 0 = -d + Delta_lambda + n (d/2 - 1) \
    <==> & space Delta_lambda = d - n (d/2 - 1)
  $
]

The scale dimension will be an important parameter, in fact it is part of the information needed to characterize an operator, as we will see later.

#example[
  We can take another more complicated example, it will actually be reduced to a very simple case (it is an action for the Ising model):
  $
    S = 1/2 integral dd^3 x space [ -partial_mu phi partial^mu phi - m^2 phi^2 - g/4! phi^4 ].
  $
  Here, the only unknown scaling dimension is $Delta_g$, so we can focus only on the third term of the sum (knowing that $d = 3$ in this example):
  $
         & space Delta_S = Delta_(dd^3 x) + (Delta_g + 4 Delta_phi) \
    <==> & space 0 = -3 + Delta_g + 4 (3/2 - 1) \
    <==> & space Delta_g = 1.
  $
]

The relation #ref(<dim1>), $cal(O)(x) -> cal(O)(lambda x) = lambda^(-Delta) cal(O)(x)$, implies that the correlation functions, under scale invariance, must be such that

$
  corr(cal(O)_1(lambda x_1) cal(O)_2(lambda x_2) ...) = lambda^(-Delta_1 - Delta_2 - ...) corr(cal(O)_1(x_1) cal(O)_2(x_2) ...).
$

#example[
  Let's take for example the 2-point correlation function $corr(cal(O)(x) cal(O)(0))$, then
  $
    corr(cal(O)(x) cal(O)(0)) -> & corr(cal(O)(lambda x) cal(O)(lambda 0)) \
                                 & = lambda^(-(Delta + Delta)) corr(cal(O)(x) cal(O)(0)) \
                                 & = lambda^(-2 Delta) corr(cal(O)(x) cal(O)(0)).
  $
]

The scale invariance of correlation functions will be the starting point for developing, subsequently, an important equation (see the section on bootstrapping), we will return to this later.

== Conserved currents and energy-momentum tensor
For simplicity, consider a scalar field $phi(x)$. We will assume that this field transforms (under a symmetry transformation) according to

$
  cases(
    x^mu -> x'^mu (x),
    phi'(x') = cal(F)(phi(x))
  )
$

where $cal(F)$ is simply the transformation function of the scalar field. As a result, we have the following associated infinitesimal transformations:

$
  & x^mu -> x'^mu (x) = x^mu + space mark(omega^A frac(delta, delta omega^A), padding: #.2em, radius: #10%, color: #red) space x^mu, \
  & phi(x) -> phi'(x) = phi(x) + space mark(omega^A frac(delta, delta omega^A), padding: #.2em, radius: #10%, color: #red) space cal(F)(phi(x))
$

where $omega^A << 1$ are infinitesimal (the capital subscript $A$ indicates that several subscripts may be present, e.g. $omega^(i j k)$, but we denote $omega^A$ for generality and convenience). We also introduce the following notation:

$
  mark(omega^A frac(delta, delta omega^A), padding: #.2em, radius: #10%, color: #red) space =: delta_omega
$

where the $omega$ should not be confused with an index but serves to identify the variation with respect to these infinitesimal parameters $omega^A$. If this infinitesimal transformation is a symmetry of the action then we must have $delta_omega S = S' - S approx 0$ by Noether's theorem (here the symbol "$approx$" indicates an equality modulo the Euler-Lagrange equations). The transformed action is therefore

$
  & space S[phi, partial_mu phi] = integral dd^d x space cal(L)(phi, partial_mu phi)

  \ -->

  & space S[phi', partial'_mu phi'] = integral dd^d x space abs(frac(partial x'^mu, partial x^nu)) cal(L)(phi + delta_omega cal(F), frac(partial x^nu, partial x'^mu) partial_nu [phi + delta_omega cal(F)])
$

where, knowing that $det(bb(1) + epsilon) approx 1 + tr(epsilon)$, we have

$
  abs(frac(partial x'^mu, partial x^nu)) &= abs(frac(partial, partial x^nu) (x^mu + delta_omega x^mu)) \
                                         &= abs(delta^mu_nu + partial_nu delta_omega x^mu) \
                                         &approx 1 + partial_mu delta_omega x^mu.
$

Substituting this expression into the transformed action, expanding and integrating by parts and neglecting boundary terms as is customary, we arrive at the following expression:

$
  delta_omega S &= -integral dd^d x space j^mu_A partial_mu omega^A (x) \
                &overset(=, "(IPP)") ... \
                &= integral dd^d x space partial_mu j^mu_A omega^A (x)
$<deltaomegaint>

where $j^mu_A$ is the _Noether current_, defined by

$
  j^mu_A (x) := space mark([frac(partial cal(L), partial (partial_mu phi)) partial_nu phi - eta^mu_(space.en nu) cal(L)], tag: #<set>, color: #red, padding: #.2em, radius: #10%) space frac(delta x^nu, delta omega^A) - frac(partial cal(L), partial (partial_mu phi)) frac(delta F, delta omega^A).

  #annot(<set>, pos: bottom + right, yshift: 2em)[tenseur énergie-impulsion (canonique)]
$<current>
#v(2em)

If the Euler-Lagrange equations are satisfied by the field $phi(x)$, $ frac(partial cal(L), partial phi) - partial_mu (frac(partial cal(L), partial (partial_mu phi))) approx 0, $ then the action is invariant under any arbitrary variation of the field: $delta S = 0$ for all $omega^A$, which leads to the Noether current conservation law: $ partial_mu j^mu_A = 0 $ and we will define the associated _Noether charge_ as $ Q := integral dd^(d - 1) x space j^0_a. $ In other words, a continuous symmetry of the action implies the existence of a conserved current. Note that adding the divergence of an antisymmetric tensor to the current $j^mu_A$ does not affect its conservation, in other words it will always be possible to find an antisymmetric $A^(mu nu)$ such that

$
  partial_mu j^mu_A = 0,
$

Indeed,

$
  & j^mu_A --> j^mu_A + partial_nu A^(mu nu) space.quad "where" space.quad A^(mu nu) = -A^(nu mu) \
  partial_mu & j^mu_A --> markul(partial_mu j^mu_A, tag: #<original>) + partial_(text(fill: #red, mu)) partial_(text(fill: #red, nu)) A^(text(fill: #red, mu nu)) = 0

  #annot(<original>, pos: bottom + right, yshift: 1em)[is 0 for current conservation]
$
#v(1.5em)

where the second term is zero by contraction of symmetric and antisymmetric objects. We therefore have the freedom to (re)define the current $j^mu_A$. We can now be interested in these currents given conformal symmetries.

*Translation and zero trace*

Consider an infinitesimal translation $x^mu -> x'^mu = x^mu + epsilon^mu$, from which we get that

$
  frac(delta x^mu, delta epsilon^nu) = delta^mu_nu space.quad "and" space.quad frac(partial cal(F), delta epsilon^nu) = 0
$

and it follows directly, by inserting this in #ref(<current>), that

$
  j^mu_A &= T^mu_(space.en nu) frac(delta x^nu, delta epsilon^A) - frac(partial cal(L), partial(partial_mu phi)) frac(delta cal(F), delta epsilon^A) \
         &= T^mu_(space.en nu) delta^nu_A.
$

In other words, given a translational symmetry, the conserved current _is_ the (canonical) energy-momentum tensor:

$
  T^(mu nu) = -eta^(mu nu)cal(L) + frac(partial cal(L), partial(partial_mu phi))partial_mu phi.
$

This _current_ is not manifestly symmetric, but we can for example use the freedom on the addition of a $partial_mu A^(mu nu)$, where $A^(mu nu) = -A^(nu mu)$, in order to determine an expression that is manifestly symmetric and that remains conserved, but this is not very important for what follows.

A particular fact about the energy-momentum tensor can be deduced from the conservation of current associated with the translational symmetry that we have just developed:

$
  0 = partial_mu j^mu &= partial_mu (T^(mu nu) epsilon_nu) \
                      &= T^(mu nu) partial_mu epsilon_nu + epsilon_nu partial_mu T^(mu nu) \
                      &= 1/2 T^(mu nu) (partial_mu epsilon_nu + partial_nu epsilon)
$

and, using the conformal Killing equation #ref(<temp1>), we find

$
                  & 0 = 1/d (partial dot epsilon) T^mu_(space.en mu) \
  <==> space.quad & markrect(T^mu_(space.en mu) = 0, padding: #.25em) space.
$

In other words, under conformal symmetries, the energy-momentum tensor has zero trace. This is a fact specific to conformal field theories: every CFT has a zero trace energy-momentum tensor! In a conformal field theory, the fact that the energy-momentum tensor has zero trace reflects the invariance of the system under expansions. Concretely, this means that the dynamics of the system does not involve any dimensional parameter that would fi x a particular scale, which is at the heart of conformal invariance.

The other symmetry transformations (rotation, dilation and special conformal) can also be associated with a current by a similar procedure, however we will not go into the details of the calculations because this is not very useful for the following and it is a work which is not specific to conformal field theory.

*Rotation*

Analogously to the study of Poincaré transformations, Lorentz rotations are associated with the angular momentum tensor, the variation $delta x^mu = omega^mu_(space.en nu) x^nu$ gives rise to the current $ M^mu_(space.en rho sigma) = x_rho T^mu_(space.en sigma) - x_sigma T^mu_(space.en rho) $<noether_r> where $T^(mu nu)$ is the energy-momentum tensor (the one that emerges from symmetries under translations).

*Dilation*

Consider a transformation $x^mu -> x'^mu = x^mu + epsilon x^mu$, in other words $delta x^mu = epsilon x^mu$, we then show that the associated Noether current is $ J^mu_"dilatation" = x_nu T^(mu nu). $<noether_d>

*Special conformity*

For the SCT, to the infinitesimal order, we have $delta x^mu = 2(b dot x) x^mu - x^2 b^mu$, from which we derive the following Noether current: $ J^mu_"SCT" = (2 x^rho x_nu - x^2 delta^rho_nu) T^(mu nu). $<noether_sct>

#linebreak()

For each of these currents, the form is not unique, in particular it is common to express everything in terms of the manifestly symmetric energy-momentum tensor $T^(mu nu)$ and, therefore, to add corrective terms.

=== The Identity of Ward-Takahashi
At the classical level, the invariance of the action under continuous symmetries implies the existence of a conserved current. However, at the quantum level, classical symmetries lead to constraints on the correlation function, known as the Ward Takahashi identities. We will say that the symmetry is "anomalous" if the functional measure in the path integral does not exhibit the symmetry of the action, i.e. $[cal(D) phi'] != [cal(D) phi]$. In the following, we will always assume that this constraint holds. Assume that the classical action is invariant under the general transformation $ phi'(x') = cal(F)(phi(x)) $ and that the symmetry is not anomalous, i.e. $[cal(D) phi'] = [cal(D) phi]$. Then

$
  corr(phi(x'_1) ... phi(x'_n)) &equiv alpha integral [cal(D) phi] space phi(x'_1) ... phi(x'_n) space e^(-S[phi]) \
                                            &= alpha integral [cal(D) phi'] space phi'(x'_1) ... phi'(x'_n) space e^(-S[phi']) \
                                            &= alpha integral [cal(D) phi] space cal(F)(phi(x'_1)) ... cal(F)(phi(x'_n)) space e^(-S[phi]) \
                                            &equiv corr(cal(F)(phi(x'_1)) ... cal(F)(phi(x'_n)))
$<w1>


where we moved from the first line to the second line by renaming $phi -> phi'$ and where $alpha$ is simply a proportionality factor. We want to find an infinitesimal version of this result. Recall that an infinitesimal transformation can be written in terms of its generators $G_A$ as

$
  phi'_cal(A) (x) = phi_cal(A) (x) - i omega^A (G_A)_cal(A)^(space.en cal(B)) phi_cal(B) (x),
$

where $omega^A$ are, again, a set of infinitesimal parameters all grouped under a single large index $A$. Setting $omega^A -> omega^A (x)$, the variation of the action $delta_omega S[phi]$ is given by #ref(<deltaomegaint>),

$
  delta_omega S[phi] = integral dd^d x space partial_mu j^mu_A (x) omega^A (x).
$

Let us set the product $X := phi(x_1) ... phi(x_n)$ and note its variation $delta_omega X$, given explicitly by

$
  delta_omega X &= omega^A frac(delta, delta omega^A) [phi(x_1) phi(x_2) ... phi(x_n)] \
                &= omega^A [frac(delta, delta omega^A) phi(x_1) phi(x_2) ... phi(x_n) + phi(x_1) frac(delta, delta omega^A) phi(x_2) ... phi(x_n) + ... \
                &"        " + phi(x_1) phi(x_2) ... frac(delta, delta omega^A) phi(x_n) ] \
                &= omega^A sum_(k = 1)^n [ phi(x_1) phi(x_2) ... frac(delta, delta omega^A) phi(x_i) ... phi(x_n) ]
$

where we just apply the rule of the product of derivatives. With $delta \/ delta omega^A = -i G_A$ we therefore obtain

$
  delta_omega X = -i omega^A sum_(k = 1)^n [ phi(x_1) phi(x_2) ... G_A phi(x_k) ... phi(x_n) ].
$

Now, taking the integral of this expression multiplied by a Dirac $d$-delta (so that the expression obtained reduces identically to the previous expression), we have

$
  delta_omega X = -i integral dd^d x space sum_(k = 1)^n delta^((d))(x - x_k) [ phi(x_1) ... G_A phi(x_k) ... phi(x_n) ] omega^A,
$

what we can insert into a $corr(...)$ to find a first intermediate expression:

$
  corr(delta_omega X) = -i integral dd^d x space sum_(k = 1)^n delta^((d))(x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) omega^A.
$ <deltaomegacorr1>

Wanting to express our result in an integral will be useful for what follows. Let's now use another equivalent notation to express $corr(delta_omega X)$ using the previous functional form. To do this, we consider the variation introduced previously on $phi$ and explicitly express $corr(X)$, which should naturally introduce a $corr(delta_omega X)$:

$
  corr(X) &= alpha integral [cal(D) phi'] space X' e^(-S[phi']) \
          &= alpha integral [cal(D) phi'] space (X + delta_omega X) e^(- (S[phi] + delta_omega S[phi])) \
          &= alpha integral [cal(D) phi'] space (X + delta_omega X) e^(-S[phi] - integral dd^d x space partial_mu j^mu_A (x) omega^A (x))
$

where, as before, we assume that the functional measure is invariant under the transformation. We can now expand the previous expression to first order in $omega^A$ for the exponential:

$
  corr(X) &= alpha integral [cal(D) phi'] space (X + delta_omega X) e^(-S[phi] - integral dd^d x partial_mu j^mu_A (x) omega^A (x)) \
          &= alpha integral [cal(D) phi'] space (X + delta_omega X) [ 1 - integral dd^d x space partial_mu j^mu_A (x) omega^A (x) + ... ] e^(-S[phi]) \
          &= corr(X) + corr(delta_omega X) - integral dd^d x space partial_mu [ alpha integral [cal(D) phi] space j^mu_A (x) X e^(-S[phi]) ] omega^A + ... \
          &= corr(X) + corr(delta_omega X) - integral dd^d x space partial_mu corr(j^mu_A (x) X) omega^A + mark(cal(O)(omega^2), tag: #<cancel>, color: #red, padding: #0.2em) \

  <==> space corr(delta_omega X) &= integral dd^d x space partial_mu corr(j^mu_A (x) X) omega^A
          
  #annot(<cancel>, yshift: 1em)[on néglige ces termes d'ordre suppérieur]
$<deltaomegacorr2>


Now that we have two expressions for $corr(delta_omega X)$, all we need to do is equate them. So we use #ref(<deltaomegacorr1>) and #ref(<deltaomegacorr2>) to form the following equation:

$
  integral dd^d x space partial_mu corr(j^mu_A (x) X) omega^A = \ -i integral dd^d x space sum_(k = 1)^n & delta^((d))(x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) omega^A,
$<temp3>

and since the $omega^A$ are arbitrary, we can rewrite #ref(<temp3>) as

#v(0.5em)
$
  markrect(partial_mu corr(j^mu_A (x) phi(x_1) ... phi(x_n)) + i sum_(k = 1)^n delta^((d))(x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) = 0, padding: #0.5em)
$<ward>
#v(0.5em)

where we have re-expressed $X = phi(x_1) phi(x_2) ... phi(x_n)$. The equation #ref(<ward>) is the _Ward-Takahashi identity_ for the current $j^mu_A (x)$ and is an infinitesimal version of #ref(<w1>) (this can be seen by integration of #ref(<ward>) and some algebraic manipulations).

#remark[
  In the literature, the terms "Ward identity" and "Ward-Takahashi identity" are sometimes encountered; the two are related and sometimes interchanged. In fact, the distinction is often made when applying the Ward-Takahashi identity specifically to the elements of the matrix $S$ in quantum field theory, where we will then simply speak of the Ward identity.
]

Very generally, Ward identities reflect the constraints imposed by a symmetry (internal or gauge for example) on the correlation functions.


=== Ward-Takahashi identity and conformal symmetries
Let's apply the equation developed in the previous section, #ref(<ward>), to a conformal field theory. We sometimes speak of Ward identities in the plural because the previous formula gives us one for each Noether current. Recall the Noether currents associated with conformal symmetries:

#align(center,
  table(
    columns: (auto, auto),
    align: (left, left),
    table.header([*Current*], [*Associated Symmetry*]),

    [$T^(mu nu) = T_cal(C)^(space.en mu nu) + partial_rho B^(rho mu nu) + 1/2 partial_lambda partial_rho X^(lambda rho mu nu) $], [translation],
    [$J^(mu nu rho) = T^(mu nu) x^rho - T^(mu rho) x^nu$], [Lorentz],
    [$j^mu_D = T^mu_(space.en nu) x^nu$], [dilation],
    [$j^(mu nu)_K = -T^mu_(space.en rho) I^(rho nu)(x)$], [special conform]
  )
)

Let us now establish Ward identities for each of these symmetries.

*Symmetry under translation*

The generator of the translations is $P_mu = -i partial_mu$ and the associated current is given by $T^(mu nu)$, so, by substituting in #ref(<ward>), we obtain

$
  0 &= partial_mu corr(j^mu_A (x) phi(x_1) ... phi(x_n)) + i sum^n_(k = 1) delta^((d)) (x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) \
    &= partial_mu corr(T^(mu nu) phi(x_1) ... phi(x_n)) + sum^n delta^((d)) (x - x_k) partial_k^nu corr(phi(x_1) ... phi(x_k) ... phi(x_n))
$

where we used the "linearity" of the correlation functions. This is the Ward identity associated with translations. More compactly, we write

#v(0.5em)
$
  markrect(partial_mu corr(T^mu_(space.en nu) X) = -sum_k delta^((d)) (x - x_k) frac(partial, partial x^nu_(space.en k)) corr(X), padding: #.5em)
$

#linebreak()
Similarly, but with a little more effort, we can obtain the other Ward identities associated with the currents #ref(<noether_r>), #ref(<noether_d>) and #ref(<noether_sct>), the results are less interesting, more complicated, and we will therefore not present them since they will not be of use to us later.


/*

*Lorentz symmetry*

The generator of the Lorentz transformations is $ L_(mu nu) = -i (x_mu partial_nu - x_nu partial_mu) $ and the associated Noether current is given by $J^(mu nu rho)$. Substituting in #ref(<ward>), we obtain

$
             & 0 = partial_mu corr(j^mu_A (x) phi(x_1) ... phi(x_n)) + i sum^n_(k = 1) delta^((d)) (x - x_k) corr(phi(x_1) ... G_A phi(x_k) ... phi(x_n)) \
  space <==> & space partial_mu corr(J^(mu nu rho) phi(x_1) ... phi(x_n)) = sum_k delta^((d)) (x - x_k) [-i (x_mu partial_nu - x_nu partial_mu)] corr(phi(x_1) ... phi(x_k) ... phi(x_n)).
$

On the left side of the equality, the partial derivative acts on $ J^(mu nu rho) = T^(mu nu) x^rho - T^(mu rho) x^nu, $ that is, on $T^(mu nu)$ and $x^rho$, so we can use the previous Ward identity to finally obtain the Ward identity associated with the Lorentz transformations:

$
  corr(T^([mu nu]) phi(x_1) ... phi(x_2)) = 1/2 sum_k delta^((d)) (x - x_k) corr(phi(x_1) ... phi(x_k) ... phi(x_n)),
$

or, more compactly,

#v(0.5em)
$
  markrect(corr(T^([mu nu])
$
#v(0.5em)

*Symmetry under dilation*

The generator of the dilations is $D = -i(x^mu partial_mu)$ and the associated Noether current is given by $j^mu_D$, Substituting in #ref(<ward>), we find

$
  partial_mu corr(T^mu_(space.en nu) & x^nu phi(x_1) ... phi(x_n)) \
        &= -sum_k delta^((d)) (x - x_k) [x_k^n frac(partial, partial x_(n, k))] corr(phi(x_1) ... phi(x_k) ... phi(x_n)).
$

As before, we use the Ward identity associated with the translations and find

$
  corr(T^mu_(space.en mu) phi(x_1) ... phi(x_n)) = -sum_k delta^((d)) (x - x_k) corr(phi(x_1) ... phi(x_k) ... phi(x_n)),
$

or, more compactly,

#v(0.5em)
$
  markrect(corr(T^mu_(space.en mu)
$
#v(0.5em)

*Symmetry under special conformal transformations*

TODO


To summarize, we have determined three equations, three _constraints_, recalled below:

$
  &partial_mu corr(T^mu_(space.en nu)
  &corr(T^([mu nu])
  &corr(T^mu_(space.en mu)
$

Note that for distinct spacetime points, $x != x_k$, these identities reduce to

$
  &partial_mu corr(T^mu_(space.en nu) X) = 0 && space.quad "(Translations)" \
  &corr(T^([mu nu])
  &corr(T^mu_(space.en mu) X) = 0 && space.quad "(Dilations)"
$

Where, as a reminder, $X := corr(phi(x_1) phi(x_2) ... phi(x_n))$. The contributions for which $x = x_k$ are known as "contact terms".

*/


== Primary and descendant operators
Conformal symmetries impose constraints on correlation functions. One way to classify the operators of a conformal field theory comes directly from the representation of the generators of the conformal group and is analogous to the creation and annihilation operators of the harmonic oscillator in quantum mechanics. To make this clear, it is useful to adopt a different convention than that used when deriving the generators associated with conformal transformations. We will use

#align(center,
  table(
    columns: (auto, auto),
    align: (left, left),
    table.header([*generator*], [*transformation*]),

    [$hat(P)_mu = partial_mu$], [Translation],
    [$hat(L)_(mu nu) = x_nu partial_mu - x_mu partial_nu$], [Lorentz],
    [$hat(D) = x^mu partial_mu$], [Dilation],
    [$hat(K)_mu = 2 x_mu x^nu partial_nu - (x^2) partial_mu)$], [Special compliant],
  )
)

In this new convention, the $-i$ "disappears" compared to what we had derived earlier. It follows that the associated algebra changes, but we are not going to rewrite everything, only

$
  & [hat(D), hat(P)_mu] = hat(P)_mu \
  & [hat(D), hat(K)_mu] = -hat(K)_mu.
$

With this convention, it is easier to realize the analogy with the creation and destruction operators in quantum mechanics:

$
  & [hat(D), hat(P)_mu] = hat(P)_mu space.quad && <--> && space.quad [hat(N), hat(a)^dagger] = hat(a)^dagger \
  & [hat(D), hat(K)_mu] = -hat(K)_mu space.quad && <--> && space.quad [hat(N), hat(a)] = -hat(a)
$

where $hat(a)^dagger$ and $hat(a)$ are the up and down operators for the harmonic oscillator, respectively, and $hat(N)$ is the number operator. This similarity suggests that $hat(P)_mu$ and $hat(K)_mu$ can also be understood as up and down operators for $hat(D)$, which is indeed the case. We will choose to work in a basis where our states have a well-defined eigenvalue, $Delta$, under dilation (this will come back a little later!) We note

$
  ket(Delta) = "state with dimension" Delta.
$

These states will be created by acting with an operator $hat(O)_Delta(0)$ at the origin, on the vacuum

$
  hat(O)_Delta (0) ket(0) equiv ket(Delta).
$

#remark[
  In our discussions we can restrict ourselves to the operators inserted at $x = 0$, at the origin, since the transformation properties at any other point can be obtained by applying a translation,

  $
    hat(O)(x) = e^(x^mu hat(P)_mu) hat(O)(0) e^(-x^mu hat(P)_mu),
  $

  and using the Baker–Campbell–Hausdorff formula as well as the commutation relations of conformal algebra. It is just more convenient to use $hat(O)(0)$.
]

By state-operator correspondence, it is possible to generate all the states of our Hilbert space by acting with a local operator at the origin. These operators, $hat(O)_Delta$, will satisfy the following commutation relation:

$
  hat(D) hat(O)_Delta (0) - hat(O)_Delta (0) hat(D) equiv [hat(D), hat(O)_Delta (0)] = Delta hat(O)_Delta (0).
$

We can see that this is all consistent by acting on our state with $hat(D)$:

$
  hat(D) ket(Delta) &= hat(D) hat(O)_Delta (0) ket(0) \
                    &= ([hat(D), hat(O)_Delta (0)] + hat(O)_Delta (0) hat(D)) ket(0) \
                    &= Delta hat(O)_Delta (0) ket(0) + 0 \
                    &= Delta ket(Delta)
$

where we used the fact that $hat(D)$ is associated with a symmetry of the system, and therefore it cancels the vacuum state (because $ket(0)$ is invariant under the symmetries of any physical system). This shows that $ket(Delta)$ is an eigenstate of $hat(D)$ with eigenvalue $Delta$.

To return to the initial discussion, in the same way that the descent operator lowers the eigenvalue of the counting operator $hat(N)$ for the states of the harmonic oscillator, the operator $hat(K)_mu$ will act as a lowering operator for the dilation operator $hat(D)$. As in the harmonic oscillator, we will therefore have a state of lowest weight for our states of given dimension. We will call these states the "primary states" and the operators that will act on the vacuum to generate them are called _primary operators_ and we will use the calligraphic notation $hat(cal(O))_Delta$ to refer to them specifically. Unlike the harmonic oscillator, now, where there is only one lowering operator, in conformal field theories we will generally have several (sometimes even infinitely many) primary states (remember that the harmonic oscillator can indeed only have one ground state). We want these states to be annihilated by $hat(K)_mu$. To this end, we impose that the primary operators commute with $hat(K)_mu$,

$
  [hat(K)_mu, hat(cal(O))_Delta (0)] = 0,
$

it is often only this relation that is given to define the _primary operators_. We can see explicitly what this implies that the primary states are annihilated by $hat(K)_mu$:

$
  hat(K)_mu ket(Delta) &= hat(K)_mu hat(cal(O))_Delta (0) ket(0) \
                       &= hat(cal(O))_Delta (0) hat(K)_mu) ket(0) && space.quad "(commutent)" \
                       &= 0
$

where, in the last line, we used the fact that $hat(K)_mu$ is associated with a symmetry of the system, and therefore that it annihilates the vacuum, as before. In other words, this commutation relation accounts for the desired annihilation.

What about $hat(P)_mu$ now? The states we discussed earlier are the "lowest" ones (if we keep the similarity with the harmonic oscillator), so we would like to see what happens if we act on them with $hat(P)_mu$, which is supposed to behave like a rise operator. Consider a new state $ket(psi)$ that is created by acting $hat(P)_mu$ on an eigenstate of the dilation operator,

$
  hat(P)_mu ket(Delta) = ket(psi)
$

Is this still an eigenstate of $hat(D)$? We can check this by explicitly calculating:

$
  hat(D) ket(psi) &= hat(D) hat(P)_mu ket(Delta) \
                  &= ([hat(D), hat(P)_mu] + hat(P)_(mu) hat(D)) ket(Delta) \
                  &= (hat(P)_mu + hat(P)_mu hat(D)) ket(Delta) \
                  &= hat(P)_mu ket(Delta) + hat(P)_mu hat(D) ket(Delta) \
                  &= hat(P)_mu ket(Delta) + hat(P)_mu Delta ket(Delta) \
                  &= (1 + Delta) hat(P)_mu ket(Delta) \
                  &= (1 + Delta) ket(psi).
$

We thus see that $ket(psi)$ is indeed an eigenstate of $hat(D)$, with a value $Delta + 1$. Concretely, if we start from a state created by the action of a primary operator $ket(Delta)$, then we apply $hat(K)_mu$​, we obtain a new state, called "descendant". Generally speaking, from a primary operator, the operators $hat(K)_mu$ generate a set of descendant operators, each corresponding to a new state whose dimension increases by $1$ each time:

$
  hat(cal(O))_Delta &= "primary dimension operator" Delta \
  hat(P)_mu hat(cal(O))_Delta &= "descending dimension operator" Delta + 1 \
                                                    &.\
                                                    &.\
                                                    &.\
  hat(P)_(mu_1) ... hat(P)_(mu_n) hat(cal(O))_Delta &= "descending dimension operator" Delta + n
$

Therefore, given a primary operator, it will always be associated with a set (often infinite) of descendant operators, we will say that they form a "family". In other words, given that the primary operators generate the descendants by the action of $hat(P)_mu$, it will never be necessary to specify operators other than the primaries, which will greatly simplify discussions in the future.

It turns out, moreover, that the transformation properties of primary operators are simple, it is possible to show that they transform like tensor densities (this is not _as good_ as transforming like a tensor, but it is still a good thing):

#v(0.5em)
$
  hat(tilde(cal(O)))^A_Delta (tilde(x)^mu) = mark(abs(frac(partial x^mu, partial tilde(x)^nu)), tag: #<j>, color: #red)^(Delta \/ D) mark(L^A_(space.en B), tag: #<l>, color: #blue) hat(cal(O))^B_Delta (x^mu)

  #annot(<j>, pos: right, yshift: 0.5em)[Jacobian]
  #annot(<l>, pos: top + right, yshift: 0.5em)[Lorentz representation]
$<density>
#v(1em)

Descending operators do not transform as well, and we will therefore only invoke them implicitly, through the primary operators from which they originate by the action of $hat(P)_mu$. We will not use this formula later; we only take it as a note.






== The operator product expansion (OPE)
We now come to an important concept (yet another one!), the _Operator Product Expansion_. We'll introduce the concept using states to get a hook on something already known, but we'll quickly get rid of them since they're not necessary and will be more of an aid than anything else. The goal is to write the operator product $phi(x) phi(0)$ as a sum of operators inserted at a single point (we'll come back to the _why_ right after). Consider the state $ket(psi)$ given by

$
  ket(psi) = phi_1(x) phi_2(0) ket(0)
$

where $phi_1$ and $phi_2$ are two arbitrary primary operators (for simplicity, we consider scalars, but the discussion remains valid for indexed operators). In the framework of a conformal theory, we have at our disposal the dilation operator $hat(D)$ and, in the same way that in quantum mechanics we can diagonalize the Hamiltonian operator and obtain a basis of eigenstates, we will diagonalize this dilation operator: we rewrite $ket(phi)$ as a sum in an eigenstate basis of $hat(D)$,

$
  ket(psi) = sum_k C_k ket(Delta_k)
$

where the state $ket(Delta_k)$ includes a primary operator and all its descendants (in fact, to have a complete basis, we must sum over all the operators). Let's rearrange this expression:

$
  ket(psi) &= phi_1(x) phi_2(0) ket(0) \
           &= sum_k C_k ket(Delta_k) \
           &= sum_(phi_I) C_(Delta, I) (x, partial) phi_I (0) ket(0)
$

where this time we make explicit the fact that we are summing over the primary operators, the descendant operators of $phi$ having been taken into account in the coefficient $C$ by the action of the partial derivative (recall that a descendant operator is defined up to a constant as an $n$-partial derivative of a primary operator). Each term of the sum therefore includes a primary operator and all its descendants. We have also included an index $Delta$ for the scaling dimension of the primary operator and an index $I$ for the Lorentz representation associated with this operator. We have expressed everything in terms of states, but this was only to start from an analogy of something known and we can forget the fact that we were talking about states,

$
  cancel(ket(psi), stroke: #(paint: red, dash: "dashed", thickness: 0.7pt), cross: #true)
            &= phi_1(x) phi_2(0) cancel(ket(0), stroke: #(paint: red, dash: "dashed", thickness: 0.7pt), cross: #true) \
            &= sum_(phi_I) C_(Delta, I) (x, partial) phi_I (0) cancel(ket(0), stroke: #(paint: red, dash: "dashed", thickness: 0.7pt), cross: #true)
$

and "promote" the discussion in terms of operators only, which then simply gives us equality between operators,

#v(0.5em)
$
  markrect(phi_1(x) phi_2(0) = sum_(phi_I) C_(Delta, I) (x, partial) phi_I (0), padding: #0.5em)
$<OPE>
#v(0.5em)

This is called _Operator Product Expansion_ (OPE for short); and it doesn't just work by magic, there's also context to consider:

1. the OPE is _true_ only in a correlation function;
2. the other operators that are in the correlation function must be "sufficiently far away" from the product considered.

#remark[
  If we try to be formal, the second point can be interpreted as follows: the other operators that are in the correlation function must be located outside a sphere of radius $abs(x)$, otherwise there are convergence problems and the OPE is not guaranteed to converge.
]

In fact, depending on the point of view adopted, the preceding discussion is either postulated for conformal field theory or demonstrable. In pure CFT, without any real other prerequisite that has not been presented in this document, we cannot do better than to take the preceding points as axiom and will, moreover, assume that the OPE converges in the framework of CFT.

#v(1.5em)
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
    //circle((2.4 + 8.4, -0.3), radius: 2pt, fill: gray)
    circle((-0.4 + 8.4, 0.6), radius: 2pt, fill: gray)
    circle((1.6 + 8.4, -0.1), radius: 2pt, fill: gray)
    //circle((2.5 + 8.4, -0.5), radius: 2pt, fill: gray)
    circle((10.85, -0.4), radius: 3pt, fill: red)

    // >

    line((1.5 + 2.5 + 8.4, 0), (0 + 2.5 + 8.4, 1.5))
    line((1.5 + 2.5 + 8.4, 0), (0 + 2.5 + 8.4, -1.5))

  }),
  caption: [Visualization of an OPE]
)<OPE_fig>
#v(1.5em)

Figure #ref(<OPE_fig>) schematically illustrates this new notion of _Operator Product Expansion_, where we see that two operators "sufficiently close" to each other in a correlation function are replaced by a new and unique operator by means of the OPE. From then on, any correlation function with $n > 2$ points can be reduced to a correlation function with $(n-1)$ points by means of the OPE.

#remark[
  It turns out that, numerically, the OPE is a rapidly converging operation. This will be particularly interesting for bootstrapping.
]

One might ask the following question: given that we have said several times that a dilation-invariant theory no longer really has a notion of being "close" or "far" (remember for example the argument given for the S matrix), why do we say that the OPE between two operators only occurs if the latter are "sufficiently close"? The answer is simple: here, we are comparing _relative_ distances, which therefore eliminates dilation-invariance from the discussion, and which therefore allows us to properly establish the OPE.

As has been noted, the OPE is defined with respect to the relative distance, hence the arbitrary choice of the product $phi(x) phi(0)$ in the definition #ref(<OPE>), we could imagine a completely equivalent definition where we take the product $phi(x_1)phi(x_2)$:

$
  phi(x_1)phi(x_2) = sum_(phi_I) C_(Delta, I) (x_1 - x_2, partial) phi_I ((x_1 + x_2) / 2)
$

and if we consider a product $phi_i (x_1) phi_j (x_2)$, then we adapt the definition to write

$
  phi_i (x_1) phi_j (x_2) = sum_k markul(C_(i j k)^(Delta, I), color: #red, tag: #<sm>) phi_k^I ((x_1 + x_2) / 2).

  #annot(<sm>, yshift: 0.7em, pos: bottom + right)[Simple summation, no Einstein notation]
$
#v(0.7em)

The notations may vary depending on convention or usage, but the idea remains the same. In these notations, it may be easier to express the second condition mentioned earlier: we will have a valid OPE iff $abs(x_1 - x_2) << abs(x_1 - x_l)$ for all $l eq.not 2$.

#remark[
  Knowing that there are an infinite number of descending operators given a primary operator, this sum must be understood as a series expansion.
]

It is possible, only by dimensional analysis, to determine the first contribution of the OPE between two scalars. For simplicity, let us take $phi_1(x) phi_2(0)$ where $phi_1$ has a scaling dimension $Delta_1$ and $phi_2$ has a scaling dimension $Delta_2$. Then, it follows that

$
  phi_1(x) phi_2(0) ~ frac(1, abs(x)^(Delta_1 + Delta_2))
$<jsp6>
#v(0.7em)

The expression #ref(<jsp6>) follows from the principle of conformal invariance: for the product of operators $phi_1(x) phi_2(0)$ to respect scale transformations, its dependence on $|x|$ must compensate for the total dimension $Delta_1+Delta_2$ of the two operators, hence the form $1 \/ abs(x)^(Delta_1 + Delta_2)$. We will see a little later in detail, in #ref(<sec_conf>), how conformal symmetries influence the form of correlation functions.


=== Example -- free and massless boson
Consider the action of a free boson, given by

$
  S = 1/2 g integral dd^2 x space (partial_mu phi partial^mu phi + m^2 phi^2)
$

where $g in RR$ is simply a normalization parameter. This action gives rise to the Klein-Gordon equation, in fact with $cal(L)(phi, partial_mu phi) = g\/2 (partial_mu phi partial^mu phi + m^2 phi^2)$ we have

$
       space & frac(partial cal(L), partial cal(phi)) - partial_mu frac(partial cal(L), partial (partial_mu phi)) approx 0 \
  <==> space & g/2 [ 2m^2 phi - partial_mu frac(partial cal(L), partial (partial_mu phi)) (partial_mu phi partial^mu phi) ] approx 0 \
  <==> space & g/2 [ 2m^2 phi - eta^(mu nu) partial_mu frac(partial cal(L), partial (partial_mu phi)) (partial_mu phi partial_nu phi) ] approx 0 \
  <==> space & g/2 [ 2m^2 phi - eta^(mu nu) partial_mu (partial_nu phi + delta^(mu nu) partial_mu) ] approx 0 \
  <==> space & g/2 [ 2m^2 phi - 2 partial_mu partial^mu phi ] approx 0 \
  <==> space & g(-square + m^2) phi(x) approx 0 space.quad "(Klein Gordon)".
$

where $square equiv partial_mu partial^mu$ is the d'Alembertian. We can define the following correlation function:

$
  K(x, y) := corr(phi(x) phi(y))
$

Well, in the context of a quantum field theory, we will prefer to speak of a _propagator_, in what interests us these terms are interchangeable. Since the action leads to the Klein-Gordon equation, we know that this propagator must satisfy

$
  g(-square + m^2) K(x, y) = delta^((2))(x - y)
$<kg1>

In other words, the propagator for $phi$ is a Green's function of the Klein-Gordon equation. Using this fact, we are able to find the expression for $K(x, y)$. To do this, let's make the coordinate change $r := abs(x - y)$ so that

$
  square = partial^2_x = 1/r frac(partial, partial r) (r frac(partial, partial r)).
$

Not considering mass interaction, $m = 0$, #ref(<kg1>) is then written

$
       space & g(-square + m^2) K(x, y) = delta^((2))(x - y) \
  <==> space & g[-1/r frac(partial, partial r) (r frac(partial, partial r)) + 0] K(r) = delta^((2))(r) \
  <==> space & -g frac(1, r) frac(partial, partial r) (r frac(partial K, partial r)) = delta^((2))(r).
$

In polar coordinates, we can show that the Dirac delta is expressed as $ delta^((2))(r) = frac(delta(r), 2 pi r), $ we then end up with

$
  -frac(g, r) frac(partial, partial r) (r frac(partial K, partial r)) = frac(delta(r), 2 pi r)
$

and all that remains is for us to solve this differential equation:

$
       space.quad & -frac(g, r) frac(partial, partial r) (r frac(partial K, partial r)) = frac(delta(r), 2 pi r) \
  <==> space.quad & -2 pi g frac(dd, dd r) (r frac(dd K, dd r)) = delta(r) \
  <==> space.quad & -2 pi g integral frac(dd, dd r) (r frac(dd K, dd r)) space dd r = integral delta(r) space dd r \
  <==> space.quad & -2 pi g (r frac(dd K, dd r)) = 1 \
  <==> space.quad & frac(dd K, dd r) = -frac(1, 2 pi g r) \ \
  <==> space.quad & markrect(K(r) = -frac(1, 2 pi g) log(r) + C, padding: #.5em)
$<s1>
#v(0.5em)

So, we have explicitly calculated the correlation function of the real free scalar field. According to the authors (see for example _Di Francesco_), this solution also takes the form

$
  K(r) = -frac(1, 4 pi g) log(r^2) + C
$<s2>

but #ref(<s1>) and #ref(<s2>) are of course completely equivalent since $log(a^b) equiv b log(a)$, this last notation is in fact more useful when we want to move to complex coordinates. By re-expressing $r$ in Cartesian coordinates, we finally found

$
  K(bold(x), bold(y)) := corr(phi(bold(x)) phi(bold(y))) &= -frac(1, 2 pi g) log(abs(bold(x) - bold(y))) + C \
                                                         &equiv -frac(1, 4 pi g) log(abs(bold(x) - bold(y))^2) + C.
$

*The OPE of $partial phi$ and $partial phi$*

By moving to complex coordinates, precisely, with $bold(x) = (x, y)$ which we re-express by defining $z := x + i y$ and $bold(y) = (u, v)$ which we re-express with $omega := y + i v$ and knowing the identity $abs(z - omega)^2 equiv (z - omega)(macron(z) - macron(omega))$, the previous result can be rewritten as

$
  corr(phi(z, macron(z)) phi(omega, macron(omega))) = -frac(1, 4 pi g) [ log(z - omega) + log(macron(z) - macron(omega)) ] + C.
$<bo1>

Now let's take the derivative of both sides of #ref(<bo1>),

$
  & corr(partial_z phi(z, macron(z)) partial_omega phi(omega, macron(omega))) = frac(1, 4 pi g) frac(1, (z - omega)^2) \
  & corr(partial_(macron(z)) phi(z, macron(z)) partial_(macron(omega)) phi(omega, macron(omega))) = frac(1, 4 pi g) frac(1, (macron(z) - macron(omega))^2)
$

and from there it is now clear that we have the following OPEs:

#v(0.5em)
$
  & markrect(partial_z phi(z, macron(z)) partial_omega phi(omega, macron(omega)) ~ frac(1, 4 pi g) frac(1, (z - omega)^2), padding: #.5em) \
  #v(4.5em)
  & markrect(partial_(macron(z)) phi(z, macron(z)) partial_(macron(omega)) phi(omega, macron(omega)) ~ frac(1, 4 pi g) frac(1, (macron(z) - macron(omega))^2), padding: #.5em)
$<bo2>
#v(0.5em)

*The OPE of $T$ and $partial phi$*

The classical energy-momentum tensor for the free, massless boson is given by

$
  T_(mu nu) = g (partial_mu phi partial nu phi - 1/2 eta_(mu nu) partial_rho phi partial^rho phi)
$

and in complex coordinates,

$
  & T(z, macron(z)) equiv -2 pi T_(z z) = -2 pi g [ (partial phi)^2 - 1/2 eta_(z z) partial_rho phi partial^rho phi ] = -2 pi g (partial phi)^2 \
  & macron(T)(z, macron(z)) equiv -2 pi macron(T)_(z z) = -2 pi g [ (macron(partial) phi)^2 - 1/2 eta_(macron(z) macron(z)) partial_rho phi partial^rho phi ] = -2 pi g (macron(partial) phi)^2
$

#remark[
  The "quantum version" of this energy-momentum tensor is usually presented with normal order and Wick's theorem, but this is beyond the scope of this paper and we will just stick to the results without going too deep, the goal is to see what the OPE looks like on concrete cases after all.
]

We can therefore show that after quantification,

$
  T(z, macron(z)) &= - 2 pi g :partial phi partial phi: \
                  &= - 2 pi g lim_(omega -> z) lim_(macron(omega) -> macron(z)) [ partial phi(z, macron(z)) partial phi(omega, macron(omega)) - corr(partial phi(z, macron(z)) partial phi(omega, macron(omega))) ]
$

The OPE of $T$ and $partial phi$ can be calculated using Wick's theorem:

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

where, in the last line, we used the result #ref(<bo2>). We can then expand $partial phi$ around $(omega, macron(omega))$,

$
  partial phi(z, macron(z)) approx partial phi(omega, macron(omega)) + partial^2 phi(omega, macron(omega)) (z - omega) + 1/2! partial^3 phi(omega, macron(omega)) (z - omega)^2 + ...
$

which ultimately gives us the following OPE:

#v(0.5em)
$
  markrect(padding: #.5em,
    T(z) partial phi(omega, macron(omega)) ~ frac(partial phi(omega, macron(omega)), (z - omega)^2) + frac(partial^2 phi(omega, macron(omega)), (z - w))
  )
$
#v(0.5em)

*The OPE of $T$ and $T$*

A similar derivation to the previous one can be done to calculate $T(z) T(omega)$, but the calculation is much heavier, so we will skip the big calculation step for convenience. We have

#v(0.5em)
$
  markrect(padding: #.5em,
    T(z) T(omega) ~ frac(1\/2, (z - omega)^4) + frac(2 T(omega), (z - omega)^2) + frac(partial T(omega), (z - omega))
  )
$<bo3>
#v(0.5em)

where, roughly, there are two ways to perform a Wick contraction $partial phi partial phi$ and there are four ways to perform a single Wick contraction, and after expanding we find #ref(<bo3>).

#remark[
  In the context of a CFT in $d = 2$, it will often be indicated that the _central charge_ associated with this OPE is here equal to $1$. More generally, the OPE of the energy-momentum tensor is written

  $
    T(z) T(omega) ~ frac(c\/2, (z - omega)^4) + frac(2 T(omega), (z - omega)^2) + frac(partial T(omega), (z - omega))
  $

  where $c in RR$ is a constant that is sometimes called the "central charge". In the context of a CFT in $d >= 3$, this notion is quite arbitrary and is actually not useful (indeed, we are just giving a name to a constant...). In fact, the central charge is useful in a two-dimensional CFT, where it corresponds to an eigenvalue of a Casimir (hence the name).

  In the present case, it is clear that $c = 1$.
]

#remark[
  If we want to go a little further and understand _on the surface_ how we calculated the previous results, we present here a very brief description of the concepts invoked above. For two operators $hat(A)$ and $hat(B)$ we define their _contraction_ as being

  $
    hat(A)^bullet hat(B)^bullet equiv hat(A) hat(B) - :hat(A)hat(B):
  $

  where $:hat(A)hat(B):$ indicates that the operators $hat(A)$ and $hat(B)$ are placed in _normal order_: all creation (or related) operators are placed to the left of all destruction (or related) operators. Contraction is therefore defined as the difference between their ordinary product and their normal-ordered product, which "measures" the extent to which the ordinary product is not already normally ordered.

  #example[
    For example, let's take $ :hat(b)^dagger hat(b): "" = "" hat(b)^dagger hat(b). $ Since the two operators are already in the desired order, Wick's notation doesn't give anything special. A more interesting example is $ :hat(b)hat(b)^dagger: "" = "" hat(b)^dagger hat(b) $ where here we see that the operators have been explicitly ordered. An example with more than two operators could be $ :hat(b)^dagger hat(b) hat(b) hat(b)^dagger hat(b) hat(b)^dagger hat(b): "" = "" hat(b)^dagger hat(b)^dagger hat(b)^dagger hat(b)hat(b)hat(b)hat(b) = (hat(b)^dagger)^3 hat(b)^4. $
  ]

  Wick's theorem states that the product $hat(A)hat(B)hat(C)hat(D)hat(E)hat(F)...$ of creation operators and destruction operators can be expressed as the sum

  $
    hat(A)hat(B)hat(C)hat(D)hat(E)hat(F)... = "" :hat(A)hat(B)hat(C)hat(D)hat(E)hat(F)...: &+ sum_"simple" :hat(A)^bullet hat(B)^bullet hat(C)hat(D)hat(E)hat(F)...: \
                                                                                        &+ sum_"double" :hat(A)^(bullet) hat(B)^(bullet bullet) hat(C)^(bullet bullet) hat(D)^bullet hat(E)hat(F)...: \
                                                                                        &+ space ...
  $

  We will not go into detail now or into the calculations using Wick contractions, but will simply mention them when it is useful to know where a result comes from.
]



/*

=== The Ghost System
Consider the following action:

$
  S = 1/2 g integral dd^2 x space b_(mu nu) partial^mu c^nu
$

where $b_(mu nu) = b_(nu mu)$ with $b^mu_(space.en mu) = 0$ and $c^nu$ are fields that anti-commute (so in the context of a QFT we would say that we are dealing with a system describing fermions). Let's start by finding the equations of motion, a way of doing this other than with the Euler-Lagrange equations and which will be more direct here is to vary the action with respect to the two fields respectively:

- *fields $c^nu$* -- we vary $S$ with respect to $c^nu$, we integrate by parts and we assume that the terms at the boundaries cancel out,

$
         & space.quad delta_c S = 1/2 g integral dd^2 x space b_(mu nu) partial^mu (delta_c c^nu) approx 0 \
         #v(1.5em)
    <==> & space.quad markrect(partial^mu b_(mu nu) approx 0, padding: #.5em)
$

- *fields $b_(mu nu)$* -- we follow the same steps, which gives us, knowing that $b$ is symmetrical,

$
         & space.quad delta_b S = 1/2 g integral dd^2 x space delta b_(mark(mu nu)) partial^(mark(mu)) c^(mark(nu)) approx 0 \
         #v(1.5em)
    <==> & space.quad markrect(partial^mu c^nu + partial^nu c^mu approx 0, padding: #.5em)
$

We move on to complex coordinates, and we set $c := c^z$ and $macron(c) = c^(macron(z))$. The first equation of motion, $partial^mu b_(mu nu) = 0$, is rewritten in complex form with $mu, nu in {z, macron(z)}$, so we will write accordingly that $partial^z = 2 partial_(macron(z)) equiv 2 macron(partial)$ and $partial^(macron(z)) = 2 partial_z equiv 2 partial$. For $nu = z$,

$
  partial^mu b_(mu nu) = 0 space.quad &<==> space.quad partial^z b_(zz) + cancel(partial^(macron(z)) b_(macron(z) z)) = 0 \
                                      #v(1.5em)
                                      &<==> space.quad markrect(macron(partial) b = 0, padding: #.5em)
$

and for $nu = macron(z)$,

$
  partial^mu b_(mu macron(z)) = 0 space.quad &<==> space.quad cancel(partial^z b_(z macron(z))) + partial^(macron(z)) b_(macron(z) macron(z)) = 0 \
                                      #v(1.5em)
                                      &<==> space.quad markrect(partial macron(b) = 0, padding: #.5em)
$

The second equation of motion, $partial^mu c^nu + partial^nu c^mu = 0$, in complex form is written

$
  & partial^zc^(macron(z)) - partial^(macron(z)) c^z = 0 \
  & partial^z macron(c) - partial^(macron(z)) = 0 \
  & partial macron(c) - macron(partial) c = 0
$

*/


== Conformal symmetries and correlation functions<sec_conf>
We have already seen a few times that conformal symmetries constrain correlation functions, this section is dedicated to a more in-depth study of this fact. We will focus the discussion on scalar operators since it is simpler to reason about them, but of course this generalizes to any kind of operator, with the only difference being that other objects will have to appear to handle indices. To keep it simple, we do not want to bother with such objects (which are really nothing more than constants). We will denote these scalar operators by $cal(O)_Delta$, where $Delta$ is their dimension, and consider them to be primary operators.

Recall that correlation functions play the role of observables in a conformal field theory, i.e. correlation functions must be independent of the choice of configuration. Therefore, in CFT, any correlation function must be invariant under conformal transformations. We therefore impose that

#v(0.5em)
$
  markrect(
      corr(tilde(cal(O))_1 (x_1^mu) tilde(cal(O))_2 (x_2^mu) space ... space tilde(cal(O))_n (x_n^mu)) overset(=, !) corr(cal(O)_1 (x_1^mu) cal(O)_2 (x_2^mu) space ... space cal(O)_n (x_n^mu)) space.quad forall x^mu_i,
      padding: #.5em
  )
$<indp>
#v(0.5em)

It is by applying this rule (which _must_ exist for the theory to be physical) that we will be able to deduce the form of the scalar correlation functions at one, two and three points, as we will see just after.

#remark[
  In #ref(<indp>), we changed the operators "$tilde(cal(O))_i -> cal(O)_i$" but kept them evaluated at the same points, as it wouldn't make much sense to compare correlation functions evaluated at different points! In the following, it will actually be more convenient to evaluate correlation functions at the transformed points, $tilde(x)^mu$ rather than at the original points, $x^mu$.
]

Let us also recall that primary operators transform like densities (see #ref(<density>)), in other words, for scalar operators,

$
       space & tilde(cal(O))^A_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial x^nu))^(Delta\/D) L^A_(space.en B) cal(O)^B_Delta (x^mu) \
  <==> space & tilde(cal(O))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial x^nu))^(Delta\/D) cal(O)_Delta (x^mu)
$

where, as announced, we thus get rid of the $L^A_(space.en B)$ which adds nothing to the discussion.

=== One-point scalar correlation functions
Let's apply the #ref(<indp>) constraint to the scalar correlation function at a point,

$
  corr(cal(O)_Delta (tilde(x)^mu)) overset(=, !) corr(tilde(cal(O))_Delta (tilde(x)^mu))
$

where, as noted just before, we evaluate it at the point $tilde(x)^mu$ rather than at $x^mu$ for convenience. This constraint must be verified for all conformal transformations.

*Translation*

For translations, $tilde(x)^mu = x^mu + a^mu$, the Jacobian is written

$
  abs(frac(partial tilde(x)^mu, partial x^nu)) = abs(frac(partial x^mu, partial x^nu) + frac(partial a^mu, partial x^nu)) = abs(delta^mu_(space.en nu)) = 1.
$

So our operator does not change under translation, $tilde(cal(O))_Delta (tilde(x)^mu) = cal(O)_Delta (x^mu)$, hence

$
  corr(cal(O)_Delta (tilde(x)^mu)) = corr(cal(O)_Delta (x^mu)).
$

Knowing that this must be true for all $x^mu$, we can conclude that the correlation function at a point is in fact a constant under translation. Let us check that the other conformal symmetry transformations agree with this statement.

*Dilation*

For dilations, $tilde(x)^mu = lambda x^mu$ or $x^mu = tilde(x)^mu \/ lambda$. The Jacobian is then written

$
  abs(frac(partial x^mu, partial tilde(x)^mu)) = abs(frac(delta^mu_nu, lambda)) = abs(1/lambda) = lambda^(-D),
$

a scalar operator is therefore transformed as

$
  tilde(cal(O))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial tilde(x)^nu))^(Delta\/D) cal(O)_Delta (x^mu) = lambda^(-Delta) cal(O)_Delta (x^mu).
$

Note that we had already intuited this result earlier. In a one-point correlation function, we then have

$
  corr(cal(O)_Delta (tilde(x)^mu)) &= corr(tilde(O)_Delta (tilde(x)^mu)) \
                                   &= corr(lambda^(-Delta) cal(O)_Delta (x^mu)) \
                                   &= lambda^(-Delta) corr(cal(O)_Delta (x^mu)) space.quad forall x^mu
$

but, previously for translations, we had found that

$
  corr(cal(O)_Delta (tilde(x)^mu)) = "const." =: C space.quad forall x^mu,
$

which indicates that

$
  space C = lambda^(-Delta) C.
$

This equation _must_ hold for any dilation factor $lambda$, which is true if $Delta = 0$ or if $C = 0$. Since the case $Delta = 0$ corresponds to a zero-dimensional operator, it can only be a constant and is therefore uninteresting. From this, we can conclude that all correlation functions at one point must vanish:

#v(0.5em)
$
  markrect(corr(cal(O)_Delta (x^mu)) = 0 space.quad forall x^mu " and for " Delta != 0, padding: #.5em)
$
#v(0.5em)

The other conformal transformations follow trivially (this will give $0$ each time).


=== Two-point scalar correlation functions
We do the same for the two-point scalar function, so we impose that

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) overset(=, !) corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu))
$<t11>

and we study conformal symmetries according to this constraint.

*Translation*

Let us note, to begin with, that $corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu))$ is a function of positions returning a number, it will be easier, in this case, to write that

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) =: f(tilde(x)_1^mu, tilde(x)_2^mu).
$

We also know from the previous point that, under translations, the primary scalar operators transform according to $tilde(cal(O))_Delta (tilde(x)^mu) = cal(O)_Delta (x^mu)$, so by inserting this result in the right-hand side of #ref(<t11>) we find

$
       space & corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) = corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) \
  <==> space & f(tilde(x)_1^mu, tilde(x)_2^mu) = f(x_1^mu, x_2^mu).
$

Furthermore, we have that $tilde(x)^mu = x^mu + a^mu$, which allows us to write that

$
       space & f(tilde(x)_1^mu, tilde(x)_2^mu) = f(x_1^mu, x_2^mu) \
  <==> space & f(x_1^mu + a^mu, x_2^mu + a^mu) = f(x_1^mu, x_2^mu) space.quad forall a^mu.
$

This result must be true regardless of the value of $a^mu$, which suggests that the $a^mu$ term must vanish at some point (otherwise the equality would never hold). The only way for $a^mu$ to vanish is by having a function dependent only on $x_1^mu - x_2^mu$,

$
  f(x_1^mu, x_2^mu) = f(x_1^mu - x_2^mu),
$

in other words, the two-point correlation function must be a function not of two positions, but rather of the displacement between these two positions:

$
  corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = f(x_1^mu - x_2^mu).
$

We can't say much more at the moment.

*Rotation*

For the Lorentz transformations, we have $tilde(x)^mu = Lambda^mu_(space.en nu) x^nu$, the Jacobian is then expressed

$
  abs(frac(partial x^mu, partial tilde(x)^nu)) = abs((Lambda^(-1))^mu_(space.en nu) delta^nu_mu) = 1
$

since the determinant of the Lorentz transformation matrix is ​​equal to $1$. The primary scalar operators are therefore transformed in the same way under translations and under rotations:

$
       & space corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu)) = corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) \
  <==> & space f(tilde(x)_1^mu, tilde(x)_2^mu) = f(x_1^mu, x_2^mu),
$

and using our result found for translations, we find that

$
  f(tilde(x)_1^mu - tilde(x)_2^mu) = f(x_1^mu - x_2^mu),
$

or even

$
  f(Lambda^mu_(space.en nu)(x_1^nu - x_2^nu)) = f(x_1^mu - x_2^mu).
$

In other words, applying a rotation has no effect on the result. Since rotations have no effect on $x_1^mu - x_2^mu$, this tells us that the function $f$ must depend not on the displacement but only on the magnitude of the latter:

$
  corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = f(abs(x_1^mu - x_2^mu)).
$

*Dilation*

Under dilation, $tilde(cal(O))_Delta (tilde(x)^mu) = lambda^(-Delta)cal(O)_Delta (x^mu)$. We substitute this into #ref(<t11>):

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu))
                          &= corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu)) \
                          &= corr(lambda^(-Delta_1)cal(O)_(Delta_1)(x_1^mu) lambda^(-Delta_2)cal(O)_(Delta_2)(x_2^mu)) \
                          &= lambda^(-Delta_1) lambda^(-Delta_2) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) \
                          &= lambda^(-(Delta_1 + Delta_2)) f(abs(x_1^mu - x_2^mu))
$

where we have combined all the results obtained so far for the two-point correlation function. Using the function notation $f$, we have therefore currently found that

$
  f(abs(tilde(x)_1^mu - tilde(x)_2^mu)) = lambda^(-(Delta_1 + Delta_2)) f(abs(x_1^mu - x_2^mu)),
$

or even

$
  f(lambda abs(x_1^mu - x_2^mu)) = lambda^(-(Delta_1 + Delta_2)) f(abs(x_1^mu - x_2^mu)).
$

Under a set of conditions that are always encountered in physics (#emoji.face.wink), we can always expand $f$ in a power series:

$
  f(abs(x_1^mu - x_2^mu)) = sum_k^infinity c_k abs(x^mu_1 - x^mu_2)^k,
$

we can then substitute this series into the previous result to find

$
  sum_k^infinity c_k lambda^k abs(x^mu_1 - x^mu_2)^k = lambda^(-(Delta_1 + Delta_2)) sum_k^infinity c_k abs(x^mu_1 - x_2^mu)^k,
$<jsp1>

which allows us to better compare the expansion factors: for equality to hold for all values ​​of $lambda$, each power of $lambda$ on the left side must correspond to the same power on the right side; this is only possible if all terms are zero except the one whose exponent is $k = -(Delta_1 + Delta_2)$, which then simply brings us to

$
  corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = C abs(x_1^mu - x_2^mu)^(-(Delta_1 + Delta_2)) space.quad C in RR
$<dil1>

where $C$ is the constant of the power development associated with $k = -(Delta_1 + Delta_2)$.

*Special transformation compliant*

We come to the last symmetry transformation with which the two-point scalar correlation function will be constrained. Recall that $tilde(x)^mu = x^mu + 2(x dot b)x^mu - b^mu x^2$, we could calculate the Jacobian and try to get by as best we can, but in fact it is simpler to remember that the special conformal transformation is composed of an inversion, then a translation, then an inversion and since we already know the result of the symmetry under translation, it is enough to tackle the "subsymmetry" under inversion. As was presented earlier, the inversion considered is given by

$
  x^mu = frac(tilde(x)^mu, tilde(x)^2)
$

from where

$
  abs(frac(partial x^mu, partial tilde(x)^nu)) = abs(frac(delta^mu_(space.en nu), tilde(x)^2)) = 1/(tilde(x)^(2 D))
$

because $tilde(x)^2 equiv tilde(x)^alpha tilde(x)_alpha in RR$ is a scalar. Under inversion, a scalar primary operator therefore transforms as

$
  cal(tilde(O))_Delta (tilde(x)^mu) = abs(frac(partial x^mu, partial tilde(x)^nu))^(Delta\/D) cal(O)_Delta (x^mu) = (frac(1, tilde(x)^(2 D)))^(Delta \/ D) cal(O)_Delta (x^mu) = frac(1, tilde(x)^(2 Delta)) cal(O)_Delta (x^mu)
$

what we replace in #ref(<t11>),

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu))
                          &= corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu)) \
                          &= corr(frac(1, tilde(x)_1^(2 Delta_1))cal(O)_(Delta_1)(x_1^mu) frac(1, tilde(x)_2^(2 Delta_2))cal(O)_(Delta_2)(x_2^mu)) \
                          &= frac(1, tilde(x)_1^(2 Delta_1)) frac(1, tilde(x)_2^(2 Delta_2)) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)).
$

We now use #ref(<dil1>) on the left and right of this equality, in order to obtain

$
       space & C abs(tilde(x)_1^mu - tilde(x)_2^mu)^(-(Delta_1 + Delta_2)) = frac(1, tilde(x)_1^(2 Delta_1)) frac(1, tilde(x)_2^(2 Delta_2)) C abs(x_1^mu - x_2^mu)^(-(Delta_1 + Delta_2)) \
  <==> space & frac(tilde(x)_1^(2 Delta_1) tilde(x)_2^(2 Delta_2), abs(tilde(x)_1^mu - tilde(x)_2^mu)^(Delta_1 + Delta_2)) = frac(1, abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2))
$

which can also be put in the following form:

$
  frac(tilde(x)_1^(2 Delta_1) tilde(x)_2^(2 Delta_2), abs(tilde(x)_1^mu - tilde(x)_2^mu)^(Delta_1 + Delta_2)) = (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^(frac(Delta_1 + Delta_2, 2)).
$<jsp2>

We can notice that, if $Delta_1 = Delta_2 =: Delta$, then the previous equality takes the following form:

$
             & space frac(tilde(x)_1^(2 Delta) tilde(x)_2^(2 Delta), abs(tilde(x)_1^mu - tilde(x)_2^mu)^(Delta + Delta)) = (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^Delta \
  <==> space & (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^Delta = (frac(tilde(x)_1^2 tilde(x)_2^2, abs(tilde(x)_1^mu - tilde(x)_2^mu)^2))^Delta \
  <==> space & 0 = 0,
$

in other words, #ref(<jsp2>) is only satisfied when $Delta_1 = Delta_2$. Symmetry under the special conformal transformation therefore tells us that the two-point scalar correlation function is in fact zero if $Delta_1 != Delta_2$ (otherwise #ref(<jsp2>) has no solution). Therefore, #ref(<dil1>) can in all generality be written as

#v(0.5em)
$
  markrect(corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) = frac(C delta_(Delta_1 Delta_2), abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2)), padding: #.5em)
$
#v(0.5em)

where $delta_(Delta_1 Delta_2)$ is a Kronecker delta,

$
  delta_(Delta_1 Delta_2) = cases(1 " if " Delta_1 = Delta_2, 0 " otherwise"),
$

which concludes our analysis of conformal symmetries for the two-point scalar correlation function. To summarize what we did to get here,

1. Under translations, we arrive at the conclusion that the correlation function must be a function of the displacement $x_1^mu - x_2^mu$;
2. Under rotations, we actually show that the correlation function is rather a function of the magnitude of the displacement, $abs(x_1^mu - x_2^mu)$;
3. Under dilations, we find the general form of this correlation function;
4. Under special conformal transformation, we conclude that the general form is stricter and exhibits a Kronecker delta.


=== Three-point scalar correlation functions
Let's continue with the three-point scalar correlation function. As before, we should have

$
  corr(cal(O)_1 (x^mu_1) cal(O)_2 (x^mu_2) cal(O)_3 (x^mu_3)) overset(=, !) corr(tilde(cal(O))_1 (x^mu_1) tilde(cal(O))_2 (x^mu_2) tilde(cal(O))_3 (x^mu_3)).
$

The calculation steps will be quite similar to the previous cases, but more tedious if you want to repeat the same calculation steps.

*Translation & Rotation*

We have seen above that translations and rotations have a similar Jacobian and, therefore, can be grouped in the same discussion (this should not be too surprising given that these are precisely the components of a Poincaré transformation). Following the same result that we managed to derive for the two-point scalar correlation function, we deduce that here too it will be a function dependent on the magnitude of the displacements $x_i^mu - x_j^mu$, that is to say

$
  corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3))
                    &= f(abs(x_1^mu - x_2^mu), abs(x_2^mu - x_3^mu), abs(x_3^mu - x_1^mu)) \
                    &equiv f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)).
$

*Dilation*

For the dilation, we will have as before

$
  corr(cal(O)_(Delta_1)(tilde(x)_1^mu) cal(O)_(Delta_2)(tilde(x)_2^mu) cal(O)_(Delta_3)(tilde(x)_3^mu))
                  &= corr(tilde(cal(O))_(Delta_1)(tilde(x)_1^mu) tilde(cal(O))_(Delta_2)(tilde(x)_2^mu) tilde(cal(O))_(Delta_3)(tilde(x)_3^mu)) \
                  &= corr(lambda^(-Delta_1)cal(O)_(Delta_1)(x_1^mu) lambda^(-Delta_2)cal(O)_(Delta_2)(x_2^mu) lambda^(-Delta_3)cal(O)_(Delta_3)(x_3^mu)) \
                  &= lambda^(-Delta_1) lambda^(-Delta_2) lambda^(-Delta_3) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu) cal(O)_(Delta_3)(x_3^mu)) \
                  &= lambda^(-(Delta_1 + Delta_2 + Delta_3)) corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu) cal(O)_(Delta_3)(x_3^mu)),
$

which, combined with the result for the Poincaré transformations, gives us

$
       space & f(abs(tilde(x)_(12)^mu), abs(tilde(x)_(23)^mu), abs(tilde(x)_(31)^mu)) = lambda^(-(Delta_1 + Delta_2 + Delta_3)) f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)) \
  <==> space & f(lambda abs(x_(12)^mu), lambda abs(x_(23)^mu), lambda abs(x_(31)^mu)) = lambda^(-(Delta_1 + Delta_2 + Delta_3)) f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)).
$

In order to compare the expansion factors, we expand the three-point scalar correlation function as a power series to obtain

$
  f(abs(x_(12)^mu), abs(x_(23)^mu), abs(x_(31)^mu)) = sum_i^infinity sum_j^infinity sum_k^infinity c_(i j k) abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k.
$

We substitute this into the previous result,

$
  sum_i^infinity sum_j^infinity sum_k^infinity c_(i j k) & lambda^i abs(x^mu_(12))^i lambda^j abs(x_(23)^mu)^j lambda^k abs(x_(31)^mu)^k \
              &= lambda^(-(Delta_1 + Delta_2 + Delta_3)) sum_i^infinity sum_j^infinity sum_k^infinity c_(i j k) abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k
$

and, with an analysis similar to what was done in the previous case, we deduce that this equality is true only if all the terms are zero, except those for which

$
  i + j + k = -(Delta_1 + Delta_2 + Delta_3),
$<jsp3>

which leads to

$
  corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) =
           markul(sum_(i + j + k = -(Delta_1 + Delta_2 + Delta_3)), tag: #<sm>, color: #red) c_(i j k) abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k

  #annot(<sm>, yshift: 1.5em, pos: left)[Triple sum over $i, j, k$ such that their sum gives $-(Delta_1 + Delta_2 + Delta_3)$]
$
#v(1.5em)

because, in fact, the condition #ref(<jsp3>) can be verified for several terms a priori.

*Special transformation compliant*

As before, we only need to impose the transformation under inversion. In the case of the two-point scalar correlation function, we arrived at the constraint that "$Delta_1 = Delta_2$". Here, since there are three points, we will have three constraints on the $i, j, k$ whose result we give directly and without development (it is a long calculation and without much interest):

$
  cases(
    i &= Delta_1 + Delta_2 - Delta_3 \
    j &= Delta_1 + Delta_3 - Delta_2 \
    k &= Delta_2 + Delta_3 - Delta_1.)
$<jsp4>

Combining everything together, we finally arrive at a result similar to what we found previously (but constrained differently):

#v(0.5em)
$
  markrect(corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) = frac(C_(123), abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k), padding: #.5em)
$
#v(0.5em)

where the powers $i, j, k in {(i, j, k) | #ref(<jsp4>) " is respected"}$ and where the constants $C_(123)$ come from the power expansion associated with the constraint #ref(<jsp4>).

=== Summary
We have thus shown that the one-, two- and three-point scalar correlation functions are completely determined up to a set of constants,

#align(center)[
  #rect()[
    #v(0.5em)
    #math.equation(block: true, numbering: none)[$
      corr(cal(O)_Delta (x^mu)) &= 0 && "(1 point)" \
      corr(cal(O)_(Delta_1)(x_1^mu) cal(O)_(Delta_2)(x_2^mu)) &= frac(C delta_(Delta_1 Delta_2), abs(x_1^mu - x_2^mu)^(Delta_1 + Delta_2)) && "(2 points)" \
      corr(cal(O)_(Delta_1) (x^mu_1) cal(O)_(Delta_2) (x^mu_2) cal(O)_(Delta_3) (x^mu_3)) &= frac(C_(123), abs(x^mu_(12))^i abs(x_(23)^mu)^j abs(x_(31)^mu)^k) space.quad && "(3 dots)" \
    $]
    #v(0.5em)
  ]
]

This set of constants is important for defining a specific conformal field theory, sometimes said to "determine the degree of interaction of operators" and will also be known as the "CFT data", to which we add the dimensions.

== The conformal bootstrap
In the previous subsection, we did not go beyond three-point scalar correlation functions. We will now discuss four-point scalar correlation functions and see that this discussion will lead us to the state of the art of CFT research (or at least a large counterpart of CFT research).

#remark[
  As already announced earlier, we stick with scalar operators because they are the simplest to consider: no transformation matrix needs to intervene to know how the indices are transformed, and we do not want to complicate things in the name of generality and completeness.
]

=== Four-point scalar correlation function
For a four-point scalar correlation function, we would want

$
  corr(cal(O)_1 (x^mu_1) cal(O)_2 (x^mu_2) cal(O)_3 (x^mu_3) (x^mu_4)) overset(=, !) corr(tilde(cal(O))_1 (x^mu_1) tilde(cal(O))_2 (x^mu_2) tilde(cal(O))_3 (x^mu_3) tilde(cal(O))_4 (x^mu_4)).
$

If we follow the same steps as before for the Poincaré transformations (translations + rotations), then we arrive at

$
  corr(cal(O)_1 (x^mu_1) cal(O)_2 (x^mu_2) cal(O)_3 (x^mu_3) (x^mu_4)) = f(abs(x^mu_(12)), abs(x^mu_(23)), abs(x^mu_(34)), abs(x^mu_(41))),
$

in other words, there are four quantities $abs(x^mu_(i j))$. It turns out that some combinations of these four quantities form functions which are in fact invariant under all conformal transformations, we can form two of them and we will then speak of _cross sections_:

#v(0.5em)
$
  u := frac(abs(x^mu_(12)) abs(x^mu_(34)), abs(x^mu_(13)) abs(x^mu_(24))) space.quad " and " space.quad v := frac(abs(x^mu_(12)) abs(x^mu_(34)), abs(x^mu_(23)) abs(x^mu_(14)))
$
#v(0.5em)

*Invariance under Poincaré*

Since $u$ and $v$ are functions only of the magnitudes of the separation between the points, invariance under translation and rotation is automatically satisfied.

*Invariance under dilation*

Invariance under dilation is also trivially satisfied:

$
  tilde(u) = frac(abs(tilde(x)^mu_(12)) abs(tilde(x)^mu_(34)), abs(tilde(x)^mu_(13)) abs(tilde(x)^mu_(24)))
           = frac(lambda abs(x^mu_(12)) lambda abs(x^mu_(34)), lambda abs(x^mu_(13)) lambda abs(x^mu_(24)))
           = u.
$

*Invariance under special conformal transformation*

As before, we don't need to look at the SCT completely but only at the inversion $tilde(x)^mu = x^mu \/ x^2$. To simplify the calculations, we can look at the squares $x_(i j)^2$ rather than the norms $abs(x_(i j))$, which makes the discussion easier without changing the result since $abs(x) equiv sqrt(x^2)$. Let's then apply the inversion to the points $x_i$ and $x_j$ (we will denote $I$ for the inversion):

$
  I(x_i) = x_i / x_i^2, quad I(x_j) = x_j / x_j^2,
$

SO

$
  I(x_i) - I(x_j) = x_i / x_i^2 - x_j / x_j^2 = frac(x_j^2 x_i - x_i^2 x_j, x_i^2 x_j^2),
$

and we can take the square:

$
  [I(x_i) - I(x_j)]^2 = frac((x_j^2 x_i - x_i^2 x_j)^2, x_i^4 x_j^4).
$

Gold,

$
  (x_j^2 x_i - x_i^2 x_j)^2 = x_i^2 x_j^2 (x_i - x_j)^2 equiv x_i^2 x_j^2 x_(i j)^2,
$

from where

$
  [I(x_i) - I(x_j)]^2 = frac(x_i^2 x_j^2 x_(i j)^2, x_i^4 x_j^4) = frac(x^2_(i j), x_i^2 x_j^2).
$

In other words, under inversion,

$
  x^2_(i j) |-> frac(x^2_(i j), x_i^2 x_j^2).
$

Applying this to $u$, we will have

$
  & x^2_(12) |-> frac(x^2_(12), x^2_1 x^2_2), quad && x^2_(34) |-> frac(x^2_(34), x^2_3 x^2_4), \
  & x^2_(13) |-> frac(x^2_(13), x^2_1 x_3^2), quad && x^2_(24) |-> frac(x^2_(24), x_2^2 x_4^2)
$

which gives rise to

$
  tilde(u) = frac(tilde(x)^2_(12) tilde(x)^2_(34), tilde(x)^2_(13) tilde(x)^2_(24)) = frac(frac(x^2_(12), x^2_1 x^2_2) frac(x^2_(34), x^2_3 x^2_4), frac(x^2_(13), x^2_1 x_3^2) frac(x^2_(24), x_2^2 x_4^2)) = frac(x^2_(12) x^2_(34), x^2_(13) x^2_(24)) = u.
$

Which clearly shows that $u$ is invariant under all conformal transformations. The same reasoning also applies to $v$.

The invariance of the functions $u$ and $v$ under conformal transformations implies that the four-point scalar correlation function is no longer completely determined up to a set of constants, and this conclusion generalizes to correlation functions with $n >= 4$ points, as well as to non-scalar operators.


=== Crossing symmetry

/*
To introduce the topic more simply, we will further simplify the problem by considering a four-point scalar correlation function where each operator is actually the same and of dimension $Delta$. From the previous points, we therefore deduce that this function must be of the following form:

$
  corr(cal(O)(x_1) cal(O)(x_2) cal(O)(x_3) cal(O)(x_4)) = frac(G(u, v), abs(x_(12))^(2 Delta) abs(x_(34))^(2 Delta))
$

where, as announced, it is no longer entirely determined by a set of constants but by a function of the cross-sections $u$ and $v$ introduced previously, denoted $G(u, v)$. The choice of the denominators $x_(12)$ and $x_(24)$ is arbitrary, any other $x_(i j)$ is possible but it will be necessary to modify $G(u, v)$ accordingly. This function $G(u, v)$ is often called a _conformal block_ (or "conformal block").

*/

Since we are somewhat "stuck" with scalar correlation functions at $n >= 4$ points, we will have to resort to an approximation to move forward, but it turns out that we already know it: the Operator Product Expansion (OPE). The OPE allows us to obtain an $n-1$ point correlation function from an $n$ point correlation function, and since we have seen that the one-, two-, and three-point correlation functions are entirely determined up to a set of constants, it will be enough to perform the OPE repeatedly until we reach one of these fi xed forms, which, as a reminder, will also produce another set of constants, and it is the set of these constants together that is best called "CFT data". It is all these constraints brought by the CFT that will give rise to the bootstrap algorithm, as we will see a little later.

Consider a four-point scalar correlation function that is developed by two successive OPEs, which can be written in all generality as

#v(1em)
$
  corr(wick(id: #0, pos: #top, cal(O))_1 (x_1) wick(id: #0, pos: #top, cal(O))_2 (x_2) & wick(id: #0, pos: #top, cal(O))_3 (x_4) wick(id: #0, pos: #top, cal(O))_4 (x_4)) \
          &= sum_(m, m') lambda_(12 m) lambda_(34 m') C_a (x_(12), partial_2) C_b (x_(34), partial_4) corr(cal(O)^a_m (x_2) cal(O)^b_m' (x_4))
$<c1>

where we have indicated with small bars on which operators the OPE considered is carried out (we sometimes speak of _contraction channels_). The right side of this equality is completely determined since we know the form of the two-point correlation function. By properties of correlation functions, it is also possible to contract different operators by OPE without the result being different:

#v(1em)
$
  corr(wick(id: #1, pos: #top, cal(O))_1 (x_1) wick(id: #0, pos: #top, cal(O))_2 (x_2) & wick(id: #0, pos: #top, cal(O))_3 (x_4) wick(id: #1, pos: #top, cal(O))_4 (x_4)) \
          &= sum_(m, m') lambda_(14 m) lambda_(23 m') C_a (x_(14), partial_4) C_b (x_(23), partial_3) corr(cal(O)^a_m (x_4) cal(O)^b_m' (x_3))
$<c2>

In other words, we "change the contraction channel". The two correlation functions must be the same, #ref(<c1>) and #ref(<c2>) must be equal regardless of the contraction channel. We will speak of "crossing symmetry" or _crossing symmetry_ in English.

#remark[
  We're slightly modifying the notations we used to introduce Operator Product Expansion to make them more relevant to the current context. However, this is only a notational change; the idea remains unchanged.
]

=== Bootstrap equation
In order to arrive at the equation we want to present for the bootstrap, we will consider the simplest possible case and will, to do so, consider a four-point scalar correlation function for which the operators are all similar (and of dimension $Delta$, let's say) and rewrite #ref(<c1>) and #ref(<c2>) in a much simpler form where the coefficients will all be absorbed into some functions:

#v(1em)
$
  & corr(wick(id: #0, pos: #top, cal(O))(x_1) wick(id: #0, pos: #top, cal(O))(x_2) wick(id: #0, pos: #top, cal(O))(x_3) wick(id: #0, pos: #top, cal(O))(x_4))
            = frac(G(u, v), x_(12)^(2 Delta) x_(34)^(2 Delta)), \ \

  & corr(wick(id: #1, pos: #top, cal(O))(x_1) wick(id: #0, pos: #top, cal(O))(x_2) wick(id: #0, pos: #top, cal(O))(x_3) wick(id: #1, pos: #top, cal(O))(x_4))
            = frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta))
$<jsp5>

where $G$ is a function of the cross-sections $u$ and $v$ introduced above and also containing the constants that appear in #ref(<c1>) and #ref(<c2>). The OPE is "hidden" in this function $G$, but note that the form of this four-point scalar correlation function is also expected from the developments we made above to determine the form of the one-, two-, and three-point scalar correlation functions: we expect the four-point scalar correlation function to take a similar form but where "the set of constants determining it" is replaced by "a function of the cross-sections $u$ and $v$" (and some constants). With a little abuse of notation (because it is not entirely the case but it will be enough for us), we will speak of _conformal blocks_ for these $G$ functions. Now, as was noted in the previous subsection, these two correlation functions must be equal, so we must have that

$
  frac(G(u, v), x_(12)^(2 Delta) x_(34)^(2 Delta)) overset(=,!) frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta)).
$

We can expand the calculations to find a more appreciable expression:

$
       space & frac(G(u, v), x_(12)^(2 Delta) x_(34)^(2 Delta)) = frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta)) \
  <==> space & frac(x_(14)^(2 Delta) x_(23)^(2 Delta), x_(12)^(2 Delta) x_(34)^(2 Delta))G(u, v) = G(v, u) \
  <==> space & (frac(x_(14)^2 x_(23)^2, x_(12)^2 x_(34)^2))^Delta G(u, v) = G(v, u) \
  <==> space & (v/u)^Delta G(u, v) = G(v, u)
$

or even

#v(0.5em)
$
  markrect((v/u)^Delta G(u, v) - G(v, u) = 0, padding: #.5em)
$<bootsrap1>
#v(0.5em)

This little equation is the fundamental equation of the bootstrap algorithm! It has various names, sometimes we talk about the _conformal bootstrap equation_ or the _crossing equation_ since it comes directly from the contraction symmetries of the OPE.


#remark[
  We have indeed

  $
    frac(x_(14)^2 x_(23)^2, x_(12)^2 x_(34)^2) equiv frac((frac(x_(14)^2 x_(23)^2, x^2_(13) x^2_(24))), (frac(x_(12)^2 x_(34)^2, x^2_(13) x^2_(24)))) = v/u
  $

  where we have, as has already been done once, used the square convention rather than the magnitude convention (so as not to drag a root around all the time...)
]

//An equality similar to #ref(<bootsrap1>) would have been obtained if we had not applied all the simplifications we proposed and started directly from #ref(<c1>) and #ref(<c2>), but the strategy adopted here probably allows us to better understand the result. If we want to be more complete, #ref(<bootsrap1>) should be written in a slightly more complicated form, which we will not demonstrate in detail (but which should not be too difficult to relate to the result we explicitly arrived at):

If we want to be a little more explicit, #ref(<bootsrap1>) would take the form of a sum over the primary operators and would explicitly show the constant indices and coefficients. By making the contents of $G$ explicit in #ref(<jsp5>), we have an expression of the following form:

#v(1.5em)
$
  corr(wick(id: #1, pos: #top, cal(O))(x_1) wick(id: #0, pos: #top, cal(O))(x_2) wick(id: #0, pos: #top, cal(O))(x_3) wick(id: #1, pos: #top, cal(O))(x_4)) = frac(G(v, u), x_(14)^(2 Delta) x_(23)^(2 Delta)) = frac(1, x_(14)^(2 Delta) x_(23)^(2 Delta)) marktc(sum_(cal(O)), tag: #<sum>, color: #red) marktc(lambda^2_(cal(O)), tag: #<lambda>, color: #blue) space g_(Delta, l) (v, u)

  #annot(<sum>, yshift: 1.5em, pos: left)[Sum over primary operators]
  #annot(<lambda>, yshift: 1.5em, pos: top + right)[OPE coefficients]
$
#v(1.5em)

and, applying the crossing symmetry in a very similar way to what we did for another OPE contraction channel, we finally arrive at the following equation:

#v(0.5em)
$
  markrect(sum_cal(O) lambda^2_cal(O) [ (v/u)^Delta g_(Delta, l)(u, v) - g_(Delta, l)(v, u) ] = 0, padding: #.5em)
$<bootsrap2>
#v(0.5em)

where the $g_(Delta, l)$ are, themselves, what we call "conformal blocks". This form is in fact #ref(<bootsrap1>) put under a slightly more explicit form, showing the constant coefficients, the indices as well as the sum over the primary operators.

//Recall that #ref(<bootsrap1>) and #ref(<bootsrap2>) are derived from the following considerations: scalar operators that are all identical. This seems like such a strong constraint that one might think it is just a toy model, but in reality it is _sufficient_ to describe the critical exponents of the 3D Ising model, as we will mention a little later.

=== Idea and illustration of the bootstrap algorithm
We will not go into detail on the whole topic, as this would probably require an entire document. We will therefore limit ourselves to offering an overview of the bootstrap algorithm, but let us begin by explaining what "bootstrap" means and what is meant by it. The English expression "_to bootstrap [...]_" is always used to mean "_self - something_", which implies an approach that is self-initiated and "self-sustaining". In the case of conformal bootstrapping, this expression emphasizes the idea of ​​solving a theory by imposing, through its own constraints (symmetries, observables, ...), an internal consistency, that is, without needing to use anything other than what has been presented so far: we solve a physical problem _without_ Lagrangian or Hamiltonian, the theory is sufficient in itself.

The "CFT data", which are present in the coefficients of #ref(<bootsrap2>), are the parameters that we are trying to determine when we talk about the bootstrap procedure. These parameters, as mentioned earlier, are related to the physics that we are trying to describe (of course, we must first give ourselves a model). The algorithm then proceeds as follows in broad outline:

1. We start with an initial set of parameters $(Delta, l)$ (if we use our previous notations);
2. We apply the equation #ref(<bootsrap2>) on these parameters and the constraints of the physical system studied also determine an altered form of #ref(<bootsrap2>) (for example we know that the Ising model has a symmetry $ZZ_2$ and this must be taken into account);
3. The result of this iteration will provide us with the following information: a region of the parameter space is eliminated: "it does not contain a solution to the problem";
4. We then choose a new set of parameters $(Delta, l)$ from the region(s) not eliminated by the last iteration;
5. We start again at step 2 and stop at the desired iteration;
6. At the end of the procedure, we find ourselves with a solution space small enough to draw conclusions.

This algorithm therefore works by eliminating regions at each step and it has been shown in the founding articles that convergence is rapid. In very few iterations, it is possible to arrive at a region of the parameter space which is smaller than the uncertainty errors and which is more precise than the numerical Monte Carlo methods (which were until then the best available with regard to the Ising model for example).

This is the idea behind the bootstrap algorithm; going into detail and explicitly showing how it works is beyond the scope of this document, but we refer, for example, to Joshua D. Qualls's _Lectures on Conformal Field Theory_ for a more detailed presentation. Figures #ref(<im14>), #ref(<im15>) and #ref(<im16>) graphically illustrate the method we have explained in the case of the three-dimensional Ising model.

#v(1.5em)

#figure(
  image("images/14.png", width: 45%),
  caption: [First iteration of the bootstrap algorithm (source: @qualls2016lectures)]
)<im14>

#v(1.5em)

#figure(
  image("images/15.png", width: 60%),
  caption: [Several iterations of the bootstrap algorithm (source: @qualls2016lectures). #linebreak() Reading is done column by column.]
)<im15>

#v(1.5em)

#figure(
  image("images/16.png", width: 60%),
  caption: [Isolation of a region after multiple iterations (source: @qualls2016lectures)]
)<im16>

#v(1.5em)

After iterating a number of times, figure #ref(<im16>) clearly illustrates that there is a region of the parameter space (here "$Delta_epsilon$" and "$Delta_sigma$") that holds up and is not eliminated from the possibility space. Error bars have been added to the graph to show that this region seems to contain the solution to the problem and that the number of iterations has been able to isolate them precisely enough. Figure #ref(<im16>) is itself taken from the original article @Kos:2014bka, where the authors found $Delta_σ = 0.51820(14)$ and $Delta_epsilon = 1.4127(11)$, which are critical exponents of the three-dimensional Ising model (which are commonly expressed in terms of _scaling dimension_ in field theory). The same authors gave a comparison of the bootstrap method with Monte Carlo simulations, their result is presented in figure #ref(<im17>).

#v(1.5em)

#figure(
  image("images/17.png", width: 75%),
  caption: [Comparison of numerical simulation methods (source: @Kos:2014bka)]
)<im17>

#v(1.5em)

In figure #ref(<im17>), the dark gray rectangle is the Monte Carlo prediction while the small light gray triangle is the bootstrap prediction. The blue region is simply a bound that the authors previously established.

#line()
#v(1.5em)

To summarize, the bootstrap procedure offers the following advantages:

- There is no need to directly use Lagrangian, Hamiltonian, partition function, action, ... the CFT is sufficient to solve the problem, which is not the case for the renormalization group approach: the conformal bootstrap is simpler;
- The method is rapidly convergent;
- The method is more accurate than alternative numerical simulations.

The idea of ​​the method is not new and dates back to the 1970s, but it experienced a resurgence of interest around 2008 when the method was successfully applied to the concrete physical case of the three-dimensional Ising model, for which we presented more recent results. However, there is still much to be done, and few other models have been studied so far.

= Conclusion
To conclude, during the four-week internship of the $1^"er"$ year of the master's degree in theoretical physics at UMons, I was introduced to conformal field theory with the main guideline being the study of phase transitions via the bootstrap approach and this document, this internship report, reflects my understanding of the subject.

= References
The work presented in this document is based on the knowledge acquired during the M1 internship in physics at the University of Mons, the references which were used during the latter are listed below.

#v(1.5em)
#bibliography("references.bib", full: true, title: none)

#line()
#v(1.5em)

