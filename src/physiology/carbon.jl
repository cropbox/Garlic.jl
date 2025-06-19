@system RespirationTracker(Q10Function) begin
    w: weather ~ ::Weather(override)
    T(w.T_air): temperature ~ track(u"°C") # should be soil temperature
    To: optimal_temperature => 20 ~ preserve(u"°C", parameter)
    Q10 => begin
        # typical Q10 value for respiration, Loomis and Amthor (1999) Crop Sci 39:1584-1596
        2
    end ~ preserve(parameter)
end

@system Carbon begin
    weather ~ hold
    pheno: phenology ~ hold

    C_to_CH2O_ratio ~ hold
    seed_mass_export_rate ~ hold
    assimilation ~ hold
    total_mass ~ hold
    green_leaf_ratio ~ hold

    dp(pheno.development_phase): development_phase ~ track::sym

    C_conc: carbon_concentration => begin
        # maize: 40% C, See Kim et al. (2007) EEB
        0.45
    end ~ preserve

    carbon_reserve_from_seed(seed_mass_export_rate, C_conc, C_to_CH2O_ratio) => begin
        seed_mass_export_rate * C_conc * C_to_CH2O_ratio
    end ~ track(u"g/d")

    #TODO: take account NSC from bulb
    #TODO: handle translocation back from carbon pool (i.e. at midnight)
    carbon_reserve(carbon_reserve_from_seed, carbon_translocation) => begin
        carbon_reserve_from_seed - carbon_translocation
    end ~ accumulate(u"g")

    carbon_translocation(carbon_reserve, carbon_translocation_rate) => begin
        carbon_reserve * carbon_translocation_rate
    end ~ track(u"g/d")

    carbon_pool(assimilation, carbon_translocation, carbon_supply) => begin
        assimilation + carbon_translocation - carbon_supply
    end ~ accumulate(u"g", min = 0u"g")

    nonstructural_carbon(carbon_pool, carbon_reserve) => begin
        carbon_pool + carbon_reserve
    end ~ track(u"g")

    nonstructural_carbon_mass(nonstructural_carbon, C_conc, CH2O_to_C_ratio) => begin
        nonstructural_carbon * CH2O_to_C_ratio / C_conc
    end ~ track(u"g")

    carbon_supply(carbon_pool, carbon_supply_rate) => begin
        carbon_pool * carbon_supply_rate
    end ~ track(u"g/d")

    # to be used by allocate_carbon()
    carbon_temperature_effect(T=nounit(weather.T_air, u"°C"), β=pheno.BF.ΔT) => begin
        #FIXME properly handle T_air
        # this needs to be f of temperature, source/sink relations, nitrogen, and probably water
        # a valve function is necessary because assimilates from CPool cannot be dumped instantaneously to parts
        # this may be used for implementing feedback inhibition due to high sugar content in the leaves
        # The following is based on Grant (1989) AJ 81:563-571

        # Normalized (0 to 1) temperature response fn parameters, Pasian and Lieth (1990)
        # Lieth and Pasian Scientifica Hortuculturae 46:109-128 1991
        # parameters were fit using rose data -
        b1 = 2.325152587
        b2 = 0.185418876 # I'm using this because it can have broad optimal region unlike beta fn or Arrhenius eqn
        b3 = 0.203535650
        Td = 48.6 #High temperature compensation point

        g1 = 1 + exp(b1 - b2 * T)
        g2 = 1 - exp(-b3 * max(0, Td - T))
        #return g2 / g1

        β
    end ~ track

    carbon_growth_factor => begin
        # translocation limitation and lag, assume it takes 1 hours to complete, 0.2=5 hrs
        # this is where source/sink (supply/demand) valve can come in to play
        # 0.2 is value for hourly interval, Grant (1989)
        1 / 5u"hr"
    end ~ preserve(u"hr^-1")

    carbon_translocating(carbon_pool) => begin
        carbon_pool < 0u"g"
    end ~ flag

    carbon_translocation_rate(carbon_temperature_effect, carbon_growth_factor) => begin
        # C_demand does not enter into equations until grain fill
        carbon_temperature_effect * carbon_growth_factor
    end ~ track(u"hr^-1", when=carbon_translocating)

    carbon_supply_rate(carbon_temperature_effect, carbon_growth_factor) => begin
        carbon_temperature_effect * carbon_growth_factor
    end ~ track(u"hr^-1")

    Rm: maintenance_respiration_coefficient => begin
        # gCH2O g-1DM day-1 at 20C for young plants, Goudriaan and van Laar (1994) Wageningen textbook p 54, 60-61
        #0.015
        #0.018 # for maize
        0.012
    end ~ preserve(u"g/g/d", parameter)

    agefn(green_leaf_ratio): carbon_age_effect => begin
        # as more leaves senesce maint cost should go down, added 1 to both denom and numer to avoid division by zero.
        #agefn = (self.p.area.green_leaf + 1) / (self.p.area.leaf + 1)
        # no maint cost for dead materials but needs to be more mechanistic, SK
        #agefn = 1.0
        # from garlic model
        #agefn = (self.p.area.green_leaf + 0.1) / (self.p.area.leaf + 0.1)
        green_leaf_ratio
    end ~ track

    # based on McCree's paradigm, See McCree(1988), Amthor (2000), Goudriaan and van Laar (1994)
    # units very important here, be explicit whether dealing with gC, gCH2O, or gCO2
    maintenance_respiration_tracker(context, weather) ~ ::RespirationTracker
    maintenance_respiration(total_mass, Rm, agefn, q=maintenance_respiration_tracker.ΔT) => begin
        total_mass * q * Rm * agefn # gCH2O dt-1, agefn effect removed. 11/17/14. SK.
    end ~ track(u"g/d")

    carbon_available(carbon_supply, maintenance_respiration) => begin
        carbon_supply - maintenance_respiration
    end ~ track(u"g/d")

    Yg: synthesis_efficiency => begin
        #1 / 1.43 # equivalent Yg, Goudriaan and van Laar (1994)
        #0.75 # synthesis efficiency, ranges between 0.7 to 0.76 for corn, see Loomis and Amthor (1999), Grant (1989), McCree (1988)
        #0.74
        0.8
    end ~ preserve(parameter)

    total_carbon(c=carbon_available, Yg) => begin
        Yg * c # gCH2O partitioned to shoot/root
    end ~ track(u"g/d")

    pt: partitioning_table => [
        # root leaf sheath scape bulb
          0.00 0.00   0.00  0.00 0.00 ; # seed garlic before germination
          0.35 0.30   0.25  0.00 0.10 ; # vegetative stage between germination and scape initiation
          0.15 0.15   0.10  0.25 0.35 ; # period between scape initiation and scape appearance
          0.05 0.10   0.00  0.35 0.50 ; # period after scape appearance before removal (scape stays intact)
          0.05 0.00   0.00  0.00 0.95 ; # period after scape removal (scape appeared and subsequently removed)
          0.00 0.00   0.00  0.00 0.00 ; # dead
    ] ~ tabulate(
        rows=(:seed, :vegetative, :bulb_growth_before_scape_appearance, :bulb_growth_after_scape_appearance, :bulb_growth_after_scape_removal, :dead),
        columns=(:root, :leaf, :sheath, :scape, :bulb),
        parameter
    )

    root_carbon(total_carbon, pt, dp) => begin
        total_carbon * pt[dp].root
    end ~ track(u"g/d")

    shoot_carbon(total_carbon, root_carbon) => begin
        total_carbon - root_carbon
    end ~ track(u"g/d")

    leaf_carbon(total_carbon, pt, dp) => begin
        total_carbon * pt[dp].leaf
    end ~ track(u"g/d")

    sheath_carbon(total_carbon, pt, dp) => begin
        total_carbon * pt[dp].sheath
    end ~ track(u"g/d")

    scape_carbon(total_carbon, pt, dp) => begin
        total_carbon * pt[dp].scape
    end ~ track(u"g/d")

    bulb_carbon(total_carbon, pt, dp) => begin
        total_carbon * pt[dp].bulb
    end ~ track(u"g/d")
end
