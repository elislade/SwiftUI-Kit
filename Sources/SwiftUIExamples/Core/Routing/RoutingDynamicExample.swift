import SwiftUIKit


public struct RoutingDynamicExample: View {
    
    enum Option: Hashable, CaseIterable, CustomStringConvertible {
        case a, b, c
        
        var description: String {
            switch self {
            case .a: return "a"
            case .b: return "b"
            case .c: return "c"
            }
        }
    }
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Routing Dynamic") {
            Reciever()
                .presentationContext()
        } parameters: {
            ExampleSection("Parameters", isExpanded: true){
                Sender()
            }
        }
        .router()
    }
    
    
    struct Content: View {
        
        @State private var showModal = false
        @State private var showDetail = false
        
        var index: Int = 0
        
        var body: some View {
            ZStack{
                Color.clear
                
                Text("Content \(index)")
                    .font(.largeTitle[.bold])
                    .navBarTitle(Text("Content \(index)"))
                    .presentation(isPresented: $showModal){
                        NavView{
                            Content(index: index + 1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 320)
                        .background(.regularMaterial)
                        .transition(.offset([0, 340]).animation(.fastSpring))
                    }
                    .navDestination(isPresented: $showDetail){
                        Content(index: index + 1)
                    }
            }
            .background{ ExampleBackground().ignoresSafeArea() }
            .onRouteRegex(/modal|detail/){ match in
                switch match {
                case "modal":
                    showModal = true
                    showDetail = false
                case "detail":
                    showDetail = true
                    showModal = false
                default: return
                }
            } other: {
                showModal = false
                showDetail = false
            }
        }
    }
    
    struct Reciever: View {
        
        @State private var option: Option = .a
        
        var body: some View {
            TabView(selection: $option) {
                ForEach(Option.allCases, id: \.self) { option in
                    NavView{
                        Content()
                    }
                    .routeNamespace(option.description)
                    .tabItem{
                        TabLabel(option).onRoute(option.description){
                            self.option = option
                        }
                        .routeRelay()
                    }
                }
            }
            .padding(.bottom, 1)
            .routeRelayReceiver()
        }
        
    }
    
    enum PresentationStyle: String, Hashable, CaseIterable, Sendable {
        case modal
        case detail
    }
    
    struct Sender: View {
        
        @Environment(\.openURL) private var open
        
        @State private var tab: RoutingDynamicExample.Option = .a
        @State private var elements: [Element] = [
            .init(style: .modal), .init(style: .detail)
        ]
        
        struct Element: Identifiable, Equatable {
            let id = UUID()
            var style: PresentationStyle
        }
        
        struct RouteComposer: View {
            
            @Binding var tab: RoutingDynamicExample.Option
            @Binding var elements: [Element]
            
            struct RouteDivider: View {
                
                var body: some View {
                    Image(systemName: "chevron.compact.right")
                        .imageScale(.large)
                        .opacity(0.3)
                }
                
            }
            
            var body: some View {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 8) {
                            Menu{
                                MenuPicker(
                                    selection: $tab,
                                    data: RoutingDynamicExample.Option.allCases
                                ){
                                    TabLabel($0)
                                }
                            } label: {
                                TabLabel(tab)
                                    .foregroundStyle(.tint)
                            }
                            
                            RouteDivider()
                            
                            EditElementsView(
                                elements: $elements.animation(.bouncy)
                            )
                        }
                        .padding(10)
                        .id("content")
                        .onChange(of: elements){ _ in
                            withAnimation(.fastSpring){
                               proxy.scrollTo("content", anchor: .trailing)
                            }
                        }
                    }
                }
            }
            
            
            struct EditElementsView: View {
                
                @Binding var elements: [Element]
                
                var body: some View {
                    ForEach($elements.lazy){ element in
                        ElementView(element: element){
                            if let idx = elements.firstIndex(where: { $0.id == element.wrappedValue.id }){
                                self.elements.remove(at: idx)
                            }
                        }
                        .transition(.scale)
                        
                        RouteDivider()
                    }
                    
                    Menu {
                        ForEach(PresentationStyle.allCases, id: \.self){ s in
                            Button{ elements.append(.init(style: s)) } label: {
                                PresentationStyleLabel(s)
                            }
                            .actionTriggerBehaviour(.immediate)
                        }
                    } label: {
                        Label{ Text("Add") } icon: {
                            Image(systemName: "plus")
                        }
                        .foregroundStyle(.tint)
                    }
                }
                
                
                struct ElementView: View {
                    
                    @Binding var element: Element
                    
                    let delete: () -> Void
                    
                    var body: some View {
                        Menu{
                            MenuPicker(
                                selection: $element.style,
                                data: PresentationStyle.allCases
                            ){
                                PresentationStyleLabel($0)
                            }

                            MenuGroupDivider()
                            
                            Button(role: .destructive){
                                delete()
                            } label: {
                                Label{ Text("Remove") } icon: {
                                    Image(systemName: "trash")
                                }
                            }
                            .actionTriggerBehaviour(.immediate)
                        } label: {
                            PresentationStyleLabel(element.style)
                                .foregroundStyle(.tint)
                                .symbolEffectBounceIfAvailable(value: element.style)
                        }
                        .transition(.scale)
                    }
                    
                }
            }
            
        }
        
        
        var body: some View {
            RouteComposer(tab: $tab, elements: $elements)
                .safeAreaInset(edge: .trailing, spacing: 10){
                    Button{
                        let path = ([tab.description] + elements.map(\.style.rawValue)).joined(separator: "/")
                        open(.example(path))
                    } label: {
                        Label{ Text("Run") } icon: {
                            Image(systemName: "play")
                        }
                    }
                    .background {
                        LinearGradient(
                            colors: [
                                .clear, .black.opacity(0.9),
                                .black.opacity(0.7), .black
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.hierarchical)
            .symbolVariant(.fill)
        }
        
        
        struct PresentationStyleLabel: View {
            let style: PresentationStyle
            
            init(_ style: PresentationStyle) {
                self.style = style
            }
            
            var body: some View {
                switch style {
                case .modal:
                    Label{ Text("Modal") } icon: {
                        Image(systemName: "arrow.up.to.line.square.fill")
                    }
                case .detail:
                    Label{ Text("Detail") } icon: {
                        Image(systemName: "arrow.right.to.line.square.fill")
                    }
                }
            }
        }
        
    }

    
    struct TabLabel: View {
        
        let option: Option
        
        init(_ option: Option) {
            self.option = option
        }
        
        var body: some View {
            switch option {
            case .a:
                Label{ Text("Tab A") } icon: {
                    Image(systemName: "a.circle")
                }
            case .b:
                Label{ Text("Tab B") } icon: {
                    Image(systemName: "b.circle")
                }
            case .c:
                Label{ Text("Tab C") } icon: {
                    Image(systemName: "c.circle")
                }
            }
        }
        
    }
}

extension URL {
    
    static func example(_ path: String) -> URL {
        URL(string: "https://example.com/\(path)")!
    }
    
}


#Preview {
    RoutingDynamicExample()
        .previewSize()
}
