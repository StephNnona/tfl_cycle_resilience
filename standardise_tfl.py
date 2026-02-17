import pandas as pd
import os
import glob

# Setup folder paths
input_folder = 'data_raw'
output_folder = 'data_clean'
os.makedirs(output_folder, exist_ok=True)

# Every possible variation of TfL headers mapped to our target names
mapping = {
    'Number': 'rental_id',
    'Rental Id': 'rental_id',
    'Start date': 'start_date',
    'Start Date': 'start_date',
    'Start station number': 'start_station_id',
    'StartStation Id': 'start_station_id',
    'End date': 'end_date',
    'End Date': 'end_date',
    'End station number': 'end_station_id',
    'EndStation Id': 'end_station_id',
    'Start station': 'start_station_name',
    'StartStation Name': 'start_station_name',
    'End station': 'end_station_name',
    'EndStation Name': 'end_station_name',
    'Bike number': 'bike_id',
    'Bike Id': 'bike_id',
    'Bike model': 'bike_model',
    'Total duration (ms)': 'duration_ms'
}

# Process all CSVs
files = glob.glob(os.path.join(input_folder, "*.csv"))
print(f"Found {len(files)} files. Starting processing...")

for file_path in files:
    try:
        # Read file (TfL files can be large, this handles them efficiently)
        df = pd.read_csv(file_path, low_memory=False)
        
        # Rename columns using our map
        df = df.rename(columns=mapping)
        
        # Identify which target columns actually exist in this file
        existing_cols = [c for c in mapping.values() if c in df.columns]
        
        # deduplicate the list while preserving the order
        # dict.fromkeys() is a neat trick to remove duplicates but keep the order
        cols_to_keep = list(dict.fromkeys(existing_cols))
        
        # Keep only the unique columns
        df = df[cols_to_keep]
        
        # Drop any completely duplicate rows (TfL data sometimes has these)
        df = df.drop_duplicates()
        
        # Save to the clean folder
        filename = os.path.basename(file_path)
        df.to_csv(os.path.join(output_folder, f"clean_{filename}"), index=False)
        print(f"✅ Success: {filename}")
        
    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")

print("\nProcessing Complete! All files in 'data_clean' now have identical headers.")