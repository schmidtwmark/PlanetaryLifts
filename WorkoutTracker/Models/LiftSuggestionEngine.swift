//
//  LiftSuggestionEngine.swift
//  WorkoutTracker
//
//  Created by Mark Schmidt on 8/31/26.
//

import Foundation
import SwiftData
import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

enum SuggestionModel: String, CaseIterable {
    case onDevice
    case privateCloudCompute

    var displayName: String {
        switch self {
        case .onDevice: "On Device"
        case .privateCloudCompute: "Private Cloud Compute"
        }
    }
}

struct LiftSuggestion: Identifiable {
    var id: String {
        type.id
    }

    var type: LiftType
    var reason: String
}

// App-wide owner of the AI suggestions so they are generated once in the
// background and every screen shows the same result.
@Observable
@MainActor
final class SuggestionStore {
    enum Status {
        // Before iOS 26 there is no on-device model; suggestions are hidden
        case unsupported
        case unavailable(String)
        case loading
        case ready(LiftSuggestionEngine.AIResult)
        case failed
    }

    private(set) var status: Status
    private var task: Task<Void, Never>?

    init() {
        if !LiftSuggestionEngine.isSupported {
            status = .unsupported
        } else if let reason = LiftSuggestionEngine.unavailableReason {
            status = .unavailable(reason)
        } else {
            status = .loading
        }
    }

    // Previous results stay visible while a refresh runs; the spinner only
    // shows before the first result exists.
    // clearingResults shows the spinner instead of the previous results, for
    // when those came from a model the user just switched away from
    func refresh(modelContext: ModelContext, after delay: Duration = .zero, clearingResults: Bool = false) {
        task?.cancel()
        guard LiftSuggestionEngine.isSupported else {
            status = .unsupported
            return
        }
        if let reason = LiftSuggestionEngine.unavailableReason {
            status = .unavailable(reason)
            return
        }
        if clearingResults {
            status = .loading
        }
        task = Task {
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }
            let hasResult = if case .ready = status { true } else { false }
            if !hasResult {
                status = .loading
            }
            let result = await LiftSuggestionEngine.generate(modelContext: modelContext)
            guard !Task.isCancelled else { return }
            if let result = result {
                status = .ready(result)
            } else if !hasResult {
                status = .failed
            }
        }
    }
}

struct SuggestionsLoadingView: View {
    var body: some View {
        HStack(spacing: 8.0) {
            ProgressView()
            Text("Analyzing your recent lifts…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Regenerates from scratch, discarding the current suggestions
struct SuggestionsRefreshButton: View {
    @Environment(SuggestionStore.self) private var store: SuggestionStore?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if let store = store, case .ready = store.status {
            Button {
                store.refresh(modelContext: modelContext, clearingResults: true)
            } label: {
                Label("Refresh Suggestions", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

// Shown in place of suggestions when there's nothing to show
struct SuggestionsMessageView: View {
    var status: SuggestionStore.Status
    var retry: () -> Void

    var body: some View {
        VStack(spacing: 8.0) {
            switch status {
            case .unavailable(let reason):
                Text(reason)
            case .failed:
                Text("Couldn't generate suggestions.")
                Button("Try Again", action: retry)
            default:
                EmptyView()
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

// Hands a foundation model (on-device, or Private Cloud Compute when enabled)
// the user's training history and the full lift catalog, and lets it pick
// what to do next.
@MainActor
enum LiftSuggestionEngine {

    static let sessionHistoryDays = 56
    static let suggestionCount = 5
    // Room left in the context window for the generated response
    static let responseTokenReserve = 700

    struct AIResult {
        var summary: String
        var suggestions: [LiftSuggestion]
        var model: SuggestionModel
    }

    static var isSupported: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    // Private Cloud Compute needs Apple's managed
    // com.apple.developer.private-cloud-compute entitlement; without it any
    // PCC request crashes the app instead of throwing. Once the entitlement is
    // granted, add it to WorkoutTracker.entitlements and add
    // PRIVATE_CLOUD_COMPUTE to Active Compilation Conditions.
    static var isPrivateCloudComputeBuilt: Bool {
        #if PRIVATE_CLOUD_COMPUTE
        return true
        #else
        return false
        #endif
    }

    static var selectedModel: SuggestionModel {
        guard isPrivateCloudComputeBuilt,
              let raw = UserDefaults.standard.string(forKey: SUGGESTION_MODEL),
              let model = SuggestionModel(rawValue: raw) else {
            return .onDevice
        }
        return model
    }

    // Name of the on-device model variant, e.g. "AFM 3 Core Advanced"
    static var onDeviceModelName: String? {
        #if canImport(FoundationModels)
        if #available(iOS 27.0, *) {
            return SystemLanguageModel.default.variant.displayName
        }
        #endif
        return nil
    }

    // Apple's guardrails reject some phrasings of this as sensitive (for
    // example asking the model to "identify the user's training patterns"
    // from their history), so reword carefully and re-test after changes.
    private static let pickingInstructions = """
    You are a workout planning assistant inside a lift tracking app. Choose \
    the lifts that best fit the next workout. Favor lifts that have been done \
    before, and include something for muscle groups that have gone the \
    longest without training. Avoid lifts that work the same muscles as the \
    most recent session.
    """

    static let instructions = pickingInstructions + """
     For each pick, give a short reason under 10 words \
    saying why it fits the next workout, such as how many days since it or \
    its muscles were last trained. Do not repeat the lift's name in the reason.
    """

    // The larger PCC model follows tight word limits too literally and
    // compresses every reason into "Muscle, N days", so it gets a full
    // sentence and is steered away from leaning on dates
    static let privateCloudInstructions = pickingInstructions + """
     For each pick, give one short sentence, under 15 \
    words, explaining what the lift adds to the next workout, such as the \
    muscle group it covers or how it balances recent sessions. Only mention \
    days since last done when that is the main reason. Do not repeat the \
    lift's name in the reason.
    """
    static let reasonDescription = "Why this lift, under 10 words, without repeating its name"
    static let privateCloudReasonDescription = "One short sentence on what this lift adds to the next workout, without repeating its name"

    // The output guardrail occasionally trips on an otherwise fine response
    static let maxAttempts = 3

    // nil when the model can run; otherwise a message for the user
    static var unavailableReason: String? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return nil
            case .unavailable(.appleIntelligenceNotEnabled):
                return "Turn on Apple Intelligence in Settings to get lift suggestions."
            case .unavailable(.modelNotReady):
                return "Lift suggestions will be available once Apple Intelligence finishes downloading."
            default:
                break
            }
        }
        #endif
        return "Lift suggestions require a device that supports Apple Intelligence."
    }

    static func generate(modelContext: ModelContext) async -> AIResult? {
        #if canImport(FoundationModels)
        guard #available(iOS 26.0, *), unavailableReason == nil else { return nil }
        do {
            let userGeneratedTypes = try modelContext.fetch(FetchDescriptor<UserGeneratedLiftType>())
            let history = try modelContext.fetch(FetchDescriptor<Lift>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)]))
            let catalog = liftCatalog(userGeneratedTypes: userGeneratedTypes)
            let byName = Dictionary(catalog.map({ ($0.string, $0) }), uniquingKeysWith: { first, _ in first })

            let startOfToday = Calendar.autoupdatingCurrent.startOfDay(for: Date())
            let doneToday = Set(history.prefix(while: { $0.timestamp >= startOfToday }).map({ $0.type.string }))
            let eligibleNames = catalog.map({ $0.string }).filter({ !doneToday.contains($0) })
            #if PRIVATE_CLOUD_COMPUTE
            // Falls through to the on-device model when offline, over quota, or failing
            if selectedModel == .privateCloudCompute, #available(iOS 27.0, *),
               let content = await respondWithPrivateCloudCompute(history: history, catalog: catalog, userGeneratedTypes: userGeneratedTypes,
                                                                  schema: try responseSchema(liftNames: eligibleNames, reasonDescription: privateCloudReasonDescription)) {
                return try parse(content, byName: byName, model: .privateCloudCompute)
            }
            #endif

            let schema = try responseSchema(liftNames: eligibleNames, reasonDescription: reasonDescription)

            let prompt = await fittedPrompt(history: history, catalog: catalog, userGeneratedTypes: userGeneratedTypes, schema: schema)
            guard let content = await respond({
                try await LanguageModelSession(instructions: instructions)
                    .respond(to: prompt, schema: schema, options: GenerationOptions(temperature: 0.3)).content
            }) else {
                return nil
            }
            return try parse(content, byName: byName, model: .onDevice)
        } catch {
            print("Suggestion generation failed: \(error)")
            return nil
        }
        #else
        return nil
        #endif
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    static func respond(_ attempt: () async throws -> GeneratedContent) async -> GeneratedContent? {
        for number in 1...maxAttempts {
            guard !Task.isCancelled else { return nil }
            do {
                return try await attempt()
            } catch {
                print("Suggestion attempt \(number) failed: \(error)")
            }
        }
        return nil
    }

    @available(iOS 26.0, *)
    static func parse(_ content: GeneratedContent, byName: [String: LiftType], model: SuggestionModel) throws -> AIResult? {
        #if DEBUG
        print("Suggestions from \(model.displayName): \(content.jsonString)")
        #endif
        let summary = try content.value(String.self, forProperty: "trainingPattern")
        let picks = try content.value([GeneratedContent].self, forProperty: "picks")

        var seen = Set<String>()
        var suggestions: [LiftSuggestion] = []
        for pick in picks {
            let name = try pick.value(String.self, forProperty: "lift")
            let reason = try pick.value(String.self, forProperty: "reason")
            guard let type = byName[name], seen.insert(name).inserted else { continue }
            suggestions.append(LiftSuggestion(type: type, reason: cleanReason(reason, liftName: name)))
        }
        guard !suggestions.isEmpty else { return nil }
        return AIResult(summary: summary, suggestions: suggestions, model: model)
    }
    #endif

    #if PRIVATE_CLOUD_COMPUTE
    // The 32K-token server context fits far more history than on-device
    static let privateCloudHistoryDays = 182
    static let privateCloudSessionLimit = 60

    @available(iOS 27.0, *)
    static func respondWithPrivateCloudCompute(history: [Lift], catalog: [LiftType], userGeneratedTypes: [UserGeneratedLiftType], schema: GenerationSchema) async -> GeneratedContent? {
        let model = PrivateCloudComputeLanguageModel()
        guard model.isAvailable, !model.quotaUsage.isLimitReached else { return nil }
        let prompt = buildPrompt(history: history, catalog: catalog, userGeneratedTypes: userGeneratedTypes,
                                 sessionLimit: privateCloudSessionLimit, historyDays: privateCloudHistoryDays)
        // Default sampling plus reasoning; the low temperature that keeps the
        // small on-device model coherent makes this one formulaic
        return await respond({
            try await LanguageModelSession(model: model, instructions: privateCloudInstructions)
                .respond(to: prompt, schema: schema, contextOptions: ContextOptions(includeSchemaInPrompt: true, reasoningLevel: .moderate)).content
        })
    }
    #endif

    // Built-in lifts plus the user's custom ones, with unique names because
    // the model answers with a name
    static func liftCatalog(userGeneratedTypes: [UserGeneratedLiftType]) -> [LiftType] {
        let all = LiftType.allCases + userGeneratedTypes.map({ .other(name: $0.name, category: $0.category, id: $0.id) })
        var names = Set<String>()
        return all.filter({ names.insert($0.string).inserted })
    }

    #if canImport(FoundationModels)
    // Built at runtime so the lift name is constrained to the catalog, and
    // generated before its reason so the reason is written about that lift.
    // Nested schemas are inlined, so they must not also be passed as
    // dependencies or GenerationSchema throws duplicateType.
    @available(iOS 26.0, *)
    static func responseSchema(liftNames: [String], reasonDescription: String) throws -> GenerationSchema {
        let pick = DynamicGenerationSchema(name: "Pick", properties: [
            .init(name: "lift",
                  description: "The chosen lift from the catalog",
                  schema: DynamicGenerationSchema(name: "LiftName", anyOf: liftNames)),
            .init(name: "reason",
                  description: reasonDescription,
                  schema: DynamicGenerationSchema(type: String.self)),
        ])
        let root = DynamicGenerationSchema(name: "SuggestionResponse", properties: [
            .init(name: "trainingPattern",
                  description: "One or two sentences describing the user's training pattern, addressed to the user",
                  schema: DynamicGenerationSchema(type: String.self)),
            .init(name: "picks",
                  description: "The \(suggestionCount) best lifts for the user's next workout, best first",
                  schema: DynamicGenerationSchema(arrayOf: pick, minimumElements: suggestionCount, maximumElements: suggestionCount)),
        ])
        return try GenerationSchema(root: root, dependencies: [])
    }

    // Drops the oldest sessions until the prompt fits the context window.
    // Token counting needs iOS 26.4; older systems use a fixed session cap.
    @available(iOS 26.0, *)
    static func fittedPrompt(history: [Lift], catalog: [LiftType], userGeneratedTypes: [UserGeneratedLiftType], schema: GenerationSchema) async -> String {
        var sessionLimit = 20
        guard #available(iOS 26.4, *) else {
            return buildPrompt(history: history, catalog: catalog, userGeneratedTypes: userGeneratedTypes, sessionLimit: 12)
        }
        let model = SystemLanguageModel.default
        let fixedCost = ((try? await model.tokenCount(for: Instructions(instructions))) ?? 0)
            + ((try? await model.tokenCount(for: schema)) ?? 0)
        let budget = model.contextSize - fixedCost - responseTokenReserve
        while true {
            let prompt = buildPrompt(history: history, catalog: catalog, userGeneratedTypes: userGeneratedTypes, sessionLimit: sessionLimit)
            guard sessionLimit > 0, let tokens = try? await model.tokenCount(for: prompt), tokens > budget else {
                return prompt
            }
            sessionLimit -= sessionLimit > 8 ? 4 : 2
        }
    }
    #endif

    // The model sometimes opens with the lift name despite instructions
    static func cleanReason(_ reason: String, liftName: String) -> String {
        var cleaned = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        for prefix in ["The \(liftName)", liftName] {
            if cleaned.lowercased().hasPrefix(prefix.lowercased()) {
                cleaned = String(cleaned.dropFirst(prefix.count))
                break
            }
        }
        let separators = CharacterSet.whitespaces.union(CharacterSet(charactersIn: ":-–—,"))
        cleaned = String(cleaned.drop(while: { $0.unicodeScalars.allSatisfy(separators.contains) }))
        guard let first = cleaned.first else { return reason }
        return first.uppercased() + cleaned.dropFirst()
    }

    // The model is small, so the digest does the arithmetic up front: a
    // per-day log of recent sessions, then every lift with lifetime count
    // and days since last done.
    static func buildPrompt(history: [Lift],
                            catalog: [LiftType],
                            userGeneratedTypes: [UserGeneratedLiftType],
                            sessionLimit: Int,
                            historyDays: Int = sessionHistoryDays) -> String {
        let calendar = Calendar.autoupdatingCurrent
        let today = calendar.startOfDay(for: Date())
        let sessionCutoff = calendar.date(byAdding: .day, value: -historyDays, to: today) ?? today
        let dayFormat = Date.FormatStyle().month(.abbreviated).day()
        func daysAgo(_ date: Date) -> Int {
            calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: today).day ?? 0
        }

        var sessions: [(day: Date, lines: [String])] = []
        for lift in history where lift.timestamp >= sessionCutoff {
            let day = calendar.startOfDay(for: lift.timestamp)
            let topWeight = lift.weighted ? lift.sets.map({ $0.weight.roundedWeight }).max() : nil
            var line = "\(lift.type.string) (\(lift.sets.count) sets"
            if let topWeight = topWeight, topWeight > 0 {
                line += ", top \(topWeight.clean)"
            }
            line += ")"
            if let last = sessions.last, last.day == day {
                sessions[sessions.count - 1].lines.append(line)
            } else {
                if sessions.count == sessionLimit { break }
                sessions.append((day: day, lines: [line]))
            }
        }
        let sessionLines = sessions.map { session in
            let ago = daysAgo(session.day)
            let when = ago == 0 ? "today" : "\(ago)d ago"
            return "\(session.day.formatted(dayFormat)) (\(when)): \(session.lines.joined(separator: ", "))"
        }

        var frequency: [String: Int] = [:]
        var lastDone: [String: Date] = [:]
        for lift in history {
            let name = lift.type.string
            frequency[name, default: 0] += 1
            if lastDone[name] == nil {
                lastDone[name] = lift.timestamp
            }
        }

        let catalogLines = catalog.map { type in
            let muscles = type.getLiftWeights(userGeneratedTypes).sortedGroups
                .prefix(3).map({ $0.0.rawValue }).joined(separator: ", ")
            let name = type.string
            let usage: String
            if let count = frequency[name], let last = lastDone[name] {
                let ago = daysAgo(last)
                usage = "done \(count)x, " + (ago == 0 ? "today" : "last \(ago)d ago")
            } else {
                usage = "never done"
            }
            return "- \(name) [\(muscles)]: \(usage)"
        }

        let sessionSection = sessionLines.isEmpty
            ? "The user has not logged any lifts recently."
            : sessionLines.joined(separator: "\n")

        return """
        Recent training sessions (most recent first):
        \(sessionSection)

        Lift catalog [muscles worked]: the user's history with each lift
        \(catalogLines.joined(separator: "\n"))

        Pick the \(suggestionCount) lifts from the catalog that best fit the user's next workout.
        """
    }
}
