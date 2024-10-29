import SwiftUIKit

struct ExampleControl {
    
    struct Anchor: View {
        
        @Binding var value: UnitPoint
        
        @SliderState private var x = 0
        @SliderState private var y = 0
        
        private var unit: UnitPoint { .init(x: x, y: y) }
        
        var body: some View {
            SliderView(x: _x, y: _y, hitTestHandle: false){
                RaisedControlMaterial(Circle())
//                Circle()
//                    .fill(.white)
                    .frame(width: 32, height: 32)
                    //.shadow(radius: 4, y: 2)
                    .overlay{
                        Text("⚓︎")
                            .font(.title2)
                            .foregroundStyle(.black)
                    }
            }
            .padding(2)
            .background{
                SunkenControlMaterial(RoundedRectangle(cornerRadius: 20))
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(.secondary)
//                    .opacity(0.2)
                
                Dots(anchor: unit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(0.2)
                    .blendMode(.hardLight)
            }
            .aspectRatio(1, contentMode: .fit)
            .onChange(of: unit){
                if $0 != value {
                    value = $0
                }
            }
            .onChangePolyfill(of: value, initial: true){
                if value != unit {
                    x = value.x
                    y = value.y
                }
            }
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
