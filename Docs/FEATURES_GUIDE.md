# Comic Info Modifier - Complete Feature Guide

## Quick Start

```bash
# Single attribute
./comic_info_modifier.py comic.cbz --attribute Series="Spider-Man"

# Multiple attributes
./comic_info_modifier.py comic.cbz --attribute Series="Spider-Man" Volume=1 Publisher="Marvel"

# Remove attributes
./comic_info_modifier.py comic.cbz --attribute Writer=null Colorist=null

# Update only (don't create new)
./comic_info_modifier.py comics/ --attribute Publisher="Marvel" --update-only

# Process entire directory
./comic_info_modifier.py /path/to/comics --attribute Series="X-Men" -v
```

## All Features

### 1. Multiple File Processing
- Process individual files: `script.py file1.cbz file2.cbr`
- Process directories: `script.py /comics/marvel`
- Recursive search for all CBZ/CBR files
- Mix files and directories: `script.py file.cbz /comics/dc`

### 2. Multiple Attributes
- Modify multiple attributes in one pass
- Much faster than running script multiple times
- Mix updates, additions, and removals
- Example: `--attribute Series="X-Men" Volume=1 Writer=null`

### 3. Update-Only Mode
- Only updates existing attributes
- Won't create new attributes when they don't exist
- Useful for fixing/standardizing existing metadata
- Example: `--attribute Publisher="Marvel" --update-only`

### 4. Remove Attributes
- Set value to `null` to remove attribute
- Works with multiple removals: `Writer=null Colorist=null`
- Update-only flag ignored for removals

### 5. Clean Archives
- Remove non-comic files (SFV, NFO, TXT, etc.)
- Fixes Kavita server volume parsing issues
- Keeps only images and ComicInfo.xml
- Example: `--attribute Series="Batman" --clean-archive`

### 6. Automatic Backup & Restore
- Backs up each file before modification
- Restores on any error
- Auto-cleanup after success
- Optional `--keep-backups` flag

### 7. Both CBZ and CBR Support
- CBZ: Standard ZIP format
- CBR: RAR format (requires unrar/rar commands)
- Preserves original format
- Automatic format detection

### 8. Directory Control
- Process entire directory trees recursively (default)
- Or process only specified directory with `--no-recursive`
- Flexible file and directory selection
- Mix files and directories as inputs

### 9. Verbose Logging
- Use `-v` flag for detailed output
- Shows each attribute change
- Useful for debugging
- Reports success/failure counts

## Common Workflows

### Fix Typos Across Collection

```bash
# Fix publisher name typo in all comics that have it
./comic_info_modifier.py /comics --attribute \
    Publisher="Marvel Comics" \
    --update-only \
    -v
```

### Standardize Metadata

```bash
# Ensure all Spider-Man comics have consistent metadata
./comic_info_modifier.py /comics/spider-man --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    LanguageISO="en"
```

### Clean Up Metadata

```bash
# Remove unwanted attributes from all comics
./comic_info_modifier.py /comics --attribute \
    Writer=null \
    Penciller=null \
    Inker=null \
    Colorist=null \
    Letterer=null
```

### Add Complete Metadata to New Comics

```bash
# Set all metadata for newly acquired comics
./comic_info_modifier.py new_issue.cbz --attribute \
    Series="Batman" \
    Number=1 \
    Volume=1 \
    Title="The Dark Knight Returns" \
    Publisher="DC Comics" \
    Year=2024 \
    LanguageISO="en"
```

### Clean Archives (Fix Kavita Server Issues)

```bash
# Remove SFV, NFO, and other junk files that cause volume parsing issues
./comic_info_modifier.py /comics/series --attribute \
    Publisher="Marvel Comics" \
    --clean-archive \
    -v
```

### Bulk Clean Entire Collection

```bash
# Clean all comics without modifying metadata
./comic_info_modifier.py /comics --attribute Format="Digital" --clean-archive
```

### Process Specific Folder Only

```bash
# Only process comics in current folder, not subdirectories
./comic_info_modifier.py /comics/marvel/spider-man --attribute \
    Series="The Amazing Spider-Man" \
    --no-recursive
```

### Selective Updates

```bash
# Part 1: Fix existing Series/Publisher (update-only)
./comic_info_modifier.py /comics --attribute \
    Series="X-Men" \
    Publisher="Marvel Comics" \
    --update-only

# Part 2: Add new fields to all
./comic_info_modifier.py /comics --attribute \
    LanguageISO="en" \
    Volume=1

# Part 3: Remove unwanted fields
./comic_info_modifier.py /comics --attribute \
    Writer=null \
    Penciller=null
```

## Performance Tips

### Process Multiple Attributes at Once
**Slow:**
```bash
./script.py /comics --attribute Series="X-Men"
./script.py /comics --attribute Volume=1
./script.py /comics --attribute Publisher="Marvel"
./script.py /comics --attribute Writer=null
```
Each run extracts, modifies, and recompresses all files.

**Fast:**
```bash
./script.py /comics --attribute \
    Series="X-Men" \
    Volume=1 \
    Publisher="Marvel" \
    Writer=null
```
Single extract/compress cycle per file.

### Use Update-Only for Large Collections
When you only want to fix existing metadata:
```bash
# Without update-only: might add thousands of new attributes
./script.py /comics --attribute Publisher="Marvel"

# With update-only: only fixes existing Publisher fields
./script.py /comics --attribute Publisher="Marvel" --update-only
```

## Error Handling

- **ComicInfo.xml missing**: File skipped with error message
- **Extraction fails**: Original restored from backup
- **Compression fails**: Original restored from backup
- **Any error**: Automatic rollback to original file

## Exit Codes

- `0`: All files processed successfully
- `1`: One or more files failed
- `130`: Interrupted by user (Ctrl+C)

## Examples by Use Case

### Organizing a New Collection

```bash
# Step 1: Add language to all
./comic_info_modifier.py /new_comics --attribute LanguageISO="en"

# Step 2: Fix existing metadata
./comic_info_modifier.py /new_comics --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    --update-only

# Step 3: Clean up junk metadata
./comic_info_modifier.py /new_comics --attribute \
    Notes=null \
    Web=null
```

### Preparing for Calibre/ComicRack

```bash
# Ensure all required fields are present
./comic_info_modifier.py /comics --attribute \
    LanguageISO="en" \
    Format="Digital"

# Standardize publisher names
./comic_info_modifier.py /comics --attribute \
    Publisher="Marvel Comics" \
    --update-only
```

### Fixing Bulk Import Errors

```bash
# Fix common typos in one pass
./comic_info_modifier.py /comics --attribute \
    Publisher="Marvel Comics" \
    Series="The Amazing Spider-Man" \
    --update-only \
    -v
```

## Testing

Run the included test scripts to see features in action:

```bash
# Basic functionality
./test_script.sh

# Update-only feature
./demo_update_only.sh

# Multiple attributes
./demo_multi_attributes.sh

# Clean archives
./demo_clean_archive.sh

# Non-recursive mode
./demo_no_recursive.sh

# Comprehensive test
./comprehensive_test.sh
```

## Tips

1. **Always use `-v` first**: Run with verbose mode on a few test files to ensure correct behavior
2. **Start with `--update-only`**: Safer for large collections
3. **Process in batches**: For huge collections, process subdirectories separately
4. **Keep backups initially**: Use `--keep-backups` until confident
5. **Test on copies**: Try on backup copies of valuable comics first

## Troubleshooting

**"No comic files found"**
- Check paths are correct
- Ensure files have .cbz or .cbr extension

**"ComicInfo.xml not found"**
- Archive doesn't contain metadata file
- Create one manually or use ComicRack

**"unrar command not found"**
- Install: `sudo apt-get install unrar`

**"rar command not found"**
- Download from rarlab.com or use CBZ format

**Changes not appearing**
- Attribute names are case-sensitive
- Check XML with: `unzip -p comic.cbz ComicInfo.xml`

**Too slow on large collection**
- Process subdirectories in parallel
- Use multiple terminal windows
- Consider update-only mode

## Support

For issues or questions, check the documentation:
- README.md - Full documentation
- UPDATE_ONLY_FEATURE.md - Update-only details
- MULTIPLE_ATTRIBUTES_FEATURE.md - Multiple attributes details