@testset "IO Tests" begin
    # Test creating FCM from CSV
    test_csv = joinpath(@__DIR__, "test_data", "test_fcm.csv")
    mkpath(dirname(test_csv))

    # Create test CSV
    open(test_csv, "w") do f
        write(f, """Concepts,A,B,C,external
                   A,0,0.5,0.3,false
                   B,-0.2,0,0.4,true
                   C,0.6,-0.3,0,false""")
    end

    # Test loading from CSV
    concepts, weights, external = FuzzyCognitiveMaps.load_fcm_from_csv(test_csv)
    @test concepts == ["A", "B", "C"]
    @test weights ≈ [0.0 0.5 0.3; -0.2 0.0 0.4; 0.6 -0.3 0.0]
    @test external == [false, true, false]

    # Test creating FCM from CSV
    fcm = create_fcm(csv_file=test_csv, activation=sigmoid)
    @test length(fcm.concepts) == 3
    @test size(fcm.weights) == (3, 3)
    @test fcm.external_concepts == [false, true, false]

    # Cleanup
    rm(test_csv)
    rm(dirname(test_csv))
end
