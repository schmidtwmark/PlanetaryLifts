#![feature(error_in_core)]
use convert_case::Casing;
use core::error::Error;
use reqwest::Client;
use serde::Deserialize;
use std::collections::BTreeMap;

fn deserialize_bool<'de, D>(deserializer: D) -> Result<bool, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let s: &str = Deserialize::deserialize(deserializer)?;
    match s.to_lowercase().as_ref() {
        "true" => Ok(true),
        "false" => Ok(false),
        _ => Ok(false),
    }
}

#[derive(Debug, Deserialize)]
struct Lift {
    lift_name: String,
    category: String,
    #[serde(deserialize_with = "deserialize_bool")]
    incline: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    decline: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    narrow_grip: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    wide_grip: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    one_arm: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    reverse: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    barbell: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    dumbbell: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    hex_bar: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    multi_grip_bar: bool,
    #[serde(deserialize_with = "deserialize_bool")]
    cable: bool,
}

impl Lift {
    fn camel_name(&self) -> String {
        self.lift_name.to_case(convert_case::Case::Camel)
    }
}
type CategoryMap = BTreeMap<String, Vec<Lift>>;

fn computed_parameter_header(param_name: &str, param_type: &str) -> String {
    format!("\tvar {param_name}: {param_type} {{\n\t\treturn switch self {{\n")
}

const COMPUTED_PARAMETER_FOOTER: &str = "\t\t}\n\t}\n";

fn to_string_computed_parameter(category_map: &CategoryMap) -> String {
    let mut output = computed_parameter_header("string", "String");
    for (category, lifts) in category_map {
        output += &format!("\t\t// MARK: {}\n", category);
        for lift in lifts {
            output += &format!(
                "\t\tcase .{camel_lift}: \"{lift_name}\"\n",
                camel_lift = lift.camel_name(),
                lift_name = lift.lift_name
            );
        }
        output += "\n"
    }
    output += "\t\tcase .other(let name, _, _): name\n";
    output += COMPUTED_PARAMETER_FOOTER;
    output
}

fn category_computed_parameter(category_map: &CategoryMap) -> String {
    let mut output = computed_parameter_header("category", "LiftCategory");
    for (category, lifts) in category_map {
        output += &format!("\t\t// MARK: {}\n", category);
        for lift in lifts {
            output += &format!(
                "\t\tcase .{lift_name}: .{lower_category}\n",
                lift_name = lift.camel_name(),
                lower_category = category.to_lowercase()
            );
        }
        output += "\n"
    }
    output += "\t\tcase .other(_, let category, _): category\n";
    output += COMPUTED_PARAMETER_FOOTER;
    output
}

fn modifiers_computed_parameter(category_map: &CategoryMap) -> String {
    let mut output = computed_parameter_header("modifiers", "[LiftModifier]");
    for (category, lifts) in category_map {
        output += &format!("\t\t// MARK: {}\n", category);
        for lift in lifts {
            let mut modifiers: Vec<&'static str> = Vec::new();
            if lift.incline {
                modifiers.push(".incline")
            }
            if lift.decline {
                modifiers.push(".decline")
            }
            if lift.narrow_grip {
                modifiers.push(".narrowGrip")
            }
            if lift.wide_grip {
                modifiers.push(".wideGrip")
            }
            if lift.one_arm {
                modifiers.push(".oneArm")
            }
            if lift.reverse {
                modifiers.push(".reverse")
            }
            if lift.barbell {
                modifiers.push(".barbell")
            }
            if lift.dumbbell {
                modifiers.push(".dumbbell")
            }
            if lift.hex_bar {
                modifiers.push(".hexBar")
            }
            if lift.multi_grip_bar {
                modifiers.push(".multiGripBar")
            }
            if lift.cable {
                modifiers.push(".cable")
            }
            if !modifiers.is_empty() {
                output += &format!(
                    "\t\tcase .{lift_name}: [{mods}]\n",
                    lift_name = lift.camel_name(),
                    mods = modifiers.join(", ")
                );
            }
        }

        output += "\n"
    }
    output += "\t\tdefault: []\n";
    output += COMPUTED_PARAMETER_FOOTER;
    output
}

fn all_cases(category_map: &CategoryMap) -> String {
    let mut output = "\tstatic var allCases: [LiftType] = [\n".to_string();
    for (category, lifts) in category_map {
        output += &format!("\t\t// MARK: {}\n", category);
        for lift in lifts {
            output += &format!("\t\t.{lift_name},\n", lift_name = lift.camel_name());
        }
    }

    output += "\t]\n";
    output
}

fn cases(category_map: &CategoryMap) -> String {
    let mut output = String::new();
    for (category, lifts) in category_map {
        output += &format!("\t// MARK: {}\n", category);
        for lift in lifts {
            output += &format!("\tcase {lift_name}\n", lift_name = lift.camel_name());
        }
    }
    output +=
        "\t// MARK: user specified\n\tcase other(name: String, category: LiftCategory, id: UUID)\n";
    output += "\n";

    output
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // Replace with your Google Sheet URL with "/export?format=csv" appended
    let url = "https://docs.google.com/spreadsheets/d/1Y7sQ783zfq6nEMZ8SOMaja55JhzPC4bFf1jiNDgi9rs/export?format=csv";

    let client = Client::new();
    let response = client.get(url).send().await?;

    if response.status().is_success() {
        let csv_data = response.text().await?;
        let mut rdr = csv::Reader::from_reader(csv_data.as_bytes());
        let mut category_map: CategoryMap = CategoryMap::new();
        rdr.deserialize::<Lift>()
            .filter_map(|result| result.ok())
            .for_each(|lift| {
                let category = &lift.category;
                if !category_map.contains_key(category) {
                    category_map.insert(category.to_owned(), Vec::new());
                }
                category_map.get_mut(category).unwrap().push(lift);
            });

        println!("// This code is automatically generated. DO NOT EDIT.\n\n");
        println!("import Foundation\n\n");
        println!("enum LiftType: Hashable, Codable{{\n");
        println!("{}", cases(&category_map));
        println!("{}", all_cases(&category_map));
        println!("{}", to_string_computed_parameter(&category_map));
        println!("{}", category_computed_parameter(&category_map));
        println!("{}", modifiers_computed_parameter(&category_map));
        println!("}}\n");
    } else {
        println!("Error downloading sheet: {}", response.status());
    }

    Ok(())
}
