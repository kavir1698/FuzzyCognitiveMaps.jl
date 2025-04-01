# FuzzyCognitiveMaps.jl

A Julia package for Fuzzy Cognitive Maps (FCM) simulation and analysis.

## Installation

```julia
using Pkg
Pkg.add("FuzzyCognitiveMaps")
```

## Basic Usage

```julia
using FuzzyCognitiveMaps

# Create a simple FCM with two concepts
concepts = ["A", "B"]
weights = [0.0 -0.3;
          0.5  0.0]  # A affects B (0.5), B affects A (-0.3)
initial_state = [1.0, 0.0]

# Create FCM with sigmoid activation
fcm = create_fcm(
    concepts=concepts,
    weights=weights,
    activation=sigmoid,
    initial_state=initial_state
)

# Run simulation for 10 iterations
run!(fcm, 10)

# Get final state
println("Final state: ", fcm.state)
```

## Loading from CSV

Create a CSV file with your FCM configuration:

```csv
concept,A,B,external
A,0,-0.3,false
B,0.5,0,false
```

Then load it:

```julia
fcm = create_fcm(
    csv_file="path/to/your/fcm.csv",
    activation=sigmoid
)
```

## Features

- Multiple activation functions: `sigmoid`, `tanh_activation`, `linear`
- State history tracking
- External/fixed concepts support
- CSV file loading
- Convergence detection

## Advanced Usage

### Tracking History

```julia
# Create FCM with history tracking
fcm = create_fcm(
    concepts=concepts,
    weights=weights,
    activation=sigmoid,
    initial_state=initial_state,
    track_history=true
)

run!(fcm, 10)

# Get state history
history = get_history(fcm)
convergence = get_convergence_history(fcm)
```

### Working with External Concepts

External concepts maintain their values during simulation:

```julia
# Mark concept A as external
external = [true, false]  # A is external, B is not

fcm = create_fcm(
    concepts=concepts,
    weights=weights,
    activation=sigmoid,
    initial_state=initial_state,
    external_concepts=external
)
```

### Modifying FCM at Runtime

```julia
# Change concept states
set_state!(fcm, "A", 0.8)

# Modify weights
set_weight!(fcm, "A", "B", 0.7)

# Get specific concept value
value = get_concept_value(fcm, "A")
```

### Generating UML Diagrams

You can generate PlantUML diagrams to visualize your FCM structure:

```julia
using FuzzyCognitiveMaps.UMLGenerator

# Generate and save UML diagram from CSV
save_uml("path/to/your/fcm.csv", "fcm_diagram.puml")
```

The generated diagram will show:
- Concepts as rectangles (external concepts in blue)
- Relationships as arrows with:
  - Green arrows for positive weights
  - Red arrows for negative weights
  - Line thickness proportional to weight magnitude
  - Weight values displayed on connections

## Expert Knowledge Integration

FuzzyCognitiveMaps.jl supports converting qualitative expert knowledge into FCM weights using fuzzy logic. This feature allows domain experts to express causal relationships using linguistic terms instead of precise numerical values.

### Available Linguistic Terms

The following standard linguistic terms are available:
- "very_positive" (strong positive influence)
- "positive" (moderate positive influence)
- "slightly_positive" (weak positive influence)
- "none" (no influence)
- "slightly_negative" (weak negative influence)
- "negative" (moderate negative influence)
- "very_negative" (strong negative influence)

### Tutorial: Creating FCM from Expert Knowledge

```julia
using FuzzyCognitiveMaps
using FuzzyCognitiveMaps.ExpertKnowledge

# Example: Creating an emotional state FCM using expert knowledge

# Expert 1's opinion on causal relationships
expert1_opinion = [
    "none"           "positive"        "slightly_negative";
    "very_positive"  "none"           "negative";
    "negative"       "slightly_positive" "none"
]

# Expert 2's opinion
expert2_opinion = [
    "none"           "very_positive"   "negative";
    "positive"       "none"           "slightly_negative";
    "slightly_negative" "positive"     "none"
]

# Combine expert opinions into weights
weights = combine_expert_opinions([expert1_opinion, expert2_opinion])

# Create FCM with the combined weights
concepts = ["happiness", "energy", "stress"]
fcm = create_fcm(
    concepts=concepts,
    weights=weights,
    activation=sigmoid,
    initial_state=[0.5, 0.5, 0.2]
)
```

### Custom Linguistic Terms

You can also define custom linguistic terms:

```julia
# Define a custom linguistic term
extreme_positive = LinguisticTerm("extreme_positive", (0.8, 0.9, 1.0, 1.0))

# Convert it to a weight
weight = convert_linguistic_to_weight(extreme_positive)
```

### Fuzzy Logic Implementation

The package uses trapezoidal membership functions to represent linguistic terms. Each term is defined by four points (a,b,c,d) that determine its fuzzy membership function. The conversion to crisp weights is done using centroid defuzzification.

For example, "positive" is represented as (0.2, 0.4, 0.6, 0.8), meaning:
- Full membership between 0.4 and 0.6
- Linear transition from 0.2 to 0.4 and 0.6 to 0.8
- Zero membership outside [0.2, 0.8]

### Working with Membership Functions

The package provides tools to work with and visualize fuzzy membership functions:

```julia
using FuzzyCognitiveMaps.ExpertKnowledge
using Plots

# Get a standard linguistic term
term = ExpertKnowledge.STANDARD_TERMS["positive"]

# Get membership value at a specific point
value = get_membership_value(term, 0.5)
println("Membership value at 0.5: $value")

# Generate data for plotting
x, y = generate_membership_plot_data(term)
plot(x, y,
     label="positive",
     xlabel="Value",
     ylabel="Membership Degree",
     title="Membership Function")

# Create custom membership function
custom_term = LinguisticTerm("custom", (-0.3, -0.1, 0.1, 0.3))
x2, y2 = generate_membership_plot_data(custom_term)
plot!(x2, y2, label="custom")

# Combine membership functions using fuzzy operations
a = get_membership_value(term, 0.5)
b = get_membership_value(custom_term, 0.5)
println("AND operation: ", fuzzy_and(a, b))
println("OR operation: ", fuzzy_or(a, b))
```

The membership functions are trapezoidal, defined by four points (a,b,c,d):
- Below a or above d: membership = 0
- Between b and c: membership = 1
- Between a and b or c and d: membership varies linearly

You can use these functions to:
- Visualize how linguistic terms map to numeric values
- Create custom fuzzy sets for specific domains
- Combine multiple fuzzy sets using AND/OR operations
- Better understand the defuzzification process

### Advanced Expert Knowledge Features

FuzzyCognitiveMaps.jl provides advanced features for analyzing and combining expert knowledge:

#### Expert Opinion Analysis

```julia
using FuzzyCognitiveMaps.ExpertKnowledge

# Example expert opinions
expert1 = [
    "none" "positive" "negative";
    "very_positive" "none" "slightly_negative";
    "negative" "positive" "none"
]

expert2 = [
    "none" "very_positive" "negative";
    "positive" "none" "negative";
    "slightly_negative" "positive" "none"
]

# Calculate entropy to measure uncertainty/disagreement
entropy = calculate_expert_entropy([expert1, expert2])

# Calculate agreement degree between experts
agreement = calculate_agreement_degree([expert1, expert2])
```

#### Weighted Opinion Combination

The package uses weighted averaging to combine expert opinions:

```julia
# Without entropy weighting (equal weights)
weights_simple = combine_expert_opinions([expert1, expert2],
                                       weight_by_entropy=false)

# With entropy weighting (more weight to consistent experts)
weights_entropy = combine_expert_opinions([expert1, expert2],
                                        weight_by_entropy=true)
```

The `weight_by_entropy` parameter:
- When `true`: Experts whose opinions result in lower entropy (more consistent) get higher weights
- When `false`: All experts are weighted equally

#### Expert Agreement Analysis

You can analyze the level of agreement between experts:

```julia
agreement = calculate_agreement_degree([expert1, expert2])

# Agreement values range from 0 (complete disagreement) to 1 (complete agreement)
println("Average agreement: ", mean(agreement))

# Find relationships with lowest agreement
min_agreement = minimum(agreement)
min_indices = findall(x -> x == min_agreement, agreement)
println("Most disputed relationships: ", min_indices)
```

This can help identify:
- Which relationships have the strongest expert consensus
- Which relationships need further expert consultation
- Overall reliability of the expert knowledge base

## Hebbian Learning

FuzzyCognitiveMaps.jl implements three biologically-inspired learning rules that allow FCMs to adapt their weights based on experience:

### Basic Usage

```julia
using FuzzyCognitiveMaps

# Create a simple FCM
concepts = ["A", "B", "C"]
weights = [0.0 0.3 -0.2;
          0.4 0.0  0.1;
          -0.3 0.2 0.0]
initial_state = [0.5, 0.6, 0.4]

fcm = create_fcm(concepts, weights, sigmoid, initial_state)

# Apply Hebbian learning
train_hebbian!(fcm, 0.01, 10)  # learning_rate = 0.01, iterations = 10
```

### Learning Rules

1. **Basic Hebbian Learning** (`train_hebbian!`)
   - Implements Hebb's rule: "Neurons that fire together, wire together"
   - Updates weights based on correlation between concept activations
   - W(t+1) = W(t) + η * x(t) * x(t)ᵀ

```julia
# Basic Hebbian learning
train_hebbian!(fcm, learning_rate=0.01, iterations=10)
```

2. **Oja's Rule** (`train_oja!`)
   - Extends Hebbian learning with weight normalization
   - Prevents unbounded weight growth
   - W(t+1) = W(t) + η * x(t) * (x(t)ᵀ - W(t)x(t)ᵀ)

```julia
# Oja's learning rule
train_oja!(fcm, learning_rate=0.01, iterations=10)
```

3. **Generalized Hebbian Learning** (`train_generalized_hebbian!`)
   - Combines Hebbian and anti-Hebbian terms
   - Includes weight decay for regularization
   - Allows fine-tuning of learning dynamics

```julia
# Generalized Hebbian learning with decay
train_generalized_hebbian!(fcm,
    learning_rate=0.01,  # Learning rate
    decay=0.1,          # Weight decay term
    iterations=10)      # Number of iterations
```

### Learning Example: Pattern Association

```julia
using FuzzyCognitiveMaps

# Create FCM for learning weather patterns
concepts = ["temperature", "humidity", "clouds", "rain"]
n = length(concepts)
weights = zeros(Float64, n, n)  # Start with no connections
initial_state = [0.0, 0.0, 0.0, 0.0]

fcm = create_fcm(concepts, weights, sigmoid, initial_state)

# Training patterns
patterns = [
    [0.8, 0.7, 0.6, 0.7],  # Hot, humid -> cloudy and rain
    [0.3, 0.2, 0.1, 0.0],  # Cool, dry -> clear
    [0.6, 0.8, 0.9, 0.8],  # Warm, very humid -> very cloudy and rain
]

# Train FCM on patterns
for _ in 1:100
    for pattern in patterns
        fcm.state = pattern
        train_hebbian!(fcm, 0.01, 1)
    end
end

# Test learned associations
fcm.state = [0.7, 0.6, 0.0, 0.0]  # Hot and humid
run!(fcm, 5)  # Run simulation
println("Predicted weather:", fcm.state)  # Should predict clouds and rain
```

### Comparison of Learning Rules

| Feature | Basic Hebbian | Oja's Rule | Generalized Rule |
|---------|--------------|------------|------------------|
| Stability | Can grow unbounded | Self-normalizing | Controlled by decay |
| Memory | Pure association | PCA-like | Sparse, regularized |
| Use Case | Simple correlations | Feature extraction | Complex patterns |
| Parameters | Learning rate | Learning rate | Learning rate, decay |

### Implementation Details

All learning rules maintain FCM constraints:
- Weights remain in [-1, 1] range
- Diagonal elements stay zero
- External concepts remain unchanged

The learning process is influenced by:
- Learning rate: Controls step size of weight updates
- Number of iterations: How many times to apply the rule
- Initial weights: Starting point for learning
- State patterns: Training examples that drive learning

## Analysis Tools

FuzzyCognitiveMaps.jl provides a comprehensive set of analysis tools for understanding and validating FCM behavior through the `Analysis` module.

### What-if Scenario Analysis

Test how changes to concept values affect the system:

```julia
using FuzzyCognitiveMaps
using FuzzyCognitiveMaps.Analysis

# Create a simple FCM
concepts = ["stress", "productivity", "sleep"]

weights = [
    # stress    productivity  sleep
     0.0       -0.8          -0.7;   # Stress reduces productivity & sleep
    -0.2        0.0           0.4;   # Productivity mitigates stress but requires sleep
    -0.3        0.2           0.0    # Poor sleep exacerbates stress, helps productivity weakly
]

initial_state = [-0.8, 0.5, 0.5]
fcm = create_fcm(concepts, weights, linear, initial_state; external_concepts=[false, false, false])

# Run a what-if scenario: What happens when stress increases?
scenario_result = run_scenario(fcm, Dict("stress" => 0.5))
println("High stress scenario results:")
for (concept, value) in zip(fcm.concepts, scenario_result)
    println("$concept: $value")
end
```

### Comparing Interventions

Compare different intervention strategies:

```julia
# Define multiple interventions to test
interventions = [
    Dict("stress" => 0.2),              # Stress reduction
    Dict("sleep" => 0.8),       # Sleep improvement
    Dict("stress" => 0.3, "sleep" => 0.7)  # Combined approach
]

# Compare their effects on productivity
fcm = create_fcm(concepts, weights, linear, initial_state)
results = compare_interventions(fcm, interventions, ["productivity"])

for (i, result) in enumerate(results)
    println("Intervention $i:")
    println("  Changes: ", result.intervention)
    println("  Effect on productivity: ", result.effects["productivity"])
end
```

### Impact Analysis

Study how changes in one concept affect others:

```julia
# Analyze how different stress levels affect other concepts
stress_levels = [-0.9, -0.45, 0.0, 0.45, 0.9]
impact = analyze_concept_impact(fcm, "stress", stress_levels, ["productivity", "sleep_quality"])

println("Impact of stress levels:")
for result in impact
    println("Stress = $(result.value):")
    println("  Productivity: $(result.impact["productivity"])")
    println("  Sleep Quality: $(result.impact["sleep_quality"])")
end
```

### Sensitivity Analysis

Identify which concepts have the most influence on a target concept:

```julia
# Analyze what factors most affect productivity
sensitivities = sensitivity_analysis(fcm, "productivity")

println("Factors affecting productivity (most to least influential):")
for (concept, sensitivity) in sensitivities
    println("$concept: $sensitivity")
end
```

### Analysis Tools Summary

| Tool | Purpose | Key Features |
|------|---------|-------------|
| `run_scenario` | Test what-if scenarios | - Temporary state modifications<br>- Preserves original state |
| `compare_interventions` | Compare different strategies | - Multiple intervention comparison<br>- Focus on target concepts |
| `analyze_concept_impact` | Study concept influences | - Multiple value testing<br>- Target concept tracking |
| `sensitivity_analysis` | Identify key influences | - Systematic perturbation<br>- Ranked sensitivity results |

These tools help in:
- Validating FCM behavior
- Understanding system dynamics
- Identifying key leverage points
- Planning effective interventions
- Predicting system evolution

## Examples

See the `examples` directory for practical applications:

- `daily_activity_mind.jl`: Decision-making simulation for daily activities
- `predator_prey_simulation.jl`: Predator-prey simulation using FuzzyCognitiveMaps
- `agent_mind_examples.jl`: Agent mind simulation with FuzzyCognitiveMaps
