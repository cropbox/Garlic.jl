@system LeafAppearance(Stage, Phyllochron, Emergence, LeafInitiation) begin
    LTA(r=PHYLC_max, β=BF.ΔT): leaf_tip_appearance => r*β ~ accumulate(when=leaf_appearing)

    leaf_appearable(emerged) ~ flag
    leaf_appeared(leaves_appeared, leaves_initiated) => begin
        #HACK ensure leaves are initiated
        leaves_appeared >= leaves_initiated > 0
    end ~ flag
    leaf_appearing(leaf_appearable & !leaf_appeared) ~ flag

    #HACK: take account of first leaf appearance which occurs with emergence
    ILTA: initial_leaf_tip_appearance => 1 ~ track::int(when=leaf_appearable)
    leaves_appeared(ILTA, LTA) => (ILTA + LTA) ~ track::int(round=:floor)
end
