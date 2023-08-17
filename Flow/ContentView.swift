import SwiftUI

struct ContentView: View {

    struct Item: Identifiable {
        let id: UUID = .init()
        let text: String
    }

    let items = "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat"
        .components(separatedBy: .whitespaces)
        .map { Item(text: $0) }
        .prefix(40)

    @State var isCompact: Bool

    var body: some View {
        ScrollView {
            VStack {
                Toggle(isOn: $isCompact) {
                    Text("Compact")
                }
                .padding()

                SimpleFlowLayout {
                    ForEach(items) {
                        TagView($0.text)
                            .padding(2)
                    }
                }
                .padding(.horizontal, isCompact ? 70 : 8)
            }
            .animation(.easeInOut(duration: 1), value: isCompact)
        }
    }
}

struct TagView: View {
    init(_ value: String) {
        self.value = value
    }

    let value: String
    var body: some View {
        Text(value)
            .lineLimit(1)
            .foregroundColor(Color.accentColor)
            .padding(6)
            .background(Color.primary)
            .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isCompact: false)
    }
}
