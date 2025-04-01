module ExpertKnowledge

using Statistics

export LinguisticTerm, convert_linguistic_to_weight, combine_expert_opinions
export generate_membership_function, get_membership_value
export generate_membership_plot_data, fuzzy_and, fuzzy_or
export calculate_expert_entropy, calculate_agreement_degree
export FuzzyImplication, Larsen, Mamdani, GodelImplication

"""
Fuzzy implication methods type
"""
@enum FuzzyImplication Larsen Mamdani GodelImplication

"""
Represents a fuzzy linguistic term with its membership function
"""
struct LinguisticTerm
    name::String
    points::NTuple{4,Float64}  # Trapezoidal membership function points (a,b,c,d)
end

# Standard linguistic terms for causal relationships
const STANDARD_TERMS = Dict(
    "very_negative" => LinguisticTerm("very_negative", (-1.0, -1.0, -0.8, -0.6)),
    "negative" => LinguisticTerm("negative", (-0.8, -0.6, -0.4, -0.2)),
    "slightly_negative" => LinguisticTerm("slightly_negative", (-0.4, -0.2, -0.1, 0.0)),
    "none" => LinguisticTerm("none", (-0.1, 0.0, 0.0, 0.1)),
    "slightly_positive" => LinguisticTerm("slightly_positive", (0.0, 0.1, 0.2, 0.4)),
    "positive" => LinguisticTerm("positive", (0.2, 0.4, 0.6, 0.8)),
    "very_positive" => LinguisticTerm("very_positive", (0.6, 0.8, 1.0, 1.0))
)

"""
Convert a linguistic term to a crisp weight value using proper centroid defuzzification
"""
function convert_linguistic_to_weight(term::Union{String,LinguisticTerm})
    if typeof(term) == String
        term = get(STANDARD_TERMS, term) do
            throw(ArgumentError("Unknown linguistic term: $term"))
        end
    end

    # Get trapezoid points
    (a, b, c, d) = term.points

    # Define the membership function
    μ = generate_membership_function(a, b, c, d)

    # Numerical integration for centroid calculation
    n_points = 1000
    x_range = range(a, d, length=n_points)
    dx = (d - a) / (n_points - 1)

    # Calculate numerator and denominator for centroid formula
    numerator = 0.0
    denominator = 0.0

    for x in x_range
        μx = μ(x)
        numerator += x * μx * dx
        denominator += μx * dx
    end

    # Return centroid
    return denominator ≈ 0 ? (a + d) / 2 : numerator / denominator
end

"""
Combine multiple expert opinions into a single weight matrix using weighted averaging
"""
function combine_expert_opinions(expert_opinions::Vector{Matrix{String}};
                               weight_by_entropy::Bool=false)
    n_concepts = size(expert_opinions[1], 1)
    n_experts = length(expert_opinions)

    # Validate input dimensions
    for opinion in expert_opinions
        if size(opinion) != (n_concepts, n_concepts)
            throw(ArgumentError("All expert opinion matrices must have the same dimensions"))
        end
    end

    # Calculate expert weights based on entropy if requested
    expert_weights = ones(n_experts) ./ n_experts  # Default to equal weights
    if weight_by_entropy
        expert_entropies = calculate_expert_entropy(expert_opinions)
        # Convert entropy to weights (lower entropy = higher weight)
        expert_weights = 1 .- expert_entropies
        # Handle case where all experts have same entropy
        if all(expert_weights .≈ expert_weights[1])
            expert_weights .= 1.0
        end
        # Normalize weights to sum to 1
        expert_weights = expert_weights ./ sum(expert_weights)
    end

    # Initialize combined weights matrix
    combined_weights = zeros(Float64, n_concepts, n_concepts)

    # Convert and average opinions using weighted average
    for i in 1:n_concepts
        for j in 1:n_concepts
            # Convert linguistic terms to numeric weights for each expert
            raw_weights = [convert_linguistic_to_weight(opinion[i,j]) for opinion in expert_opinions]

            # Calculate weighted average
            combined_weights[i,j] = sum(expert_weights .* raw_weights)
        end
    end

    return combined_weights
end

"""
Generate a trapezoidal membership function
"""
function generate_membership_function(a::Float64, b::Float64, c::Float64, d::Float64)
    function membership(x::Float64)
        if x <= a || x >= d
            return 0.0
        elseif b <= x <= c
            return 1.0
        elseif a < x < b
            return (x - a) / (b - a)
        else # c < x < d
            return (d - x) / (d - c)
        end
    end
    return membership
end

"""
Get membership value for a linguistic term at a specific point
"""
function get_membership_value(term::LinguisticTerm, x::Float64)
    membership = generate_membership_function(term.points...)
    return membership(x)
end

"""
Generate membership values for plotting
"""
function generate_membership_plot_data(term::LinguisticTerm, points::Int=100)
    x_range = range(-1, 1, length=points)
    membership = generate_membership_function(term.points...)
    y_values = map(membership, x_range)
    return collect(x_range), y_values
end

"""
Fuzzy intersection (AND) of two membership values
"""
fuzzy_and(a::Float64, b::Float64) = min(a, b)

"""
Fuzzy union (OR) of two membership values
"""
fuzzy_or(a::Float64, b::Float64) = max(a, b)

"""
Calculate entropy of expert opinions to measure overall uncertainty of each expert.
Returns normalized entropy values between 0 and 1.
Higher entropy indicates more uncertainty/variability in expert's ratings.
"""
function calculate_expert_entropy(expert_opinions::Vector{Matrix{String}})
    n_experts = length(expert_opinions)
    n_concepts = size(expert_opinions[1], 1)
    expert_entropies = zeros(n_experts)
    n_bins = 10
    max_entropy = log2(n_bins)  # Maximum possible entropy for uniform distribution

    for expert_idx in 1:n_experts
        # Collect all ratings from this expert into a single vector
        ratings = Float64[]
        for i in 1:n_concepts
            for j in 1:n_concepts
                if i != j  # Skip diagonal elements
                    push!(ratings, convert_linguistic_to_weight(expert_opinions[expert_idx][i,j]))
                end
            end
        end

        # Normalize ratings to probability-like values
        normalized = (ratings .+ 1) ./ 2  # Map from [-1,1] to [0,1]

        # Create histogram-like bins for entropy calculation
        hist = zeros(n_bins)
        for r in normalized
            bin = min(n_bins, max(1, ceil(Int, r * n_bins)))
            hist[bin] += 1
        end
        hist = hist ./ sum(hist)  # Normalize to probabilities

        # Calculate entropy for this expert
        entropy = 0.0
        for p in hist
            if p > 0
                entropy -= p * log2(p)
            end
        end

        # Normalize entropy to [0,1] range
        expert_entropies[expert_idx] = entropy / max_entropy
    end

    return expert_entropies
end

"""
Calculate agreement degree between experts accounting for weights
"""
function calculate_agreement_degree(expert_opinions::Vector{Matrix{String}})
    n_concepts = size(expert_opinions[1], 1)
    n_experts = length(expert_opinions)
    agreement_matrix = zeros(n_concepts, n_concepts)

    for i in 1:n_concepts
        for j in 1:n_concepts
            # Convert linguistic terms to numeric weights
            ratings = [convert_linguistic_to_weight(opinion[i,j]) for opinion in expert_opinions]

            # Calculate weighted pairwise agreement
            agreements = Float64[]
            for k in 1:n_experts
                for l in (k+1):n_experts
                    # Use similarity measure based on normalized distance
                    agreement = 1 - abs(ratings[k] - ratings[l])/2  # Division by 2 since max difference is 2 (-1 to 1)
                    push!(agreements, agreement)
                end
            end

            agreement_matrix[i,j] = mean(agreements)
        end
    end

    return agreement_matrix
end

"""
Apply fuzzy implication method to combine membership values
"""
function fuzzy_implication(a::Float64, b::Float64, method::FuzzyImplication=Larsen)
    if method == Larsen
        return a * b
    elseif method == Mamdani
        return min(a, b)
    elseif method == GodelImplication
        return a <= b ? 1.0 : b
    end
end

end # module
