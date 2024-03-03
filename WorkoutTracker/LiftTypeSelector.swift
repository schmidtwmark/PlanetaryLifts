//
//  LiftTypeSelector.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 3/3/24.
//

import SwiftUI

extension String {
    func containsIgnoringCase(_ target: String) -> Bool {
        self.range(of: target, options: .caseInsensitive) != nil
        
    }
}

struct LiftTypeSelector: View {
    @Binding var selectedLiftType : LiftType
    @State var searchText: String = ""
    @Environment(\.dismiss) var dismiss

    
    
    var filteredCategories : [LiftCategory] {
        LiftCategory.allCases.filter({ category in
            searchText == "" || category.rawValue.containsIgnoringCase(searchText) || LiftType.liftsByCategory[category]!.contains(where: { liftType in
                liftType.string.containsIgnoringCase(searchText)
            })
        })
    }
    
    var body: some View {
        List {
            ForEach(filteredCategories, id: \.rawValue) { category in
                Section(category.rawValue) {
                    ForEach(LiftType.liftsByCategory[category]!, id: \.string) { lift in
                        if searchText == "" || category.rawValue.containsIgnoringCase(searchText) || lift.string.contains(searchText) {
                            HStack {
                                Text(lift.string)
                                Spacer()
                                if lift == selectedLiftType {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                withAnimation {
                                    selectedLiftType = lift
                                    dismiss()
                                }
                            })
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    NavigationStack {
        LiftTypeSelector(selectedLiftType: .constant(.backSquat))
    }
}
