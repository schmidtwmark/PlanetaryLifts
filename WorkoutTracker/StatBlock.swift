//
//  StatBlock.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 5/15/24.
//

import SwiftUI
extension Double {
    
    var roundedWithAbbreviations: String {
        let thousand = self / 1000.0
        let million = self / 1000000.0
        let billion = self / 1000000000.0
        if billion >= 1.0 {
            return "\(((billion * 10).rounded()/10.0).clean)B"
        }
        else if million >= 1.0 {
            return "\(((million * 10).rounded()/10.0).clean)M"
        }
        else if thousand >= 1.0 {
            return "\(((thousand * 10).rounded()/10.0).clean)K"
        }
        else {
            return "\(self.clean)"
        }
    }
}

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
