import SwiftUIKit


public struct RoutingExample: View {
    
    @State private var showBranch = false
    @State private var deferred = false
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Routing"){
            VStack {
                VStack {
                    if showBranch {
                        Branch()
                            .padding()
                    } else {
                        Text("Root")
                    }
                }
                .onRoute("branch"){
                    showBranch = true
                } other: {
                    showBranch = false
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
                
                Group {
                    Link("Branch 1", destination: .example("branch/1"))
                    Link("Branch 2", destination: .example("branch/2"))
                    Link("Root", destination: .example(""))
                }
                .disabled(deferred)
                
                Link("Deferred", destination: .example("deferred"))
                    .disabled(!deferred)
            }
            .buttonStyle(.tinted)
            .exampleParameterCell()
            
            Toggle(isOn: $deferred){
                Text("Defer Unhandled")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            .toggleStyle(.swiftUIKitSwitch)
        }
        .router(shouldDeferUnhandled: deferred)
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
                        }
                    
                    Text("2")
                        .opacity(branch == "2" ? 1 : 0.5)
                        .padding()
                        .onRoute("2"){
                            branch = "2"
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
