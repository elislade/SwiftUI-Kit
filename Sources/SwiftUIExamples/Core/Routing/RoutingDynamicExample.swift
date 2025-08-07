import SwiftUIKit

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
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
    
    @Environment(\.isPresented) private var isPresented
    
    public init(){}
    
    public var body: some View {
        Reciever()
            .safeAreaInset(edge: .top, spacing: 0){
                Sender()
                    .paddingAddingSafeArea()
                    .background(.regularMaterial)
                
            }
            .presentationMatchCaptureMode(.snapshot)
            //.paddingAddingSafeArea()
            .sceneEnvironment()
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
                        if #available(iOS 16.4, *) {
                            NavView{
                                Content(index: index + 1)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 320)
                            .background(.regularMaterial)
                            .transition(.offset([0, 340]).animation(.fastSpring))
                        } else {
                            
                        }
                    }
                    .navDestination(isPresented: $showDetail){
                        Content(index: index + 1)
                    }
            }
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
                    .presentationContext()
                    .tabItem{
                        TabLabel(option).onRoute(option.description){
                            self.option = option
                        }
                        .routeRelay()
                    }
                }
            }
            .routeRelayReceiver()
            .tint(Color(option))
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
        
        private var divider: some View {
            Image(systemName: "chevron.compact.right")
                .imageScale(.large)
                .opacity(0.3)
        }
        
        var body: some View {
            VStack(spacing: 0) {
                ExampleTitle("Routing Dynamic")
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 8) {
                                Menu{
                                    MenuPicker(selection: $tab, data: RoutingDynamicExample.Option.allCases){
                                        TabLabel($0)
                                    }
                                } label: {
                                    TabLabel(tab)
                                        .foregroundStyle(.tint)
                                }
                                
                               divider
                                
                                ForEach($elements){ binding in
                                    Menu{
                                        MenuPicker(selection: binding.style, data: PresentationStyle.allCases){ s in
                                            PresentationStyleLabel(s)
                                        }
                                        
                                        MenuGroupDivider()
                                        
                                        Button(role: .destructive){
                                            elements.removeAll(where: {
                                                $0.id == binding.wrappedValue.id
                                            })
                                        } label: {
                                            Label{ Text("Remove") } icon: {
                                                Image(systemName: "trash")
                                            }
                                        }
                                    } label: {
                                        PresentationStyleLabel(binding.wrappedValue.style)
                                            .foregroundStyle(.tint)
                                            .symbolEffectBounce(value: binding.wrappedValue.style)
                                            //.contentTransition(.symbolEffect)
                                    }
                                    .transition(.scale)
                                    
                                    divider
                                }
                                
                                Menu {
                                    ForEach(PresentationStyle.allCases, id: \.self){ s in
                                        Button{ elements.append(.init(style: s)) } label: {
                                            PresentationStyleLabel(s)
                                        }
                                    }
                                } label: {
                                    Label{ Text("Add") } icon: {
                                        Image(systemName: "plus")
                                    }
                                    .foregroundStyle(.tint)
                                }
                                .id("last")
                            }
                            .padding(10)
                            .animation(.bouncy, value: elements)
                        }
                        .onChangePolyfill(of: elements){
                            withAnimation(.fastSpring){
                                proxy.scrollTo("last", anchor: .trailing)
                            }
                        }
                    }
                    
                    Capsule()
                        .frame(width: 3, height: 32)
                        .opacity(0.5)
                    
                    Button{
                        let path = ([tab.description] + elements.map(\.style.rawValue)).joined(separator: "/")
                        print("Open", path)
                        open(.example(path))
                    } label: {
                        Label{ Text("Run") } icon: {
                            Image(systemName: "play")
                        }
                        .padding()
                    }
                }
                .font(.title2[.semibold])
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
                .symbolVariant(.fill)
            }
            .tint(Color(tab))
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
                Label{ Text("Red") } icon: {
                    Image(systemName: "a.circle")
                }
            case .b:
                Label{ Text("Green") } icon: {
                    Image(systemName: "b.circle")
                }
            case .c:
                Label{ Text("Blue") } icon: {
                    Image(systemName: "c.circle")
                }
            }
        }
        
    }
}


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Color {
    init(_ option: RoutingDynamicExample.Option){
        switch option {
        case .a: self = .red
        case .b: self = .green
        case .c: self = .blue
        }
    }
}

extension URL {
    
    static func example(_ path: String) -> URL {
        URL(string: "https://example.com/\(path)")!
    }
    
}


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
#Preview {
    RoutingDynamicExample()
        .previewSize()
}
