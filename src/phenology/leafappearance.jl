@system LeafAppearance(Stage, Emergence, LeafInitiation) begin
    LTARa_max: maximum_phyllochron_asymptote => 0.4421 ~ preserve(u"d^-1", parameter)
    _SDm => 117.7523 ~ preserve(u"d", parameter)
    _k => 0.0256 ~ preserve(u"d^-1", parameter)

    LTAR_max0(LTARa_max, SD, _SDm, _k): initial_maximum_phyllochron => begin
        LTARa_max / (1 + exp(-k * (SD - SDm)))
    end ~ preserve(u"d^-1", parameter)

    LTAR_max(LTAR_max0, LTARa_max, n=leaves_appeared, ng=leaves_generic): maximum_phyllochron => begin
        n0 = 0
        r0 = LTAR_max0
        r1 = LTARa_max / 2
        r0 + (r1 - r0) * (clamp(n, n0, ng) - n0) / (ng - n0)
    end ~ track(u"d^-1")

    LTA(r=LTAR_max, β=BF.ΔT): leaf_tip_appearance => r*β ~ accumulate(when=leaf_appearing)

    leaf_appearable(emerged) ~ flag
    leaf_appeared(leaves_appeared, leaves_initiated) => begin
        #HACK ensure leaves are initiated
        leaves_appeared >= leaves_initiated > 0
    end ~ flag
    leaf_appearing(leaf_appearable & !leaf_appeared) ~ flag

    #HACK: take account of sprout leaf appeared in emergence stage
    ILTA: initial_leaf_tip_appearance => 1 ~ track::int(when=emerged)
    leaves_appeared(ILTA, LTA) => (ILTA + LTA) ~ track::int(round=:floor)
end
