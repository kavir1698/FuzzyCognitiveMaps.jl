module UMLGenerator

using ..FuzzyCognitiveMaps: load_fcm_from_csv

"""
    generate_uml(csv_path::String)

Generate a PlantUML diagram string from an FCM CSV file.
Returns a string containing the PlantUML diagram code.
"""
function generate_uml(csv_path::String)
    # Load FCM data
    concepts, weights, external = load_fcm_from_csv(csv_path)

    # Start PlantUML diagram
    uml = """
    @startuml FCM_Concepts
    skinparam defaultTextAlignment center
    """

    # Add concepts as components
    for (i, concept) in enumerate(concepts)
        component_name = replace(concept, " " => "_")
        style = external[i] ? " #lightBlue" : ""
        uml *= "\ncomponent \"$concept\" as $component_name$style"
    end

    # Add relationships
    for i in 1:length(concepts)
        for j in 1:length(concepts)
            weight = weights[i, j]
            if weight != 0
                source = replace(concepts[i], " " => "_")
                target = replace(concepts[j], " " => "_")

                # Style based on weight
                color = weight > 0 ? "green" : "red"
                # Scale thickness to 1-10 range
                thickness = max(1, floor(Int, abs(weight) * 10))

                uml *= "\n$source -[#$color,thickness=$(thickness)]-> $target : $(round(weight, digits=2))"
            end
        end
    end

    uml *= "\n@enduml"
    return uml
end

"""
    save_uml(csv_path::String, output_path::String)

Generate a PlantUML diagram from a CSV file and save it to the specified path.
"""
function save_uml(csv_path::String, output_path::String)
    open(output_path, "w") do io
        write(io, generate_uml(csv_path))
    end
end

export generate_uml, save_uml

end # module
