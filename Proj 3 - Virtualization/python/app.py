# app.py
from flask import Flask, render_template, jsonify, request
from datetime import datetime
import os
import re
import glob
from log_collector import collect_logs
from collections import defaultdict


app = Flask(__name__)

# Configuration
LOG_DIRECTORY = './collected_logs/'

# Global variable to store parsed log data
log_data = []
vm_identifiers = set()

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

def parse_log_files():
    """Parse all log files in the collected_logs directory at application startup"""
    global log_data, vm_identifiers
    log_dir = "./collected_logs/"

    # Ensure the directory exists
    if not os.path.exists(log_dir):
        print(f"Warning: Directory {log_dir} does not exist")
        return

    # Find all log files matching the pattern
    log_files = [f for f in os.listdir(log_dir) if f.startswith("entry-file_192.168.56.")]

    for log_file in log_files:
        file_path = os.path.join(log_dir, log_file)
        try:
            with open(file_path, 'r') as f:
                for line in f:
                    # Expected format: 2025-04-08 15:25:01 sftp-2
                    match = re.match(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) ([\w-]+)', line.strip())
                    if match:
                        timestamp_str, vm_id = match.groups()
                        timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
                        log_data.append({
                            'timestamp': timestamp,
                            'vm_id': vm_id
                        })
                        vm_identifiers.add(vm_id)
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")

    # Sort log data by timestamp
    log_data.sort(key=lambda x: x['timestamp'])
    print(f"Parsed {len(log_data)} log entries from {len(log_files)} files")
    print(f"Found VM identifiers: {vm_identifiers}")


@app.route('/')
def index():
    refresh_logs()
    creators = get_available_creators()
    # Default to first creator if available
    default_creator = creators[0] if creators else None
    
    # Get logs for the default creator
    logs = get_log_entries(default_creator) if default_creator else []

    return render_template('index.html', creators=creators, logs=logs, selected_creator=default_creator)

@app.route('/api/table_logs')
def get_logs_table():
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

@app.route('/charts')
def charts():
    """Render the main page with the chart"""
    return render_template('charts.html', vm_list=sorted(list(vm_identifiers)))

@app.route('/api/logs')
def get_logs_chart():
    """API endpoint to get log data filtered by date range and grouped by time granularity"""
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    granularity = request.args.get('granularity', 'day')

    # Convert string dates to datetime objects
    start = datetime.strptime(start_date, '%Y-%m-%d') if start_date else None
    end = datetime.strptime(end_date, '%Y-%m-%d') if end_date else None

    # Filter logs by date range if provided
    filtered_logs = log_data
    if start:
        filtered_logs = [log for log in filtered_logs if log['timestamp'] >= start]
    if end:
        # Add one day to include the end date fully
        end = datetime(end.year, end.month, end.day, 23, 59, 59)
        filtered_logs = [log for log in filtered_logs if log['timestamp'] <= end]

    # Group logs by VM ID and time granularity
    vm_data = defaultdict(lambda: defaultdict(int))

    for log in filtered_logs:
        timestamp = log['timestamp']
        vm_id = log['vm_id']

        if granularity == 'hour':
            time_key = timestamp.strftime('%Y-%m-%d %H:00')
        elif granularity == 'week':
            # ISO week date format: year and week number
            time_key = f"{timestamp.isocalendar()[0]}-W{timestamp.isocalendar()[1]}"
        else:  # default to day
            time_key = timestamp.strftime('%Y-%m-%d')

        vm_data[vm_id][time_key] += 1

    # Prepare data for Chart.js
    chart_data = {
        'labels': sorted(set(time_key for vm in vm_data.values() for time_key in vm)),
        'datasets': []
    }
    # Generate random colors for each VM
    colors = [
        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
        '#FF9F40', '#C9CBCF', '#7BC8A4', '#E84D8A', '#73BFB8'
    ]

    # Create a dataset for each VM
    for i, vm_id in enumerate(sorted(vm_data.keys())):
        dataset = {
            'label': vm_id,
            'data': [vm_data[vm_id].get(label, 0) for label in chart_data['labels']],
            'borderColor': colors[i % len(colors)],
            'backgroundColor': colors[i % len(colors)] + '20',  # Add transparency
            'fill': False,
            'tension': 0.1
        }
        chart_data['datasets'].append(dataset)

    return jsonify({
        'chart_data': chart_data,
        'total_logs': len(filtered_logs),
        'vm_list': sorted(vm_data.keys())
    })

# Initialize the app with data before first request using Flask 2.0+ approach
@app.before_request
def initialize_on_first_request():
    global log_data
    # Only parse if we haven't already
    if not log_data:
        parse_log_files()


if __name__ == '__main__':
    # Parse logs at startup
    parse_log_files()
    app.run(debug=True)
