abstract type Interface end

abstract type DelegatorTrait end
struct DontDelegate <: DelegatorTrait end
struct DelegateTo{T} <: DelegatorTrait end

# by default, don't delegate
DelegatorTrait(interface, x) = DontDelegate()

delegator(interface, x) = delegator(interface, x, DelegatorTrait(x))
delegator(interface, x, ::DontDelegate) = throw(ArgumentError("Cannot delegate to $interface"))
delegator(interface, x, ::DelegateTo{P}) where {P} = getproperty(x, P)

abstract type ImplementorTrait end
struct Implements <: ImplementorTrait end
struct NotImplements <: ImplementorTrait end

function ImplementorTrait(interface, x)
    # recurse check to delegator
    if DelegatorTrait(interface, x) isa DelegateTo
        return ImplementorTrait(interface, delegator(interface, x))
    else
        return NotImplements()
    end
end

"""
    Effect

Abstract type for effects.
"""
abstract type Effect end

function checkeffect end

"""
    handle!(x, effect::Effect)

Handle the `effect` on `x`. By default, does nothing.
"""
function handle! end
