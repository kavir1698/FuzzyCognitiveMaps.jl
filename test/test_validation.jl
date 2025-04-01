
@testset "Validation" begin
    concepts = ["A", "B", "C"]
    valid_weights = [0.0 0.5 -0.3; -0.2 0.0 0.4; 0.1 -0.4 0.0]
    valid_state = [0.5, 0.2, 0.3]

    @test_nowarn FuzzyCognitiveMaps.validate_fcm_inputs(concepts, valid_weights, valid_state)

    @test_warn "Found completely isolated concepts" FuzzyCognitiveMaps.validate_fcm_inputs(
        concepts, zeros(3, 3), valid_state)  # isolated nodes

    @test_throws ErrorException FuzzyCognitiveMaps.validate_fcm_inputs(
        concepts, ones(3, 3), valid_state)  # diagonal not zero

    @test_throws ErrorException FuzzyCognitiveMaps.validate_fcm_inputs(
        concepts, valid_weights, [0.5, 0.2])  # wrong state length
end
