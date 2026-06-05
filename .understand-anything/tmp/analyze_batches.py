import json
import os
import subprocess

PROJECT_ROOT = "/Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu"
SKILL_DIR = "/Users/jingtaiwei/.agents/skills/understand"
INTERMEDIATE_DIR = os.path.join(PROJECT_ROOT, ".understand-anything", "intermediate")
TMP_DIR = os.path.join(PROJECT_ROOT, ".understand-anything", "tmp")

with open(os.path.join(INTERMEDIATE_DIR, "batches.json"), "r") as f:
    batches_data = json.load(f)

batches = batches_data["batches"]

for batch in batches:
    idx = batch["batchIndex"]
    print(f"Processing batch {idx}...")
    
    input_data = {
        "projectRoot": PROJECT_ROOT,
        "batchFiles": batch["files"],
        "batchImportData": batch["batchImportData"]
    }
    
    input_path = os.path.join(TMP_DIR, f"ua-file-analyzer-input-{idx}.json")
    with open(input_path, "w") as f:
        json.dump(input_data, f)
    
    output_path = os.path.join(TMP_DIR, f"ua-file-extract-results-{idx}.json")
    
    cmd = [
        "node",
        os.path.join(SKILL_DIR, "extract-structure.mjs"),
        input_path,
        output_path
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error processing batch {idx}: {result.stderr}")
    else:
        print(f"Batch {idx} structural extraction complete.")

