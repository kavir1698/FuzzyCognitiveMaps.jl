@testset "Utility Functions Tests" begin
    concepts = ["A", "B", "C"]
    weights = [0.0 0.5 0.3; -0.2 0.0 0.4; 0.6 -0.3 0.0]
    initial_state = [0.5, 0.6, 0.7]
    fcm = create_fcm(concepts, weights, sigmoid, initial_state, track_history=true)

    # Test get_concept_value
    @test get_concept_value(fcm, "A") ≈ Float16(0.5)
    @test get_concept_value(fcm, "B") ≈ Float16(0.6)

    # Test set_weight!
    set_weight!(fcm, "A", "B", 0.8)
    @test fcm.weights[1, 2] ≈ Float16(0.8)
    @test_throws ErrorException set_weight!(fcm, "A", "B", 1.5)

    # Test set_state!
    set_state!(fcm, "A", 0.3)
    @test get_concept_value(fcm, "A") ≈ Float16(0.3)

    # Test history tracking
    update!(fcm)
    @test length(get_history(fcm)) == 2
    @test length(get_convergence_history(fcm)) == 1
end
