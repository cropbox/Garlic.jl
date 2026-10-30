using Cropbox
using Garlic
using Test

import Dates

@testset "weather input" begin
    for suffix in ("", ":00")
        csv = "year,jday,time\n2020,306,00:00$suffix\n2020,306,01:00$suffix\n2020,306,01:00$suffix\n2020,306,02:00$suffix\n"
        df = Garlic.loadwea(IOBuffer(csv), tz"America/Los_Angeles")
        @test df.time == [Dates.Time(h) for h in (0, 1, 1, 2)]
        @test df.index == ZonedDateTime(2020, 11, 1, tz"America/Los_Angeles") .+ Dates.Hour.(0:3)
    end
end

@testset "garlic" begin
    r = simulate(Garlic.Model;
        config=Garlic.Examples.AoB.KM_2014_P2_SR0,
        stop="calendar.count",
        snap=s -> Dates.hour(s.calendar.time') == 12,
    )
    @test r.leaves_initiated[end] > 0
    visualize(r, :DAP, [:leaves_appeared, :leaves_mature, :leaves_dropped], kind=:step) |> println # Fig. 3.D
    visualize(r, :DAP, :green_leaf_area) |> println # Fig. 4.D
    visualize(r, :DAP, [:leaf_mass, :bulb_mass, :total_mass]) |> println
end
