//
//  FlowLayout.swift
//  DailyCheckIn
//
//  Created by Wahid on 17.08.26.
//

import SwiftUI

struct FlowLayout: Layout {
    
    var spacing: CGFloat = 10
    var rowSpacing: CGFloat = 10
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        
        let availableWidth = proposal.width ?? .infinity
        
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        var totalHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0
        
        for subview in subviews {
            
            let size = subview.sizeThatFits(
                ProposedViewSize(
                    width: nil,
                    height: nil
                )
            )
            
            let newRowWidth =
                currentRowWidth == 0
                ? size.width
                : currentRowWidth + spacing + size.width
            
            if newRowWidth > availableWidth {
                
                totalHeight += currentRowHeight
                
                if totalHeight > 0 {
                    totalHeight += rowSpacing
                }
                
                maxRowWidth = max(
                    maxRowWidth,
                    currentRowWidth
                )
                
                currentRowWidth = size.width
                currentRowHeight = size.height
                
            } else {
                
                currentRowWidth = newRowWidth
                currentRowHeight = max(
                    currentRowHeight,
                    size.height
                )
            }
        }
        
        totalHeight += currentRowHeight
        
        maxRowWidth = max(
            maxRowWidth,
            currentRowWidth
        )
        
        return CGSize(
            width: min(maxRowWidth, availableWidth),
            height: totalHeight
        )
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        
        var x = bounds.minX
        var y = bounds.minY
        
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            
            let size = subview.sizeThatFits(
                ProposedViewSize(
                    width: nil,
                    height: nil
                )
            )
            
            if x != bounds.minX &&
                x + size.width > bounds.maxX {
                
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(
                    x: x,
                    y: y
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: size.width,
                    height: size.height
                )
            )
            
            x += size.width + spacing
            
            rowHeight = max(
                rowHeight,
                size.height
            )
        }
    }
}
