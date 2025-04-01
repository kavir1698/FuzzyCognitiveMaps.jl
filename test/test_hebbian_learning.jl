@testset "Hebbian Learning" begin
    # Create a simple test FCM
    concepts = ["A", "B", "C"]
    weights = [0.0 0.3 -0.2;
              0.4 0.0 0.1;
              -0.3 0.2 0.0]
    initial_state = [0.5, 0.6, 0.4]

    @testset "Basic Hebbian Learning" begin
        fcm = create_fcm(concepts, weights, sigmoid, initial_state)
        old_weights = deepcopy(fcm.weights)

        train_hebbian!(fcm, 0.1, 5)

        # Test weight changes
        @test fcm.weights != old_weights
        @test all(FuzzyCognitiveMaps.diag(fcm.weights) .== 0)  # Diagonal should remain zero
        @test all(-1 .<= fcm.weights .<= 1)  # Weights should stay in range
    end

    @testset "Oja's Rule" begin
        fcm = create_fcm(concepts, weights, sigmoid, initial_state)
        old_weights = deepcopy(fcm.weights)

        train_oja!(fcm, 0.1, 5)

        @test fcm.weights != old_weights
        @test all(FuzzyCognitiveMaps.diag(fcm.weights) .== 0)
        @test all(-1 .<= fcm.weights .<= 1)
    end

    @testset "Generalized Hebbian" begin
        fcm = create_fcm(concepts, weights, sigmoid, initial_state)
        old_weights = deepcopy(fcm.weights)

        train_generalized_hebbian!(fcm, 0.1, 0.05, 5)

        @test fcm.weights != old_weights
        @test all(FuzzyCognitiveMaps.diag(fcm.weights) .== 0)
        @test all(-1 .<= fcm.weights .<= 1)

        # Test with different decay rates
        fcm2 = create_fcm(concepts, weights, sigmoid, initial_state)
        train_generalized_hebbian!(fcm2, 0.1, 0.2, 5)
        @test fcm.weights != fcm2.weights  # Different decay should give different results
    end
end
