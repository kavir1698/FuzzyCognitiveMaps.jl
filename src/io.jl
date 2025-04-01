function load_fcm_from_csv(filepath::String)
    df = CSV.read(filepath, DataFrame)
    concepts = String.(df[!, 1])
    external = df[!, :external]
    weights = Matrix{Float64}(df[!, 2:end-1])
    return concepts, weights, external
end

"""
        create_fcm(;
    csv_file::Union{String, Nothing}=nothing,
    concepts::Vector{String}=String[],
    weights::Matrix{Float64}=Matrix{Float64}(undef, 0, 0),
    activation::Function=sigmoid,
    initial_state::Union{Vector{Float64}, Nothing}=nothing,
    track_history::Bool=false,
    external_concepts::Union{Vector{Bool}, Nothing}=nothing)

Create a Fuzzy Cognitive Map (FCM) from a CSV file.

# Arguments
- `csv_file::Union{String, Nothing}`: Path to the CSV file containing the FCM data.
- `concepts::Vector{String}`: Names of the concepts in the FCM.
- `weights::Matrix{Float64}`: Weights of the connections between the concepts.
- `activation::Function`: Activation function for the FCM.
- `initial_state::Union{Vector{Float64}, Nothing}`: Initial state of the concepts.
- `track_history::Bool`: Whether to track the state of the FCM at each iteration.
- `external_concepts::Union{Vector{Bool}, Nothing}`: Whether the concepts are external.
"""
function create_fcm(;
    csv_file::Union{String, Nothing}=nothing,
    concepts::Vector{String}=String[],
    weights::Matrix{Float64}=Matrix{Float64}(undef, 0, 0),
    activation::Function=sigmoid,
    initial_state::Union{Vector{Float64}, Nothing}=nothing,
    track_history::Bool=false,
    external_concepts::Union{Vector{Bool}, Nothing}=nothing)

    if !isnothing(csv_file)
        concepts, weights, external_concepts = load_fcm_from_csv(csv_file)
    end

    n = length(concepts)
    initial_state = isnothing(initial_state) ? zeros(Float64, n) : initial_state
    external_concepts = isnothing(external_concepts) ? Vector{Bool}(falses(n)) : external_concepts

    create_fcm(concepts, weights, activation, initial_state,
               track_history=track_history, external_concepts=external_concepts)
end
