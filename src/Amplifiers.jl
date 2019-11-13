module Amplifiers

using ..Microwaves.Networks: Network, SParameters

"""
    Γ_in(net::Network, Γ_L::Vector{Complex})

Returns the input reflection coefficient of a two-port network with
a reflection coefficient `Γ_L` appearing looking out of port 2.
"""
function Γ_in(net::Network, Γ_L::Vector{Complex})
    sparams = SParameters(net)
    sparams.s[:,1,1] .+ (sparams.s[:,1,2] .* sparams.s[:,2,1] .* Γ_L) ./ (1 .- sparams.s[:,2,2] .* Γ_L)
end

"""
    Γ_out(net::Network, Γ_S::Vector{Complex})

Returns the output (port 2) reflection coefficient of a two-port network
with a reflection coefficient `Γ_S` appearing looking out of port 1.
"""
function Γ_out(net::Network, Γ_S::Vector{Complex})
    sparams = SParameters(net)
    sparams.s[:,2,2] .+ (sparams.s[:,1,2] .* sparams.s[:,2,1] .* Γ_S) ./ (1 .- sparams.s[:,1,1] .* Γ_S)
end

"""
    power_gain(net::Network, Γ_L::Vector{Complex})

Returns the power gain of a two port network with a reflection coefficient `Γ_L`
appearing looking out of port 2.
"""
function power_gain(net::Network, Γ_L::Vector{Complex})
    s = SParameters(net)
    num = abs.(s.s[:,2,1]).^2 .* (1 .- abs.(Γ_L).^2)
    den = (1 .- abs.(Γ_in(s, Γ_L)).^2) .* abs.(1 .- s.s[:,2,2] .* Γ_L).^2
    num ./ den
end

"""
    available_power_gain(net::Network, Γ_S::Vector{Complex})

Returns the available power gain of a two port network with a reflection
coefficient `Γ_S` appearing looking out of port 1.
"""
function available_power_gain(net::Network, Γ_S::Vector{Complex})
    s = SParameters(net)
    num = abs.(s.s[:,2,1]).^2 .* (1 .- abs.(Γ_S).^2)
    den = abs.(1 .- s.s[:,1,1] .* Γ_S).^2 .* (1 .- Γ_out(s, Γ_S).^2)
    num ./ den
end

"""
    transducer_power_gain(net::Network, Γ_S::Vector{Complex}, Γ_L::Vector{Complex})

Returns the transducer power gain of a two port network with a reflection
coefficient `Γ_S` appearing looking out of port 1 and a reflection coefficient
`Γ_L` appearing looking out of port 2.
"""
function transducer_power_gain(net::Network, Γ_S::Vector{Complex}, Γ_L::Vector{Complex})
    s = SParameters(net)
    num = abs.(s.s[:,2,1]).^2 .* (1 .- abs.(Γ_S).^2) .* (1 .- abs.(Γ_L).^2)
    den = abs.(1 .- Γ_S .* Γ_in(s, Γ_L)).^2 .* abs(1 .- s.s[:,2,2] .* Γ_L).^2
    num ./ den
end

"""
    μ_test(net::Network[, retmu=false])

Performs the μ-test for unconditional stability of a two-port network `net`.

A network is unconditionally stable if μ > 1, and larger values of μ correspond
to greater stability.

Returns true if the network is unconditionally stable at all frequencies that
network parameters have been specified for.

If `retmu` is set to true, the calculated μ vector will be returned as well.
"""
function μ_test(net::Network; retmu=false)
    s = SParameters(net)
    Δ = s.s[:,1,1] .* s.s[:,2,2] .- s.s[:,1,2] .* s.s[:,2,1]
    μ = (1 .- abs.(s.s[:,1,1]).^2) ./ (abs.(s.s[:,2,2] .- Δ .* conj.(s.s[:,1,1])) .+
                                       abs.(s.s[:,1,2] .* s.s[:,2,1]))
    result = true
    for muval=μ
        if muval <= 1
            result = false
        end
    end
    if retmu
        return result, μ
    end
    result
end

end # module
