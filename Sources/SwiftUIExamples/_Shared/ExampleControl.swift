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
            .aspectRatio(1, contentMode: .fit)
        }
        
        
        struct Dots: View {
            
            var anchor: UnitPoint = .center
            
            var body: some View {
                Canvas { ctx, size in
                    let anchorLocation = CGPoint(
                        x: size.width * anchor.x,
                        y: size.height * anchor.y
                    )
                    
                    let numberOfItems = 10
                    let itemSize = size.width / (Double(numberOfItems) * 2)
                    
                    for i in 0...numberOfItems {
                        for j in 0...numberOfItems {
                            let x = Double(j) * itemSize * 2, y = Double(i) * itemSize * 2
                            let distanceToAnchor = hypot(x - anchorLocation.x, y - anchorLocation.y)
                            let m = distanceToAnchor / (size.width / 4)
                            let location = CGPoint(x: x + (itemSize/2), y: y + (itemSize/2))
                            let size = CGSize(width: itemSize - m, height: itemSize - m)
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
            .frame(width: 100)
            .padding()
    }
}
