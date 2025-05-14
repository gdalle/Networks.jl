using Test
using SafeTestsets

@testset "Unit" verbose = true begin
    @safetestset "Network" include("unit/network.jl")
    @safetestset "Taggable" include("unit/taggable.jl")
end

@testset "Integration" verbose = true begin end
