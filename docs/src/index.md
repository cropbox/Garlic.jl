# Garlic.jl

[Garlic.jl](https://github.com/cropbox/Garlic.jl) is a reimplementation of garlic model using [Cropbox](https://github.com/cropbox/Cropbox.jl) framework. The [original model](https://github.com/uwkimlab/cropbox-garlic) was written in C++ and published in "[A process-based model for leaf development and growth in hardneck garlic (*Allium sativum*)](https://doi.org/10.1093/aob/mcz060)".

## Installation

```julia
using Pkg
Pkg.add("Garlic")
```

## Getting Started

```@example garlic
using Cropbox
using Garlic
```

The model is a system named `Model` defined in `Garlic` module.

```@example garlic
parameters(Garlic.Model; alias = true, recursive = true)
```

As the parameter list goes quite long, let's try a parameter set included in the package. It was calibrated for Korean Mountain (KM) cultivar planted and grown in Seattle as described in the [paper](https://doi.org/10.1093/aob/mcz060).

```@example garlic
config = @config Garlic.Examples.AoB.KM_2014_P2_SR0
```

Simulation is run until `stop` condition is met which corresponds to the number of *hours* (`calendar.count`) between starting (`calendar.init`) and ending date (`calendar.last`)  as specified in the configuration above. The output of simulation is `snap`-ped each day, not by every hour, to reduce overhead.

```@example garlic
r = simulate(Garlic.Model; config, stop = "calendar.count", snap = 1u"d")
; # hide
```

The output data frame can be now used for making some plots. Here is a plot replicating [Fig. 3.D](https://academic.oup.com/view-large/figure/198476944/mcz060f0003.jpg) from the paper showing leaf development over time.

```@example garlic
visualize(r, :time, [:leaves_appeared, :leaves_mature, :leaves_dropped]; kind = :line)
```

Another plot replicating [Fig. 4.D](https://academic.oup.com/view-large/figure/198476946/mcz060f0004.jpg) from the paper showing the area of green leaf taking account of leaf aging.

```@example garlic
visualize(r, :time, :green_leaf_area; kind = :line)
```

Similarly, dry biomass of organ types per plant can be visualized.

```@example garlic
visualize(r, :time, [:leaf_mass, :bulb_mass, :total_mass]; kind = :line)
```

For more information about using the framework such as `simulate()` and `visualize()` functions, please refer to the [Cropbox documentation](http://cropbox.github.io/Cropbox.jl/stable/).
