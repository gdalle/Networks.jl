using Test
using Networks

@testset "Unit" verbose = true begin
    @testset "Network" include("unit/network.jl")
end

@testset "Integration" verbose = true begin end
