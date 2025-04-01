@testset "Core FuzzyCognitiveMaps Operations" begin
    concepts = ["A", "B", "C"]
    weights = [0.0 0.5 -0.3; -0.2 0.0 0.4; 0.1 -0.4 0.0]
    initial_state = [0.5, 0.2, 0.3]

    @testset "FCM Creation" begin
        fcm = create_fcm(concepts, weights, sigmoid, initial_state)
        @test fcm.concepts == concepts
        @test fcm.weights ≈ Float16.(weights)
        @test fcm.state ≈ initial_state
    end

    @testset "FCM Update" begin
        fcm = create_fcm(concepts, weights, sigmoid, initial_state, track_history=true)
        update!(fcm)
        @test length(fcm.history) == 2
        @test fcm.state != initial_state
    end

    @testset "FCM Run" begin
        fcm = create_fcm(concepts, weights, sigmoid, initial_state, track_history=true)
        final_state = run!(fcm, 10)
        @test length(fcm.history) > 1
    end
end
