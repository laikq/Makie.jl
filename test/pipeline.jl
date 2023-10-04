# extracted from interfaces.jl
function test_copy(; kw...)
    scene = Scene()
    return Makie.merged_get!(
        ()-> Makie.default_theme(scene, Lines),
        :lines, scene, Attributes(kw)
    )
end

function test_copy2(attr; kw...)
    return merge!(Attributes(kw), attr)
end

@testset "don't copy in theme merge" begin
    x = Observable{Any}(1)
    res=test_copy(linewidth=x)
    res.linewidth === x
end

@testset "don't copy observables in when calling merge!" begin
    x = Observable{Any}(1)
    res=test_copy2(Attributes(linewidth=x))
    res.linewidth === x
end

@testset "don't copy attributes in recipe" begin
    fig = Figure()
    ax = Axis(fig[1, 1])
    list = Observable{Any}([1, 2, 3, 4])
    xmax = Observable{Any}([0.25, 0.5, 0.75, 1])

    p = hlines!(ax, list, xmax = xmax, color = :blue)
    @test getfield(p, :input_args)[1] === list
    @test p.xmax === xmax
    fig
end

@testset "Cycled" begin
    # Test for https://github.com/MakieOrg/Makie.jl/issues/3266
    f, ax, pl = lines(1:4; color=Cycled(2))
    cpalette = ax.palette[:color][]
    @test pl.calculated_colors[] == cpalette[2]
    pl2 = lines!(ax, 1:4; color=Cycled(1))
    @test pl2.calculated_colors[] == cpalette[1]
end
