#!/usr/bin/env bash

# Advanced usage examples for soft-delete
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

echo "=== soft-delete Advanced Usage Examples ==="
echo

# Note: These are example scripts - review before running!

echo "=== Cleanup Scripts ==="
echo

echo "Example 1: Clean up temporary files older than 7 days"
cat << 'EOF'
#!/usr/bin/env bash
# cleanup_temp.sh - Clean up old temporary files

TEMP_DIRS=("/tmp" "/var/tmp" "$HOME/tmp")

for dir in "${TEMP_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "Cleaning temporary files in $dir..."
        find "$dir" -name "*.tmp" -mtime +7 -exec soft-delete {} \;
        find "$dir" -name "*.temp" -mtime +7 -exec soft-delete {} \;
        find "$dir" -name "core.*" -mtime +7 -exec soft-delete {} \;
    fi
done
EOF
echo

echo "Example 2: Clean up log files while keeping recent ones"
cat << 'EOF'
#!/usr/bin/env bash
# cleanup_logs.sh - Archive old log files

LOG_DIR="/var/log/myapp"

if [[ -d "$LOG_DIR" ]]; then
    echo "Archiving old log files..."
    find "$LOG_DIR" -name "*.log" -mtime +30 -exec soft-delete {} \;
    find "$LOG_DIR" -name "*.log.*" -mtime +30 -exec soft-delete {} \;
    echo "Recent logs (last 30 days) preserved"
fi
EOF
echo

echo "=== Development Workflows ==="
echo

echo "Example 3: Safe project cleanup"
cat << 'EOF'
#!/usr/bin/env bash
# clean_project.sh - Clean up development artifacts

echo "Cleaning build artifacts..."
soft-delete build/
soft-delete dist/
soft-delete *.o
soft-delete *.so
soft-delete .cache/

echo "Cleaning temporary files..."
soft-delete *.tmp
soft-delete *.swp
soft-delete *~
soft-delete .DS_Store

echo "Cleaning logs..."
soft-delete *.log
soft-delete debug.txt
EOF
echo

echo "Example 4: Batch file processing with safety"
cat << 'EOF'
#!/usr/bin/env bash
# process_and_cleanup.sh - Process files then safely remove originals

INPUT_DIR="./raw_data"
OUTPUT_DIR="./processed_data"

for file in "$INPUT_DIR"/*.txt; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        echo "Processing $filename..."
        
        # Process file (example: convert to uppercase)
        if tr '[:lower:]' '[:upper:]' < "$file" > "$OUTPUT_DIR/$filename"; then
            echo "Processed successfully, removing original..."
            soft-delete "$file"
        else
            echo "Processing failed, keeping original: $file"
        fi
    fi
done
EOF
echo

echo "=== System Maintenance ==="
echo

echo "Example 5: Safe system cleanup (run as appropriate user)"
cat << 'EOF'
#!/usr/bin/env bash
# system_cleanup.sh - System maintenance with soft deletion

echo "Cleaning user cache directories..."
if [[ -d "$HOME/.cache" ]]; then
    find "$HOME/.cache" -type f -atime +30 -exec soft-delete {} \;
fi

echo "Cleaning old downloads..."
if [[ -d "$HOME/Downloads" ]]; then
    find "$HOME/Downloads" -name "*.deb" -mtime +90 -exec soft-delete {} \;
    find "$HOME/Downloads" -name "*.rpm" -mtime +90 -exec soft-delete {} \;
    find "$HOME/Downloads" -name "*.zip" -mtime +90 -exec soft-delete {} \;
fi

echo "Cleaning old screenshots..."
if [[ -d "$HOME/Pictures/Screenshots" ]]; then
    find "$HOME/Pictures/Screenshots" -name "*.png" -mtime +180 -exec soft-delete {} \;
fi
EOF
echo

echo "=== Integration Examples ==="
echo

echo "Example 6: Git hook integration (pre-commit)"
cat << 'EOF'
#!/usr/bin/env bash
# .git/hooks/pre-commit
# Clean up temporary files before commit

echo "Cleaning temporary files before commit..."

# Remove common temporary files
find . -name "*.tmp" -exec soft-delete {} \;
find . -name "*.swp" -exec soft-delete {} \;
find . -name "*~" -exec soft-delete {} \;
find . -name ".DS_Store" -exec soft-delete {} \;

# Remove build artifacts that shouldn't be committed
if [[ -d "build" ]]; then
    soft-delete build/
fi

if [[ -d "dist" ]]; then
    soft-delete dist/
fi

echo "Cleanup complete."
EOF
echo

echo "Example 7: Cron job for automated cleanup"
cat << 'EOF'
# Add to crontab with: crontab -e
# Clean up temporary files daily at 2 AM
0 2 * * * /usr/local/bin/soft-delete $HOME/tmp/*.tmp $HOME/.cache/thumbnails/* 2>/dev/null

# Weekly cleanup of old downloads
0 3 * * 0 find $HOME/Downloads -mtime +30 -exec /usr/local/bin/soft-delete {} \; 2>/dev/null

# Monthly cleanup of old backups (made by soft-delete itself)
0 4 1 * * find /tmp -name "backup-*" -mtime +7 -exec rm -rf {} \; 2>/dev/null
EOF
echo

echo "=== Recovery and Maintenance Scripts ==="
echo

echo "Example 8: Find and restore files"
cat << 'EOF'
#!/usr/bin/env bash
# find_and_restore.sh - Helper script to find and restore deleted files

search_term="${1:-}"

if [[ -z "$search_term" ]]; then
    echo "Usage: $0 <search_term>"
    echo "Example: $0 document.pdf"
    exit 1
fi

echo "Searching for files containing: $search_term"
echo

# Find matching files in backup directories
matches=$(find /tmp -path "*/backup-*/*" -name "*$search_term*" 2>/dev/null)

if [[ -z "$matches" ]]; then
    echo "No files found matching: $search_term"
    exit 1
fi

echo "Found matches:"
echo "$matches"
echo

read -p "Enter the full path of the file to restore: " restore_path

if [[ -f "$restore_path" ]]; then
    filename=$(basename "$restore_path")
    echo "Restoring $filename to current directory..."
    cp "$restore_path" "./$filename"
    echo "File restored as: ./$filename"
else
    echo "File not found or not accessible: $restore_path"
    exit 1
fi
EOF
echo

echo "Example 9: Cleanup old backup directories"
cat << 'EOF'
#!/usr/bin/env bash
# cleanup_backups.sh - Remove old soft-delete backup directories

days_old=${1:-7}

echo "Removing backup directories older than $days_old days..."

# Find and remove old backup directories
old_backups=$(find /tmp -maxdepth 1 -name "backup-*" -type d -mtime +$days_old 2>/dev/null)

if [[ -n "$old_backups" ]]; then
    echo "Found old backup directories:"
    echo "$old_backups"
    echo
    
    read -p "Remove these directories? [y/N]: " confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        echo "$old_backups" | xargs rm -rf
        echo "Old backup directories removed."
    else
        echo "Operation cancelled."
    fi
else
    echo "No old backup directories found."
fi
EOF
echo

echo "=== Best Practices ==="
echo
echo "1. Always test scripts in a safe environment first"
echo "2. Use absolute paths in cron jobs and system scripts"
echo "3. Add error checking and logging to production scripts"
echo "4. Regularly clean up old backup directories"
echo "5. Consider disk space when setting up automated cleanup"
echo "6. Document your cleanup procedures for team members"
echo

echo "=== End of Advanced Examples ==="
