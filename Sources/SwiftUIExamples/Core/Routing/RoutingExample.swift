import SwiftUIKit


public struct RoutingExample: View {
    
    @State private var showBranch: String?
    @State private var deferred = false
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Routing"){
            VStack {
                Text("Root")
                
                HStack(alignment: .top) {
                    VStack {
                        Text("A")
                            .opacity(showBranch == "a" ? 1 : 0.5)
                        
                        if showBranch == "a" {
                            NumberRoute()
                        }
                    }
                    .onRoute("a"){
                        showBranch = "a"
                    } other: {
                        print("Other A")
                    }
                    
                    VStack {
                        Text("B")
                            .opacity(showBranch == "b" ? 1 : 0.5)
                        
                        if showBranch == "b" {
                            NumberRoute()
                        }
                    }
                    .onRoute("b"){
                        showBranch = "b"
                    } other: {
                        print("Other B")
                    }
                }
                
                if !deferred {
                    DeferredContent()
                }
            }
            .font(.largeTitle.weight(.bold))
        } parameters: {
            HStack {
                Text("Links")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                VStack(spacing: 10) {
                    Link("Root", destination: .example("/"))
                    HStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Link("A", destination: .example("/a"))
                            HStack(spacing: 16) {
                                Link("1", destination: .example("/a/1"))
                                Link("2", destination: .example("/a/2"))
                            }
                        }
                        
                        VStack(spacing: 10) {
                            Link("B", destination: .example("/b"))
                            HStack(spacing: 16) {
                                Link("1", destination: .example("/b/1"))
                                Link("2", destination: .example("/b/2"))
                            }
                        }
                    }
                }
                .disabled(deferred)
            }
            .buttonStyle(.tinted)
            .exampleParameterCell()
            
            Toggle(isOn: $deferred){
                HStack {
                    Text("Defer Unhandled")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Link("Trigger", destination: .example("deferred"))
                        .disabled(!deferred)
                }
            }
            .exampleParameterCell()
            .toggleStyle(.swiftUIKitSwitch)
        }
        .router(shouldDeferUnhandled: deferred)
    }
    
    
    struct NumberRoute: View {
        
        @State private var number: String?
        
        var body: some View {
            HStack {
                Text("1")
                    .opacity(number == "1" ? 1 : 0.5)
                    .onRoute("1"){
                        number = "1"
                    } other: {
                        print("Other 1")
                    }
                
                Text("2")
                    .opacity(number == "2" ? 1 : 0.5)
                    .onRoute("2"){
                        number = "2"
                    } other: {
                        print("Other 2")
                    }
            }
        }
        
    }
    
    
    struct Branch: View {
        
        @State private var branch: String?
        
        var body: some View {
            VStack {
                Text("Branch")
                
                Spacer()
                
                if let branch {
                    Image(systemName: branch + ".circle.fill")
                        .resizable()
                        .scaledToFit()
                }
                
                Spacer()
                
                HStack {
                    Text("1")
                        .opacity(branch == "1" ? 1 : 0.5)
                        .padding()
                        .onRoute("1"){
                            branch = "1"
                        } other: {
                            print("Other 1")
                        }
                    
                    Text("2")
                        .opacity(branch == "2" ? 1 : 0.5)
                        .padding()
                        .onRoute("2"){
                            branch = "2"
                        } other: {
                            print("Other 2")
                        }
                }
                
                Spacer()
                
            }
        }
    }
    
    
    struct DeferredContent: View {
        
        @State private var count: Int = 0
        
        var body: some View {
            Text("Deferred Clicked \(count)")
                .onRoute("deferred"){
                    count += 1
                }
        }
        
    }
    
}


#Preview {
    RoutingExample()
        .previewSize()
}
