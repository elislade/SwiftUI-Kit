import SwiftUIKit

struct ExampleControl {
    
    struct Anchor: View {
        
        @Environment(\.isEnabled) private var isEnabled
        @Binding var value: UnitPoint
        
        var body: some View {
            SliderView(
                x: .init($value.x),
                y: .init($value.y),
                hitTestHandle: false
            ){
                RaisedControlMaterial(Circle())
                    .frame(width: 32, height: 32)
                    .overlay{
                        Text("⚓︎")
                            .font(.title2)
                            .foregroundStyle(.black)
                    }
                    .opacity(isEnabled ? 1 : 0.7)
            }
            .padding(2)
            .background{
                SunkenControlMaterial(RoundedRectangle(cornerRadius: 20))
                Dots(anchor: value)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(0.2)
                    .blendMode(.hardLight)
                    .opacity(isEnabled ? 1 : 0.5)
            }
        }
        
        
        struct Dots: View {
            
            var anchor: UnitPoint = .center
            var spacing: Double = 15 // distance between dots
            
            var body: some View {
                Canvas { ctx, size in
                    let itemSize = spacing / 2
                    
                    for row in 0...Int(size.height / spacing) {
                        for col in 0...Int(size.width / spacing) {
                            let x = Double(col) * spacing, y = Double(row) * spacing
                            let relativeLocation = (x: x / size.width, y: y / size.height)
                            let relativeDistanceToAnchor = 1.0 - (0.8 * hypot(relativeLocation.x - anchor.x, relativeLocation.y - anchor.y))
                            let location = CGPoint(x: x + (itemSize/2), y: y + (itemSize/2))
                            let size = CGSize(
                                width: itemSize * relativeDistanceToAnchor,
                                height: itemSize * relativeDistanceToAnchor
                            )
                            let rect = CGRect(origin: location, size: size)
                            
                            let path = Circle().path(in: rect)
                            ctx.fill(path, with: .color(.primary))
                        }
                    }
                }
            }
        }
        
        
    }
}


#Preview{
    InlineBinding(UnitPoint()){
        ExampleControl.Anchor(value: $0)
            .padding()
    }
}
