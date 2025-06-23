struct SimpleEdge{T} <: AbstractEdge
    v1::T
    v2::T

    SimpleEdge(v1::T, v2::T) where {T} = new{T}(minmax(v1, v2)...)
end

"""
    AdjacentNetwork <: AbstractNetwork

A network represented as an adjacency list.
It is the translation of `SimpleGraph` from Graphs.jl to the [`Network`](@ref) interface.
"""
mutable struct AdjacentNetwork{T<:Integer} <: AbstractNetwork
    fadjlist::Vector{Vector{T}}
    ne::Int
end

AdjacentNetwork{T}() where {T} = AdjacentNetwork{T}(Vector{Vector{T}}(), 0)
AdjacentNetwork{T}(n::Integer) where {T} = AdjacentNetwork{T}([T[] for _ in 1:n], 0)

Base.copy(g::AdjacentNetwork) = AdjacentNetwork(copy.(g.fadjlist), g.ne)

DelegatorTraits.ImplementorTrait(::Network, ::AdjacentNetwork) = DelegatorTraits.Implements()
EdgePersistenceTrait(::AdjacentNetwork) = RemoveEdges()

vertices(g::AdjacentNetwork) = 1:length(g.fadjlist)
edges(g::AdjacentNetwork) = SimpleEdgeIter(g)

edge_incidents(g::AdjacentNetwork, e::SimpleEdge) = [e.v1, e.v2]
vertex_incidents(g::AdjacentNetwork, v) = g.fadjlist[v]

vertex_type(g::AdjacentNetwork{T}) where {T} = T
edge_type(g::AdjacentNetwork{T}) where {T} = SimpleEdge{T}

hasvertex(g::AdjacentNetwork, v) = 1 <= v <= length(g.fadjlist)
hasedge(g::AdjacentNetwork, e::SimpleEdge) = e.v2 ∈ g.fadjlist[e.v1]

nvertices(g::AdjacentNetwork) = length(g.fadjlist)
nedges(g::AdjacentNetwork) = g.ne

edges_set_strand(::AdjacentNetwork{T}) where {T} = SimpleEdge{T}[]
edges_set_open(::AdjacentNetwork{T}) where {T} = SimpleEdge{T}[]
edges_set_hyper(::AdjacentNetwork{T}) where {T} = SimpleEdge{T}[]

function addvertex!(g::AdjacentNetwork)
    n = nvertices(g) + 1
    push!(g.fadjlist, Vector{vertex_type(g)}())
    return n
end

function addedge!(g::AdjacentNetwork, e::SimpleEdge)
    a, b = e.v1, e.v2
    @assert a ∈ vertices(g)
    @assert b ∈ vertices(g)

    if !hasedge(g, e)
        push!(g.fadjlist[a], b)
        push!(g.fadjlist[b], a)
        g.ne += 1
    end

    return e
end

function addedge!(g::AdjacentNetwork, u, v)
    e = SimpleEdge(u, v)
    return addedge!(g, e)
end

function rmvertex!(g::AdjacentNetwork, v)
    @assert hasvertex(g, v)

    # Update the adjacency lists of other vertices
    for (i, irow) in enumerate(g.fadjlist)
        filter!(!=(v), irow)
        irow .= -1
    end

    # Remove the vertex from the adjacency list
    deleteat!(g.fadjlist, v)

    return v
end

function rmedge!(g::AdjacentNetwork, e::SimpleEdge)
    @assert hasedge(g, e)
    a, b = e.v1, e.v2

    if hasedge(g, e)
        filter!(!=(b), g.fadjlist[a])
        filter!(!=(a), g.fadjlist[b])
        g.ne -= 1
    end

    return e
end

Base.@propagate_inbounds fadj(g::AdjacentNetwork) = g.fadjlist
Base.@propagate_inbounds fadj(g::AdjacentNetwork, u) = g.fadjlist[u]

struct SimpleEdgeIter{T}
    g::AdjacentNetwork{T}
end

Base.IteratorSize(::Type{<:SimpleEdgeIter}) = Base.HasLength()
Base.length(g::SimpleEdgeIter) = nedges(g.g)

Base.IteratorEltype(::Type{<:SimpleEdgeIter}) = Base.HasEltype()
Base.eltype(::Type{<:SimpleEdgeIter{T}}) where {T} = SimpleEdge{T}

@inline function Base.iterate(eit::SimpleEdgeIter{G}, state=(one(vertex_type(eit.g)), 1)) where {G}
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
