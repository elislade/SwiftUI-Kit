import SwiftUIKit


struct VisualEffectViewExamples : View {

    @State private var filters: Set<VisualEffectView.Filter> = []
    @State private var blur: CGFloat = 29.5
    
    private func binding(for filter: VisualEffectView.Filter) -> Binding<Bool> {
        .init(
            get: { filters.contains(filter) },
            set: {
                if $0 {
                    filters.insert(filter)
                } else {
                    filters.remove(filter)
                }
            }
        )
    }
    
    var body: some View {
        ExampleView(title: "Visual Effect View"){
            ZStack {
                Canvas { ctx, canvasSize in
                    let size = CGSizeMake(canvasSize.width / 21, canvasSize.height / 21)
                    for i in 0...20 {
                        for j in 0...20 {
                            let origin = CGPoint(x: Double(j) * size.width, y: Double(i) * size.height)
                            let color = Color(
                                hue: Double(j) / 21,
                                saturation: (Double(i) / 10),
                                brightness: min(2 - (Double(i) / 10.0), 1)
                            )
                            ctx.fill(Path(CGRect(origin: origin, size: size)), with: .color(color))
                        }
                    }
                }
                
                VisualEffectView(disableFilters: filters, blurRadius: blur)
                    .id(Double(filters.count) + blur)
            }
            .ignoresSafeArea()
        } parameters: {
            ExampleSection("Disabling Filters", isExpanded: true){
                ForEach(VisualEffectView.Filter.allCases) { filter in
                    Toggle(isOn: binding(for: filter)){
                        Text(filter.rawValue.splitCamelCaseFormat)
                            .font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    if filter == .gaussianBlur {
                        Slider(value: $blur, in: 0...60)
                            .padding([.horizontal, .bottom])
                            .disabled(filters.contains(.gaussianBlur))
                    }
                    
                    Divider()
                }
            }
        }
    }

}



#Preview("Visual Effect View") {
    VisualEffectViewExamples()
}
