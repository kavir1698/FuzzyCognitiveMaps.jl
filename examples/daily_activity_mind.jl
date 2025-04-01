using FuzzyCognitiveMaps

function create_daily_activity_mind()
    fcm_file = "daily_activity_mind.csv"
    return create_fcm(csv_file=fcm_file, track_history=false, activation=tanh_activation)
end

function demonstrate_daily_activity_mind()
    mind = create_daily_activity_mind()
    println("=== Morning Rush Hour Scenario ===")

    # Set morning conditions
    set_state!(mind, "time_morning", 1.0)
    set_state!(mind, "time_evening", 0.0)
    set_state!(mind, "traffic_congestion", 0.7)
    set_state!(mind, "bad_weather", 0.1)

    run!(mind, 10)
    println("\nDecision state after morning rush hour:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $(round(value, digits=3))")
    end

    println("\n=== Evening Bad Weather Scenario ===")

    # Reset and set evening conditions
    set_state!(mind, "time_morning", 0.0)
    set_state!(mind, "time_evening", 1.0)
    set_state!(mind, "traffic_congestion", -0.5)
    set_state!(mind, "bad_weather", 0.3)

    run!(mind, 10)
    println("\nDecision state after evening scenario:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $(round(value, digits=3))")
    end
end

# Run demonstration
demonstrate_daily_activity_mind()
