using Test
using Networks

# testing fixtures
const fixture = let
    vm = Dict(
        :a => Set([1, 2]),
        :b => Set([1, 3, 4, 5]),
        :c => Set([4, 5, 11, 12]),
        :d => Set([3, 4, 6]),
        :e => Set([2, 6, 9]),
        :f => Set([9, 14, 17]),
        :g => Set([10, 11, 13, 15, 14]),
        :h => Set([12, 13, 16]),
        :j => Set{Int}(),
    )

    em = Dict(
        1 => Set([:a, :b]),
        2 => Set([:a, :e]),
        3 => Set([:d, :b]),
        4 => Set([:b, :d, :c]),
        5 => Set([:b, :c]),
        6 => Set([:d, :e]),
        11 => Set([:c, :g]),
        12 => Set([:c, :h]),
        13 => Set([:g, :h]),
        14 => Set([:g, :f]),
        15 => Set([:g]),
        16 => Set([:h]),
        17 => Set([:f]),
    )

    (;
        vertex_map=vm,
        edge_map=em,
        vertex_type=Symbol,
        edge_type=Int,
        vertices=collect(keys(vm)),
        edges=collect(keys(em)),
        edges_strand=Set{Int}([]),
        edges_open=Set{Int}([15, 16, 17]),
        edges_hyper=Set{Int}([4]),
        vertex_strand=:j,
        new_vertex=(;
            vertex=:i,
            edge_set=Set([15, 16, 17]),
        ),
        new_edge=(;
            edge=10,
            vertex_set=Set([:d, :g]),
        ),
    )
end

# wraps a network to test interface delegation
struct WrapNetwork{G}
    g::G
end

WrapNetwork(v, e) = WrapNetwork(SimpleNetwork(v, e))
Networks.DelegatorTrait(::Networks.Network, ::WrapNetwork) = Networks.DelegateTo{:g}()

# mocks a network to test default implementations of optional methods
struct MockNetwork{V,E}
    g::SimpleNetwork{V,E}
end

MockNetwork(v::V, e::E) where {V,E} = MockNetwork(SimpleNetwork(v, e))

Networks.ImplementorTrait(::Networks.Network, ::MockNetwork) = Networks.Implements()
Networks.vertices(g::MockNetwork) = vertices(g.g)
Networks.edges(g::MockNetwork) = edges(g.g)
Networks.edge_incidents(g::MockNetwork, edge) = edge_incidents(g.g, edge)
Networks.vertex_incidents(g::MockNetwork, vertex) = vertex_incidents(g.g, vertex)
Networks.vertex_type(g::MockNetwork) = vertex_type(g.g)
Networks.edge_type(g::MockNetwork) = edge_type(g.g)

Networks.addvertex_inner!(g::MockNetwork, vertex) = addvertex!(g.g, vertex)
Networks.rmvertex_inner!(g::MockNetwork, vertex) = rmvertex!(g.g, vertex)
Networks.addedge_inner!(g::MockNetwork, edge, vertex_set) = addedge!(g.g, edge, vertex_set)
Networks.rmedge_inner!(g::MockNetwork, edge) = rmedge!(g.g, edge)

@testset "vertices" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test issetequal(vertices(network), fixture.vertices)
    end
end

@testset "edges" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test issetequal(edges(network), fixture.edges)
    end
end

@testset "edge_incidents" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        for (edge, vertex_set) in fixture.edge_map
            @test issetequal(edge_incidents(network, edge), vertex_set)
        end
    end
end

@testset "vertex_incidents" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        for (vertex, edge_set) in fixture.vertex_map
            @test issetequal(vertex_incidents(network, vertex), edge_set)
        end
    end
end

@testset "vertex_type" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test vertex_type(network) === fixture.vertex_type
    end
end

@testset "edge_type" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test edge_type(network) === fixture.edge_type
    end
end

@testset "hasvertex" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        for vertex in fixture.vertices
            @test hasvertex(network, vertex)
        end

        @test !hasvertex(network, fixture.new_vertex.vertex)
    end
end

@testset "hasedge" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        for edge in fixture.edges
            @test hasedge(network, edge)
        end

        @test !hasedge(network, fixture.new_edge.edge)
    end
end

@testset "nvertices" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test nvertices(network) == length(fixture.vertices)
    end
end

@testset "nedges" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test nedges(network) == length(fixture.edges)
    end
end

@testset "edges_set_strand" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test issetequal(edges_set_strand(network), fixture.edges_strand)
    end
end

@testset "edges_set_open" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test issetequal(edges_set_open(network), fixture.edges_open)
    end
end

@testset "edges_set_hyper" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        @test issetequal(edges_set_hyper(network), fixture.edges_hyper)
    end
end

@testset "addvertex!" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        addvertex!(network, fixture.new_vertex.vertex)
        @test hasvertex(network, fixture.new_vertex.vertex)

        # vertex already exists so it should throw an error
        @test_throws ArgumentError addvertex!(network, fixture.new_vertex.vertex)
    end
end

@testset "addedge!" begin
    @testset "$(typeof(network))" for network in [
        SimpleNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map)
    ]
        # TODO

        # addedge!(network, fixture.new_edge.edge, fixture.new_edge.vertex_set)
        # @test hasedge(network, fixture.new_edge.edge)

        # # edge already exists so it should throw an error
        # @test_throws ArgumentError addedge!(network, fixture.new_edge.edge, fixture.new_edge.vertex_set)
    end
end

@testset "rmvertex!" begin
    @testset "SimpleNetwork" begin
        network = SimpleNetwork(fixture.vertex_map, fixture.edge_map)

        # test vertex removal
        @test hasvertex(network, fixture.vertex_strand)
        rmvertex!(network, fixture.vertex_strand)
        @test !hasvertex(network, fixture.vertex_strand)

        # vertex does not exist anymore so it should throw an error
        @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

        # `SimpleNetwork` has `PersistEdges` trait
        for edge in fixture.edges
            @test hasedge(network, edge)
        end
    end

    @testset "WrapNetwork{SimpleNetwork}" begin
        network = WrapNetwork(fixture.vertex_map, fixture.edge_map)

        # test vertex removal
        @test hasvertex(network, fixture.vertex_strand)
        rmvertex!(network, fixture.vertex_strand)
        @test !hasvertex(network, fixture.vertex_strand)

        # vertex does not exist anymore so it should throw an error
        @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

        # `WrapNetwork{SimpleNetwork}` has `PersistEdges` trait
        for edge in fixture.edges
            @test hasedge(network, edge)
        end
    end
end

@testset "rmedge!" begin
    # TODO
end
