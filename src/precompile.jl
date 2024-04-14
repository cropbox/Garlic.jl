import PrecompileTools

PrecompileTools.@compile_workload begin
    r = simulate(Model;
        config=Examples.RCP.ND_RICCA_2014_field,
        stop="calendar.stop",
        verbose=false,
    )
    visualize(r, :DAP, :leaf_area; backend=:UnicodePlots)
    visualize(r, :DAP, :leaf_area; backend=:Gadfly)
end
