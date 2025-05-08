
struct SimpleNetwork{V,E} <: AbstractNetwork
    vertexmap::Dict{V,Set{E}}
    edgemap::Dict{E,Set{V}}
end

SimpleNetwork{V,E}() where {V,E} = SimpleNetwork{V,E}(Dict{V,Set{E}}(), Dict{E,Set{V}}())

# Network implementation
ImplementorTrait(::Network, graph::SimpleNetwork) = Implements()

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

# checkeffect(graph::SimpleNetwork, e::)
