struct Taggable <: Interface end

# traits
# WARN experimental
abstract type TagKind end
struct VertexTagKind <: TagKind end
struct EdgeTagKind <: TagKind end

function tag_kind end
tag_kind(_::T) where {T} = tag_kind(T)

# TODO is this correct?
tag_kind(::Type{<:AbstractVertex}) = VertexTagKind()
tag_kind(::Type{<:AbstractEdge}) = EdgeTagKind()

# dispatching methods
# WARN experimental
function tags end
function tag end
function hastag end
function tag_at end
function replace_tag! end

# query methods
function vertex_tags end
function edge_tags end

function has_vertex_tag end
function has_edge_tag end

function vertex_at end
function edge_at end

function tag_at_vertex end
function tag_at_edge end

# mutating methods
function tag_vertex! end
function tag_vertex_inner! end

function tag_edge! end
function tag_edge_inner! end

function untag_vertex! end
function untag_vertex_inner! end

function untag_edge! end
function untag_edge_inner! end

function replace_vertex_tag! end
function replace_vertex_tag_inner! end

function replace_edge_tag! end
function replace_edge_tag_inner! end

# effects
"""
    TagVertexEffect{Tag,Vertex} <: Effect

Represents the effect of setting a tag on a vertex.
"""
struct TagVertexEffect{T,V} <: Effect
    tag::T
    obj::V
end

"""
    TagEdgeEffect{Tag,Edge} <: Effect

Represents the effect of setting a tag on an edge.
"""
struct TagEdgeEffect{T,E} <: Effect
    tag::T
    obj::E
end

const TagEffect{T,O} = Union{TagVertexEffect{T,O},TagEdgeEffect{T,O}}

"""
    UntagVertexEffect{Tag} <: Effect

Represents the effect of removing a tag from a vertex.
"""
struct UntagVertexEffect{T} <: Effect
    tag::T
end

"""
    UntagEdgeEffect{Tag} <: Effect

Represents the effect of removing a tag from an edge.
"""
struct UntagEdgeEffect{T} <: Effect
    tag::T
end

const UntagEffect{T} = Union{UntagVertexEffect{T},UntagEdgeEffect{T}}

"""
    ReplaceVertexTagEffect{New,Old} <: Effect

Represents the effect of replacing a vertex tag `Old` with a new tag `New`.
"""
struct ReplaceVertexTagEffect{New,Old} <: Effect
    new::New
    old::Old
end

"""
    ReplaceEdgeTagEffect{New,Old} <: Effect

Represents the effect of replacing an edge tag `Old` with a new tag `New`.
"""
struct ReplaceEdgeTagEffect{New,Old} <: Effect
    new::New
    old::Old
end

const ReplaceTagEffect{New,Old} = Union{ReplaceVertexTagEffect{New,Old},ReplaceEdgeTagEffect{New,Old}}

# implementation
## TODO `tags`
## TODO `tag`

## `hastag`
hastag(graph, tag) = hastag(graph, tag, TagKind(tag))
hastag(graph, tag, ::VertexTagKind) = has_vertex_tag(graph, tag)
hastag(graph, tag, ::EdgeTagKind) = has_edge_tag(graph, tag)

## `tag_at`
### TODO add methods based on trait instead of abstract type?
tag_at(graph, v::AbstractVertex) = tag_at_vertex(graph, v)
tag_at(graph, e::AbstractEdge) = tag_at_edge(graph, e)

## `replace_tag!`
replace_tag!(graph, old, new) = replace_tag!(graph, old, new, TagKind(old), TagKind(new))
replace_tag!(graph, old, new, ::VertexTagKind, ::VertexTagKind) = replace_vertex_tag!(graph, old, new)
replace_tag!(graph, old, new, ::EdgeTagKind, ::EdgeTagKind) = replace_edge_tag!(graph, old, new)
replace_tag!(graph, old, new, ::TagKind, ::TagKind) = throw(MethodError(replace_tag!, (graph, old, new)))

## `vertex_tags`
vertex_tags(graph) = vertex_tags(graph, DelegatorTrait(Taggable(), graph))
vertex_tags(graph, ::DelegateTo) = vertex_tags(delegator(Taggable(), graph))
vertex_tags(graph, ::DontDelegate) = throw(MethodError(vertex_tags, (graph,)))

## `edge_tags`
edge_tags(graph) = edge_tags(graph, DelegatorTrait(Taggable(), graph))
edge_tags(graph, ::DelegateTo) = edge_tags(delegator(Taggable(), graph))
edge_tags(graph, ::DontDelegate) = throw(MethodError(edge_tags, (graph,)))

## `has_vertex_tag`
has_vertex_tag(graph, tag) = has_vertex_tag(graph, tag, DelegatorTrait(Taggable(), graph))
has_vertex_tag(graph, tag, ::DelegateTo) = has_vertex_tag(delegator(Taggable(), graph), tag)
has_vertex_tag(graph, tag, ::DontDelegate) = throw(MethodError(has_vertex_tag, (graph, tag)))

## `has_edge_tag`
has_edge_tag(graph, tag) = has_edge_tag(graph, tag, DelegatorTrait(Taggable(), graph))
has_edge_tag(graph, tag, ::DelegateTo) = has_edge_tag(delegator(Taggable(), graph), tag)
has_edge_tag(graph, tag, ::DontDelegate) = throw(MethodError(has_edge_tag, (graph, tag)))

## `vertex_at`
vertex_at(graph, tag) = vertex_at(graph, tag, DelegatorTrait(Taggable(), graph))
vertex_at(graph, tag, ::DelegateTo) = vertex_at(delegator(Taggable(), graph), tag)
vertex_at(graph, tag, ::DontDelegate) = throw(MethodError(vertex_at, (graph, tag)))

## `edge_at`
edge_at(graph, tag) = edge_at(graph, tag, DelegatorTrait(Taggable(), graph))
edge_at(graph, tag, ::DelegateTo) = edge_at(delegator(Taggable(), graph), tag)
edge_at(graph, tag, ::DontDelegate) = throw(MethodError(edge_at, (graph, tag)))

## `tag_at_vertex`
tag_at_vertex(graph, vertex) = vertex_at_vertex(graph, vertex, DelegatorTrait(Taggable(), graph))
tag_at_vertex(graph, vertex, ::DelegateTo) = tag_at_vertex(delegator(Taggable(), graph), vertex)
tag_at_vertex(graph, vertex, ::DontDelegate) = throw(MethodError(tag_at_vertex, (graph, vertex)))

## `tag_at_edge`
tag_at_edge(graph, edge) = vertex_at_vertex(graph, edge, DelegatorTrait(Taggable(), graph))
tag_at_edge(graph, edge, ::DelegateTo) = tag_at_edge(delegator(Taggable(), graph), edge)
tag_at_edge(graph, edge, ::DontDelegate) = throw(MethodError(tag_at_edge, (graph, edge)))

## `tag_vertex!`
function tag_vertex!(graph, vertex, tag)
    checkeffect(graph, TagVertexEffect(tag, vertex))
    tag_vertex_inner!(graph, vertex, tag)
    handle!(graph, TagVertexEffect(tag, vertex))
    return graph
end

## `tag_vertex_inner!`
tag_vertex_inner!(graph, vertex, tag) = tag_vertex_inner!(graph, vertex, tag, DelegatorTrait(Taggable(), graph))
tag_vertex_inner!(graph, vertex, tag, ::DelegateTo) = tag_vertex_inner!(delegator(Taggable(), graph), vertex, tag)
tag_vertex_inner!(graph, vertex, tag, ::DontDelegate) = throw(MethodError(tag_vertex_inner!, (graph, vertex, tag)))

## `tag_edge!`
function tag_edge!(graph, edge, tag)
    checkeffect(graph, TagEdgeEffect(tag, edge))
    tag_edge_inner!(graph, edge, tag)
    handle!(graph, TagEdgeEffect(tag, edge))
    return graph
end

## `tag_edge_inner!`
tag_edge_inner!(graph, edge, tag) = tag_edge_inner!(graph, edge, tag, DelegatorTrait(Taggable(), graph))
tag_edge_inner!(graph, edge, tag, ::DelegateTo) = tag_edge_inner!(delegator(Taggable(), graph), edge, tag)
tag_edge_inner!(graph, edge, tag, ::DontDelegate) = throw(MethodError(tag_edge_inner!, (graph, edge, tag)))

## `untag_vertex!`
function untag_vertex!(graph, tag)
    checkeffect(graph, UntagVertexEffect(tag))
    untag_vertex_inner!(graph, tag)
    handle!(graph, UntagVertexEffect(tag))
    return graph
end

## `untag_vertex_inner!`
untag_vertex_inner!(graph, tag) = untag_vertex_inner!(graph, tag, DelegatorTrait(Taggable(), graph))
untag_vertex_inner!(graph, tag, ::DelegateTo) = untag_vertex_inner!(delegator(Taggable(), graph), tag)
untag_vertex_inner!(graph, tag, ::DontDelegate) = throw(MethodError(untag_vertex_inner!, (graph, tag)))

## `untag_edge!`
function untag_edge!(graph, tag)
    checkeffect(graph, UntagEdgeEffect(tag))
    untag_edge_inner!(graph, tag)
    handle!(graph, UntagEdgeEffect(tag))
    return graph
end

## `untag_edge_inner!`
untag_edge_inner!(graph, tag) = untag_edge_inner!(graph, tag, DelegatorTrait(Taggable(), graph))
untag_edge_inner!(graph, tag, ::DelegateTo) = untag_edge_inner!(delegator(Taggable(), graph), tag)
untag_edge_inner!(graph, tag, ::DontDelegate) = throw(MethodError(untag_edge_inner!, (graph, tag)))

## `replace_vertex_tag!`
function replace_vertex_tag!(graph, old, new)
    checkeffect(graph, ReplaceVertexTagEffect(new, old))
    replace_vertex_tag_inner!(graph, old, new)
    handle!(graph, ReplaceVertexTagEffect(new, old))
    return graph
end

## `replace_vertex_tag_inner!`
function replace_vertex_tag_inner!(graph, old, new)
    replace_vertex_tag_inner!(graph, old, new, DelegatorTrait(Taggable(), graph))
end

function replace_vertex_tag_inner!(graph, old, new, ::DelegateTo)
    replace_vertex_tag_inner!(delegator(Taggable(), graph), old, new)
end

function replace_vertex_tag_inner!(graph, old, new, ::DontDelegate)
    throw(MethodError(replace_vertex_tag_inner!, (graph, old, new)))
end

## `replace_edge_tag!`
function replace_edge_tag!(graph, old, new)
    checkeffect(graph, ReplaceEdgeTagEffect(new, old))
    replace_edge_tag_inner!(graph, old, new)
    handle!(graph, ReplaceEdgeTagEffect(new, old))
    return graph
end

## `replace_edge_tag_inner!`
function replace_edge_tag_inner!(graph, old, new)
    replace_edge_tag_inner!(graph, old, new, DelegatorTrait(Taggable(), graph))
end

function replace_edge_tag_inner!(graph, old, new, ::DelegateTo)
    replace_edge_tag_inner!(delegator(Taggable(), graph), old, new)
end

function replace_edge_tag_inner!(graph, old, new, ::DontDelegate)
    throw(MethodError(replace_edge_tag_inner!, (graph, old, new)))
end
