import SwiftUI
import SwiftUIKitCore


public struct MenuPicker<V: Hashable, Data: RandomAccessCollection, Label: View>: View where Data.Element == V {
    
    @Environment(\.menuStyle) private var style
    @Environment(\.isInMenu) private var isInMenu
    
    @Binding private var selection: V
    let data: Data
    @ViewBuilder private let label: @MainActor (Data.Element) -> Label
    
    public init(
        selection: Binding<V>,
        data: Data,
        @ViewBuilder label: @MainActor @escaping (Data.Element) -> Label
    ) {
        self._selection = selection
        self.data = data
        self.label = label
    }
    
    private func binding(for element: Data.Element) -> Binding<Bool> {
        .init(
            get: { selection == element },
            set: { _ in
                selection = element
            }
        )
    }
    
    public var body: some View {
        if isInMenu {
            ForEach(data, id: \.self){ i in
                Toggle(isOn: binding(for: i)){
                    label(i)
                }
                
                if i != data.last {
                    MenuDivider()
                }
            }
            .toggleStyle(MenuToggleStyle(exclusivity: .exclusive))
            .actionTriggerBehaviour(.immediate)
        } else {
            Picker("", selection: $selection){
                ForEach(data, id: \.self){
                    label($0).tag($0)
                }
            }
        }
    }
    
}


#Preview {
    InlineBinding("Option A"){ binding in
        MenuContainer{
            VStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 40)
                    .background{
                        Image(systemName: "book.fill")
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 40)
                            .opacity(0.3)
                    }
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                
                Text("What's your favourite option?")
                    .font(.system(.title2, design: .serif)[.bold])
                    .accessibilityHeading(.h1)
                
                Text("You can only pick one.")
                    .font(.system(.body, design: .serif).italic())
                    .accessibilityHeading(.h2)
                    .opacity(0.5)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding()
            .padding(.vertical)
            .fixedSize(horizontal: false, vertical: true)
            
            MenuPicker(
                selection: binding,
                data: ["Option A", "Option B", "Option C"]
            ){ ele in
                Label {
                    Text(ele)
                        .font(.system(.headline, design: .serif))
                } icon: { EmptyView() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            Rectangle()
                .fill(.tint)
                .mask{
                    LinearGradient(
                        colors: [.black.opacity(0.6), .black.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .tint(.brown)
        .ignoresSafeArea()
    }
}
