// This code is automatically generated. DO NOT EDIT.


import Foundation


enum LiftType: Hashable, Codable{

	// MARK: Arms
	case bicepCurl
	case hammerCurl
	case reverseHyperextension
	case kettleBellSwing
	case skullcrushers
	case tricepExtensions
	// MARK: Back
	case backSquat
	case frontSquat
	case deadlift
	case latPulldowns
	case hackSquat
	case backExtensions
	case row
	// MARK: Chest
	case benchPress
	case vikingPress
	case landminePress
	case pushups
	case plankPullThrough
	// MARK: Core
	case hipAdduction
	case hipThrust
	// MARK: Legs
	case gobletSquat
	case lunge
	case legPressMachine
	case legExtensionMachine
	case hamstringCurls
	// MARK: Shoulders
	case overheadPress
	// MARK: user specified
	case other(name: String, category: LiftCategory, id: UUID)


	static var allCases: [LiftType] = [
		// MARK: Arms
		.bicepCurl,
		.hammerCurl,
		.reverseHyperextension,
		.kettleBellSwing,
		.skullcrushers,
		.tricepExtensions,
		// MARK: Back
		.backSquat,
		.frontSquat,
		.deadlift,
		.latPulldowns,
		.hackSquat,
		.backExtensions,
		.row,
		// MARK: Chest
		.benchPress,
		.vikingPress,
		.landminePress,
		.pushups,
		.plankPullThrough,
		// MARK: Core
		.hipAdduction,
		.hipThrust,
		// MARK: Legs
		.gobletSquat,
		.lunge,
		.legPressMachine,
		.legExtensionMachine,
		.hamstringCurls,
		// MARK: Shoulders
		.overheadPress,
	]

	var string: String {
		return switch self {
		// MARK: Arms
		case .bicepCurl: "Bicep Curl"
		case .hammerCurl: "Hammer Curl"
		case .reverseHyperextension: "Reverse Hyperextension"
		case .kettleBellSwing: "Kettle Bell Swing"
		case .skullcrushers: "Skullcrushers"
		case .tricepExtensions: "Tricep Extensions"

		// MARK: Back
		case .backSquat: "Back Squat"
		case .frontSquat: "Front Squat"
		case .deadlift: "Deadlift"
		case .latPulldowns: "Lat Pulldowns"
		case .hackSquat: "Hack Squat"
		case .backExtensions: "Back Extensions"
		case .row: "Row"

		// MARK: Chest
		case .benchPress: "Bench Press"
		case .vikingPress: "Viking Press"
		case .landminePress: "Landmine Press"
		case .pushups: "Pushups"
		case .plankPullThrough: "Plank Pull through"

		// MARK: Core
		case .hipAdduction: "Hip Adduction"
		case .hipThrust: "Hip Thrust"

		// MARK: Legs
		case .gobletSquat: "Goblet Squat"
		case .lunge: "Lunge"
		case .legPressMachine: "Leg Press Machine"
		case .legExtensionMachine: "Leg Extension Machine"
		case .hamstringCurls: "Hamstring Curls"

		// MARK: Shoulders
		case .overheadPress: "Overhead Press"

		case .other(let name, _, _): name
		}
	}

	var category: LiftCategory {
		return switch self {
		// MARK: Arms
		case .bicepCurl: .arms
		case .hammerCurl: .arms
		case .reverseHyperextension: .arms
		case .kettleBellSwing: .arms
		case .skullcrushers: .arms
		case .tricepExtensions: .arms

		// MARK: Back
		case .backSquat: .back
		case .frontSquat: .back
		case .deadlift: .back
		case .latPulldowns: .back
		case .hackSquat: .back
		case .backExtensions: .back
		case .row: .back

		// MARK: Chest
		case .benchPress: .chest
		case .vikingPress: .chest
		case .landminePress: .chest
		case .pushups: .chest
		case .plankPullThrough: .chest

		// MARK: Core
		case .hipAdduction: .core
		case .hipThrust: .core

		// MARK: Legs
		case .gobletSquat: .legs
		case .lunge: .legs
		case .legPressMachine: .legs
		case .legExtensionMachine: .legs
		case .hamstringCurls: .legs

		// MARK: Shoulders
		case .overheadPress: .shoulders

		case .other(_, let category, _): category
		}
	}

	var modifiers: [LiftModifier] {
		return switch self {
		// MARK: Arms
		case .bicepCurl: [.incline, .oneArm, .reverse, .barbell, .dumbbell]
		case .skullcrushers: [.incline, .decline]
		case .tricepExtensions: [.incline, .oneArm, .dumbbell, .cable]

		// MARK: Back
		case .backSquat: [.barbell, .dumbbell]
		case .frontSquat: [.barbell, .dumbbell]
		case .deadlift: [.narrowGrip, .wideGrip, .barbell, .hexBar]
		case .latPulldowns: [.narrowGrip, .wideGrip]
		case .row: [.oneArm, .cable]

		// MARK: Chest
		case .benchPress: [.incline, .decline, .narrowGrip, .wideGrip, .barbell, .dumbbell, .multiGripBar]
		case .vikingPress: [.narrowGrip, .wideGrip]
		case .pushups: [.incline, .narrowGrip, .wideGrip, .oneArm]
		case .plankPullThrough: [.incline]

		// MARK: Core

		// MARK: Legs
		case .lunge: [.reverse, .dumbbell]

		// MARK: Shoulders
		case .overheadPress: [.narrowGrip, .wideGrip, .multiGripBar]

		default: []
		}
	}

}

