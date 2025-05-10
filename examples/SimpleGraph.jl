using Networks
using Networks: Network

struct SimpleEdge{T} <: Networks.AbstractEdge
    v1::T
    v2::T

    SimpleEdge(v1::T, v2::T) where {T} = new{T}(v1, v2) # new{T}(minmax(v1, v2)...)
end

struct SimpleGraph{T<:Integer} <: Networks.AbstractNetwork
    fadjlist::Vector{Vector{T}}
    ne::Int
end

Networks.Implements(::Network, ::SimpleGraph) = Networks.Implements()
Networks.EdgePersistenceTrait(::SimpleGraph) = Networks.RemoveEdges()

Networks.vertices(g::SimpleGraph) = 1:length(g.fadjlist)
Networks.edges(g::SimpleGraph) = SimpleEdgeIter(g)

Networks.edge_incidents(g::SimpleGraph, e::SimpleEdge) = [e.v1, e.v2]
Networks.vertex_incidents(g::SimpleGraph, v) = g.fadjlist[v]

Networks.vertex_type(g::SimpleGraph{T}) where {T} = T
Networks.edge_type(g::SimpleGraph{T}) where {T} = SimpleEdge{T}

Networks.hasvertex(g::SimpleGraph, v) = 1 <= v <= length(g.fadjlist)
Networks.hasedge(g::SimpleGraph, e::SimpleEdge) = e.v2 ∈ g.fadjlist[e.v1]

Networks.nvertices(g::SimpleGraph) = length(g.fadjlist)
Networks.nedges(g::SimpleGraph) = g.ne

Networks.edges_set_strand(::SimpleGraph{T}) where {T} = SimpleEdge{T}[]
Networks.edges_set_open(::SimpleGraph{T}) where {T} = SimpleEdge{T}[]
Networks.edges_set_hyper(::SimpleGraph{T}) where {T} = SimpleEdge{T}[]

Base.@propagate_inbounds fadj(g::SimpleGraph) = g.fadjlist
Base.@propagate_inbounds fadj(g::SimpleGraph, u) = g.fadjlist[u]

struct SimpleEdgeIter{T}
    g::SimpleGraph{T}
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
