# View Mode Feature

## Overview

Added a new `--view` mode to ComicInfoEdit.py that allows you to quickly view metadata from a comic file without leaving the terminal or making any modifications.

## What Changed

### 1. New `--view` Flag
- Added `--view` argument to the command-line interface
- View mode is mutually exclusive with modification mode
- Requires exactly one file (no wildcards or directories)

### 2. New `view_metadata()` Method
- Reads metadata from CBZ or CBR files
- Displays all populated fields in a clean format
- No backups needed (read-only operation)
- Fast - only extracts ComicInfo.xml

### 3. Modified Initialization
- `attributes` parameter is now optional (defaults to empty list)
- Allows creating a ComicInfoModifier instance without attributes for view mode

### 4. Updated Argument Parsing
- `--attribute` is now optional (required only when not in view mode)
- Main function validates proper usage of view vs modification modes

## Usage

### Basic Syntax
```bash
./ComicInfoEdit.py <file> --view
```

### Examples

**View metadata from a comic:**
```bash
./ComicInfoEdit.py "Amazing Spider-Man #1.cbz" --view
```

**Output:**
```
Archive: Amazing Spider-Man #1.cbz
ComicInfo.xml found ✓

Metadata:
  Series: Amazing Spider-Man
  Number: 1
  Volume: 2018
  Summary: Peter Parker faces his greatest challenge...
  Publisher: Marvel Comics
  Writer: Dan Slott
  PageCount: 24
  LanguageISO: en
```

**Verbose mode works too:**
```bash
./ComicInfoEdit.py comic.cbz --view -v
```

**File with no ComicInfo.xml:**
```bash
./ComicInfoEdit.py old_scan.cbr --view
```
```
Archive: old_scan.cbr
ComicInfo.xml not found ✗
```

## Error Handling

**Must be a single file:**
```bash
$ ./ComicInfoEdit.py file1.cbz file2.cbz --view
Error: --view mode requires exactly one file path
```

**Must be a file, not a directory:**
```bash
$ ./ComicInfoEdit.py /comics --view
Error: --view mode requires a file, not a directory: /comics
```

**Must be a comic file:**
```bash
$ ./ComicInfoEdit.py document.pdf --view
Error: Not a comic file: document.pdf
```

## Workflow Integration

### Before (cumbersome):
1. Working in terminal
2. Need to check metadata
3. Switch to Windows
4. Open file in WinRAR
5. Navigate to ComicInfo.xml
6. Open in text editor
7. Switch back to terminal

### After (streamlined):
1. Working in terminal
2. Need to check metadata
3. `./ComicInfoEdit.py file.cbz --view`
4. Continue working

## Implementation Details

### How It Works
1. Validates input is a single comic file
2. Creates temporary directory for extraction
3. Extracts only the archive contents (not full repackaging)
4. Finds and parses ComicInfo.xml
5. Displays all non-empty XML elements
6. Truncates long values (>80 chars) for readability
7. Cleans up temporary files automatically

### Performance
- **Fast**: No backup creation needed
- **Lightweight**: Only extracts, doesn't repackage
- **Clean**: Automatic cleanup of temp files

### Compatibility
- ✓ Works with CBZ (zip) files
- ✓ Works with CBR (rar) files
- ✓ Compatible with verbose mode
- ✓ No interference with existing features

## Use Cases

1. **Pre-modification check**: See what metadata exists before making changes
2. **Post-modification verification**: Confirm your changes applied correctly
3. **Quick inspection**: Check if a file has ComicInfo.xml at all
4. **Collection auditing**: Quickly scan files to see what needs updating
5. **Debugging**: Verify metadata when troubleshooting Kavita/server issues

## Technical Notes

### Code Changes
- Modified `__init__` to make `attributes` parameter optional with default `None`
- Added `view_metadata()` method to ComicInfoModifier class
- Updated argument parser to add `--view` flag
- Made `--attribute` conditional (not required in view mode)
- Added view mode handling in `main()` before normal processing

### Testing Considerations
- Test with CBZ files
- Test with CBR files
- Test with files that have ComicInfo.xml
- Test with files that don't have ComicInfo.xml
- Test with multiple file arguments (should error)
- Test with directory arguments (should error)
- Test with non-comic files (should error)

## Benefits

1. **Speed**: No need to switch applications or extract manually
2. **Convenience**: Stay in your workflow/terminal
3. **Safety**: Read-only operation, no risk of accidental changes
4. **Efficiency**: Only extracts what's needed (ComicInfo.xml)
5. **Clarity**: Clean, easy-to-read output format

## Future Enhancements (Possible)

- JSON output format option for scripting
- Filter to show only specific fields
- Diff mode to compare metadata between two files
- Batch view mode with summary statistics

## Conclusion

The `--view` mode addresses a common workflow friction point by allowing quick metadata inspection without leaving the terminal. It's fast, safe, and integrates seamlessly with your existing comic management workflow.