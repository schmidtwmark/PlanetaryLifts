// This code is automatically generated. DO NOT EDIT.


import Foundation


enum LiftType: Hashable, Codable, Sendable {

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
	case landminePress
	// MARK: Back
	case deadlift
	case latPulldowns
	case backExtensions
	case row
	case chestSupportedRow
	case bentOverRow
	case seatedRow
	case pullUp
	// MARK: Chest
	case benchPress
	case vikingPress
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
	case legRaises
	// MARK: Glutes
	case hipThrust
	case reverseHyperextension
	case kickbacks
	case romanainDeadlifts
	case goodMornings
	case stepUps
	// MARK: Legs
	case backSquat
	case hackSquat
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


	static let allCases: [LiftType] = [
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
		.landminePress,
		// MARK: Back
		.deadlift,
		.latPulldowns,
		.backExtensions,
		.row,
		.chestSupportedRow,
		.bentOverRow,
		.seatedRow,
		.pullUp,
		// MARK: Chest
		.benchPress,
		.vikingPress,
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
		.legRaises,
		// MARK: Glutes
		.hipThrust,
		.reverseHyperextension,
		.kickbacks,
		.romanainDeadlifts,
		.goodMornings,
		.stepUps,
		// MARK: Legs
		.backSquat,
		.hackSquat,
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
		case .landminePress: "Landmine Press"

		// MARK: Back
		case .deadlift: "Deadlift"
		case .latPulldowns: "Lat Pulldowns"
		case .backExtensions: "Back Extensions"
		case .row: "Row"
		case .chestSupportedRow: "Chest Supported Row"
		case .bentOverRow: "Bent Over Row"
		case .seatedRow: "Seated Row"
		case .pullUp: "Pull Up"

		// MARK: Chest
		case .benchPress: "Bench Press"
		case .vikingPress: "Viking Press"
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
		case .plankPullThrough: "Plank Pull Through"
		case .legRaises: "Leg Raises"

		// MARK: Glutes
		case .hipThrust: "Hip Thrust"
		case .reverseHyperextension: "Reverse Hyperextension"
		case .kickbacks: "Kickbacks"
		case .romanainDeadlifts: "Romanain Deadlifts"
		case .goodMornings: "Good Mornings"
		case .stepUps: "Step Ups"

		// MARK: Legs
		case .backSquat: "Back Squat"
		case .hackSquat: "Hack Squat"
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

	init?(from: String) {
		 switch from {
		// MARK: Arms
		case "Bicep Curl": self = .bicepCurl
		case "Hammer Curl": self = .hammerCurl
		case "Kettle Bell Swing": self = .kettleBellSwing
		case "Skullcrushers": self = .skullcrushers
		case "Tricep Extensions": self = .tricepExtensions
		case "Preacher Curls": self = .preacherCurls
		case "Lateral Raises": self = .lateralRaises
		case "Tricep Kickback": self = .tricepKickback
		case "Arnold Press": self = .arnoldPress
		case "Tricep Pushdown ": self = .tricepPushdown
		case "Landmine Press": self = .landminePress

		// MARK: Back
		case "Deadlift": self = .deadlift
		case "Lat Pulldowns": self = .latPulldowns
		case "Back Extensions": self = .backExtensions
		case "Row": self = .row
		case "Chest Supported Row": self = .chestSupportedRow
		case "Bent Over Row": self = .bentOverRow
		case "Seated Row": self = .seatedRow
		case "Pull Up": self = .pullUp

		// MARK: Chest
		case "Bench Press": self = .benchPress
		case "Viking Press": self = .vikingPress
		case "Pushups": self = .pushups
		case "Floor Press": self = .floorPress
		case "Flyes": self = .flyes
		case "Dip": self = .dip
		case "Chest Press": self = .chestPress

		// MARK: Core
		case "Renegade Row": self = .renegadeRow
		case "Plank": self = .plank
		case "Side Plank": self = .sidePlank
		case "Russian Twists": self = .russianTwists
		case "Side Bends": self = .sideBends
		case "Plank Pull Through": self = .plankPullThrough
		case "Leg Raises": self = .legRaises

		// MARK: Glutes
		case "Hip Thrust": self = .hipThrust
		case "Reverse Hyperextension": self = .reverseHyperextension
		case "Kickbacks": self = .kickbacks
		case "Romanain Deadlifts": self = .romanainDeadlifts
		case "Good Mornings": self = .goodMornings
		case "Step Ups": self = .stepUps

		// MARK: Legs
		case "Back Squat": self = .backSquat
		case "Hack Squat": self = .hackSquat
		case "Front Squat": self = .frontSquat
		case "Hip Adduction": self = .hipAdduction
		case "Lateral Lunge": self = .lateralLunge
		case "Lunge": self = .lunge
		case "Leg Press Machine": self = .legPressMachine
		case "Leg Extension Machine": self = .legExtensionMachine
		case "Hamstring Curls": self = .hamstringCurls
		case "Goblet Squat": self = .gobletSquat
		case "Bulgarian Split Squat": self = .bulgarianSplitSquat

		// MARK: Shoulders
		case "Overhead Press": self = .overheadPress
		case "Face Pull": self = .facePull
		case "Upright Row": self = .uprightRow
		case "Front Raise": self = .frontRaise

		default: return nil
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
		case .landminePress: .arms

		// MARK: Back
		case .deadlift: .back
		case .latPulldowns: .back
		case .backExtensions: .back
		case .row: .back
		case .chestSupportedRow: .back
		case .bentOverRow: .back
		case .seatedRow: .back
		case .pullUp: .back

		// MARK: Chest
		case .benchPress: .chest
		case .vikingPress: .chest
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
		case .legRaises: .core

		// MARK: Glutes
		case .hipThrust: .glutes
		case .reverseHyperextension: .glutes
		case .kickbacks: .glutes
		case .romanainDeadlifts: .glutes
		case .goodMornings: .glutes
		case .stepUps: .glutes

		// MARK: Legs
		case .backSquat: .legs
		case .hackSquat: .legs
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
		case .deadlift: [.narrowGrip, .wideGrip, .barbell, .hexBar, .deficit]
		case .latPulldowns: [.narrowGrip, .wideGrip, .cable]
		case .row: [.oneArm, .barbell, .dumbbell, .cable]
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
		case .backSquat: [.barbell, .dumbbell]
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

	var weights: LiftWeights {
		return switch self {
		// MARK: Arms
		case .bicepCurl: LiftWeights([(.biceps, 1), (.forearms, 0.5), (.deltoid, 0.5)])
		case .hammerCurl: LiftWeights([(.biceps, 1), (.forearms, 0.25), (.deltoid, 0.25)])
		case .kettleBellSwing: LiftWeights([(.glutes, 0.75), (.hamstrings, 0.75), (.lowerBack, 0.5)])
		case .skullcrushers: LiftWeights([(.triceps, 1)])
		case .tricepExtensions: LiftWeights([(.triceps, 1)])
		case .preacherCurls: LiftWeights([(.biceps, 1)])
		case .lateralRaises: LiftWeights([(.deltoid, 1)])
		case .tricepKickback: LiftWeights([(.triceps, 1)])
		case .arnoldPress: LiftWeights([(.triceps, 0.75), (.deltoid, 1)])
		case .tricepPushdown: LiftWeights([(.triceps, 1)])
		case .landminePress: LiftWeights([(.biceps, 0.5), (.triceps, 0.5), (.deltoid, 1)])

		// MARK: Back
		case .deadlift: LiftWeights([(.latissmusDorsi, 1), (.glutes, 0.5), (.lowerBack, 0.75)])
		case .latPulldowns: LiftWeights([(.biceps, 0.5), (.latissmusDorsi, 1)])
		case .backExtensions: LiftWeights([(.lowerBack, 1)])
		case .row: LiftWeights([(.biceps, 0.25), (.triceps, 0.5), (.latissmusDorsi, 1)])
		case .chestSupportedRow: LiftWeights([(.trapezius, 0.75), (.latissmusDorsi, 1), (.lowerBack, 0.5)])
		case .bentOverRow: LiftWeights([(.biceps, 0.75), (.triceps, 0.5), (.latissmusDorsi, 1)])
		case .seatedRow: LiftWeights([(.biceps, 0.75), (.latissmusDorsi, 1)])
		case .pullUp: LiftWeights([(.biceps, 0.25), (.trapezius, 0.5), (.latissmusDorsi, 1)])

		// MARK: Chest
		case .benchPress: LiftWeights([(.triceps, 0.75), (.forearms, 0.25), (.abs, 0.25), (.chest, 1), (.deltoid, 0.5)])
		case .vikingPress: LiftWeights([(.biceps, 0.5), (.triceps, 0.5), (.forearms, 0.25), (.chest, 0.25), (.deltoid, 1)])
		case .pushups: LiftWeights([(.triceps, 0.5), (.chest, 1)])
		case .floorPress: LiftWeights([(.triceps, 0.75), (.chest, 0.75)])
		case .flyes: LiftWeights([(.chest, 0.75)])
		case .dip: LiftWeights([(.triceps, 0.75), (.forearms, 0.5), (.chest, 1)])
		case .chestPress: LiftWeights([(.triceps, 0.75), (.forearms, 0.5), (.chest, 1)])

		// MARK: Core
		case .renegadeRow: LiftWeights([(.latissmusDorsi, 0.5), (.abs, 1)])
		case .plank: LiftWeights([(.abs, 1)])
		case .sidePlank: LiftWeights([(.abs, 0.5), (.obliques, 1)])
		case .russianTwists: LiftWeights([(.abs, 0.75), (.obliques, 1)])
		case .sideBends: LiftWeights([(.obliques, 1)])
		case .plankPullThrough: LiftWeights([(.biceps, 0.25), (.abs, 1)])
		case .legRaises: LiftWeights([(.abs, 1)])

		// MARK: Glutes
		case .hipThrust: LiftWeights([(.glutes, 1)])
		case .reverseHyperextension: LiftWeights([(.glutes, 1), (.hamstrings, 0.75), (.lowerBack, 0.5)])
		case .kickbacks: LiftWeights([(.glutes, 1), (.lowerBack, 1)])
		case .romanainDeadlifts: LiftWeights([(.glutes, 1), (.hamstrings, 1), (.lowerBack, 0.5)])
		case .goodMornings: LiftWeights([(.glutes, 0.75), (.hamstrings, 1), (.lowerBack, 0.5)])
		case .stepUps: LiftWeights([(.glutes, 1), (.quadriceps, 0.75), (.calves, 0.25)])

		// MARK: Legs
		case .backSquat: LiftWeights([(.glutes, 0.5), (.quadriceps, 1), (.lowerBack, 0.25)])
		case .hackSquat: LiftWeights([(.glutes, 0.75), (.quadriceps, 1)])
		case .frontSquat: LiftWeights([(.glutes, 0.75), (.hamstrings, 0.75), (.quadriceps, 1), (.calves, 0.75), (.abs, 0.5), (.lowerBack, 0.25)])
		case .hipAdduction: LiftWeights([(.glutes, 0.5), (.hamstrings, 0.5), (.quadriceps, 0.5)])
		case .lateralLunge: LiftWeights([(.glutes, 1), (.quadriceps, 0.75), (.lowerBack, 0.5)])
		case .lunge: LiftWeights([(.glutes, 1), (.quadriceps, 1)])
		case .legPressMachine: LiftWeights([(.glutes, 1), (.quadriceps, 1)])
		case .legExtensionMachine: LiftWeights([(.quadriceps, 1)])
		case .hamstringCurls: LiftWeights([(.hamstrings, 1)])
		case .gobletSquat: LiftWeights([(.glutes, 1), (.quadriceps, 1)])
		case .bulgarianSplitSquat: LiftWeights([(.glutes, 1), (.quadriceps, 1)])

		// MARK: Shoulders
		case .overheadPress: LiftWeights([(.triceps, 0.75), (.deltoid, 1)])
		case .facePull: LiftWeights([(.deltoid, 0.75)])
		case .uprightRow: LiftWeights([(.trapezius, 0.75), (.forearms, 0.25), (.deltoid, 1)])
		case .frontRaise: LiftWeights([(.trapezius, 0.5), (.deltoid, 1)])

		default: LiftWeights([])
		}
	}

}

