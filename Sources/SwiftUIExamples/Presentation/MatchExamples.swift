import SwiftUIKit


public struct MatchExampleView: View {
    
    @State private var presentValue: Int?
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 260, maximum: 400))]){
                ForEach(0..<12){ i in
                    Button(action: { presentValue = i }){
                        HStack {
                            FocalView(value: i)
                                .aspectRatio(1, contentMode: .fit)
                                .presentationMatch(i)
           
                            Text("Element \(i + 1)")
                                .font(.title2.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .contentShape(Rectangle())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    }
                    .buttonStyle(.plain)
                    .frame(maxHeight: 100)
                }
            }
            .padding()
            .animation(.smooth, value: presentValue)
        }
        .presentation(value: $presentValue){ value in
            Detail(value: value)
                .clipShape(ContainerRelativeShape())
                .background {
                    ContainerRelativeShape()
                        .fill(.background)
                        .shadow(
                            color: .black.opacity(0.2),
                            radius: 10,
                            y: 10
                        )
                }
                .containerShape(RoundedRectangle(cornerRadius: 30))
                .frame(maxWidth: 640)
                .presentationMatch(value)
                .padding(8)
                .transition(
                    .offset([0, 590]).animation(.bouncy)
                )
        }
        .presentationContext()
        .ignoresSafeArea(edges: [.top, .horizontal])
    }
    
    
    struct FocalView: View {
        let value: Int
        
        var body: some View {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(
                    hue: 0.4 + Double(value) / 40,
                    saturation: 1,
                    brightness: 1
                ))
        }
    }
    
    
    struct Detail: View {
        let value: Int
        
        @State private var present: Int?
        
        var body: some View {
            ScrollView {
                VStack(spacing: 10) {
                    FocalView(value: value)
                        .aspectRatio(1.8, contentMode: .fit)
                        .overlay(alignment: .bottomTrailing){
                            Button("Examine", systemImage: "eye.fill"){ present = value }
                                .presentation(value: $present){ value in
                                    FocalView(value: value)
                                        .presentationMatch("value")
                                        .padding(.horizontal)
                                        .presentationBackdrop {
                                            Rectangle().fill(.background)
                                        }
                                        .transition(.opacity.animation(.smooth))
                                }
                                .padding()
                                .labelStyle(.iconOnly)
                                .buttonStyle(.plain)
                        }
                        .presentationMatch("value")
                        //.presentationMatch(value)
                    
                    ForEach(0..<4){ _ in
                        RoundedRectangle(cornerRadius: 15)
                            .opacity(0.2)
                            .frame(height: 50)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: 440)
            .safeAreaInset(edge: .top, spacing: 0) {
                Text("Element \(value + 1)")
                    .font(.title.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background{
                        Rectangle().fill(.regularMaterial)
                    }
                    .overlay(alignment: .bottom){
                        Divider()
                    }
            }
        }
    }
}


#Preview {
    MatchExampleView()
        .previewSize()
}
