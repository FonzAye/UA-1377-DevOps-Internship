# app.py
from flask import Flask, render_template, jsonify, request
import os
import re
import glob
from log_collector import collect_logs


app = Flask(__name__)

# Configuration
LOG_DIRECTORY = './collected_logs/'

def get_available_creators():
    """Extract all unique creator IDs from the log filenames."""
    pattern = re.compile(r'entry-file_192\.168\.56\.1(\d+)\.txt$')
    creators = []
    
    # Get all log files
    log_files = glob.glob(os.path.join(LOG_DIRECTORY, 'entry-file_*.txt'))
    
    for file_path in log_files:
        filename = os.path.basename(file_path)
        match = pattern.search(filename)
        if match:
            creator_id = int(match.group(1))
            creators.append(f"sftp-{creator_id}")
    
    return sorted(creators, key=lambda x: int(x.split('-')[1]))

def get_log_entries(creator_id):
    """Parse log file for the specified creator ID."""
    # Extract the numeric part from creator_id (e.g., "sftp-3" -> "3")
    creator_num = creator_id.split('-')[1]
    
    # Find the corresponding log file
    filename = f"entry-file_192.168.56.1{creator_num}.txt"
    file_path = os.path.join(LOG_DIRECTORY, filename)
    
    entries = []
    try:
        with open(file_path, 'r') as file:
            for line in file:
                parts = line.strip().split(' ', 2)
                if len(parts) == 3:
                    date, time, creator = parts
                    entries.append({
                        'date': date,
                        'time': time,
                        'creator': creator
                    })
    except FileNotFoundError:
        pass  # Return empty list if file not found
    
    return entries

@app.route('/')
def index():
    creators = get_available_creators()
    # Default to first creator if available
    default_creator = creators[0] if creators else None
    
    # Get logs for the default creator
    logs = get_log_entries(default_creator) if default_creator else []
    
    return render_template('index.html', creators=creators, logs=logs, selected_creator=default_creator)

@app.route('/api/logs')
def get_logs():
    creator_id = request.args.get('creator', '')
    logs = get_log_entries(creator_id)
    return jsonify(logs)

@app.route('/api/refresh-logs')
def refresh_logs():
    try:
        num_vms = int(request.args.get('num_vms', 3))  # Default to 3
        collect_logs(num_vms)
        return jsonify({"status": "success"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
