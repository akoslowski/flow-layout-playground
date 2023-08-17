import SwiftUI

/// Try to provide a "FlowView" for items with homogeneous heights.
///
/// - https://developer.apple.com/documentation/swiftui/layout
/// - https://swiftui-lab.com/layout-protocol-part-1/
///
struct SimpleFlowLayout: Layout {

    /// Calculate and return the size of the layout container.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheBucket) -> CGSize {
        print(#function)
        var container = FlowLayoutContainer(bounds: .init(x: 0, y: 0, width: proposal.width ?? 0, height: proposal.height ?? 0))
        subviews.forEach {
            let position = container.appendItem(with: $0.sizeThatFits(proposal))
            cache.positions.append(position)
        }
        return container.sizeThatFits
    }

    /// Assigns positions to each of the layout’s subviews.
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheBucket) {
        print(#function)
        var container = FlowLayoutContainer(bounds: bounds)

        subviews.enumerated().forEach { index, subview in
            let position = container.appendItem(with: subview.sizeThatFits(proposal))
            subview.place(at: position, proposal: proposal)
        }
    }

    // MARK: - Cache

    /**
     Call-Order:

     1. makeCache(subviews:)
     2. sizeThatFits(proposal:subviews:cache:)
     3. placeSubviews(in:proposal:subviews:cache:)
     */

    struct CacheBucket {
        var positions: [CGPoint]
    }

    func makeCache(subviews: Subviews) -> CacheBucket {
        print(#function)
        return CacheBucket(positions: [])
    }

    func updateCache(_ cache: inout CacheBucket, subviews: Subviews) {
        print(#function)
    }
}

struct FlowLayoutContainer {

    let bounds: CGRect
    var sizeThatFits: CGSize

    private(set) var remainingWidth: CGFloat
    private(set) var insertionPoint: CGPoint

    init(bounds: CGRect) {
        self.bounds = bounds
        self.sizeThatFits = .init(width: bounds.width, height: .zero)
        self.remainingWidth = bounds.width
        self.insertionPoint = bounds.origin
    }

    mutating func appendItem(with size: CGSize) -> CGPoint {
        if sizeThatFits.height == .zero {
            sizeThatFits = .init(width: sizeThatFits.width, height: size.height)
        }

        var remainingWidthAfterAppending = remainingWidth - size.width

        if remainingWidthAfterAppending < 0.0 {
            // Adding a "line break"
            insertionPoint = CGPoint(
                x: bounds.origin.x,
                y: insertionPoint.y + size.height
            )
            remainingWidthAfterAppending = bounds.width - size.width

            // Increasing the height to accommodate the "next line"
            sizeThatFits = .init(
                width: sizeThatFits.width,
                height: sizeThatFits.height + size.height
            )
        }

        let insertionPointAfterAppending = CGPoint(
            x: insertionPoint.x + size.width,
            y: insertionPoint.y
        )

        let returnValue = insertionPoint
        insertionPoint = insertionPointAfterAppending
        remainingWidth = remainingWidthAfterAppending
        return returnValue
    }
}

struct FlowView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleFlowLayout {
            ForEach(colors, id: \.self) {
                $0.frame(width: randomWidth(), height: 60)
            }
        }
        .border(Color.black)
        .padding()
        .previewDisplayName("Random widths")

        SimpleFlowLayout {
            Color.red.frame(width: 140, height: 60)
            Color.blue.frame(width: 200, height: 60)
            Color.cyan.frame(width: 100, height: 60)
            Color.yellow.frame(width: 80, height: 60)
            Color.green.frame(width: 140, height: 60)
            Color.orange.frame(width: 80, height: 60)
            Color.indigo.frame(width: 180, height: 60)
            Color.teal.frame(width: 90, height: 60)
            Color.pink.frame(width: 240, height: 60)
            Color.purple.frame(width: 100, height: 60)
        }
        .border(Color.black)
        .padding()
        .previewDisplayName("Fixed widths")
    }
}

let colors: [Color] = [.red, .blue, .cyan, .yellow, .green, .orange, .indigo, .teal, .pink, .purple]
func randomWidth() -> CGFloat {
    CGFloat((5...20).randomElement() ?? 70) * 10.0
}
