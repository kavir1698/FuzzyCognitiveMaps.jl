@testset "Types" begin
    concepts = ["A", "B", "C"]
    weights = Float16[0 0.5 -0.3; -0.2 0 0.4; 0.1 -0.4 0]
    activation = sigmoid
    state = Float16[0.5, 0.2, 0.3]

    fcm = FuzzyCognitiveMap(
        concepts,
        Dict(c => i for (i, c) in enumerate(concepts)),
        weights,
        activation,
        state,
        Vector{Float16}[],
        false,
        falses(3)
    )

    @test fcm.concepts == concepts
    @test fcm.weights == weights
    @test fcm.state == state
    @test fcm.activation == activation
end
