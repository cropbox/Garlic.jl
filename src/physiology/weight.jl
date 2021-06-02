@system Weight begin
    CO2_weight => 44.0098 ~ preserve(u"g/mol")
    C_weight => 12.0107 ~ preserve(u"g/mol")
    CH2O_weight => 30.031 ~ preserve(u"g/mol")
    H2O_weight => 18.01528 ~ preserve(u"g/mol")

    C_to_CH2O_ratio(C_weight, CH2O_weight) => begin
        CH2O_weight / C_weight
    end ~ preserve

    CH2O_to_C_ratio(C_to_CH2O_ratio) => (1 / C_to_CH2O_ratio) ~ preserve
end
