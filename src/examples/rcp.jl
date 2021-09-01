module RCP

using Cropbox
using ..Garlic
using TimeZones
using Dates
using Interpolations: LinearInterpolation
using BSON

tz = tz"Asia/Seoul"

KMSP = @config (
# # CV PHYL ILN GLN LL LER SG SD LTAR LTARa LIR Topt Tceil critPPD
# KM1 134 4 10 65.0 4.70 1.84 122 0 0.4421 0.1003 22.28 34.23 12
    :Phenology => (
        optimal_temperature = 22.28, # Topt
        ceiling_temperature = 34.23, # Tceil
        critical_photoperiod = 12, # critPPD
        #initial_leaves_at_harvest = , # ILN
        maximum_leaf_initiation_rate = 0.1003, # LIR
        # storage_days = 100, # SD
        storage_temperature = 5,
        maximum_phyllochron_asymptote = 0.4421, # LTARa
        leaves_generic = 10, # GLN
    ),
    :Leaf => (
        maximum_elongation_rate = 4.70, # LER
        minimum_length_of_longest_leaf = 65.0, # LL
        # stay_green = , # SG
    ),
    :Carbon => (
# # Rm Yg
# 0.012 0.8
        maintenance_respiration_coefficient = 0.012, # Rm
        synthesis_efficiency = 0.8, # Yg
        partitioning_table = [
        # root leaf sheath scape bulb
          0.00 0.00   0.00  0.00 0.00 ; # seed garlic before germination
          0.35 0.30   0.25  0.00 0.10 ; # vegetative stage between germination and scape initiation
          0.15 0.15   0.10  0.25 0.35 ; # period between scape initiation and scape appearance
          0.05 0.10   0.00  0.35 0.50 ; # period after scape appearance before removal (scape stays intact)
          0.05 0.00   0.00  0.00 0.95 ; # period after scape removal (scape appeared and subsequently removed)
          0.00 0.00   0.00  0.00 0.00 ; # dead
        ],
    ),
)

ND = @config (KMSP,
    :Phenology => (;
        critical_photoperiod = 12, # critPPD
        initial_leaves_at_harvest = 6, # ILN
        storage_temperature = 8,
        maximum_phyllochron_asymptote = 0.4421, # LTARa
        scape_appearance_threshold = 3.0,
    ),
    :Leaf => (;
        minimum_length_of_longest_leaf = 90.0, # LL
        maximum_elongation_rate = 90.0 / 18, # LER
        stay_green = 1.5, # SG
    ),
    :Plant => (;
        initial_planting_density = 55.5, # PD0
    ),
    :Carbon => (
        maintenance_respiration_coefficient = 0.015,
        synthesis_efficiency = 0.75,
        partitioning_table = [
        # root leaf sheath scape bulb
          0.00 0.00   0.00  0.00 0.00 ; # seed garlic before germination
          0.35 0.30   0.25  0.00 0.10 ; # vegetative stage between germination and scape initiation
          0.15 0.15   0.10  0.25 0.35 ; # period between scape initiation and scape appearance
          0.05 0.10   0.00  0.35 0.50 ; # period after scape appearance before removal (scape stays intact)
          0.05 0.00   0.00  0.00 0.95 ; # period after scape removal (scape appeared and subsequently removed)
          0.00 0.00   0.00  0.00 0.00 ; # dead
        ],
    )
)

GL = @config (
    :Location => (; latitude = 37.1288422, longitude = 128.3628756),
    :Plant => (; initial_planting_density = 55.5),
)
GL_2012 = @config (GL,
    :Weather => (
        store = Garlic.loadwea(Garlic.datapath("Korea/garliclab_2012.wea"), tz),
    ),
    :Calendar => (
        init = ZonedDateTime(2012, 10, 1, tz),
        last = ZonedDateTime(2013, 6, 30, tz),
    ),
)
ND_GL_2012 = let planting_date = Garlic.date(2012, 10, 4; tz)
    @config (
        ND, GL_2012,
        :Phenology => (;
            planting_date,
            scape_removal_date = nothing,
            harvest_date = ZonedDateTime(2013, 6, 15, tz),
            storage_days = Garlic.storagedays(planting_date),
        )
    )
end

JS = @config (
    :Location => (; latitude = 33.46835535536083, longitude = 126.51765156091567),
    :Plant => (; initial_planting_density = 55.5),
)
JS_2009 = @config (JS,
    :Weather => (
        store = Garlic.loadwea(Garlic.datapath("Korea/184_2009.wea"), tz),
    ),
    :Calendar => (
        init = ZonedDateTime(2009, 9, 1, tz),
        last = ZonedDateTime(2010, 6, 30, tz),
    ),
)
ND_JS_2009 = let planting_date = ZonedDateTime(2009, 9, 15, tz)
    @config (
        ND, JS_2009,
        :Phenology => (;
            planting_date,
            scape_removal_date = ZonedDateTime(2010, 5, 1, tz),
            harvest_date = ZonedDateTime(2010, 6, 18, tz),
            storage_days = Garlic.storagedays(planting_date),
        )
    )
end

RICCA = @config (
    :Location => (; latitude = 33, longitude = 126),
    :Plant => (; initial_planting_density = 55.5),
)
RICCA_2014 = @config (JS,
    :Weather => (
        store = Garlic.loadwea(Garlic.datapath("Korea/184_2014.wea"), tz),
    ),
    :Calendar => (
        init = ZonedDateTime(2014, 10, 1, tz),
        last = ZonedDateTime(2015, 6, 30, tz),
    ),
)
ND_RICCA_2014 = let planting_date = ZonedDateTime(2014, 10, 8, tz)
    @config (
        ND, RICCA_2014,
        :Phenology => (;
            planting_date,
            scape_removal_date = nothing,
            harvest_date = ZonedDateTime(2015, 6, 19, tz),
            storage_days = Garlic.storagedays(planting_date),
        )
    )
end
ND_RICCA_2014_field = @config ND_RICCA_2014
ND_RICCA_2014_tgc = @config (ND_RICCA_2014,
    :Phenology => (;
        emergence_date = ZonedDateTime(2014, 10, 10, tz), #HACK: 3-9 plants per section already emerged on 10-13
    ),
)

STATION_NAMES = Dict(
    101 => :Chuncheon,
    165 => :Mokpo,
    185 => :Gosan,
    221 => :Jechun,
    261 => :Haenam,
    262 => :Goheung,
    263 => :Euryung,
    272 => :Youngju,
    295 => :Namhae,
    601 => :Danyang,
)

LATLONGS = Dict(
    101 => (; latitude = 37.90262, longitude = 127.7357),
    165 => (; latitude = 34.81689, longitude = 126.38121),
    185 => (; latitude = 33.29382, longitude = 126.16283),
    221 => (; latitude = 37.15927, longitude = 128.1943),
    261 => (; latitude = 34.55375, longitude = 126.56907),
    262 => (; latitude = 34.61826, longitude = 127.27572),
    263 => (; latitude = 35.3226, longitude = 128.2881),
    272 => (; latitude = 36.87188, longitude = 128.51695),
    295 => (; latitude = 34.81662, longitude = 127.92641),
    601 => (; latitude = 36.98553, longitude = 128.3669),
)

korea_config(; config=(), tz=tz, kw...) = _korea_config(; config, meta=kw, tz, kw...)
_korea_config(; config=(), meta=(), tz=tz, station, year, sowing_day, emergence_day, scape_removal_day) = begin
    latlongs = LATLONGS[station]
    name = "$(station)_$(year)"
    weaname = Garlic.datapath("Korea/$name.wea")
    garlic_config(; config, meta, tz, latlongs..., weaname, year, sowing_day, emergence_day, scape_removal_day)
end

rcp_co2(scenario, year) = begin
    if scenario == :RCP00
        return 390
    end
    # Table AII.4.1
    # https://www.ipcc.ch/site/assets/uploads/2017/09/WG1AR5_AnnexII_FINAL.pdf
    x = [2000, 2005, 2010, 2020, 2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100]
    y = if scenario == :RCP45
        [368.9, 378.8, 389.1, 411.1, 435.0, 460.8, 486.5, 508.9, 524.3, 531.1, 533.7, 538.4]
    elseif scenario == :RCP85
        [368.9, 378.8, 389.3, 415.8, 448.8, 489.4, 540.5, 603.5, 677.1, 758.2, 844.8, 935.9]
    end
    LinearInterpolation(x, Float64.(y))(year)
end

rcp_config(; config=(), tz=tz, kw...) = _rcp_config(; config, meta=kw, tz, kw...)
_rcp_config(; config=(), meta=(), tz=tz, scenario, station, year, repetition, sowing_day, emergence_day, scape_removal_day) = begin
    latlongs = LATLONGS[station]
    name = "$(scenario)_$(station)_$(year)_$(repetition)"
    weaname = Garlic.datapath("RCP/$name.wea")
    CO2 = rcp_co2(scenario, year)
    garlic_config(; config, meta, tz, latlongs..., weaname, CO2, year, sowing_day, emergence_day, scape_removal_day)
end

garlic_config(; config=(), meta=(), tz=tz, latitude, longitude, altitude=20, weaname, CO2=390, year, sowing_day, emergence_day, scape_removal_day) = begin
    start_date = Garlic.date(year, 9, 1; tz)
    end_date = Garlic.date(year+1, 6, 30; tz)

    planting_date = Garlic.date(year, sowing_day; tz)
    emergence_date = isnothing(emergence_day) ? nothing : planting_date + Day(emergence_day)
    scape_removal_date = Garlic.date(year, scape_removal_day; tz)
    harvest_date = Garlic.date(year+1, 5, 15; tz)
    storage_days = Garlic.storagedays(planting_date)

    @config (ND,
        :Location => (;
            latitude,
            longitude,
            altitude,
        ),
        :Weather => (;
            store = Garlic.loadwea(weaname, tz),
            CO2,
        ),
        :Calendar => (;
            init = start_date,
            last = end_date,
        ),
        :Phenology => (;
            planting_date,
            emergence_date,
            scape_removal_date,
            harvest_date,
            storage_days,
        ),
        :Meta => meta,
        config,
    )
end

#setting = (; scenario=:RCP45, station=165, year=2021, repetition=1, sowing_day=250, scape_removal_day=nothing)

garlic_simulate(; config, target) = begin
    callback(s) = s.calendar.time' == s.config[:Phenology][:harvest_date]
    simulate(Garlic.Model; config, target, meta=:Meta, stop=callback, snap=callback, verbose=false)
end

rcp_settings = (;
    scenario = [:RCP45, :RCP85],
    station = keys(STATION_NAMES),
    year = 2020:10:2090,
    repetition = 0:9,
    sowing_day = 240:10:350,
    emergence_day = [nothing, 1, 7, 14],
    scape_removal_day = [1],
)
normal_settings = (;
    scenario = [:RCP00],
    station = keys(STATION_NAMES),
    year = [1980],
    repetition = 0:9,
    sowing_day = 240:10:350,
    emergence_day = [nothing, 1, 7, 14],
    scape_removal_day = [1],
)
rcp_run(; configurator=rcp_config, settings=rcp_settings, kw...) = garlic_run(; configurator, settings, kw...)

korea_settings = (;
    station = [185, 101], # Gosan, Chuncheon
    year = 2007:2016,
    sowing_day = 240:10:350,
    emergence_day = [nothing, 1, 7, 14],
    scape_removal_day = [1],
)
korea_run(; configurator=korea_config, settings=korea_settings, kw...) = garlic_run(; configurator, settings, kw...)

garlic_compose(; config=(), configurator, settings) = begin
    K = keys(settings)
    V = values(settings)
    P = Iterators.product(V...) |> collect
    [configurator(; config, zip(K, p)...) for p in P]
end

garlic_run(;
    target=[:bulb_mass, :total_mass, :planting_density, :dry_yield, :fresh_yield, :leaf_area],
    config=(),
    configurator,
    settings,
    cache=nothing,
    verbose=true,
) = begin
    C = garlic_compose(; config, configurator, settings)
    n = length(C)
    R = isnothing(cache) ? Vector(undef, n) : cache
    @assert length(R) == n
    dt = verbose ? 1 : Inf
    p = Cropbox.Progress(n; dt, Cropbox.barglyphs)
    try
        Threads.@threads for i in 1:n
            config = C[i]
            !isassigned(R, i) && (R[i] = garlic_simulate(; config, target))
            Cropbox.ProgressMeter.next!(p)
        end
    catch
        return R
    end
    Cropbox.ProgressMeter.finish!(p)
    reduce(vcat, R)
end

garlic_run_storage(; configurator, settings, name, kw...) = begin
    c0 = :Meta => :storage => true
    c1 = (
        :Phenology => :storage_days => 100,
        :Meta => :storage => false,
    )
    r0 = garlic_run(; configurator, settings, config=c0)
    bson("garlic_$name-storage-on.bson", df = r0)
    r1 = garlic_run(; configurator, settings, config=c1)
    bson("garlic_$name-storage-off.bson", df = r1)
    r = [r0; r1]
    bson("garlic_$name-storage.bson", df = r)
end

#garlic_run_storage(configurator=korea_config, settings=(; korea_settings..., station=[185]), name=:korea)
#garlic_run_storage(configurator=rcp_config, settings=(; normal_settings..., station=[185]), name=:normal)
#garlic_run_storage(configurator=rcp_config, settings=(; rcp_settings..., station=[185]), name=:rcp)

garlic_run_cold(; configurator, settings, name, kw...) = begin
    c0 = :Meta => :cold => true
    c1 = (
        :Density => :enable_cold_damage => false,
        :LeafColdInjury => :_enable => false,
        :Meta => :cold => false,
    )
    r0 = garlic_run(; configurator, settings, config=c0)
    bson("garlic_$name-cold-on.bson", df = r0)
    r1 = garlic_run(; configurator, settings, config=c1)
    bson("garlic_$name-cold-off.bson", df = r1)
    r = [r0; r1]
    bson("garlic_$name-cold.bson", df = r)
end

#garlic_run_cold(configurator=korea_config, settings=(; korea_settings..., station=[101]), name=:korea)
#garlic_run_cold(configurator=rcp_config, settings=(; normal_settings..., station=[101]), name=:normal)
#garlic_run_cold(configurator=rcp_config, settings=(; rcp_settings..., station=[101]), name=:rcp)

export garlic_run_storage, garlic_run_cold
export korea_config, korea_settings
export rcp_config, rcp_settings, normal_settings

end
