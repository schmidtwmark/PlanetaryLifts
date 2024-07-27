//
//  StatBlock.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 5/15/24.
//

import SwiftUI


struct StatBlock: View {
    var description: String
    var unit: String
    var number: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(description)
            HStack(alignment: .firstTextBaseline) {
                Text("\(number.roundedWithAbbreviations) \(unit)\(number.rounded() != 1.0 ? "s" : "")")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}

#Preview {
    StatBlock(description:"All Time Max", unit:"Pound", number: 1500000.0)
}
