import json

MANIFEST_PATH = "f1_dbt/target/manifest.json"

HIDE_PACKAGES = [
    "dbt_utils",
    "dbt_spark"
]

with open(MANIFEST_PATH, "r") as f:
    manifest = json.load(f)

# Hide macros belonging to unwanted packages
for macro_id, macro in manifest.get("macros", {}).items():
    for pkg in HIDE_PACKAGES:
        if macro_id.startswith(f"macro.{pkg}."):
            macro["docs"]["show"] = False

# Hide nodes (models/tests) if they exist
for node_id, node in manifest.get("nodes", {}).items():
    for pkg in HIDE_PACKAGES:
        if node_id.startswith(f"model.{pkg}."):
            node["docs"]["show"] = False

with open(MANIFEST_PATH, "w") as f:
    json.dump(manifest, f, indent=2)

print("Packages hidden from dbt docs.")