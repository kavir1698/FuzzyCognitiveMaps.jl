@testset "Expert Knowledge Integration" begin
    @testset "Linguistic Term Conversion" begin
        # Test standard terms conversion
        @test isapprox(convert_linguistic_to_weight("very_positive"), 0.84434, atol=0.0001)
        @test isapprox(convert_linguistic_to_weight("positive"), 0.5, atol=0.0001)
        @test isapprox(convert_linguistic_to_weight("none"), 0.0, atol=0.0001)
        @test isapprox(convert_linguistic_to_weight("negative"), -0.5, atol=0.0001)
        @test isapprox(convert_linguistic_to_weight("very_negative"), -0.8443, atol=0.0001)

        # Test custom linguistic term
        custom_term = LinguisticTerm("custom", (-0.5, -0.3, 0.3, 0.5))
        @test isapprox(convert_linguistic_to_weight(custom_term), 0.0, atol=0.0001)

        # Test invalid term
        @test_throws ArgumentError convert_linguistic_to_weight("invalid_term")
    end

    @testset "Expert Opinion Combination" begin
        expert1 = ["none" "positive" "negative";
                  "very_positive" "none" "slightly_negative";
                  "negative" "positive" "none"]

        expert2 = ["none" "very_positive" "negative";
                  "positive" "none" "negative";
                  "slightly_negative" "positive" "none"]

        # Test equal weights combination
        combined = combine_expert_opinions([expert1, expert2])
        @test size(combined) == (3, 3)

        # Test some combined values with equal weights
        expected_val = (convert_linguistic_to_weight("positive") +
                       convert_linguistic_to_weight("very_positive")) / 2
        @test isapprox(combined[1,2], expected_val, atol=0.0001)

        # Test entropy-weighted combination
        combined_weighted = combine_expert_opinions([expert1, expert2], weight_by_entropy=true)
        @test size(combined_weighted) == (3, 3)
        @test all(-1 .<= combined_weighted .<= 1)

        # Test agreement degree
        agreement = calculate_agreement_degree([expert1, expert2])
        @test size(agreement) == (3, 3)
        @test all(0 .<= agreement .<= 1)

        # Test error for mismatched dimensions
        expert3 = ["none" "positive";
                  "negative" "none"]
        @test_throws ArgumentError combine_expert_opinions([expert1, expert3])
    end

    @testset "Membership Functions" begin
        # Test membership function generation
        term = LinguisticTerm("test", (-0.5, -0.2, 0.2, 0.5))

        # Test membership values at key points
        @test isapprox(get_membership_value(term, -0.6), 0.0, atol=0.0001)  # Below support
        @test isapprox(get_membership_value(term, -0.35), 0.5, atol=0.0001)  # Rising edge
        @test isapprox(get_membership_value(term, 0.0), 1.0, atol=0.0001)  # Core region
        @test isapprox(get_membership_value(term, 0.35), 0.5, atol=0.0001)  # Falling edge
        @test isapprox(get_membership_value(term, 0.6), 0.0, atol=0.0001)  # Above support

        # Test plot data generation
        x, y = generate_membership_plot_data(term, 5)
        @test length(x) == 5
        @test length(y) == 5
        @test all(0 .<= y .<= 1)

        # Test fuzzy operations
        @test isapprox(fuzzy_and(0.3, 0.7), 0.3, atol=0.0001)
        @test isapprox(fuzzy_or(0.3, 0.7), 0.7, atol=0.0001)
    end

    @testset "Expert Opinion Analysis" begin
        expert1 = ["none" "positive" "negative";
                  "very_positive" "none" "slightly_negative";
                  "negative" "positive" "none"]

        expert2 = ["none" "very_positive" "negative";
                  "positive" "none" "negative";
                  "slightly_negative" "positive" "none"]

        # Test entropy calculation
        entropy = calculate_expert_entropy([expert1, expert2])
        @test length(entropy) == 2
        @test all(0 .<= entropy .<= 1)  # Entropy should be between 0 and 1

        # Test agreement degree
        agreement = calculate_agreement_degree([expert1, expert2])
        @test size(agreement) == (3, 3)
        @test all(0 .<= agreement .<= 1)

        # Test enhanced combine_expert_opinions
        combined_op = combine_expert_opinions([expert1, expert2],
                                                weight_by_entropy=true)
        @test size(combined_op) == (3, 3)
        @test all(-1 .<= combined_op .<= 1)
    end
end
