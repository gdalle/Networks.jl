module Networks

include("Utils.jl")

include("Interfaces/Interface.jl")

include("Interfaces/Network.jl")
export Network

export vertices, edge_incidents, vertex_type, hasvertex, nvertices, addvertex!, rmvertex!
export edges, vertex_incidents, edge_type, hasedge, nedges, addedge!, rmedge!
export edges_set_strand, edges_set_open, edges_set_hyper

include("Components/SimpleNetwork.jl")
export SimpleNetwork

include("Components/AdjacencyNetwork.jl")
export AdjacencyNetwork

end # module Networks
