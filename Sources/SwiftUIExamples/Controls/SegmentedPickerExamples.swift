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
        let i = index > options.count - 1 ? 0 : index < 0 ? options.count - 1  : index
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
            .controlSize(controlSize)
            .layoutDirectionSuggestion(suggetion)
            .environment(\.layoutDirection, layout)
            .disabled(disable)
            .padding()
        } parameters: {
            ExampleSection(isExpanded: true){
                HStack {
                    Toggle(isOn: $disable){
                        Text("Disable")
                    }
                    
                    Button{ set(index: selectionIndex - 1) } label: {
                        Label("Previous", systemImage: "arrow.left")
                            .labelStyle(.iconOnly)
                    }
                    
                    Button{ set(index: selectionIndex + 1) } label: {
                        Label("Next", systemImage: "arrow.right")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ExampleCell.ControlRoundness(value: $controlRoundness)
                
                HStack {
                    ExampleCell.ControlSize(value: $controlSize)
                        .fixedSize()
                    
                    ExampleCell.LayoutDirectionSuggestion(value: $suggetion)
                }
                
                ExampleCell.LayoutDirection(value: $layout)
            } label: {
                Text("Parameters")
            }
        }
    }
    
}


#Preview("Segmented Picker") {
    SegmentedPickerExamples()
        .previewSize()
}
