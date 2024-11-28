import SwiftUIKit


struct InlineBindingExample: View {
    
    var body: some View {
        VStack(spacing: 0) {
            InlineBinding(ColorScheme.light){ binding in
                Text(binding.wrappedValue == .dark ? "Dark" : "Light")
                    .font(.largeTitle.weight(.heavy))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
                    .environment(\.colorScheme, binding.wrappedValue)
                    .onTapGesture {
                        if binding.wrappedValue == .dark {
                            binding.wrappedValue = .light
                        } else {
                            binding.wrappedValue = .dark
                        }
                    }
            }
            
            Divider().ignoresSafeArea()
            
            ExampleTitle("Inline Binding")
                .padding()
        }
    }
    
}

#Preview {
    InlineBindingExample()
}
