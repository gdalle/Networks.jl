
struct SimpleNetwork{V,E} <: AbstractNetwork
    vertexmap::Dict{V,Set{E}}
    edgemap::Dict{E,Set{V}}

    SimpleNetwork{V,E}() where {V,E} = new{V,E}(Dict{V,Set{E}}(), Dict{E,Set{V}}())
    SimpleNetwork{V,E}(vertexmap, edgemap) where {V,E} = new{V,E}(copy(vertexmap), copy(edgemap))
end

SimpleNetwork(vertexmap::Dict{V,Set{E}}, edgemap::Dict{E,Set{V}}) where {V,E} = SimpleNetwork{V,E}(vertexmap, edgemap)

# Network implementation
ImplementorTrait(::Network, graph::SimpleNetwork) = Implements()
EdgePersistenceTrait(::SimpleNetwork) = PersistEdges()

vertices(graph::SimpleNetwork) = keys(graph.vertexmap)
edges(graph::SimpleNetwork) = keys(graph.edgemap)

# TODO should we copy the sets to avoid accidental mutation?
edge_incidents(graph::SimpleNetwork, e) = graph.edgemap[e]
vertex_incidents(graph::SimpleNetwork, v) = graph.vertexmap[v]

vertex_type(::SimpleNetwork{V,E}) where {V,E} = V
edge_type(::SimpleNetwork{V,E}) where {V,E} = E

hasvertex(graph::SimpleNetwork, v) = haskey(graph.vertexmap, v)
hasedge(graph::SimpleNetwork, e) = haskey(graph.edgemap, e)

nvertices(graph::SimpleNetwork) = length(graph.vertexmap)
nedges(graph::SimpleNetwork) = length(graph.edgemap)

function edges_set_strand(graph::SimpleNetwork{V,E}) where {V,E}
    stranded_edges = Set{E}()
    for (edge, vertex_set) in pairs(graph.edgemap)
        if isempty(vertex_set)
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function edges_set_open(graph::SimpleNetwork{V,E}) where {V,E}
    stranded_edges = Set{E}()
    for (edge, vertex_set) in pairs(graph.edgemap)
        if length(vertex_set) == 1
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function edges_set_hyper(graph::SimpleNetwork{V,E}) where {V,E}
    stranded_edges = Set{E}()
    for (edge, vertex_set) in pairs(graph.edgemap)
        if length(vertex_set) > 2
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function addvertex_inner!(graph::SimpleNetwork{V,E}, vertex) where {V,E}
    hasvertex(graph, vertex) && return graph
    graph.vertexmap[vertex] = Set{E}()
    return graph
end

function rmvertex_inner!(graph::SimpleNetwork, vertex)
    # isempty(vertex_incidents(graph, vertex)) || throw(ArgumentError("Vertex $vertex is incident to edges. Remove edges first."))

    # unlink vertex-edge pairs
    for edge in vertex_incidents(graph, vertex)
        unlink_inner!(graph, vertex, edge)
    end

    # remove vertex
    delete!(graph.vertexmap, vertex)
    return graph
end

function addedge_inner!(graph::SimpleNetwork{V,E}, edge) where {V,E}
    hasedge(graph, edge) && return graph
    graph.edgemap[edge] = Set{V}()
    return graph
end

function rmedge_inner!(graph::SimpleNetwork, edge)
    # isempty(edge_incidents(graph, edge)) || throw(ArgumentError("Edge $edge is incident to vertices. Remove vertices first."))

    # unlink edge-vertex pairs
    for vertex in edge_incidents(graph, edge)
        unlink_inner!(graph, vertex, edge)
    end

    # remove edge
    delete!(graph.edgemap, edge)
    return graph
end

function link_inner!(graph::SimpleNetwork, vertex, edge)
    push!(graph.vertexmap[vertex], edge)
    push!(graph.edgemap[edge], vertex)
end

function unlink_inner!(graph::SimpleNetwork, vertex, edge)
    delete!(graph.vertexmap[vertex], edge)
    delete!(graph.edgemap[edge], vertex)
end
