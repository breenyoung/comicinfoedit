# Version 3.1 Update - Non-Recursive Mode Added

## New Feature: `--no-recursive`

You can now control whether the script processes subdirectories!

### Default Behavior (Recursive)

By default, the script processes **all** comics in a directory and its subdirectories:

```bash
./comic_info_modifier.py /comics --attribute Publisher="Marvel"
```

**Processes:**
- `/comics/issue1.cbz` ✓
- `/comics/series_a/volume1.cbz` ✓
- `/comics/series_a/subfolder/issue.cbz` ✓
- **All subdirectories included**

### New: Non-Recursive Mode

With `--no-recursive`, process **only** files in the specified directory:

```bash
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --no-recursive
```

**Processes:**
- `/comics/issue1.cbz` ✓
- `/comics/series_a/volume1.cbz` ✗ Skipped
- `/comics/series_a/subfolder/issue.cbz` ✗ Skipped
- **Subdirectories ignored**

## Why This Matters

### Use Cases

1. **Test before bulk operation**
   ```bash
   # Test on just one directory
   ./comic_info_modifier.py /comics --attribute Series="Test" --no-recursive -v
   ```

2. **Process each series separately**
   ```bash
   # Different metadata per series
   ./comic_info_modifier.py /comics/spider-man --attribute Series="Spider-Man" --no-recursive
   ./comic_info_modifier.py /comics/x-men --attribute Series="X-Men" --no-recursive
   ```

3. **Avoid touching organized subdirectories**
   ```bash
   # Process only new downloads, skip already-sorted folders
   ./comic_info_modifier.py /downloads --attribute LanguageISO="en" --no-recursive
   ```

4. **Selective folder processing**
   ```bash
   # Clean only root directory
   ./comic_info_modifier.py /comics --attribute Format="Digital" --clean-archive --no-recursive
   ```

## Demo

The test creates this structure:

```
root_level/
  ├── root_comic_1.cbz
  ├── root_comic_2.cbz
  ├── subfolder1/
  │   ├── sub1_comic_1.cbz
  │   └── deep_folder/
  │       └── deep_comic.cbz
  └── subfolder2/
      └── sub2_comic.cbz
```

**Results:**
- **Recursive mode:** Finds 6 files (all levels)
- **Non-recursive mode:** Finds 2 files (root only)

Run it yourself:
```bash
./demo_no_recursive.sh
```

## Combining Features

All features work together:

```bash
# Update only existing metadata in current directory, clean junk files
./comic_info_modifier.py /comics/series --attribute \
    Publisher="Marvel Comics" \
    Series="Spider-Man" \
    --update-only \
    --clean-archive \
    --no-recursive \
    -v
```

## Updated Files

**Main Script:**
- **[comic_info_modifier.py](computer:///mnt/user-data/outputs/comic_info_modifier.py)** - Added `--no-recursive` flag

**Documentation:**
- **[NO_RECURSIVE_FEATURE.md](computer:///mnt/user-data/outputs/NO_RECURSIVE_FEATURE.md)** - Complete guide to non-recursive mode
- **[README.md](computer:///mnt/user-data/outputs/README.md)** - Updated with examples
- **[QUICK_REFERENCE.md](computer:///mnt/user-data/outputs/QUICK_REFERENCE.md)** - Added to flags and examples
- **[FEATURES_GUIDE.md](computer:///mnt/user-data/outputs/FEATURES_GUIDE.md)** - Updated feature list
- **[CHANGELOG.md](computer:///mnt/user-data/outputs/CHANGELOG.md)** - Documented as v3.1 feature

**Test:**
- **[demo_no_recursive.sh](computer:///mnt/user-data/outputs/demo_no_recursive.sh)** - Demonstrates the difference

## Complete Feature Set (v3.1)

1. ✅ Multiple file/directory processing
2. ✅ Multiple attributes per command
3. ✅ Update-only mode
4. ✅ Remove attributes
5. ✅ Clean archives
6. ✅ Automatic backup & restore
7. ✅ CBZ and CBR support
8. ✅ **Non-recursive mode** (NEW!)
9. ✅ Verbose logging
10. ✅ Recursive addition bug fix

## Quick Examples

```bash
# Default: Process all subdirectories
./comic_info_modifier.py /comics --attribute Publisher="Marvel"

# New: Process only current directory
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --no-recursive

# Test before full run
./comic_info_modifier.py /comics/test_folder --attribute Series="Test" --no-recursive -v

# Process multiple directories without their subdirectories
./comic_info_modifier.py /comics/series1 /comics/series2 --attribute Volume=1 --no-recursive
```

## Migration Notes

**No changes needed for existing scripts!**

The default behavior is unchanged - the script still processes subdirectories recursively unless you add `--no-recursive`.

## Thanks!

This feature gives you much more control over which comics to process, making it safer and more flexible for complex library organization tasks.

Great suggestion! 🎯