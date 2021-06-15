@system Emergence(Stage, Planting) begin
    emergence_date => nothing ~ preserve::datetime(optional, parameter)
    begin_from_emergence(emergence_date) => !isnothing(emergence_date) ~ preserve::Bool

    ER_max: maximum_emergence_rate => 0.0876 ~ preserve(u"d^-1", parameter)

    ER_T_opt: emergence_optimal_temperature => 12.7 ~ preserve(parameter, u"°C")
    ER_T_ceil: emergence_ceiling_temperature => 35.9 ~ preserve(parameter, u"°C")
    ER_BF(context, T, To=ER_T_opt', Tx=ER_T_ceil'): germination_beta_function ~ ::BetaFunction

    emergence(r=ER_max, β=ER_BF.ΔT) => begin
        #FIXME prevent extra accumulation after it's `over`
        r * β
    end ~ accumulate(when=emerging)

    emergeable(planted) ~ flag
    emerged(emergence, begin_from_emergence, emergence_date, t=calendar.time) => begin
        if begin_from_emergence
            t >= emergence_date
        else
            emergence >= 1.0
        end
    end ~ flag
    emerging(emergeable & !emerged) ~ flag

    # #FIXME postprocess similar to @produce?
    # def finish(self):
    #     GDD_sum = self.pheno.gdd_recorder.rate
    #     T_grow = self.pheno.growing_temperature
    #     print(f"* Emergence: time = {self.time}, GDDsum = {GDD_sum}, Growing season T = {T_grow}")

    #     #HACK reset GDD tracker after emergence
    #     self.emerge_GDD = GDD_sum
    #     self.pheno.gdd_recorder.reset()
end
