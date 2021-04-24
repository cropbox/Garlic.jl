module Garlic

using Cropbox

include("atmosphere/atmosphere.jl")
include("rhizosphere/rhizosphere.jl")
include("phenology/phenology.jl")
include("morphology/morphology.jl")
include("physiology/physiology.jl")

include("examples/examples.jl")

end
