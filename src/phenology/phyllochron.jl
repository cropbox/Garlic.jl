@system Phyllochron(Stage) begin
    leaves_appeared ~ hold
    leaves_generic ~ hold

    PHYLCa_max: maximum_phyllochron_asymptote => 0.4421 ~ preserve(u"d^-1", parameter)
    _SDm => 117.7523 ~ preserve(u"d", parameter)
    _k => 0.0256 ~ preserve(u"d^-1", parameter)

    PHYLC_max0(PHYLCa_max, SD, _SDm, _k): initial_maximum_phyllochron => begin
        PHYLCa_max / (1 + exp(-k * (SD - SDm)))
    end ~ preserve(u"d^-1", parameter)

    PHYLC_max(PHYLC_max0, PHYLCa_max, n=leaves_appeared, ng=leaves_generic): maximum_phyllochron => begin
        n0 = 0
        r0 = PHYLC_max0
        r1 = PHYLCa_max / 2
        r0 + (r1 - r0) * (clamp(n, n0, ng) - n0) / (ng - n0)
    end ~ track(u"d^-1")
end
