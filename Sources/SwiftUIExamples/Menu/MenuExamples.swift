import SwiftUIKit


public struct MenuExamples: View {
    
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var alignment: Alignment = .center
    
    public init() {}
    
    struct Cell: View {
        
        @State private var selection = "Option A"
        
        let number: Int
        
        private var picker: some View {
            MenuPicker(
                selection: $selection,
                data: ["Option A", "Option B", "Option C"]
            ){ i in
                Label { Text(i) } icon: {
                    Image(systemName: "\(i.last!.lowercased()).circle.fill")
                }
            }
        }
        
        var body: some View {
            HStack {
                Text("Cell \(number)")
                    .font(.title[.bold])
                
                Spacer()
                
                Menu {
                    Menu{
                        Menu{
                            picker
                        } label: {
                            Label { Text("Submenu Options") } icon: {
                                Image(systemName: "checklist")
                            }
                        }
                    } label: {
                        Label { Text("Submenu Options") } icon: {
                            Image(systemName: "checklist")
                        }
                    }
                    
                    MenuGroupDivider()
                    
                    HStack {
                        Button{ print("1") } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "1.circle.fill")
                                    .font(.title2)
                                
                                Text("Item 1")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(6)
                        }
                        
                        Button{ print("2") } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "2.circle.fill")
                                    .font(.title2)
                                
                                Text("Item 2")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(6)
                        }
                    }
                    .font(.callout[.semibold])
                    .lineLimit(1)
                    
                    MenuGroupDivider()
                    
                    picker
                } label: {
                    Text(selection)
                        .opacity(0.5)
                        .menuIndicatorStyle()
                }
            }
        }
    }
    
    
    public var body: some View {
        ExampleView(title: "Menu"){
            ScrollView{
                VStack(spacing: 0) {
                    ForEach(0..<20){ i in
                        Cell(number: i + 1)
                            .lineLimit(1)
                            .padding()
                            .padding(.vertical, 10)
                            .background(alignment: .bottom){
                                Divider().ignoresSafeArea()
                            }
                    }
                }
            }
            .environment(\.layoutDirection, layoutDirection)
            .presentationContext()
            .presentationEnvironmentBehaviour(.usePresentation)
            .fontWidth(.expanded)
        } parameters: {
            ExampleCell.LayoutDirection(value: $layoutDirection)
            //ExampleCell.Alignment(value: $alignment)
        }
    }
    
}

#Preview {
    ZStack {
        MenuContainer {
            Menu {
                Button{} label: {
                    Label("Option A", systemImage: "pencil.and.scribble")
                }
                Menu {
                    Button{} label: {
                        Label("Option A", systemImage: "pencil.and.scribble")
                    }
                } label: {
                    Label("Submenu Z", systemImage: "pencil.and.scribble")
                }
            } label: {
                Label("Submenu Q", systemImage: "pencil.and.scribble")
            }
            
            Button{} label: {
                Label("Option A", systemImage: "hare")
            }
            
            Menu {
                Button{} label: {
                    Label("Option A", systemImage: "pencil.and.scribble")
                }
            } label: {
                Label("Submenu A", systemImage: "pencil.and.scribble")
            }

            Button{} label: {
                Label("Option B", systemImage: "widget.extralarge.badge.plus")
            }
            
            MenuDivider()
            
            Button(role: .destructive){} label: {
                Label("Delete", systemImage: "trash")
            }
            
            MenuDivider()
            
            Menu {
                Button{} label: {
                    Label("Option A", systemImage: "pencil.and.scribble")
                }
            } label: {
                Label("Submenu B", systemImage: "pencil.and.scribble")
            }
        }
    }
    .submenuPresentationContext()
    .previewSize()
}


#Preview("Menu") {
    MenuExamples()
        .previewSize()
}


public struct CustomMenuBGStyle: MaterialStyle {
    
    public func makeBody(shape: AnyInsettableShape) -> some View {
        ZStack {
            shape
                .fill(.background)
                .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            
            RaisedControlMaterial(shape)
                .blendMode(.overlay)
            
            EdgeHighlightMaterial(shape)
        }
    }
    
}


extension MaterialStyle where Self == CustomMenuBGStyle {
    
    public static var sample: Self { .init() }
    
}
