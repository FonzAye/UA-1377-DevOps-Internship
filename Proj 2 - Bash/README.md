# 🛠️ Bash Scripts Project

This project contains two Bash scripts designed for automation and data extraction:

1. **`password_script.sh`** - A password strength checker that analyzes passwords from a file.
2. **`pid_script.sh`** - A log file processor that extracts and analyzes process IDs (PIDs).

## 📌 Scripts Overview

### 🔑 `password_script.sh` - Password Strength Checker
This script checks passwords from a given file and evaluates their strength based on the following criteria:
- At least **10 characters** long
- Contains **uppercase and lowercase** letters
- Includes **at least one number**
- Has **at least two special characters** (`!@#$%^&*()_+`)

**Usage:**
```bash
./password_script.sh <logfile>
```
**Example:**
```bash
./password_script.sh system.log
```
**Output:** (saved to `password_script_output.txt`)
```
Password: 'Example123!!' - STRONG
Password: 'weakpass' - WEAK (Missing: Length (< 10 chars) Uppercase Number Special chars less than 2)
```

---

### 📄 `pid_script.sh` - PID Extractor & Analyzer
This script scans a log file for process IDs (PIDs), extracts and sorts them, and provides insights such as:
- All extracted PIDs
- Unique PIDs (sorted)
- Total count of unique PIDs

**Usage:**
```bash
./pid_script.sh <logfile>
```
**Example:**
```bash
./pid_script.sh system.log
```
**Output:** (saved to `pid_script_output.txt`)
```
Extract all PIDs from logfile:
[pid 1234]
[pid 5678]
[pid 1234]
Extract only numbers:
1234
5678
1234
Sort numbers and get rid of all the non-unique ones:
1234
5678
Count the number of new lines:
2
```

## 🚀 Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/bash-scripts-project.git
   ```
2. Navigate to the project folder:
   ```bash
   cd bash-scripts-project
   ```
3. Give execution permissions to the scripts:
   ```bash
   chmod +x password_script.sh pid_script.sh
   ```
4. Run the scripts with appropriate input files.

## 📝 Notes
- Ensure the input files (`password_file` and `logfile`) exist before running the scripts.
- The outputs are saved in `password_script_output.txt` and `pid_script_output.txt`.

## 📧 Contact
For any questions or improvements, feel free to open an issue or submit a pull request! 🚀


