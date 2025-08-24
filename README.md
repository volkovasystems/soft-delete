# soft-delete

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/bash-%3E%3D4.0-green.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/version-0.0.0-blue.svg)](https://github.com/volkovasystems/soft-delete)

A safe file deletion utility that moves files and directories to timestamped backup locations instead of permanently deleting them.

## Features

- 📦 **Homebrew Support**: Easy installation via Homebrew package manager

- 🗑️ **Safe Deletion**: Moves files to timestamped backup directories in `/tmp`
- 🔄 **Easy Recovery**: Files are preserved with original names and permissions
- ⚡ **Fast**: Lightweight bash script with minimal dependencies
- 🛡️ **Robust**: Comprehensive error handling and validation
- 📝 **Verbose Mode**: Debug output for troubleshooting
- 🎯 **Simple**: Clean command-line interface

## Installation

### Quick Install

```bash
git clone https://github.com/volkovasystems/soft-delete.git
cd soft-delete
sudo make install
```

### Homebrew Install (macOS/Linux)

```bash
# Tap our repository
brew tap volkovasystems/soft-delete

# Install soft-delete
brew install soft-delete
```

### Manual Install

```bash
git clone https://github.com/volkovasystems/soft-delete.git
cd soft-delete

# Option 1: Use install script
sudo ./install.sh

# Option 2: Manual copy
sudo cp soft-delete.sh /usr/local/bin/soft-delete
sudo chmod +x /usr/local/bin/soft-delete
```

### From Source

```bash
wget https://raw.githubusercontent.com/volkovasystems/soft-delete/main/bin/soft-delete
sudo mv soft-delete /usr/local/bin/
sudo chmod +x /usr/local/bin/soft-delete
```

## Usage

### Basic Usage

```bash
# Delete a file
soft-delete file.txt

# Delete a directory
soft-delete /path/to/directory

# Using the --path option
soft-delete --path ~/documents/old_file.doc
soft-delete -p ./temp_folder
```

### Options

```bash
# Show help
soft-delete --help
soft-delete -h

# Show version
soft-delete --version
soft-delete -v

# Enable verbose output
soft-delete --verbose file.txt
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Display comprehensive help message and exit |
| `-v, --version` | Display version information and exit |
| `-p, --path PATH` | Specify the path to the file or directory to soft delete |
| `--verbose` | Enable verbose output for debugging |

## How It Works

`soft-delete` creates backup directories in `/tmp` with the format:
```
backup-XXXXX-YYYYMMDD-HHMMSS
```

Where:
- `XXXXX` is a unique random string
- `YYYYMMDD` is the date (e.g., 20250122)
- `HHMMSS` is the time (e.g., 143052)

### Example Backup Location
```
/tmp/backup-a7f3k-20250122-143052/file.txt
```

## Examples

### Basic File Operations

```bash
# Soft delete a document
soft-delete important-document.pdf
# Output: Soft deleted: 'important-document.pdf' -> '/tmp/backup-x9k2m-20250122-143052/important-document.pdf'

# Soft delete a directory
soft-delete old-project/
# Output: Soft deleted: 'old-project/' -> '/tmp/backup-p4n7q-20250122-143115/old-project'
```

### Using Different Options

```bash
# Using --path option
soft-delete --path ~/Downloads/temp.zip

# Using short option
soft-delete -p ./cache/

# With verbose output
soft-delete --verbose large-file.bin
# Output: [DEBUG] Starting soft delete for: large-file.bin
#         [DEBUG] Created backup directory: /tmp/backup-m5t8w-20250122-143200
#         Soft deleted: 'large-file.bin' -> '/tmp/backup-m5t8w-20250122-143200/large-file.bin'
#         [DEBUG] Operation completed successfully
```

### Recovery

To recover files, simply move them back from the backup location:

```bash
# Find your file
ls /tmp/backup-*/

# Restore it
mv /tmp/backup-x9k2m-20250122-143052/important-document.pdf ./
```

## Error Handling

The script provides clear error messages for common issues:

```bash
# File doesn't exist
soft-delete nonexistent.txt
# Error: Path 'nonexistent.txt' does not exist

# No arguments provided
soft-delete
# Error: No arguments provided
# Usage: soft-delete [OPTIONS] [PATH]

# Permission denied
soft-delete /root/protected-file
# Error: Path '/root/protected-file' is not readable
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - file/directory was moved successfully |
| 1 | General error - invalid arguments or operation failed |
| 2 | Usage error - missing or invalid arguments |

## Testing

Run the test suite:

```bash
make test
```

Or run tests manually:

```bash
# Install bats if not already installed
sudo apt-get install bats  # Ubuntu/Debian
brew install bats-core     # macOS

# Run tests
bats tests/
```

## Development

### Project Structure

```
soft-delete/
├── bin/
│   └── soft-delete          # Built executable
├── examples/
│   ├── README.md            # Examples documentation
│   ├── basic_usage.sh       # Basic usage examples
│   └── advanced_usage.sh    # Advanced integration examples
├── tests/
│   ├── soft-delete.bats     # Main test suite
│   └── test_helper.bash     # Test utilities
├── .editorconfig            # Code formatting standards
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # Contribution guidelines
├── install.sh               # Simple installation script
├── LICENSE                  # MIT License
├── Makefile                 # Build automation
├── README.md                # This file
└── soft-delete.sh           # Source script
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes to `soft-delete.sh`
4. Build: `make build` (copies to bin/soft-delete)
5. Add tests for new functionality
6. Run tests: `make test`
7. Commit changes: `git commit -am 'Add feature'`
8. Push to branch: `git push origin feature-name`
9. Create a Pull Request

## Requirements

- Bash 4.0 or later
- Standard Unix utilities (`mv`, `mktemp`, `date`, etc.)
- Write access to `/tmp` directory
- Optional: `bats` for running tests

## Compatibility

- ✅ Linux (all major distributions)
- ✅ macOS
- ✅ BSD variants
- ✅ Windows (with WSL/Git Bash)
- ✅ Android (with Termux)

## FAQ

### Q: Where are my files stored after soft deletion?
A: Files are moved to timestamped directories in `/tmp` with format `backup-XXXXX-YYYYMMDD-HHMMSS`.

### Q: How do I recover deleted files?
A: Use standard `mv` command to move files back from the backup location shown in the output.

### Q: Do backup directories get cleaned up automatically?
A: No, backup directories remain in `/tmp` until manually removed or system reboot (depending on your system's `/tmp` cleanup policy).

### Q: Can I change the backup location?
A: Currently, backups are always created in `/tmp`. This may be configurable in future versions.

### Q: What happens if I try to delete a file I don't have permission to read?
A: The script will show an error message and exit without making any changes.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Richeve S. Bebedor** - [richeve.bebedor@gmail.com](mailto:richeve.bebedor@gmail.com)

Part of the volkovasystems utility collection

## Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/volkovasystems/soft-delete/issues)
- 💡 **Feature Requests**: [GitHub Issues](https://github.com/volkovasystems/soft-delete/issues)
- 📖 **Documentation**: [GitHub Wiki](https://github.com/volkovasystems/soft-delete/wiki)

---

**Made with ❤️ for safer file operations**
