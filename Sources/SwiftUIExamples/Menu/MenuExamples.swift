import SwiftUIKit


public struct MenuExamples: View {
    
    @State private var selection = "Option B"
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var alignment: Alignment = .center
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Menu"){
            ZStack(alignment: alignment) {
                Color.clear
            
                Menu {
                    Menu{
                        Button{ print("A") } label: {
                            Text("A Item")
                                .equalInsetItem()
                        }
                    } label: {
                        Text("Item 1")
                    }
                    
                    MenuGroupDivider()
                    
                    Menu{
                        MenuPicker(
                            selection: $selection,
                            data: ["Option A", "Option B", "Option C"]
                        ){ i in
                            Label { Text(i) } icon: {
                                Image(systemName: "\(i.last!.lowercased()).circle.fill")
                            }
                        }
                    } label: {
                        Label { Text("Options") } icon: {
                            Image(systemName: "car")
                        }
                    }
                    
                    MenuGroupDivider()
                    
                    Button{ print("Three") } label: {
                        Label("Item 3", systemImage: "3.circle.fill")
                    }
                    
                    Button{ print("Four") } label: {
                        Label("Item 4", systemImage: "4.circle.fill")
                    }
                    
                    MenuGroupDivider()

                    MenuPicker(
                        selection: $selection,
                        data: ["Option A", "Option B", "Option C"]
                    ){
                        Text($0)
                    }
                } label: {
                    HStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 50, height: 50)
                            .opacity(0.1)
                        
                        Text(selection)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .font(.title[.bold])
                    .menuIndicatorStyle()
                }
            }
            .presentationContext()
            .environment(\.layoutDirection, layoutDirection)
        } parameters: {
            ExampleCell.LayoutDirection(value: $layoutDirection)
            ExampleCell.Alignment(value: $alignment)
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
    .tint(.gray)
    .submenuPresentationContext()
    //.menuBackgroundStyle(.sample)
}


#Preview("Menu") {
    MenuExamples()
        .previewSize()
}


public struct SampleCustomStyle: MaterialStyle {
    
    public func makeBody(shape: AnyInsettableShape) -> some View {
        ZStack {
            shape.fill(.red.opacity(0.5))
            OuterShadowMaterial(shape, radius: 10)
        }
    }
    
}


extension MaterialStyle where Self == SampleCustomStyle {
    
    public static var sample: Self { .init() }
    
}
