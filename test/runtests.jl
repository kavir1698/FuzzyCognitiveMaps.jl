using FuzzyCognitiveMaps
using FuzzyCognitiveMaps.ExpertKnowledge
using FuzzyCognitiveMaps.HebbianLearning
using Test

@testset "FuzzyCognitiveMaps.jl" begin
    include("test_types.jl")
    include("test_validation.jl")
    include("test_core.jl")
    include("test_io.jl")
    include("test_utils.jl")
    include("test_expert_knowledge.jl")
    include("test_hebbian_learning.jl")
end
