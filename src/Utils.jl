function hist(x; init=Dict{eltype(x),Int}())
    for xi in x
        if haskey(init, xi)
            init[xi] += 1
        else
            init[xi] = 1
        end
    end
    return init
end

# from https://discourse.julialang.org/t/sort-keys-of-namedtuple/94630/3
@generated sort_nt(nt::NamedTuple{KS}) where {KS} = :(NamedTuple{$(Tuple(sort(collect(KS))))}(nt))
sort_nt(nt::@NamedTuple{}) = nt
