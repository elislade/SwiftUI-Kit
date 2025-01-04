import SwiftUIKit


public struct SegmentedPickerExamples : View {
    
    private let options = ["A", "B", "C", "D"]
    
    @State private var suggetion: LayoutDirectionSuggestion = .useSystemDefault
    @State private var layout: LayoutDirection = .leftToRight
    @State private var selection = "A"
    @State private var controlSize: ControlSize = .regular
    @State private var controlRoundness: Double = 1
    @State private var disable = false
    
    private var selectionIndex: Int {
        options.firstIndex(where: { $0 == selection }) ?? 0
    }
    
    private func set(index: Int){
        let i = index > options.count - 1 ? 0 : index
        selection = options[i]
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Segmented Control"){
            AxisStack(
                suggetion.useVertical ? .horizontal : .vertical,
                spacing: 10
            ) {
                ExampleCard(title: "SwiftUI") {
                    Picker("", selection: $selection){
                        ForEach(options){
                            Label(
                                "Item " + $0,
                                systemImage: $0.lowercased() + ".circle\(selection == $0 ? ".fill" : "")"
                            ).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                ExampleCard(title: "SwiftUIKit") {
                    SegmentedPicker(
                        selection: $selection,
                        items: options
                    ){
                        Label(
                            "Item " + $0,
                            systemImage: $0.lowercased() + ".circle\(selection == $0 ? ".fill" : "")"
                        )
                    }
                }
                .labelStyle(.iconOnly)
            }
            .animation(.bouncy, value: suggetion)
            .animation(.bouncy, value: selection)
            .controlRoundness(controlRoundness)
            //.interactionGranularity(1)
            .controlSize(controlSize)
            .layoutDirectionSuggestion(suggetion)
            .environment(\.layoutDirection, layout)
            .disabled(disable)
            .padding()
        } parameters: {
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Select Next"){
                    set(index: selectionIndex + 1)
                }
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $disable){
                Text("Disable")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            ExampleCell.ControlRoundness(value: $controlRoundness)
            
            Divider()
            
            ExampleCell.ControlSize(value: $controlSize)
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $layout)
            
            Divider()
            
            ExampleCell.LayoutDirectionSuggestion(value: $suggetion)
        }
    }
    
}


#Preview("Segmented Picker") {
    SegmentedPickerExamples()
        .previewSize()
}
