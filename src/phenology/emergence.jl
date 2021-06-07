@system Emergence(Stage, Phyllochron, Germination) begin
    emergence_date => nothing ~ preserve::datetime(optional, parameter)
    begin_from_emergence(emergence_date) => !isnothing(emergence_date) ~ preserve::Bool

    emergence(r=PHYLC_max, β=BF.ΔT) => r*β ~ accumulate(when=emerging)

    emergeable(germinated) ~ flag
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
