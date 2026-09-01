//
//  PageSwipePicker.swift
//  DailyCheckIn
//
//  Created by Wahid on 30.08.26.
//

import SwiftUI

struct PagedSwipePicker<Item: Identifiable & Equatable, Content: View>: View {
    let items: [Item]
    @Binding var selection: Item
    let cardWidthRatio: CGFloat
    let cardHeight: CGFloat
    let cardSpacing: CGFloat
    @ViewBuilder let content: (Item, Bool, CGFloat) -> Content
    
    @State private var scrollPosition: Item.ID?
    
    init(
        items: [Item],
        selection: Binding<Item>,
        cardWidthRatio: CGFloat = 0.72,
        cardHeight: CGFloat = 330,
        cardSpacing: CGFloat = 12,
        @ViewBuilder content: @escaping (Item, _ isSelected: Bool, _ dragProgress: CGFloat) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.cardWidthRatio = cardWidthRatio
        self.cardHeight = cardHeight
        self.cardSpacing = cardSpacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let viewportWidth = geometry.size.width
            let cardWidth = viewportWidth * cardWidthRatio

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(items) { item in
                        GeometryReader { cardGeometry in
                            let cardMidX = cardGeometry.frame(in: .named("swipeCarousel")).midX
                            let viewportMidX = viewportWidth / 2
                            let distance = abs(cardMidX - viewportMidX)

                            // 0.0 wenn genau mittig, bis zu 1.0 wenn aus dem Sichtfeld
                            let progress = min(distance / (cardWidth + cardSpacing), 1)

                            // Zoom- und Transparenz-Effekt
                            let scale = 1 - (progress * 0.20)
                            let opacity = 1 - (progress * 0.48)

                            content(item, item == selection, progress)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .animation(.easeOut(duration: 0.18), value: progress)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                        selection = item
                                        scrollPosition = item.id
                                    }
                                }
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        .id(item.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, (viewportWidth - cardWidth) / 2)
            }
            .coordinateSpace(name: "swipeCarousel")
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .onAppear {
                scrollPosition = selection.id
            }
            .onChange(of: scrollPosition) { _, newID in
                guard let newID, let matchingItem = items.first(where: { $0.id == newID }) else { return }
                withAnimation(.easeInOut(duration: 0.35)) {
                    selection = matchingItem
                }
            }
        }
        .frame(height: cardHeight + 30)
    }
}
