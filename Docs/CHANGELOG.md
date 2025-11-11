# Comic Info Modifier - Feature Summary & Changelog

## Current Version Features

### Core Functionality
✅ **Modify ComicInfo.xml files** in CBZ/CBR archives  
✅ **Process multiple files or entire directories** recursively  
✅ **Automatic backup and restore** on failure  
✅ **Support for both CBZ and CBR** formats  

### Advanced Features

#### 1. Multiple Attributes (Added)
Process multiple attributes in a single run for maximum efficiency.

```bash
./comic_info_modifier.py comic.cbz --attribute \
    Series="Spider-Man" \
    Volume=1 \
    Publisher="Marvel" \
    Writer=null
```

**Benefits:**
- Single extraction/compression cycle
- Much faster than multiple runs
- Mix updates, additions, and removals

#### 2. Update-Only Mode (Added)
Only modify attributes that already exist - won't create new ones.

```bash
./comic_info_modifier.py comics/ --attribute Publisher="Marvel" --update-only
```

**Use Cases:**
- Fix typos without adding new fields
- Standardize existing metadata
- Safe batch updates

#### 3. Clean Archives (Added)
Remove non-comic files (SFV, NFO, TXT, etc.) that cause server parsing issues.

```bash
./comic_info_modifier.py comics/ --attribute Series="Batman" --clean-archive
```

**Removes:**
- ❌ SFV (verification files)
- ❌ NFO (info files)
- ❌ TXT (readme files)
- ❌ URL (shortcuts)
- ❌ MD5/PAR (checksums)

**Keeps:**
- ✅ JPG, PNG, GIF, WEBP (images)
- ✅ ComicInfo.xml (metadata)

**Solves:**
- Kavita server volume detection issues
- Comic readers displaying non-image files
- Unnecessary archive bloat

### Command Line Options

| Option | Description |
|--------|-------------|
| `paths` | File(s) or directory(ies) to process |
| `-a, --attribute` | Attribute(s) to modify (multiple allowed) |
| `-v, --verbose` | Show detailed logging |
| `--update-only` | Only update existing attributes |
| `--clean-archive` | Remove non-comic files |
| `--keep-backups` | Don't delete backup files |

## Feature Combinations

All features work together:

```bash
# Update existing metadata, remove attributes, clean junk files
./comic_info_modifier.py /comics --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    Writer=null \
    --update-only \
    --clean-archive \
    -v
```

## Use Case Examples

### For Kavita Users
```bash
# Fix volume detection by cleaning archives
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --clean-archive
```

### For Collection Organizers
```bash
# Standardize metadata across entire collection
./comic_info_modifier.py /comics --attribute \
    LanguageISO="en" \
    Format="Digital" \
    --clean-archive
```

### For Batch Metadata Updates
```bash
# Fix typos in existing fields only
./comic_info_modifier.py /comics --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    --update-only
```

### For Download Cleanup
```bash
# Clean downloaded comics in one command
./comic_info_modifier.py ~/Downloads/*.cbz --attribute \
    LanguageISO="en" \
    --clean-archive \
    -v
```

## Changelog

### Version 3.0 (Current)
- ✨ **NEW:** Clean archives feature (`--clean-archive`)
  - Removes SFV, NFO, TXT, and other non-comic files
  - Fixes Kavita server volume parsing issues
  - Reduces archive bloat
  
- 🔧 **ENHANCED:** Multiple attributes support
  - Process multiple attributes in one pass
  - Much faster for bulk operations
  
- 🎯 **ADDED:** Update-only mode (`--update-only`)
  - Only modifies existing attributes
  - Safe for large collection updates

### Version 2.0
- ✨ Multiple attributes per command
- ✨ Update-only mode
- 🔧 Improved error handling
- 📝 Comprehensive documentation

### Version 1.0
- ⭐ Initial release
- Basic ComicInfo.xml modification
- CBZ/CBR support
- Automatic backup/restore
- Recursive directory processing

## Documentation

- **README.md** - Complete user guide
- **FEATURES_GUIDE.md** - All features explained with examples
- **QUICK_REFERENCE.md** - Command cheat sheet
- **CLEAN_ARCHIVE_FEATURE.md** - Detailed clean archive guide
- **MULTIPLE_ATTRIBUTES_FEATURE.md** - Multiple attributes guide
- **UPDATE_ONLY_FEATURE.md** - Update-only mode guide

## Testing

Comprehensive test suite included:

```bash
./test_script.sh              # Basic functionality
./demo_update_only.sh          # Update-only mode
./demo_multi_attributes.sh     # Multiple attributes
./demo_clean_archive.sh        # Clean archives
./comprehensive_test.sh        # All features
```

## Requirements

- Python 3.6+
- `unrar` for CBR extraction
- `rar` for CBR creation
- `zip` for CBZ (built-in)

## Installation

```bash
chmod +x comic_info_modifier.py
```

Optional dependencies:
```bash
sudo apt-get install unrar rar  # Debian/Ubuntu
```

## Performance

**Before (multiple runs):**
```bash
./script.py comics/ --attribute Series="X-Men"      # Extract + compress all
./script.py comics/ --attribute Volume=1            # Extract + compress all
./script.py comics/ --attribute Publisher="Marvel"  # Extract + compress all
```
⏱️ 3x extraction, 3x compression

**After (single run):**
```bash
./script.py comics/ --attribute Series="X-Men" Volume=1 Publisher="Marvel"
```
⏱️ 1x extraction, 1x compression

**Result:** Up to 3x faster for multiple attributes!

## Safety Features

✅ Automatic backups before modifications  
✅ Restore on any error  
✅ Verbose mode shows all changes  
✅ Optional backup retention  
✅ Non-destructive by default  

## Common Workflows

1. **Fix Kavita issues:** Use `--clean-archive`
2. **Standardize metadata:** Use multiple attributes
3. **Safe updates:** Use `--update-only`
4. **Test first:** Use `-v` and `--keep-backups`
5. **Process in batches:** Start with subdirectories

## Support

For questions or issues:
1. Check documentation in docs folder
2. Run demo scripts to see features in action
3. Use `-v` flag for detailed logging
4. Test on backup copies first

## License

Free to use and modify for personal and commercial use.

---

**Current Version:** 3.0  
**Last Updated:** November 2025  
**Platform:** Linux (Ubuntu 24)  
**Language:** Python 3.6+