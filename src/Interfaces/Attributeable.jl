struct Attributeable <: Interface end

# TODO should we have a `unsetattr!` or `deleteattr!` method?

# NOTE the API has been designed to have dynamic attrs that can be saved in a `Dict{Symbol,Any}`, but there should be
# nothing holding back to have static attributes. perhaps for type-stability we may need to use a `AttrKey{T}` type on
# which to dispatch or have a `AttributeTypeTrait` with `StaticAttribute` and `DynamicAttribute` traits.

# dispatching methods
function attrs end
function getattr end
function setattr! end
function hasattr end

# query methods
function attrs_global end
function attrs_vertex end
function attrs_edge end

function getattr_global end
function getattr_vertex end
function getattr_edge end

function hasattr_global end
function hasattr_vertex end
function hasattr_edge end

# mutating methods
function setattr_global_inner! end
function setattr_vertex_inner! end
function setattr_edge_inner! end

function setattr_global! end
function setattr_vertex! end
function setattr_edge! end

# effects
struct SetAttrGlobal{T} <: Effect
    key::Symbol
    value::T
end

struct SetAttrVertex{V,T} <: Effect
    vertex::V
    key::Symbol
    value::T
end

struct SetAttrEdge{E,T} <: Effect
    edge::E
    key::Symbol
    value::T
end

# implementation
## `attrs`
attrs(tn) = attrs_global(tn)
attrs(tn, vertex::AbstractVertex) = attrs_vertex(tn, vertex)
attrs(tn, edge::AbstractEdge) = attrs_edge(tn, edge)

## `getattr`
getattr(tn, key) = getattr_global(tn, key)
getattr(tn, vertex::AbstractVertex, key) = getattr_vertex(tn, vertex, key)
getattr(tn, edge::AbstractEdge, key) = getattr_edge(tn, edge, key)

getattr(tn, key, default) = hasattr(tn, key) ? getattr(tn, key) : default
getattr(tn, vertex::AbstractVertex, key, default) = hasattr(tn, vertex, key) ? getattr(tn, vertex, key) : default
getattr(tn, edge::AbstractEdge, key, default) = hasattr(tn, edge, key) ? getattr(tn, edge, key) : default

## `setattr!`
setattr!(tn, key, value) = setattr_global!(tn, key, value)
setattr!(tn, vertex::AbstractVertex, key, value) = setattr_vertex!(tn, vertex, key, value)
setattr!(tn, edge::AbstractEdge, key, value) = setattr_edge!(tn, edge, key, value)

## `hasattr`
hasattr(tn, key) = hasattr_global(tn, key)
hasattr(tn, vertex::AbstractVertex, key) = hasattr_vertex(tn, vertex, key)
hasattr(tn, edge::AbstractEdge, key) = hasattr_vertex(tn, edge, key)

## `attrs_global`
attrs_global(tn) = attrs_global(tn, delegates(Attributeable(), tn))
attrs_global(tn, ::DelegateTo) = attrs_global(delagate(Attributeable(), tn))
attrs_global(tn, ::DontDelegate) = throw(MethodError(attrs_global, (tn,)))

## `attrs_vertex`
attrs_vertex(tn, vertex) = attrs_vertex(tn, vertex, delegates(Attributeable(), tn))
attrs_vertex(tn, vertex, ::DelegateTo) = attrs_vertex(delegate(Attributeable(), tn), vertex)
attrs_vertex(tn, vertex, ::DontDelegate) = throw(MethodError(attrs_vertex, (tn, vertex)))

## `attrs_edge`
attrs_edge(tn, edge) = attrs_edge(tn, edge, delegates(Attributeable(), tn))
attrs_edge(tn, edge, ::DelegateTo) = attrs_edge(delegate(Attributeable(), tn), edge)
attrs_edge(tn, edge, ::DontDelegate) = throw(MethodError(attrs_edge, (tn, edge)))

## `getattr_global`
getattr_global(tn, key) = getattr_global(tn, key, delegates(Attributeable(), tn))
getattr_global(tn, key, ::DelegateTo) = getattr_global(delegate(Attributeable(), tn), key)
function getattr_global(tn, key, ::DontDelegate)
    fallback(getattr_global)
    return getindex(attrs_global(tn), key)
end

## `getattr_vertex`
getattr_vertex(tn, vertex, key) = getattr_vertex(tn, vertex, key, delegates(Attributeable(), tn))
getattr_vertex(tn, vertex, key, ::DelegateTo) = getattr_vertex(delegate(Attributeable(), tn), vertex, key)
function getattr_vertex(tn, vertex, key, ::DontDelegate)
    fallback(getattr_vertex)
    return getindex(attrs_vertex(tn, vertex), key)
end

## `getattr_edge`
getattr_edge(tn, edge, key) = getattr_edge(tn, edge, key, delegates(Attributeable(), tn))
getattr_edge(tn, edge, key, ::DelegateTo) = getattr_edge(delegate(Attributeable(), tn), edge, key)
function getattr_edge(tn, edge, key, ::DontDelegate)
    fallback(getattr_edge)
    return getindex(attrs_edge(tn, edge), key)
end

## `hasattr_global`
hasattr_global(tn, key) = hasattr_global(tn, key, delegates(Attributeable(), tn))
hasattr_global(tn, key, ::DelegateTo) = hasattr_global(delegate(Attributeable(), tn), key)
function hasattr_global(tn, key, ::DontDelegate)
    fallback(hasattr_global)
    return haskey(attrs_global(tn), key)
end

## `hasattr_vertex`
hasattr_vertex(tn, vertex, key) = hasattr_vertex(tn, vertex, key, delegates(Attributeable(), tn))
hasattr_vertex(tn, vertex, key, ::DelegateTo) = hasattr_vertex(delegate(Attributeable(), tn), vertex, key)
function hasattr_vertex(tn, vertex, key, ::DontDelegate)
    fallback(hasattr_vertex)
    return haskey(attrs_vertex(tn, vertex), key)
end

## `hasattr_edge`
hasattr_edge(tn, edge, key) = hasattr_edge(tn, edge, key, delegates(Attributeable(), tn))
hasattr_edge(tn, edge, key, ::DelegateTo) = hasattr_edge(delegate(Attributeable(), tn), edge, key)
function hasattr_edge(tn, edge, key, ::DontDelegate)
    fallback(hasattr_edge)
    return haskey(attrs_edge(tn, edge), key)
end

## `setattr_global_inner!`
setattr_global_inner!(tn, key, value) = setattr_global_inner!(tn, key, value, delegates(Attributeable(), tn))
setattr_global_inner!(tn, key, value, ::DelegateTo) = setattr_global_inner!(delegate(Attributeable(), tn), key, value)
setattr_global_inner!(tn, key, value, ::DontDelegate) = throw(MethodError(setattr_global_inner!, (tn, key, value)))

## `setattr_vertex_inner!`
function setattr_vertex_inner!(tn, vertex, key, value)
    setattr_vertex_inner!(tn, vertex, key, value, delegates(Attributeable(), tn))
end
function setattr_vertex_inner!(tn, vertex, key, value, ::DelegateTo)
    setattr_vertex_inner!(delegate(Attributeable(), tn), vertex, key, value)
end
function setattr_vertex_inner!(tn, vertex, key, value, ::DontDelegate)
    throw(MethodError(setattr_vertex_inner!, (tn, vertex, key, value)))
end

## `setattr_edge_inner!`
setattr_edge_inner!(tn, edge, key, value) = setattr_edge_inner!(tn, edge, key, value, delegates(Attributeable(), tn))
function setattr_edge_inner!(tn, edge, key, value, ::DelegateTo)
    setattr_edge_inner!(delegate(Attributeable(), tn), edge, key, value)
end
function setattr_edge_inner!(tn, edge, key, value, ::DontDelegate)
    throw(MethodError(setattr_edge_inner!, (tn, edge, key, value)))
end

## `setattr_global!`
function setattr_global!(tn, key, value)
    checkeffect(tn, SetAttrGlobal(key, value))
    setattr_global_inner!(tn, key, value)
    handle!(tn, SetAttrGlobal(key, value))
    return tn
end

checkeffect(tn, e::SetAttrGlobal) = checkeffect(tn, e, delegates(Attributeable(), tn))
checkeffect(tn, e::SetAttrGlobal, ::DelegateTo) = checkeffect(delegate(Attributeable(), tn), e)
checkeffect(_, e::SetAttrGlobal, ::DontDelegate) = nothing

handle!(tn, e::SetAttrGlobal) = handle!(tn, e, delegates(Attributeable(), tn))
handle!(tn, e::SetAttrGlobal, ::DelegateTo) = handle!(delegate(Attributeable(), tn), e)
handle!(_, e::SetAttrGlobal, ::DontDelegate) = nothing

## `setattr_vertex!`
function setattr_vertex!(tn, vertex, key, value)
    checkeffect(tn, SetAttrVertex(vertex, key, value))
    setattr_vertex_inner!(tn, vertex, key, value)
    handle!(tn, SetAttrVertex(vertex, key, value))
    return tn
end

checkeffect(tn, e::SetAttrVertex) = checkeffect(tn, e, delegates(Attributeable(), tn))
checkeffect(tn, e::SetAttrVertex, ::DelegateTo) = checkeffect(delegate(Attributeable(), tn), e)
function checkeffect(tn, e::SetAttrVertex, ::DontDelegate)
    hasvertex(tn, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))
end

handle!(tn, e::SetAttrVertex) = handle!(tn, e, delegates(Attributeable(), tn))
handle!(tn, e::SetAttrVertex, ::DelegateTo) = handle!(delegate(Attributeable(), tn), e)
handle!(_, e::SetAttrVertex, ::DontDelegate) = nothing

## `setattr_edge!`
function setattr_edge!(tn, edge, key, value)
    checkeffect(tn, SetAttrEdge(edge, key, value))
    setattr_edge_inner!(tn, edge, key, value)
    handle!(tn, SetAttrEdge(edge, key, value))
    return tn
end

checkeffect(tn, e::SetAttrEdge) = checkeffect(tn, e, delegates(Attributeable(), tn))
checkeffect(tn, e::SetAttrEdge, ::DelegateTo) = checkeffect(delegate(Attributeable(), tn), e)
function checkeffect(tn, e::SetAttrEdge, ::DontDelegate)
    hasedge(tn, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))
end

handle!(tn, e::SetAttrEdge) = handle!(tn, e, delegates(Attributeable(), tn))
handle!(tn, e::SetAttrEdge, ::DelegateTo) = handle!(delegate(Attributeable(), tn), e)
handle!(_, e::SetAttrEdge, ::DontDelegate) = nothing
