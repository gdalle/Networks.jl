struct Network <: Interface end

# auxiliar types
abstract type AbstractNetwork end

abstract type AbstractVertex end
struct Vertex{T} <: AbstractVertex
    id::T
end

abstract type AbstractEdge end
struct Edge{T} <: AbstractEdge
    id::T
end

# traits
"""
    EdgePersistenceTrait

Trait for edge persitence in a [`Network`](@ref). It defines the behavior of edges when a vertex is removed.
The following traits are defined:

- `PersistEdges`: edges are **never** removed implicitly.
- `RemoveEdges`: edges are **always** removed implicitly.
- `PruneEdges` (default): edges are removed if left stranded (i.e. no other vertex is linked with it).
"""
abstract type EdgePersistenceTrait end
struct PersistEdges <: EdgePersistenceTrait end
struct RemoveEdges <: EdgePersistenceTrait end
struct PruneEdges <: EdgePersistenceTrait end

EdgePersistenceTrait(graph) = EdgePersistenceTrait(graph, DelegatorTrait(Network(), graph))
EdgePersistenceTrait(graph, ::DelegateTo) = EdgePersistenceTrait(delegator(Network(), graph))
EdgePersistenceTrait(graph, ::DontDelegate) = PruneEdges()

# query methods
function vertices end
function edges end

function edge_incidents end
function vertex_incidents end

:(Base.copy)

# query methods with default implementation
function vertex_type end
function edge_type end

function hasvertex end
function hasedge end

function nvertices end
function nedges end

function edges_set_strand end
function edges_set_open end
function edges_set_hyper end

# mutating methods
function addvertex_inner! end
function addedge_inner! end
function rmvertex_inner! end
function rmedge_inner! end
function link_inner! end
function unlink_inner! end

function addvertex! end
function addedge! end
function rmvertex! end
function rmedge! end
function link! end
function unlink! end

# mutating methods with default implementation
function prune_edges! end

# effects
"""

    AddVertexEffect{F} <: Effect

Represents the effect of adding a vertex to a graph.
"""
struct AddVertexEffect{V} <: Effect
    vertex::V
end

"""
    AddEdgeEffect{F} <: Effect

Represents the effect of adding an edge to a graph.
"""
struct AddEdgeEffect{E} <: Effect
    edge::E
end

"""
    RemoveVertexEffect{F} <: Effect

Represents the effect of removing a vertex from a graph.
"""
struct RemoveVertexEffect{V} <: Effect
    vertex::V
end

"""
    RemoveEdgeEffect{F} <: Effect

Represents the effect of removing an edge from a graph.
"""
struct RemoveEdgeEffect{E} <: Effect
    edge::E
end

"""
    LinkEffect{F} <: Effect

Represents the effect of linking a vertex to an edge in a graph.
"""
struct LinkEffect{V,E} <: Effect
    vertex::V
    edge::E
end

"""
    UnlinkEffect{F} <: Effect

Represents the effect of unlinking a vertex from an edge in a graph.
"""
struct UnlinkEffect{V,E} <: Effect
    vertex::V
    edge::E
end

# implementation
## `vertices`
vertices(graph) = vertices(graph, DelegatorTrait(Network(), graph))
vertices(graph, ::DelegateTo) = vertices(delegator(Network(), graph))
vertices(graph, ::DontDelegate) = throw(MethodError(vertices, (graph,)))

## `edges`
edges(graph) = edges(graph, DelegatorTrait(Network(), graph))
edges(graph, ::DelegateTo) = edges(delegator(Network(), graph))
edges(graph, ::DontDelegate) = throw(MethodError(edges, (graph,)))

## `edge_incidents`
edge_incidents(graph, e) = edge_incidents(graph, e, DelegatorTrait(Network(), graph))
edge_incidents(graph, e, ::DelegateTo) = edge_incidents(delegator(Network(), graph), e)
edge_incidents(graph, e, ::DontDelegate) = throw(MethodError(edge_incidents, (graph, e)))

## `vertex_incidents`
vertex_incidents(graph, v) = vertex_incidents(graph, v, DelegatorTrait(Network(), graph))
vertex_incidents(graph, v, ::DelegateTo) = vertex_incidents(delegator(Network(), graph), v)
vertex_incidents(graph, v, ::DontDelegate) = throw(MethodError(vertex_incidents, (graph, v)))

## `vertex_type`
vertex_type(graph) = vertex_type(graph, DelegatorTrait(Network(), graph))
vertex_type(graph, ::DelegateTo) = vertex_type(delegator(Network(), graph))
function vertex_type(graph, ::DontDelegate)
    fallback(vertex_type)
    return Any # mapreduce(typeof, typejoin, vertices(graph))
end

## `edge_type`
edge_type(graph) = edge_type(graph, DelegatorTrait(Network(), graph))
edge_type(graph, ::DelegateTo) = edge_type(delegator(Network(), graph))
function edge_type(graph, ::DontDelegate)
    fallback(edge_type)
    return Any # mapreduce(typeof, typejoin, edges(graph))
end

## `hasvertex`
hasvertex(graph, v) = hasvertex(graph, v, DelegatorTrait(Network(), graph))
hasvertex(graph, v, ::DelegateTo) = hasvertex(delegator(Network(), graph), v)
function hasvertex(graph, v, ::DontDelegate)
    fallback(hasvertex)
    return v in vertices(graph)
end

## `hasedge`
hasedge(graph, e) = hasedge(graph, e, DelegatorTrait(Network(), graph))
hasedge(graph, e, ::DelegateTo) = hasedge(delegator(Network(), graph), e)
function hasedge(graph, e, ::DontDelegate)
    fallback(hasedge)
    return e in edges(graph)
end

## `nvertices`
nvertices(graph) = nvertices(graph, DelegatorTrait(Network(), graph))
nvertices(graph, ::DelegateTo) = nvertices(delegator(Network(), graph))
function nvertices(graph, ::DontDelegate)
    fallback(nvertices)
    return length(vertices(graph))
end

## `nedges`
nedges(graph) = nedges(graph, DelegatorTrait(Network(), graph))
nedges(graph, ::DelegateTo) = nedges(delegator(Network(), graph))
function nedges(graph, ::DontDelegate)
    fallback(nedges)
    return length(edges(graph))
end

## `edges_set_strand`
edges_set_strand(graph) = edges_set_strand(graph, DelegatorTrait(Network(), graph))
edges_set_strand(graph, ::DelegateTo) = edges_set_strand(delegator(Network(), graph))
function edges_set_strand(graph, ::DontDelegate)
    fallback(edges_set_strand)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) == 0
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

## `edges_set_open`
edges_set_open(graph) = edges_set_open(graph, DelegatorTrait(Network(), graph))
edges_set_open(graph, ::DelegateTo) = edges_set_open(delegator(Network(), graph))
function edges_set_open(graph, ::DontDelegate)
    fallback(edges_set_open)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) == 1
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

## `edges_set_hyper`
edges_set_hyper(graph) = edges_set_hyper(graph, DelegatorTrait(Network(), graph))
edges_set_hyper(graph, ::DelegateTo) = edges_set_hyper(delegator(Network(), graph))
function edges_set_hyper(graph, ::DontDelegate)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) > 2
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

## `addvertex_inner!`
addvertex_inner!(graph, v) = addvertex_inner!(graph, v, DelegatorTrait(Network(), graph))
addvertex_inner!(graph, v, ::DelegateTo) = addvertex_inner!(delegator(Network(), graph), v)
addvertex_inner!(graph, v, ::DontDelegate) = throw(MethodError(addvertex_inner!, (graph, v)))

## `addedge_inner!`
addedge_inner!(graph, e) = addedge_inner!(graph, e, DelegatorTrait(Network(), graph))
addedge_inner!(graph, e, ::DelegateTo) = addedge_inner!(delegator(Network(), graph), e)
addedge_inner!(graph, e, ::DontDelegate) = throw(MethodError(addedge_inner!, (graph, e)))

## `rmvertex_inner!`
rmvertex_inner!(graph, v) = rmvertex_inner!(graph, v, DelegatorTrait(Network(), graph))
rmvertex_inner!(graph, v, ::DelegateTo) = rmvertex_inner!(delegator(Network(), graph), v)
rmvertex_inner!(graph, v, ::DontDelegate) = throw(MethodError(rmvertex_inner!, (graph, v)))

## `rmedge_inner!`
rmedge_inner!(graph, e) = rmedge_inner!(graph, e, DelegatorTrait(Network(), graph))
rmedge_inner!(graph, e, ::DelegateTo) = rmedge_inner!(delegator(Network(), graph), e)
rmedge_inner!(graph, e, ::DontDelegate) = throw(MethodError(rmedge_inner!, (graph, e)))

## `link_inner!`
link_inner!(graph, v, e) = link_inner!(graph, v, e, DelegatorTrait(Network(), graph))
link_inner!(graph, v, e, ::DelegateTo) = link_inner!(delegator(Network(), graph), v, e)
link_inner!(graph, v, e, ::DontDelegate) = throw(MethodError(link_inner!, (graph, v, e)))

## `unlink_inner!`
unlink_inner!(graph, v, e) = unlink_inner!(graph, v, e, DelegatorTrait(Network(), graph))
unlink_inner!(graph, v, e, ::DelegateTo) = unlink_inner!(delegator(Network(), graph), v, e)
unlink_inner!(graph, v, e, ::DontDelegate) = throw(MethodError(unlink_inner!, (graph, v, e)))

## `addvertex!`
function addvertex!(graph, v)
    checkeffect(graph, AddVertexEffect(v))
    addvertex_inner!(graph, v)
    handle!(graph, AddVertexEffect(v))
    return graph
end

checkeffect(graph, e::AddVertexEffect) = checkeffect(graph, e, DelegatorTrait(Network(), graph))
checkeffect(graph, e::AddVertexEffect, ::DelegateTo) = checkeffect(delegator(Network(), graph), e)
checkeffect(graph, e::AddVertexEffect, ::DontDelegate) = hasvertex(graph, e.vertex) && throw(ArgumentError("Vertex $(e.vertex) already exists in network"))

# by default, do nothing because no extra mapping should be defined at this level
handle!(graph, e::AddVertexEffect) = handle!(graph, e, DelegatorTrait(Network(), graph))
handle!(graph, e::AddVertexEffect, ::DelegateTo) = handle!(delegator(Network(), graph), e)
handle!(graph, e::AddVertexEffect, ::DontDelegate) = nothing

## `addedge!`
function addedge!(graph, e)
    checkeffect(graph, AddEdgeEffect(e))
    addedge_inner!(graph, e)
    handle!(graph, AddEdgeEffect(e))
    return graph
end

checkeffect(graph, e::AddEdgeEffect) = checkeffect(graph, e, DelegatorTrait(Network(), graph))
checkeffect(graph, e::AddEdgeEffect, ::DelegateTo) = checkeffect(delegator(Network(), graph), e)
checkeffect(graph, e::AddEdgeEffect, ::DontDelegate) = hasedge(graph, e.edge) && throw(ArgumentError("Edge $(e.edge) already exists in network"))

# by default, do nothing because no extra mapping should be defined at this level
handle!(graph, e::AddEdgeEffect) = handle!(graph, e, DelegatorTrait(Network(), graph))
handle!(graph, e::AddEdgeEffect, ::DelegateTo) = handle!(delegator(Network(), graph), e)
handle!(graph, e::AddEdgeEffect, ::DontDelegate) = nothing

## `rmvertex!`
rmvertex!(graph, v) = rmvertex!(graph, v, EdgePersistenceTrait(graph))

function rmvertex!(graph, v, ::PersistEdges)
    checkeffect(graph, RemoveVertexEffect(v))
    rmvertex_inner!(graph, v)
    handle!(graph, RemoveVertexEffect(v))
    return graph
end

function rmvertex!(graph, v, ::RemoveEdges)
    checkeffect(graph, RemoveVertexEffect(v))

    # trait is to remove edges on vertex removal
    for edge in vertex_incidents(graph, e.vertex)
        rmedge!(graph, edge)
    end

    rmvertex_inner!(graph, v)
    handle!(graph, RemoveVertexEffect(v))
    return graph
end

function rmvertex!(graph, v, ::PruneEdges)
    checkeffect(graph, RemoveVertexEffect(v))

    # trait is to remove edges on vertex removal if that leaves them stranded
    # (i.e. no open indices left)
    for edge in vertex_incidents(graph, v)
        if length(edge_incidents(graph, edge)) == 1
            rmedge!(graph, edge)
        end
    end

    rmvertex_inner!(graph, v)
    handle!(graph, RemoveVertexEffect(v))
    return graph
end

checkeffect(graph, e::RemoveVertexEffect) = checkeffect(graph, e, DelegatorTrait(Network(), graph))
checkeffect(graph, e::RemoveVertexEffect, ::DelegateTo) = checkeffect(delegator(Network(), graph), e)
checkeffect(graph, e::RemoveVertexEffect, ::DontDelegate) = hasvertex(graph, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))

# by default, do nothing because no extra mapping should be defined at this level
handle!(graph, e::RemoveVertexEffect) = handle!(graph, e, DelegatorTrait(Network(), graph))
handle!(graph, e::RemoveVertexEffect, ::DelegateTo) = handle!(delegator(Network(), graph), e)
handle!(graph, e::RemoveVertexEffect, ::DontDelegate) = nothing

## `rmedge!`
function rmedge!(graph, e)
    checkeffect(graph, RemoveEdgeEffect(e))
    rmedge_inner!(graph, e)
    handle!(graph, RemoveEdgeEffect(e))
    return graph
end

checkeffect(graph, e::RemoveEdgeEffect) = checkeffect(graph, e, DelegatorTrait(Network(), graph))
checkeffect(graph, e::RemoveEdgeEffect, ::DelegateTo) = checkeffect(delegator(Network(), graph), e)
checkeffect(graph, e::RemoveEdgeEffect, ::DontDelegate) = hasedge(graph, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))

# by default, do nothing because no extra mapping should be defined at this level
handle!(graph, e::RemoveEdgeEffect) = handle!(graph, e, DelegatorTrait(Network(), graph))
handle!(graph, e::RemoveEdgeEffect, ::DelegateTo) = handle!(delegator(Network(), graph), e)
handle!(graph, e::RemoveEdgeEffect, ::DontDelegate) = nothing

## `link!`
function link!(graph, v, e)
    checkeffect(graph, LinkEffect(e))
    link_inner!(graph, v, e)
    handle!(graph, LinkEffect(e))
    return graph
end

checkeffect(graph, e::LinkEffect) = checkeffect(graph, e, DelegatorTrait(Network(), graph))
checkeffect(graph, e::LinkEffect, ::DelegateTo) = checkeffect(delegator(Network(), graph), e)
function checkeffect(graph, e::LinkEffect, ::DontDelegate)
    hasvertex(graph, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))
    hasedge(graph, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))
end

# by default, do nothing because no extra mapping should be defined at this level
handle!(graph, e::LinkEffect) = handle!(graph, e, DelegatorTrait(Network(), graph))
handle!(graph, e::LinkEffect, ::DelegateTo) = handle!(delegator(Network(), graph), e)
handle!(graph, e::LinkEffect, ::DontDelegate) = nothing

## `unlink!`
function unlink!(graph, v, e)
    checkeffect(graph, UnlinkEffect(e))
    unlink_inner!(graph, v, e)
    handle!(graph, UnlinkEffect(e))
    return graph
end

checkeffect(graph, e::UnlinkEffect) = checkeffect(graph, e, DelegatorTrait(Network(), graph))
checkeffect(graph, e::UnlinkEffect, ::DelegateTo) = checkeffect(delegator(Network(), graph), e)
function checkeffect(graph, e::UnlinkEffect, ::DontDelegate)
    hasvertex(graph, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))
    hasedge(graph, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))
end

# by default, do nothing because no extra mapping should be defined at this level
handle!(graph, e::UnlinkEffect) = handle!(graph, e, DelegatorTrait(Network(), graph))
handle!(graph, e::UnlinkEffect, ::DelegateTo) = handle!(delegator(Network(), graph), e)
handle!(graph, e::UnlinkEffect, ::DontDelegate) = nothing

## `prune_edges!`
function prune_edges!(graph)
    for edge in edges_set_strand(graph)
        rmedge!(graph, edge)
    end
    return graph
end
