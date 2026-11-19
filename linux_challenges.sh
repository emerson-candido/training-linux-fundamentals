#!/usr/bin/env bash
# ==============================================================================
# Linux Fundamentals - Interactive Hands-On Challenge Lab (v2)
# ==============================================================================
# Usage:
#   chmod +x linux_challenges-v2.sh
#   ./linux_challenges-v2.sh
#
# Learners keep this script open in Terminal 1, open Terminal 2 to solve the
# tasks, and press ENTER in Terminal 1 to validate their work.
# If any check fails, their work stays intact so they can fix it and re-verify
# immediately without starting over.
# ==============================================================================

set -u

LAB_BASE="/tmp/linux_lab_${USER}"

# Colors for clear terminal readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_header() {
    clear
    echo -e "${CYAN}${BOLD}=================================================================${RESET}"
    echo -e "${CYAN}${BOLD}          LINUX FUNDAMENTALS - INTERACTIVE CHALLENGE LAB         ${RESET}"
    echo -e "${CYAN}${BOLD}=================================================================${RESET}"
    echo ""
}

pause_and_verify() {
    echo ""
    echo -e "${YELLOW}👉 Open a SECOND terminal window/tab to complete (or fix) the tasks above.${RESET}"
    echo -e "${YELLOW}👉 When you are ready for verification, press [ENTER] here...${RESET}"
    read -r
}

# ------------------------------------------------------------------------------
# CHALLENGE 1 (EASY): File System Navigation, File Creation & Permissions
# Covers: Module 2 (mkdir, touch, cp, mv, chmod, echo/cat)
# ------------------------------------------------------------------------------
setup_challenge_1() {
    rm -rf "${LAB_BASE}/ch1"
    mkdir -p "${LAB_BASE}/ch1/incoming"
    cat << 'EOF' > "${LAB_BASE}/ch1/incoming/notes.txt"
Linux System Administration Training
Topic: File Management and Permissions
Status: Draft
EOF
}

show_instructions_1() {
    print_header
    echo -e "${GREEN}${BOLD}[Challenge 1 - EASY] Workspace Setup & File Permissions${RESET}"
    echo -e "Base directory: ${BOLD}${LAB_BASE}/ch1${RESET}"
    echo ""
    echo -e "${BOLD}Your Objectives:${RESET}"
    echo "  1. Inside ${LAB_BASE}/ch1, create a new directory named 'archive'."
    echo "  2. Copy 'notes.txt' from '${LAB_BASE}/ch1/incoming/' into '${LAB_BASE}/ch1/archive/'."
    echo "  3. Rename the copied file inside 'archive/' from 'notes.txt' to 'final_notes.txt'."
    echo "  4. Create an empty executable script file '${LAB_BASE}/ch1/deploy.sh' with"
    echo "     exact permissions 750 (rwxr-x---)."
    echo ""
    echo -e "${BLUE}Helpful commands: mkdir, cp, mv, touch, chmod, ls -l${RESET}"
}

run_challenge_1() {
    # Only initialize the workspace if it does not exist yet
    if [[ ! -d "${LAB_BASE}/ch1" ]]; then
        setup_challenge_1
    fi

    while true; do
        show_instructions_1
        pause_and_verify

        echo -e "${BOLD}Checking your work...${RESET}"
        local passed=0
        local total=4

        # Check 1: archive directory exists
        if [[ -d "${LAB_BASE}/ch1/archive" ]]; then
            echo -e "  [${GREEN}PASS${RESET}] Directory 'archive' exists."
            ((passed++))
        else
            echo -e "  [${RED}FAIL${RESET}] Directory '${LAB_BASE}/ch1/archive' was not found."
        fi

        # Check 2 & 3: final_notes.txt exists with original content and incoming/notes.txt still exists
        if [[ -f "${LAB_BASE}/ch1/archive/final_notes.txt" ]] && grep -q "File Management and Permissions" "${LAB_BASE}/ch1/archive/final_notes.txt"; then
            echo -e "  [${GREEN}PASS${RESET}] 'final_notes.txt' exists in 'archive/' with valid content."
            ((passed++))
        else
            echo -e "  [${RED}FAIL${RESET}] 'final_notes.txt' is missing from '${LAB_BASE}/ch1/archive/' or has wrong content."
        fi

        if [[ -f "${LAB_BASE}/ch1/incoming/notes.txt" ]]; then
            echo -e "  [${GREEN}PASS${RESET}] Original 'incoming/notes.txt' was preserved (copied, not moved)."
            ((passed++))
        else
            echo -e "  [${RED}FAIL${RESET}] Original 'incoming/notes.txt' is missing (did you use mv instead of cp?)."
        fi

        # Check 4: deploy.sh exists with 750 permissions
        if [[ -f "${LAB_BASE}/ch1/deploy.sh" ]]; then
            local perms
            perms=$(stat -c "%a" "${LAB_BASE}/ch1/deploy.sh" 2>/dev/null)
            if [[ "$perms" == "750" ]]; then
                echo -e "  [${GREEN}PASS${RESET}] 'deploy.sh' exists with exact permissions 750 (rwxr-x---)."
                ((passed++))
            else
                echo -e "  [${RED}FAIL${RESET}] 'deploy.sh' has permissions '${perms}', expected '750'."
            fi
        else
            echo -e "  [${RED}FAIL${RESET}] File '${LAB_BASE}/ch1/deploy.sh' does not exist."
        fi

        echo ""
        if [[ $passed -eq $total ]]; then
            echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS! Challenge 1 completed (${passed}/${total})!${RESET}"
            echo ""
            read -rp "Press [ENTER] to return to the main menu..."
            return
        else
            echo -e "${YELLOW}⚠️  Score: ${passed}/${total}. Your files have NOT been deleted—fix the failed items in Terminal 2!${RESET}"
            echo ""
            echo "  [ENTER] Re-check my work now"
            echo "  [r]     Reset this challenge from scratch"
            echo "  [m]     Return to main menu (keep current progress)"
            read -rp "Choose an option [ENTER/r/m]: " next_action
            case "$next_action" in
                r|R)
                    setup_challenge_1
                    echo -e "${CYAN}Challenge 1 workspace has been reset.${RESET}"
                    sleep 1
                    ;;
                m|M)
                    return
                    ;;
                *)
                    # Loop repeats without resetting, keeping all learner progress
                    ;;
            esac
        fi
    done
}

# ------------------------------------------------------------------------------
# CHALLENGE 2 (MEDIUM): Text Filtering (grep) & Log Investigation
# Covers: Module 2 & 4 (grep, pipes, redirection, directory traversal)
# ------------------------------------------------------------------------------
setup_challenge_2() {
    rm -rf "${LAB_BASE}/ch2"
    mkdir -p "${LAB_BASE}/ch2/logs/app1" "${LAB_BASE}/ch2/logs/app2" "${LAB_BASE}/ch2/reports"

    cat << 'EOF' > "${LAB_BASE}/ch2/logs/app1/auth.log"
2026-11-19 08:01:12 INFO User alice logged in from 10.0.1.15
2026-11-19 08:04:45 Failed password for invalid user admin from 192.168.1.99 port 51234
2026-11-19 08:05:01 Failed password for root from 192.168.1.99 port 51238
2026-11-19 08:12:30 INFO User bob logged in from 10.0.1.22
2026-11-19 08:19:10 failed password for user guest from 192.168.1.105 port 44120
EOF

    cat << 'EOF' > "${LAB_BASE}/ch2/logs/app2/system.log"
# System Configuration & Event Log
2026-11-19 09:00:01 INFO Cron daemon started
2026-11-19 09:15:22 ERROR Disk usage on /var reached 92%
2026-11-19 09:16:05 ERROR Failed to connect to database replica
2026-11-19 09:20:00 INFO Backup completed successfully
# End of daily log
EOF
}

show_instructions_2() {
    print_header
    echo -e "${YELLOW}${BOLD}[Challenge 2 - MEDIUM] Log Investigation & Text Filtering${RESET}"
    echo -e "Base directory: ${BOLD}${LAB_BASE}/ch2${RESET}"
    echo ""
    echo -e "${BOLD}Your Objectives:${RESET}"
    echo "  1. Search '${LAB_BASE}/ch2/logs/app1/auth.log' for all failed password attempts"
    echo "     (case-insensitive! Notice one line uses lowercase 'failed password')"
    echo "     and save those matching lines into:"
    echo "     ${LAB_BASE}/ch2/reports/failed_logins.txt"
    echo "  2. Extract all 'ERROR' lines from '${LAB_BASE}/ch2/logs/app2/system.log'"
    echo "     and save them into:"
    echo "     ${LAB_BASE}/ch2/reports/errors_only.txt"
    echo "  3. Create a file '${LAB_BASE}/ch2/reports/error_count.txt' containing ONLY"
    echo "     the numeric count (number) of ERROR lines in 'system.log'."
    echo ""
    echo -e "${BLUE}Helpful commands: grep (-i, -c), > (output redirection), cat, wc -l${RESET}"
}

run_challenge_2() {
    # Only initialize the workspace if it does not exist yet
    if [[ ! -d "${LAB_BASE}/ch2" ]]; then
        setup_challenge_2
    fi

    while true; do
        show_instructions_2
        pause_and_verify

        echo -e "${BOLD}Checking your work...${RESET}"
        local passed=0
        local total=3

        # Check 1: failed_logins.txt should have 3 lines (case-insensitive)
        if [[ -f "${LAB_BASE}/ch2/reports/failed_logins.txt" ]]; then
            local count1
            count1=$(grep -ci "failed password" "${LAB_BASE}/ch2/reports/failed_logins.txt")
            local total_lines1
            total_lines1=$(wc -l < "${LAB_BASE}/ch2/reports/failed_logins.txt")
            if [[ "$count1" -eq 3 && "$total_lines1" -eq 3 ]]; then
                echo -e "  [${GREEN}PASS${RESET}] 'failed_logins.txt' contains all 3 case-insensitive failed attempts."
                ((passed++))
            else
                echo -e "  [${RED}FAIL${RESET}] 'failed_logins.txt' has ${total_lines1} lines (expected 3). Did you use 'grep -i'?"
            fi
        else
            echo -e "  [${RED}FAIL${RESET}] File '${LAB_BASE}/ch2/reports/failed_logins.txt' was not found."
        fi

        # Check 2: errors_only.txt should have 2 ERROR lines
        if [[ -f "${LAB_BASE}/ch2/reports/errors_only.txt" ]]; then
            local count2
            count2=$(grep -c "ERROR" "${LAB_BASE}/ch2/reports/errors_only.txt")
            local total_lines2
            total_lines2=$(wc -l < "${LAB_BASE}/ch2/reports/errors_only.txt")
            if [[ "$count2" -eq 2 && "$total_lines2" -eq 2 ]]; then
                echo -e "  [${GREEN}PASS${RESET}] 'errors_only.txt' contains the exact 2 ERROR lines."
                ((passed++))
            else
                echo -e "  [${RED}FAIL${RESET}] 'errors_only.txt' has ${total_lines2} lines (expected 2 ERROR lines)."
            fi
        else
            echo -e "  [${RED}FAIL${RESET}] File '${LAB_BASE}/ch2/reports/errors_only.txt' was not found."
        fi

        # Check 3: error_count.txt should contain '2'
        if [[ -f "${LAB_BASE}/ch2/reports/error_count.txt" ]]; then
            local val
            val=$(tr -d '[:space:]' < "${LAB_BASE}/ch2/reports/error_count.txt")
            if [[ "$val" == "2" ]]; then
                echo -e "  [${GREEN}PASS${RESET}] 'error_count.txt' accurately reports '2'."
                ((passed++))
            else
                echo -e "  [${RED}FAIL${RESET}] 'error_count.txt' contains '${val}', expected '2'."
            fi
        else
            echo -e "  [${RED}FAIL${RESET}] File '${LAB_BASE}/ch2/reports/error_count.txt' was not found."
        fi

        echo ""
        if [[ $passed -eq $total ]]; then
            echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS! Challenge 2 completed (${passed}/${total})!${RESET}"
            echo ""
            read -rp "Press [ENTER] to return to the main menu..."
            return
        else
            echo -e "${YELLOW}⚠️  Score: ${passed}/${total}. Your files have NOT been deleted—fix the failed items in Terminal 2!${RESET}"
            echo ""
            echo "  [ENTER] Re-check my work now"
            echo "  [r]     Reset this challenge from scratch"
            echo "  [m]     Return to main menu (keep current progress)"
            read -rp "Choose an option [ENTER/r/m]: " next_action
            case "$next_action" in
                r|R)
                    setup_challenge_2
                    echo -e "${CYAN}Challenge 2 workspace has been reset.${RESET}"
                    sleep 1
                    ;;
                m|M)
                    return
                    ;;
                *)
                    ;;
            esac
        fi
    done
}

# ------------------------------------------------------------------------------
# CHALLENGE 3 (HARD): Shell Scripting, Processes & Automation
# Covers: Module 3 & 6 (Bash scripts, shebang, variables, ps/kill, background jobs)
# ------------------------------------------------------------------------------
setup_challenge_3() {
    rm -rf "${LAB_BASE}/ch3"
    mkdir -p "${LAB_BASE}/ch3"

    # Start a harmless rogue background process with a unique identifiable marker
    pkill -f "rogue_worker_lab_${USER}" 2>/dev/null || true
    bash -c "exec -a rogue_worker_lab_${USER} sleep 3600" &
    disown 2>/dev/null || true
}

show_instructions_3() {
    print_header
    echo -e "${RED}${BOLD}[Challenge 3 - HARD] Process Troubleshooting & Bash Automation${RESET}"
    echo -e "Base directory: ${BOLD}${LAB_BASE}/ch3${RESET}"
    echo ""
    echo -e "${BOLD}Scenario:${RESET}"
    echo "  A rogue background worker process named 'rogue_worker_lab_${USER}' is running"
    echo "  on this system, and the operations team needs a reusable health-check script."
    echo ""
    echo -e "${BOLD}Your Objectives:${RESET}"
    echo "  1. Find the rogue process named 'rogue_worker_lab_${USER}' and terminate it."
    echo "  2. Create a Bash script at: ${LAB_BASE}/ch3/sys_audit.sh"
    echo "     - It MUST start with a valid Bash shebang (#!/bin/bash or #!/usr/bin/env bash)."
    echo "     - It MUST be executable (chmod +x)."
    echo "     - When executed, it must write a report to '${LAB_BASE}/ch3/audit_report.txt'"
    echo "       containing:"
    echo "         * The system hostname (output of 'hostname')"
    echo "         * The current username (output of 'whoami' or \$USER)"
    echo "         * The kernel version (output of 'uname -r')"
    echo "  3. Run your 'sys_audit.sh' script at least once so 'audit_report.txt' is generated."
    echo ""
    echo -e "${BLUE}Helpful commands: ps aux | grep, kill, nano, chmod +x, \$(hostname), \$(uname -r)${RESET}"
}

run_challenge_3() {
    # Only initialize workspace if it does not exist yet
    if [[ ! -d "${LAB_BASE}/ch3" ]]; then
        setup_challenge_3
    fi

    while true; do
        show_instructions_3
        pause_and_verify

        echo -e "${BOLD}Checking your work...${RESET}"
        local passed=0
        local total=4

        # Check 1: Rogue process has been killed
        if ! pgrep -f "rogue_worker_lab_${USER}" >/dev/null 2>&1; then
            echo -e "  [${GREEN}PASS${RESET}] Rogue process 'rogue_worker_lab_${USER}' is terminated."
            ((passed++))
        else
            local current_rogue_pid
            current_rogue_pid=$(pgrep -f "rogue_worker_lab_${USER}" | head -n 1)
            echo -e "  [${RED}FAIL${RESET}] Process 'rogue_worker_lab_${USER}' (PID ${current_rogue_pid}) is still running! Use 'kill'."
        fi

        # Check 2: Script exists, has shebang, and is executable
        local script="${LAB_BASE}/ch3/sys_audit.sh"
        if [[ -f "$script" && -x "$script" ]] && head -n 1 "$script" | grep -qE "^#!(.*bash)"; then
            echo -e "  [${GREEN}PASS${RESET}] 'sys_audit.sh' exists, has a valid Bash shebang, and is executable."
            ((passed++))
        else
            echo -e "  [${RED}FAIL${RESET}] 'sys_audit.sh' is missing, not executable (+x), or lacks '#!/bin/bash' on line 1."
        fi

        # Check 3: Report exists and contains required system info
        local report="${LAB_BASE}/ch3/audit_report.txt"
        if [[ -f "$report" ]]; then
            local expected_host expected_user expected_kernel
            expected_host=$(hostname)
            expected_user=$(whoami)
            expected_kernel=$(uname -r)

            if grep -q "$expected_host" "$report" && grep -q "$expected_user" "$report" && grep -q "$expected_kernel" "$report"; then
                echo -e "  [${GREEN}PASS${RESET}] 'audit_report.txt' contains hostname (${expected_host}), user (${expected_user}), and kernel (${expected_kernel})."
                ((passed++))
            else
                echo -e "  [${RED}FAIL${RESET}] 'audit_report.txt' is missing one of: hostname, username, or kernel version."
            fi
        else
            echo -e "  [${RED}FAIL${RESET}] '${report}' does not exist. Did you run './sys_audit.sh'?"
        fi

        # Check 4: Verify script actually regenerates the file when deleted and re-run
        if [[ -x "$script" ]]; then
            rm -f "$report"
            (cd "${LAB_BASE}/ch3" && ./sys_audit.sh >/dev/null 2>&1)
            if [[ -s "$report" ]]; then
                echo -e "  [${GREEN}PASS${RESET}] Script successfully regenerated 'audit_report.txt' upon automated re-test."
                ((passed++))
            else
                echo -e "  [${RED}FAIL${RESET}] Re-running './sys_audit.sh' did not generate a non-empty 'audit_report.txt'."
            fi
        else
            echo -e "  [${RED}FAIL${RESET}] Cannot test script execution because 'sys_audit.sh' is not executable."
        fi

        echo ""
        if [[ $passed -eq $total ]]; then
            echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS! Challenge 3 completed (${passed}/${total})!${RESET}"
            echo ""
            read -rp "Press [ENTER] to return to the main menu..."
            return
        else
            echo -e "${YELLOW}⚠️  Score: ${passed}/${total}. Your script and files have NOT been deleted—fix the failed items in Terminal 2!${RESET}"
            echo ""
            echo "  [ENTER] Re-check my work now"
            echo "  [r]     Reset this challenge from scratch"
            echo "  [m]     Return to main menu (keep current progress)"
            read -rp "Choose an option [ENTER/r/m]: " next_action
            case "$next_action" in
                r|R)
                    setup_challenge_3
                    echo -e "${CYAN}Challenge 3 workspace has been reset.${RESET}"
                    sleep 1
                    ;;
                m|M)
                    return
                    ;;
                *)
                    ;;
            esac
        fi
    done
}

cleanup_all() {
    pkill -f "rogue_worker_lab_${USER}" 2>/dev/null || true
    rm -rf "${LAB_BASE}"
    echo -e "${GREEN}All temporary lab files in ${LAB_BASE} and test processes have been cleaned up.${RESET}"
    sleep 1
}

# ==============================================================================
# MAIN MENU LOOP
# ==============================================================================
while true; do
    print_header
    echo -e "Welcome, ${BOLD}${USER}${RESET}! Select a challenge to begin:"
    echo ""
    echo -e "  ${GREEN}1)${RESET} Challenge 1 [EASY]   - Directories, File Operations & Permissions (Module 2)"
    echo -e "  ${YELLOW}2)${RESET} Challenge 2 [MEDIUM] - Log Investigation & Text Filtering with grep (Module 2 & 4)"
    echo -e "  ${RED}3)${RESET} Challenge 3 [HARD]   - Process Management & Bash Scripting (Module 3 & 6)"
    echo ""
    echo -e "  ${CYAN}4)${RESET} Clean up lab files & exit"
    echo -e "  ${CYAN}0)${RESET} Exit without deleting lab files"
    echo ""
    read -rp "Enter your choice [0-4]: " choice

    case "$choice" in
        1) run_challenge_1 ;;
        2) run_challenge_2 ;;
        3) run_challenge_3 ;;
        4) cleanup_all; exit 0 ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please choose 0-4.${RESET}"; sleep 1 ;;
    esac
done
