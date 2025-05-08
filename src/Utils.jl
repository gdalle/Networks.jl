fallback(f) = @debug "Falling back to default method" f

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
