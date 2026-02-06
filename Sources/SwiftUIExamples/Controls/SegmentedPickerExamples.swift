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
                
                #if !os(watchOS)
                ExampleCard(title: "SwiftUI") {
                    Picker("", selection: $selection){
                        ForEach(options, id: \.self){
                            Label(
                                "Item " + $0,
                                systemImage: $0.lowercased() + ".circle\(selection == $0 ? ".fill" : "")"
                            ).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                #endif
                
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
                    .animation(.bouncy, value: selection)
                }
                .labelStyle(.iconOnly)
            }
            .animation(.bouncy, value: suggetion)
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
            .exampleParameterCell()
          
            Toggle(isOn: $disable){
                Text("Disable")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            ExampleCell.ControlRoundness(value: $controlRoundness)
            
            ExampleCell.ControlSize(value: $controlSize)
            
            ExampleCell.LayoutDirection(value: $layout)
            
            ExampleCell.LayoutDirectionSuggestion(value: $suggetion)
        }
    }
    
}


#Preview("Segmented Picker") {
    SegmentedPickerExamples()
        .previewSize()
}
