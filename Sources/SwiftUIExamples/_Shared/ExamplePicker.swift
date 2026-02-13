import SwiftUIKit

struct ExampleInlinePicker<Data: RandomAccessCollection, Content: View, Label: View> : View where Data.Element: Equatable, Data.Index : Hashable {
    
    @Namespace private var ns
    
    let data: Data
    @Binding var selection: Data.Element
    let content: (Data.Element) -> Content
    let label: () -> Label
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(data.indices, id: \.hashValue){ i in
                    content(data[i])
                        .font(.exampleParameterTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 10)
                        .frame(height: .controlSize)
                        .frame(maxWidth: .infinity)
                        .background{
                            if data[i] == selection {
                                ContainerRelativeShape()
                                    .inset(by: 2)
                                    .fill(.tint)
                                    .blendMode(.overlay)
                                    .matchedGeometryEffect(id: "bg", in: ns)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selection = data[i]
                        }
                }
            }
            .labelStyle(.iconOnly)
            .background{
                SunkenControlMaterial(ContainerRelativeShape())
                    .scaleEffect(y: -1)
                
                ContainerRelativeShape()
                    .opacity(0.1)
            }
            .compositingGroup()
            
            label()
                .foregroundStyle(.primary.opacity(0.5))
                .font(.caption[.bold])
        }
        .containerShape(PercentageRoundedRectangle(.vertical, percentage: 0.7))
    }
    
}

extension ExampleInlinePicker where Label == EmptyView {
    
    init(
        data: Data,
        selection: Binding<Data.Element>,
        content: @escaping (Data.Element) -> Content
    ){
        self.init(
            data: data,
            selection: selection,
            content: content,
            label: { EmptyView() }
        )
    }
    
}


struct ExampleMenuPicker<Data: RandomAccessCollection, Content: View, Label: View> : View where Data.Element : Hashable, Data.Index : Hashable {
    
    @Namespace private var ns
    @State private var picking = false
    
    let data: Data
    @Binding var selection: Data.Element
    let content: @MainActor (Data.Element) -> Content
    let label: () -> Label
    
    var body: some View {
        Button{ picking.toggle() } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    label()
                        .labelStyle(.titleOnly)
                        .font(.exampleParameterTitle)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    
                    content(selection)
                        .font(.exampleParameterValue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .opacity(0.5)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .fontWeight(.bold)
            }
        }
        .buttonStyle(.example)
        .anchorPresentation(
            isPresented: $picking,
            type: .vertical(preferredAlignment: .center)
        ){
            MenuContainer{
                MenuPicker(
                    selection: $selection,
                    data: data,
                    label: content
                )
            }
            .presentationBackdrop(.changedPassthrough)
            .transition(
                .scale(0.5).animation(.bouncy.speed(1.5))
                + .opacity.animation(.easeInOut(duration: 0.15))
            )
        }
    }
    
}

#Preview {
    VStack {
        InlineBinding("Option A"){ b in
            ExampleInlinePicker(
                data: ["Option A", "Option B", "Option C"],
                selection: b
            ){ i in
                Text(i)
            } label: {
                Text("Options")
            }
            
            ExampleMenuPicker(
                data: ["Option A", "Option B", "Option C"],
                selection: b
            ){ i in
                Text(i)
            } label: {
                Text("Options")
            }
        }
        .containerShape(RoundedRectangle(cornerRadius: 22))
        .padding()
    }
    .presentationContext()
    .previewSize()
}
