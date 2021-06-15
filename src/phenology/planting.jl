@system Planting(Stage) begin
    planting_date ~ hold

    planted(planting_date, t=calendar.time) => (t >= planting_date) ~ flag
end
