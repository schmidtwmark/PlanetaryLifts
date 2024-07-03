//
//  ImportExportView.swift
//  GoodVibesOnly
//
//  Created by Mark Schmidt on 10/22/23.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers


enum TSVLabels: String, CaseIterable {
    case type
    case category
    case timestamp
    case units
    case sets
    case weighted
    case notes
}
let separator = "\t"

func toTsv(_ lifts: [Lift]) -> String {
    var tsvString = TSVLabels.allCases.map({$0.rawValue}).joined(separator: separator).appending("\n")
    for lift in lifts {
        let units = lift.sets.first?.weight.units ?? .pounds
        let sets = lift.sets.map({ "\($0.reps)@\($0.weight.roundedWeight)"}).joined(separator: "|")
        let row = [lift.type.string, lift.type.category.rawValue, lift.timestamp.ISO8601Format(), units.rawValue, sets, String(lift.weighted), lift.notes].joined(separator: separator).appending("\n")
        
        tsvString = tsvString.appending(row)
    }
    return tsvString

}

enum TSVParseError : Error {
    case missingFirstLine
    case incorrectColumnLabel(String)
    case invalidLine([Substring.SubSequence], Int)
    case invalidCategory(String, Int)
    case invalidTimestamp(String, Int)
    case invalidUnits(String, Int)
    case invalidSets(String, Int)
    case invalidWeighted(String, Int)

    case other(Swift.Error)
}


func fromTsv(_ tsvString: String) -> Result<([Lift], [UserGeneratedLiftType]), TSVParseError> {
    let lines = tsvString.split(separator: "\n")
    guard let key = lines.first else { return .failure(.missingFirstLine)}
    do {
        let paramMap =  try key.split(separator: separator, omittingEmptySubsequences: false).enumerated().reduce(into: Dictionary<TSVLabels, Int>(), { output, item in
            let string = String(item.element)
            guard let label = TSVLabels(rawValue: string) else  { throw TSVParseError.incorrectColumnLabel(string) }
            output[label] = item.offset
        })
        
        let lifts = try lines.suffix(from: 1).enumerated().map({ line in
            let index = line.offset
            let items = Array(line.element.split(separator: separator, omittingEmptySubsequences: false))
            guard items.count == TSVLabels.allCases.count else { throw TSVParseError.invalidLine(items, index)}
            
            let typeString = String(items[paramMap[.type]!])
            let categoryString = String(items[paramMap[.category]!])
            let timestampString = String(items[paramMap[.timestamp]!])
            let unitsString = String(items[paramMap[.units]!])
            let setsString = String(items[paramMap[.sets]!])
            let weightedString = String(items[paramMap[.weighted]!])
            let notesString = String(items[paramMap[.notes]!])
            
            guard let category = LiftCategory(rawValue: categoryString) else { throw TSVParseError.invalidCategory(categoryString, index)}
            
            let type = LiftType(from: typeString) ?? .other(name: typeString, category: category, id: UUID())
            guard let timestamp = ISO8601DateFormatter().date(from: timestampString) else { throw TSVParseError.invalidTimestamp(timestampString, index)}
            
            guard let units = WeightUnits(rawValue: unitsString) else { throw TSVParseError.invalidUnits(unitsString, index)}
            
            let sets = try setsString.split(separator: "|").map({ setString in
                let repsAndWeight = setString.split(separator: "@")
                guard repsAndWeight.count == 2 else { throw TSVParseError.invalidSets(String(setString), index) }
                
                guard let reps = Int(repsAndWeight[0]) else { throw TSVParseError.invalidSets(String(setString), index)}
                guard let weight = Double(repsAndWeight[1]) else { throw TSVParseError.invalidSets(String(setString), index)}
                
                return LiftSet(reps: reps, weight: weight, units: units)
            })
            
            guard let weighted = Bool(weightedString) else { throw TSVParseError.invalidWeighted(weightedString, index)}
            
            return Lift(liftType: type, sets: sets, timestamp: timestamp, notes: notesString, weighted: weighted)
        })
        
        // Get the unique user types
        let userTypes = Array(Set(lifts.compactMap({
            if case .other(let name, let category, _) = $0.type { return UserGeneratedLiftType(name: name, category: category)}
            else { return nil }
        })))
        
        return .success((lifts, userTypes))
    } catch let error as TSVParseError {
      return .failure(error)
    } catch {
      return .failure(.other(error))
    }
}

func importLifts(from importUrl: URL) -> Result<([Lift], [UserGeneratedLiftType]), TSVParseError>{
    do {
        let tsvString = try String(contentsOf: importUrl, encoding: .utf8)
        return try .success(fromTsv(tsvString).get())
        
    } catch let error as TSVParseError {
        return .failure(error)
    } catch {
        return .failure(.other(error))
    }
}


struct TSVFile: FileDocument {
    // tell the system we support only plain text
    static let readableContentTypes = [UTType.tabSeparatedText]
    static let writableContentTypes = [UTType.tabSeparatedText]

    // by default our document is empty
    var text = ""

    // a simple initializer that creates new, empty documents
    init(initialText: String = "") {
        text = initialText
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct ExportSheet: View {
    
    private enum ExportState {
        case processing
        case processSuccess(String)
        case processFailure
        case exportSuccess(Int)
        case exportFailure(String)
        
        func getTsvData() -> String? {
            switch self {
            case .processSuccess(let tsvData):
                    return tsvData
            default: return nil
            }
        }
    }
    
    @Query(sort: \Lift.timestamp, order: .reverse) var lifts: [Lift]

    @Environment(\.dismiss) var dismiss
    
    @State var exportDialogPresented = false
    @State private var exportState : ExportState = .processing
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Data for Planetary Lifts")
                    .multilineTextAlignment(.leading)
                switch self.exportState {
                case .processing:
                    ProgressView()
                case .processSuccess(let tsvData):
                    Button("Export") {
                        exportDialogPresented = true
                    }
                    .buttonStyle(.bordered)
                    .fileExporter(isPresented: $exportDialogPresented, document: TSVFile(initialText: tsvData), contentType: UTType.tabSeparatedText, defaultFilename: "PlanetaryLifts.tsv", onCompletion: { result in
                        switch result {
                        case .success(let file):
                            print("Successfully wrote export contents to \(file)")
                            exportState = .exportSuccess(lifts.count)
                        case .failure(let error):
                            print("Failed exporting with \(error)")
                            exportState = .exportFailure(error.localizedDescription)
                        }
                    })

                case .processFailure:
                    Text("Failed to prepare for export")
                case .exportSuccess(let count):
                    Text("Successfully exported \(count) lifts!")
                    Button("Close") {
                        dismiss()
                    }
                case .exportFailure(let error):
                    Text("Failed to export with error: \(error)")
                    Button("Close") {
                        dismiss()
                    }
                }
                
            }
            .padding(20)
            .navigationTitle("Export")
            .toolbar(content: {
                ToolbarItem(id: "Cancel", placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
            .task {
                let tsv = toTsv(lifts)
                self.exportState = .processSuccess(tsv)
            }
        }
    }
}

struct ImportSheet: View {
    private enum ImportState {
        case prompt
        case importReady(Bool)
        case success(Int)
        case failure(String)
        
        func shouldDelete() -> Bool {
            switch self {
                case .prompt, .success(_), .failure(_): return false
                case .importReady(let replace): return replace
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss
    @State var importPresented = false
    @State private var importState : ImportState = .prompt
    @Environment(\.modelContext) private var modelContext
    @Query var userGeneratedLiftTypes: [UserGeneratedLiftType]
   
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Import data into Planetary Lifts")
                    .multilineTextAlignment(.leading)
                switch self.importState{
                case .prompt:
                    HStack {
                        Button("Erase and Import", role: .destructive) {
                            importState = .importReady(true)
                            importPresented = true
                        }.tint(.red)
                        Button("Import") {
                            importState = .importReady(false)
                            importPresented = true
                        }
                    }.buttonStyle(.borderedProminent)
                case .importReady(_):
                    ProgressView()
                case .success(let count):
                    Text("Imported \(count) lifts!")
                    Button("Close") { dismiss() }
                case .failure(let error):
                    Text("Failed to import lifts with error \(error)!")
                }
            }
            .padding(20)
            .navigationTitle("Import")
            .toolbar(content: {
                ToolbarItem(id: "Cancel", placement: .topBarTrailing) {
                    Button("Cancel"){
                        dismiss()
                    }
                }
            })
            .fileImporter(isPresented: $importPresented, allowedContentTypes: [.tabSeparatedText], onCompletion: { result in
                print("File importer finished with result \(result)")
                switch result {
                case .success(let importUrl):
                    switch importLifts(from: importUrl) {
                    case .success((let lifts, let userTypes)):
                        print("Got \(lifts.count) lifts from import")
                        // If the user requested to replace their data
                        if importState.shouldDelete() {
                            do {
                                try modelContext.delete(model: Lift.self)
                                try modelContext.delete(model: UserGeneratedLiftType.self)
                            } catch {
                                print("Failed to delete \(error.localizedDescription)")
                                importState = .failure(error.localizedDescription)
                                return
                            }
                        }
                        for lift in lifts {
                            modelContext.insert(lift)
                        }
                        for userType in userTypes {
                            if userGeneratedLiftTypes.contains(where: {$0.name == userType.name && $0.category == userType.category}) { continue }
                            modelContext.insert(userType)
                        }
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save")
                            importState = .failure(error.localizedDescription)
                        }
                        importState = .success(lifts.count)
                    case .failure(let error):
                        print("Failed getting entries: \(error)")
                        importState = .failure("Failed opening entries from file with error: \(error)")
                    }
                case .failure(let error):
                    print("Failed getting directory for import with error: \(error)")
                    importState = .failure(error.localizedDescription)
                }
            })
            
        }
    }
}

