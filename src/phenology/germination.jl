@system Germination(Stage, Planting, Emergence) begin
    germinateable(planted) ~ flag
    #HACK: assume germination occurs at 50% of emergence (2021-06-14: SHK, KDY)
    germinated(emergence, emerged) => begin
        (emergence >= 0.5) || emerged
    end ~ flag
    germinating(germinateable & !germinated) ~ flag
end
