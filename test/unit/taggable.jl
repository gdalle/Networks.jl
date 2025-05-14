using Test
using Networks
using Networks: Vertex, Edge

# mocking Tenet.jl behavior
struct MockTensor{T}
    data::T
end

struct MockIndex{T}
    data::T
end

struct MockSite{T}
    data::T
end

struct MockLink{T}
    data::T
end

Networks.tag_kind(::Type{<:MockTensor}) = Networks.VertexTagKind()
Networks.tag_kind(::Type{<:MockIndex}) = Networks.EdgeTagKind()
Networks.tag_kind(::Type{<:MockSite}) = Networks.VertexTagKind()
Networks.tag_kind(::Type{<:MockLink}) = Networks.EdgeTagKind()

@testset "tag_kind" begin
    @test Networks.tag_kind(Vertex(1)) === Networks.VertexTagKind()
    @test Networks.tag_kind(Vertex) === Networks.VertexTagKind()

    @test Networks.tag_kind(Edge(1)) === Networks.EdgeTagKind()
    @test Networks.tag_kind(Edge) === Networks.EdgeTagKind()

    @test Networks.tag_kind(MockTensor([1])) === Networks.VertexTagKind()
    @test Networks.tag_kind(MockTensor) === Networks.VertexTagKind()

    @test Networks.tag_kind(MockIndex(:i)) === Networks.EdgeTagKind()
    @test Networks.tag_kind(MockIndex) === Networks.EdgeTagKind()

    @test Networks.tag_kind(MockSite((1,))) === Networks.VertexTagKind()
    @test Networks.tag_kind(MockSite) === Networks.VertexTagKind()

    @test Networks.tag_kind(MockLink((MockSite(1), MockSite(2)))) === Networks.EdgeTagKind()
    @test Networks.tag_kind(MockLink) === Networks.EdgeTagKind()
end

@testset "vertex_tags" begin end

@testset "edge_tags" begin end

@testset "has_vertex_tag" begin end

@testset "has_edge_tag" begin end

@testset "vertex_at" begin end

@testset "edge_at" begin end

@testset "tag_at_vertex" begin end

@testset "tag_at_edge" begin end

@testset "tag_vertex!" begin end

@testset "tag_edge!" begin end

@testset "untag_vertex!" begin end

@testset "untag_edge!" begin end

@testset "replace_vertex_tag!" begin end

@testset "replace_edge_tag!" begin end
