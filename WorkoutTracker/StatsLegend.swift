//
//  StatsLegend.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 6/20/24.
//

import SwiftUI

struct StatsLegend<T: Hashable & Comparable & Identifiable & Equatable>: View {
    
    var chunkSize: Int
    var categories: [T]
    @Binding var selectedCategory: T?
    var stringMapping: (T) -> String
    var colorMapping: (String) -> Color
    @Binding var legendPosition: Int?
    
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(Array(categories.chunked(into: chunkSize).enumerated()), id: \.offset) { offset, chunk in
                    VStack(alignment: .leading) {
                        ForEach(chunk) { category in
                            let isSelected = category == selectedCategory
                            HStack {
                                let string = stringMapping(category)
                                colorMapping(string).clipShape(Circle())
                                Text(string)
                            }
                            .padding(5)
                            .background(isSelected ? Color.gray : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            .fixedSize()
                            .onTapGesture(perform: {
                                withAnimation {
                                    if isSelected {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = category
                                    }
                                }
                            })
                        }
                    }
                    .tag(offset)
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
            .scrollIndicators(.hidden)
        }
        .scrollPosition(id: $legendPosition)
    }
}
