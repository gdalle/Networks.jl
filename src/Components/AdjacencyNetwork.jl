struct SimpleEdge{T} <: AbstractEdge
    v1::T
    v2::T

    SimpleEdge(v1::T, v2::T) where {T} = new{T}(minmax(v1, v2)...)
end

"""
    AdjacencyNetwork <: AbstractNetwork

A network represented as an adjacency list.
It is the translation of `SimpleGraph` from Graphs.jl to the [`Network`](@ref) interface.
"""
struct AdjacencyNetwork{T<:Integer} <: AbstractNetwork
    fadjlist::Vector{Vector{T}}
    ne::Int
end

Base.copy(g::AdjacencyNetwork) = AdjacencyNetwork(copy.(g.fadjlist), g.ne)

Implements(::Network, ::AdjacencyNetwork) = Implements()
EdgePersistenceTrait(::AdjacencyNetwork) = RemoveEdges()

vertices(g::AdjacencyNetwork) = 1:length(g.fadjlist)
edges(g::AdjacencyNetwork) = SimpleEdgeIter(g)

edge_incidents(g::AdjacencyNetwork, e::SimpleEdge) = [e.v1, e.v2]
vertex_incidents(g::AdjacencyNetwork, v) = g.fadjlist[v]

vertex_type(g::AdjacencyNetwork{T}) where {T} = T
edge_type(g::AdjacencyNetwork{T}) where {T} = SimpleEdge{T}

hasvertex(g::AdjacencyNetwork, v) = 1 <= v <= length(g.fadjlist)
hasedge(g::AdjacencyNetwork, e::SimpleEdge) = e.v2 ∈ g.fadjlist[e.v1]

nvertices(g::AdjacencyNetwork) = length(g.fadjlist)
nedges(g::AdjacencyNetwork) = g.ne

edges_set_strand(::AdjacencyNetwork{T}) where {T} = SimpleEdge{T}[]
edges_set_open(::AdjacencyNetwork{T}) where {T} = SimpleEdge{T}[]
edges_set_hyper(::AdjacencyNetwork{T}) where {T} = SimpleEdge{T}[]

Base.@propagate_inbounds fadj(g::AdjacencyNetwork) = g.fadjlist
Base.@propagate_inbounds fadj(g::AdjacencyNetwork, u) = g.fadjlist[u]

struct SimpleEdgeIter{T}
    g::AdjacencyNetwork{T}
end

Base.IteratorSize(::Type{<:SimpleEdgeIter}) = Base.HasLength()
Base.length(g::SimpleEdgeIter) = nedges(g.g)

Base.IteratorEltype(::Type{<:SimpleEdgeIter}) = Base.HasEltype()
Base.eltype(::Type{<:SimpleEdgeIter{T}}) where {T} = SimpleEdge{T}

@inline function Base.iterate(
    eit::SimpleEdgeIter{G}, state=(one(vertex_type(eit.g)), 1)
) where {G}
    g = eit.g
    T = vertex_type(g)
    n = T(nvertices(g))
    u, i = state

    @inbounds while u < n
        list_u = fadj(g, u)
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadj(g, u), u)
            continue
        end
        e = SimpleEdge(u, list_u[i])
        state = (u, i + 1)
        return e, state
    end

    @inbounds (n == 0 || i > length(fadj(g, n))) && return nothing

    e = SimpleEdge(n, n)
    state = (u, i + 1)
    return e, state
end
