import SwiftUIKit


public struct MatchExampleView: View {
    
    public init() {}
    
    static let item = GridItem(.adaptive(minimum: 260, maximum: 400))
    
    public var body: some View {
        ExampleView("Match Views"){
            ScrollView {
                LazyVGrid(columns: [Self.item]){
                    ForEach(0..<12){ i in
                        Cell(i: i)
                            .buttonStyle(.plain)
                            .frame(maxHeight: 100)
                    }
                }
                .padding()
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
                        .presentationMatch(i)
                        .aspectRatio(1, contentMode: .fit)
   
                    Text("Element \(i + 1)")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .presentation(isPresented: $isPresented){
                NavView{
                    Detail(value: i)
                }
                .modalCard()
            }
        }
    }
    
    struct FocalView: View {
        let value: Int
        
        var body: some View {
            RoundedRectangle(cornerRadius: 30)
                .fill(.background)
                .overlay{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.tint)
                        .opacity(Double(value + 1) / 13)
                    
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder()
                        .opacity(0.1)
                }
        }
    }
    
    
    struct Detail: View {
        @Environment(\.dismissPresentation) private var dismiss
        let value: Int
        
        @State private var present: Int?
        @State private var detail: Bool = false
        @State private var modal: Bool = false
        
        var body: some View {
            ScrollView{
                VStack(spacing: 10) {
                    FocalView(value: value)
                        .presentationMatch(value)
                        .overlay(alignment: .bottomTrailing){
                            Button{ present = value } label: {
                                Label("Examine", systemImage: "eye.fill")
                            }
                            .presentation(value: $present){ value in
                                FocalView(value: value)
                                    .presentationMatch(value)
                                    .padding()
                                    .ignoresSafeArea()
                                    .transition(.scale([0.0,0.0]).animation(.bouncy))
                            }
                            .padding()
                            .labelStyle(.iconOnly)
                            .buttonStyle(.plain)
                        }
                        .aspectRatio(2.8, contentMode: .fit)
                    
                    ForEach(0..<2){ _ in
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.black.opacity(0.2))
                            .frame(height: 80)
                    }
                    
                    HStack(spacing: 16) {
                        Button{ detail = true } label: {
                            Label("Detail", systemImage: "arrow.right.circle.fill")
                        }
                        .navDestination(isPresented: $detail){
                            Detail(value: value)
                                .background(.regularMaterial)
                        }
                        
                        Button{ modal = true } label: {
                            Label("Modal", systemImage: "arrow.up.circle.fill")
                        }
                        .presentation(isPresented: $modal){
                            NavView{
                                Detail(value: value)
                            }
                            .modalCard()
                        }
                    }
                    .buttonStyle(.bar)
                    .padding()
                }
                .padding()
            }
            .navBarTitle{
                Text("Element \(value + 1)")
                    .font(.title.bold())
            }
            .navBarTrailing{
                Button{ dismiss(.context) } label: {
                    Label("Close", systemImage: "xmark")
                }
            }
        }
    }
}


extension View {
    
    nonisolated func modalCard() -> some View {
        mask{
            RoundedRectangle(cornerRadius: 32)
                .ignoresSafeArea()
        }
        .background{
            RoundedRectangle(cornerRadius: 32)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 44)
                .ignoresSafeArea()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .inset(by: -1)
                .strokeBorder()
                .opacity(0.1)
                .ignoresSafeArea()
        }
        .frame(maxHeight: 400)
        .transition(
            .moveEdgeIgnoredByLayout(.bottom).animation(.fastSpring)
            + .offset([0, 80]).animation(.fastSpring)
        )
        .presentationBackdrop(.changedPassthrough)
    }
    
}

#Preview {
    MatchExampleView()
        .previewSize()
}
