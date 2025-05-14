module Networks

include("Utils.jl")

include("Interfaces/Interface.jl")

include("Interfaces/Network.jl")
export Network

export vertices, edge_incidents, vertex_type, hasvertex, nvertices, addvertex!, rmvertex!
export edges, vertex_incidents, edge_type, hasedge, nedges, addedge!, rmedge!
export edges_set_strand, edges_set_open, edges_set_hyper

# WARN `Taggable` is still experimantal, so don't export it yet
include("Interfaces/Taggable.jl")

# WARN `Attributeable` is still experimantal, so don't export it yet
include("Interfaces/Attributeable.jl")

include("Components/IncidentNetwork.jl")
export IncidentNetwork

include("Components/AdjacentNetwork.jl")
export AdjacentNetwork

end # module Networks
