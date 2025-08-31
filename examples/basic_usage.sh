#!/usr/bin/env bash
set -euo pipefail

# Basic usage examples for soft-delete
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

echo "=== soft-delete Basic Usage Examples ==="
echo

# Note: This script demonstrates usage but doesn't actually run the commands
# to avoid modifying your system. Copy and paste the commands you want to try.

echo "1. Basic file deletion:"
echo "   soft-delete unwanted-file.txt"
echo

echo "2. Delete multiple files:"
echo "   soft-delete file1.txt file2.log temp.data"
echo

echo "3. Delete a directory:"
echo "   soft-delete old-project/"
echo

echo "4. Using the --path option:"
echo "   soft-delete --path ~/Downloads/large-file.zip"
echo "   soft-delete -p ./cache-directory/"
echo

echo "5. Enable verbose output for debugging:"
echo "   soft-delete --verbose important-file.pdf"
echo

echo "6. Get help:"
echo "   soft-delete --help"
echo "   soft-delete -h"
echo

echo "7. Check version:"
echo "   soft-delete --version"
echo "   soft-delete -v"
echo

echo "8. Delete files with special characters:"
echo "   soft-delete 'file with spaces.txt'"
echo "   soft-delete \"report (final version).doc\""
echo

echo "9. Delete files using wildcards (be careful!):"
echo "   soft-delete *.tmp"
echo "   soft-delete logs/*.log"
echo

echo "10. Example backup location format:"
echo "    When you delete 'document.pdf', it might be moved to:"
echo "    /tmp/backup-k7m9p-20250122-143052/document.pdf"
echo

echo "=== Recovery Examples ==="
echo

echo "11. List backup directories to find your files:"
echo "    ls -la /tmp/backup-*/"
echo

echo "12. Restore a file:"
echo "    # Find the backup"
echo "    ls /tmp/backup-*/document.pdf"
echo "    # Restore it"
echo "    mv /tmp/backup-k7m9p-20250122-143052/document.pdf ./"
echo

echo "13. Clean up old backups manually:"
echo "    rm -rf /tmp/backup-k7m9p-20250122-143052/"
echo

echo "=== Safety Tips ==="
echo
echo "• Always check the backup location shown in the output"
echo "• Backup directories remain until manually removed or system reboot"
echo "• Use --verbose flag if you need to debug issues"
echo "• Remember: only files deleted with soft-delete can be easily restored"
echo

echo "=== End of Examples ==="
