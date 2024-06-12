// This code is automatically generated. DO NOT EDIT.


import Foundation


enum LiftType: Hashable, Codable{

	// MARK: Arms
	case bicepCurl
	case hammerCurl
	case kettleBellSwing
	case skullcrushers
	case tricepExtensions
	case preacherCurls
	case lateralRaises
	case tricepKickback
	case arnoldPress
	case tricepPushdown
	// MARK: Back
	case backSquat
	case deadlift
	case latPulldowns
	case hackSquat
	case backExtensions
	case chestSupportedRow
	case bentOverRow
	case seatedRow
	// MARK: Chest
	case benchPress
	case vikingPress
	case landminePress
	case pushups
	case floorPress
	case flyes
	case dip
	case chestPress
	// MARK: Core
	case renegadeRow
	case plank
	case sidePlank
	case russianTwists
	case sideBends
	case plankPullThrough
	// MARK: Glutes
	case hipThrust
	case reverseHyperextension
	case kickbacks
	case romanainDeadlifts
	case goodMornings
	case stepUps
	// MARK: Legs
	case frontSquat
	case hipAdduction
	case lateralLunge
	case lunge
	case legPressMachine
	case legExtensionMachine
	case hamstringCurls
	case gobletSquat
	case bulgarianSplitSquat
	// MARK: Shoulders
	case overheadPress
	case facePull
	case uprightRow
	case frontRaise
	// MARK: user specified
	case other(name: String, category: LiftCategory, id: UUID)


	static var allCases: [LiftType] = [
		// MARK: Arms
		.bicepCurl,
		.hammerCurl,
		.kettleBellSwing,
		.skullcrushers,
		.tricepExtensions,
		.preacherCurls,
		.lateralRaises,
		.tricepKickback,
		.arnoldPress,
		.tricepPushdown,
		// MARK: Back
		.backSquat,
		.deadlift,
		.latPulldowns,
		.hackSquat,
		.backExtensions,
		.chestSupportedRow,
		.bentOverRow,
		.seatedRow,
		// MARK: Chest
		.benchPress,
		.vikingPress,
		.landminePress,
		.pushups,
		.floorPress,
		.flyes,
		.dip,
		.chestPress,
		// MARK: Core
		.renegadeRow,
		.plank,
		.sidePlank,
		.russianTwists,
		.sideBends,
		.plankPullThrough,
		// MARK: Glutes
		.hipThrust,
		.reverseHyperextension,
		.kickbacks,
		.romanainDeadlifts,
		.goodMornings,
		.stepUps,
		// MARK: Legs
		.frontSquat,
		.hipAdduction,
		.lateralLunge,
		.lunge,
		.legPressMachine,
		.legExtensionMachine,
		.hamstringCurls,
		.gobletSquat,
		.bulgarianSplitSquat,
		// MARK: Shoulders
		.overheadPress,
		.facePull,
		.uprightRow,
		.frontRaise,
	]

	var string: String {
		return switch self {
		// MARK: Arms
		case .bicepCurl: "Bicep Curl"
		case .hammerCurl: "Hammer Curl"
		case .kettleBellSwing: "Kettle Bell Swing"
		case .skullcrushers: "Skullcrushers"
		case .tricepExtensions: "Tricep Extensions"
		case .preacherCurls: "Preacher Curls"
		case .lateralRaises: "Lateral Raises"
		case .tricepKickback: "Tricep Kickback"
		case .arnoldPress: "Arnold Press"
		case .tricepPushdown: "Tricep Pushdown "

		// MARK: Back
		case .backSquat: "Back Squat"
		case .deadlift: "Deadlift"
		case .latPulldowns: "Lat Pulldowns"
		case .hackSquat: "Hack Squat"
		case .backExtensions: "Back Extensions"
		case .chestSupportedRow: "Chest Supported Row"
		case .bentOverRow: "Bent Over Row"
		case .seatedRow: "Seated Row"

		// MARK: Chest
		case .benchPress: "Bench Press"
		case .vikingPress: "Viking Press"
		case .landminePress: "Landmine Press"
		case .pushups: "Pushups"
		case .floorPress: "Floor Press"
		case .flyes: "Flyes"
		case .dip: "Dip"
		case .chestPress: "Chest Press"

		// MARK: Core
		case .renegadeRow: "Renegade Row"
		case .plank: "Plank"
		case .sidePlank: "Side Plank"
		case .russianTwists: "Russian Twists"
		case .sideBends: "Side Bends"
		case .plankPullThrough: "Plank Pull through"

		// MARK: Glutes
		case .hipThrust: "Hip Thrust"
		case .reverseHyperextension: "Reverse Hyperextension"
		case .kickbacks: "Kickbacks"
		case .romanainDeadlifts: "Romanain Deadlifts"
		case .goodMornings: "Good Mornings"
		case .stepUps: "Step Ups"

		// MARK: Legs
		case .frontSquat: "Front Squat"
		case .hipAdduction: "Hip Adduction"
		case .lateralLunge: "Lateral Lunge"
		case .lunge: "Lunge"
		case .legPressMachine: "Leg Press Machine"
		case .legExtensionMachine: "Leg Extension Machine"
		case .hamstringCurls: "Hamstring Curls"
		case .gobletSquat: "Goblet Squat"
		case .bulgarianSplitSquat: "Bulgarian Split Squat"

		// MARK: Shoulders
		case .overheadPress: "Overhead Press"
		case .facePull: "Face Pull"
		case .uprightRow: "Upright Row"
		case .frontRaise: "Front Raise"

		case .other(let name, _, _): name
		}
	}

	var category: LiftCategory {
		return switch self {
		// MARK: Arms
		case .bicepCurl: .arms
		case .hammerCurl: .arms
		case .kettleBellSwing: .arms
		case .skullcrushers: .arms
		case .tricepExtensions: .arms
		case .preacherCurls: .arms
		case .lateralRaises: .arms
		case .tricepKickback: .arms
		case .arnoldPress: .arms
		case .tricepPushdown: .arms

		// MARK: Back
		case .backSquat: .back
		case .deadlift: .back
		case .latPulldowns: .back
		case .hackSquat: .back
		case .backExtensions: .back
		case .chestSupportedRow: .back
		case .bentOverRow: .back
		case .seatedRow: .back

		// MARK: Chest
		case .benchPress: .chest
		case .vikingPress: .chest
		case .landminePress: .chest
		case .pushups: .chest
		case .floorPress: .chest
		case .flyes: .chest
		case .dip: .chest
		case .chestPress: .chest

		// MARK: Core
		case .renegadeRow: .core
		case .plank: .core
		case .sidePlank: .core
		case .russianTwists: .core
		case .sideBends: .core
		case .plankPullThrough: .core

		// MARK: Glutes
		case .hipThrust: .glutes
		case .reverseHyperextension: .glutes
		case .kickbacks: .glutes
		case .romanainDeadlifts: .glutes
		case .goodMornings: .glutes
		case .stepUps: .glutes

		// MARK: Legs
		case .frontSquat: .legs
		case .hipAdduction: .legs
		case .lateralLunge: .legs
		case .lunge: .legs
		case .legPressMachine: .legs
		case .legExtensionMachine: .legs
		case .hamstringCurls: .legs
		case .gobletSquat: .legs
		case .bulgarianSplitSquat: .legs

		// MARK: Shoulders
		case .overheadPress: .shoulders
		case .facePull: .shoulders
		case .uprightRow: .shoulders
		case .frontRaise: .shoulders

		case .other(_, let category, _): category
		}
	}

	var modifiers: [LiftModifier] {
		return switch self {
		// MARK: Arms
		case .bicepCurl: [.incline, .oneArm, .reverse, .barbell, .dumbbell, .cable]
		case .hammerCurl: [.dumbbell]
		case .skullcrushers: [.incline, .decline, .dumbbell]
		case .tricepExtensions: [.incline, .oneArm, .dumbbell, .cable]
		case .preacherCurls: [.oneArm, .barbell, .dumbbell, .cable]
		case .lateralRaises: [.oneArm, .dumbbell]
		case .tricepKickback: [.oneArm, .dumbbell]
		case .arnoldPress: [.oneArm, .dumbbell]
		case .tricepPushdown: [.oneArm, .cable]

		// MARK: Back
		case .backSquat: [.barbell, .dumbbell]
		case .deadlift: [.narrowGrip, .wideGrip, .barbell, .hexBar]
		case .latPulldowns: [.narrowGrip, .wideGrip, .cable]
		case .chestSupportedRow: [.incline, .narrowGrip, .wideGrip, .oneArm, .barbell, .dumbbell]
		case .bentOverRow: [.oneArm, .dumbbell]
		case .seatedRow: [.narrowGrip, .wideGrip, .oneArm, .dumbbell, .cable]

		// MARK: Chest
		case .benchPress: [.incline, .decline, .narrowGrip, .wideGrip, .barbell, .dumbbell, .multiGripBar]
		case .vikingPress: [.narrowGrip, .wideGrip]
		case .pushups: [.incline, .narrowGrip, .wideGrip, .oneArm]
		case .floorPress: [.narrowGrip, .wideGrip, .oneArm, .barbell, .dumbbell, .multiGripBar]
		case .flyes: [.incline, .decline, .reverse, .dumbbell, .cable]
		case .dip: [.narrowGrip, .wideGrip]
		case .chestPress: [.narrowGrip, .wideGrip, .cable]

		// MARK: Core
		case .renegadeRow: [.oneArm, .dumbbell]
		case .sidePlank: [.incline]
		case .sideBends: [.oneArm, .dumbbell]
		case .plankPullThrough: [.incline]

		// MARK: Glutes
		case .kickbacks: [.cable]
		case .romanainDeadlifts: [.narrowGrip, .wideGrip, .barbell, .dumbbell]
		case .goodMornings: [.barbell]
		case .stepUps: [.dumbbell]

		// MARK: Legs
		case .frontSquat: [.barbell, .dumbbell]
		case .lateralLunge: [.dumbbell]
		case .lunge: [.incline, .decline, .reverse, .dumbbell]
		case .gobletSquat: [.incline, .decline, .dumbbell]
		case .bulgarianSplitSquat: [.barbell]

		// MARK: Shoulders
		case .overheadPress: [.narrowGrip, .wideGrip, .dumbbell, .multiGripBar]
		case .facePull: [.cable]
		case .uprightRow: [.narrowGrip, .wideGrip, .oneArm, .barbell, .dumbbell, .cable]
		case .frontRaise: [.oneArm, .dumbbell, .cable]

		default: []
		}
	}

}

