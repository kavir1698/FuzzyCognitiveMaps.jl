"""
FuzzyCognitiveMap type definition
"""
mutable struct FuzzyCognitiveMap
    concepts::Vector{String}
    concept_indices::Dict{String, Int}
    weights::Matrix{Float16}
    activation::Function
    state::Vector{Float16}
    history::Vector{Vector{Float16}}
    track_history::Bool
    external_concepts::Vector{Bool}
end
