import SwiftUIKit


public struct MatchExampleView: View {
    
    public init() {}
    
    public var body: some View {
        NavView {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 260, maximum: 400))]){
                    ForEach(0..<12){ i in
                        Cell(i: i)
                            .buttonStyle(.plain)
                            .frame(maxHeight: 100)
                    }
                }
                .padding()
            }
            .navBarTitle{
                Text("Match Views")
                    .font(.title.bold())
            }
        }
    }
    
    
    struct Cell: View {
        
        @State private var isPresented: Bool = false
        let i: Int
        
        var body: some View {
            Button{ isPresented = true } label: {
                HStack {
                    FocalView(value: i)
                        //.aspectRatio(1, contentMode: .fit)
                        .presentationMatch(i)
                        .aspectRatio(1, contentMode: .fit)
   
                    Text("Element \(i + 1)")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                //.presentationMatch(i)
            }
            //.presentationMatch(i)
            .presentation(isPresented: $isPresented){
               // .navDestination(isPresented: $isPresented){
                NavView{
                    Detail(value: i)
                }
                .background{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.background)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: 400)
                .transition(
                    .offset([0, 590]).animation(.fastSpring)
                )
            }
        }
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
        @State private var detail: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                ScrollView{
                    VStack(spacing: 10) {
                        FocalView(value: value)
                            .overlay(alignment: .bottomTrailing){
                                Button{ present = value } label: {
                                    Label("Examine", systemImage: "eye.fill")
                                }
                                .presentation(value: $present){ value in
                                    FocalView(value: value)
                                        .presentationMatch(value)
                                        .padding(30)
                                }
                                .padding()
                                .labelStyle(.iconOnly)
                                .buttonStyle(.plain)
                            }
                            .presentationMatch(value)
                            .aspectRatio(2.8, contentMode: .fit)
                        
                        ForEach(0..<3){ _ in
                            ContainerRelativeShape()
                                .opacity(0.2)
                                .frame(height: 50)
                        }
                        
                        Button{ detail = true } label: {
                            Label("Detail", systemImage: "eye.fill")
                        }
                        .navDestination(isPresented: $detail){
                            VStack(spacing: 0) {
                                Color.gray.frame(height: 200)
                                Detail(value: value)
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .padding()
                    }
                    .padding()
                }
                .navBarTitle{
                    Text("Element \(value + 1)")
                        .font(.title.bold())
                }
            }
        }
    }
}


#Preview {
    MatchExampleView()
        .previewSize()
}
