module FuzzyCognitiveMaps

using Statistics
using LinearAlgebra
using CSV
using DataFrames

include("types.jl")
include("activation_functions.jl")
include("validation.jl")
include("core.jl")
include("io.jl")
include("utils.jl")
include("uml_generator.jl")
include("expert_knowledge.jl")
include("hebbian_learning.jl")
include("analysis.jl")

export FuzzyCognitiveMap
export sigmoid, tanh_activation, linear, triangular
export create_fcm, update!, run!
export get_concept_value, set_weight!, set_state!
export get_history, get_convergence_history
export UMLGenerator
export ExpertKnowledge
export train_hebbian!, train_oja!, train_generalized_hebbian!
export Analysis

end # module