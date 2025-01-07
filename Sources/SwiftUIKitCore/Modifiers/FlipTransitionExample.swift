import SwiftUI


struct FlipTransitionExample: View {
    
    @State private var show = false
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .zIndex(1)
                .contentShape(Rectangle())
                .onTapGesture {
                    show.toggle()
                }
            
            if show {
                Color.random
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(width: 250, height: 250)
                    .zIndex(2)
                        .transitions(
                            //.scale(0),
                            .flipHorizontal(.leading),
                            .offset([300,0]),
                            .scale(0),
                            .blur(radius: 30)
                        )
            } else {
                Color.random
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(width: 250, height: 250)
                    .zIndex(3)
                    .transitions(
                        .flipHorizontal(.trailing),
                        .offset([-300,0]),
                        .scale(0),
                        .blur(radius: 30)
                    )
            }
        }
        .foregroundStyle(.red)
        .animation(.bouncy.speed(1), value: show)
    }
    
}

#Preview {
    FlipTransitionExample()
}
