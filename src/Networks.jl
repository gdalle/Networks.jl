module Networks

include("Utils.jl")

include("Interfaces/Interface.jl")

include("Interfaces/Network.jl")
export Network, vertices, edges, edge_incidents, vertex_incidents, vertex_type, edge_type, hasvertex, hasedge, nvertices, nedges, addvertex!, addedge!, rmvertex!, rmedge!

export SimpleNetwork
include("Components/SimpleNetwork.jl")

end # module Networks
