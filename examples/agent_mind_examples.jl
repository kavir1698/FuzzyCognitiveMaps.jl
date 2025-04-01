using FuzzyCognitiveMaps

# Example 1: Predator Agent Mind
# Concepts: hunger, prey_presence, fear, attack_motivation, flee_motivation
function create_predator_mind()
    concepts = ["hunger", "prey_presence", "fear", "attack_motivation", "flee_motivation"]

    # Define relationships between concepts
    weights = Float64[
        # hunger prey  fear  attack flee
        0.0    0.0    0.2   0.6   -0.2;  # hunger affects fear(+), attack(+), flee(-)
        0.0    0.0    0.3   0.7    0.0;  # prey affects fear(+), attack(+)
        0.0   -0.2    0.0  -0.8    0.9;  # fear reduces prey detection(-), attack(-), increases flee(+)
        0.0    0.0   -0.3   0.0   -0.5;  # attack reduces fear(-), flee(-)
        0.0    0.0    0.2  -0.4    0.0   # flee increases fear(+), reduces attack(-)
    ]

    # Initial state: moderately hungry, no prey, no fear
    initial_state = [0.5, 0.0, 0.0, 0.0, 0.0]

    return create_fcm(concepts, weights, sigmoid, initial_state, track_history=true)
end

# Example 2: Social Agent Mind
# Concepts: social_need, friendship, loneliness, approach_others, stay_alone
function create_social_mind()
    concepts = ["social_need", "friendship", "loneliness", "approach_others", "stay_alone"]

    weights = Float64[
        # social friend lone  appr  stay
        0.0    0.2    0.6   0.7  -0.4;  # social_need increases friendship, loneliness, approach, reduces stay_alone
        0.3   0.0   -0.8   0.4  -0.6;  # friendship reduces loneliness, increases approach, reduces stay_alone
        0.4  -0.3    0.0   0.6   0.4;  # loneliness affects everything
        0.2   0.5   -0.4   0.0  -0.7;  # approach_others builds friendship, reduces loneliness and stay_alone
        -0.3  -0.4   0.5  -0.6   0.0   # stay_alone reduces social activity, increases loneliness
    ]

    initial_state = [0.3, 0.2, 0.4, 0.0, 0.0]

    return create_fcm(concepts, weights, sigmoid, initial_state, track_history=true)
end

# Usage examples
function demonstrate_predator_mind()
    println("=== Predator Agent Mind Demonstration ===")
    mind = create_predator_mind()

    println("Initial state:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end

    # Simulate detecting prey
    println("\nSetting prey presence to 0.8...")
    set_state!(mind, "prey_presence", 0.8)
    println("\nImmediate state after prey detection:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end

    run!(mind, 5)
    println("\nState after 5 iterations:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end

    # Introduce fear
    println("\nSetting fear to 0.7...")
    set_state!(mind, "fear", 0.7)
    println("\nImmediate state after fear increase:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end

    run!(mind, 5)
    println("\nState after 5 more iterations:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end
end

function demonstrate_social_mind()
    println("\n=== Social Agent Mind Demonstration ===")
    mind = create_social_mind()

    println("Initial state:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end

    # Simulate increasing loneliness
    set_state!(mind, "loneliness", 0.8)
    run!(mind, 5)

    println("\nAfter increased loneliness to 0.8:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end

    # Simulate making friends
    set_state!(mind, "friendship", 0.7)
    run!(mind, 5)

    println("\nAfter making friends to 0.7:")
    for (concept, value) in zip(mind.concepts, mind.state)
        println("$concept: $value")
    end
end

# Run demonstrations
demonstrate_predator_mind()
demonstrate_social_mind()
