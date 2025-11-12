# Non-Recursive Mode Feature

## Overview

The `--no-recursive` flag processes only files in the specified directory, without descending into subdirectories. This gives you precise control over which comics to process.

## Usage

```bash
./comic_info_modifier.py [directory] --attribute [attrs] --no-recursive
```

## Default Behavior (Recursive)

By default, the script processes **all** CBZ/CBR files in the specified directory and all subdirectories:

```bash
./comic_info_modifier.py /comics --attribute Publisher="Marvel"
```

**Processes:**
```
/comics/
  ├── issue1.cbz          ✓ Processed
  ├── issue2.cbz          ✓ Processed
  ├── series_a/
  │   ├── volume1.cbz     ✓ Processed
  │   └── volume2.cbz     ✓ Processed
  └── series_b/
      ├── arc1/
      │   └── part1.cbz   ✓ Processed
      └── arc2/
          └── part2.cbz   ✓ Processed
```

**Result:** 6 files processed

## Non-Recursive Mode

With `--no-recursive`, only files in the specified directory are processed:

```bash
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --no-recursive
```

**Processes:**
```
/comics/
  ├── issue1.cbz          ✓ Processed
  ├── issue2.cbz          ✓ Processed
  ├── series_a/
  │   ├── volume1.cbz     ✗ Skipped
  │   └── volume2.cbz     ✗ Skipped
  └── series_b/
      ├── arc1/
      │   └── part1.cbz   ✗ Skipped
      └── arc2/
          └── part2.cbz   ✗ Skipped
```

**Result:** 2 files processed (only in /comics)

## When to Use Each Mode

### Use Recursive Mode (default) when:
- ✅ Processing entire collection
- ✅ Organizing large library
- ✅ Bulk operations across all comics
- ✅ You want to process everything under a directory

### Use Non-Recursive Mode (`--no-recursive`) when:
- ✅ Processing specific folder only
- ✅ Avoiding subdirectories intentionally
- ✅ Testing on one directory before bulk operation
- ✅ Organizing by individual series/volumes
- ✅ You have different rules for different subdirectories

## Examples

### Example 1: Test Before Bulk Operation

```bash
# Test on just the root directory first
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --no-recursive -v

# If everything looks good, run on all subdirectories
./comic_info_modifier.py /comics --attribute Publisher="Marvel" -v
```

### Example 2: Process Each Series Separately

```bash
# Different metadata for each series
./comic_info_modifier.py /comics/spider-man --attribute Series="The Amazing Spider-Man" --no-recursive
./comic_info_modifier.py /comics/x-men --attribute Series="Uncanny X-Men" --no-recursive
./comic_info_modifier.py /comics/avengers --attribute Series="The Avengers" --no-recursive
```

### Example 3: Organize by Directory Level

```bash
# Add LanguageISO to all root-level comics
./comic_info_modifier.py /downloads --attribute LanguageISO="en" --no-recursive

# Then process subdirectories separately with different attributes
./comic_info_modifier.py /downloads/english --attribute LanguageISO="en"
./comic_info_modifier.py /downloads/japanese --attribute LanguageISO="ja"
```

### Example 4: Clean Only Root Directory

```bash
# Clean junk files only from root, leave subdirectories untouched
./comic_info_modifier.py /comics --attribute Format="Digital" --clean-archive --no-recursive
```

### Example 5: Selective Processing

```bash
# Directory structure:
#   /comics/
#     ├── completed/     (already organized)
#     ├── in_progress/   (needs processing)
#     └── new_downloads/ (needs processing)

# Only process new downloads, skip others
./comic_info_modifier.py /comics/new_downloads --attribute LanguageISO="en" --no-recursive
```

## Real-World Scenario

### Scenario: Organizing Downloaded Comics

You've downloaded a batch of comics into different folders:

```
/downloads/
  ├── temp_comic_1.cbz
  ├── temp_comic_2.cbz
  ├── already_sorted/
  │   └── (organized comics you don't want to touch)
  └── to_review/
      └── (comics that need manual review)
```

You want to add metadata to only the root-level comics without touching the subdirectories:

```bash
# Process only root-level downloads
./comic_info_modifier.py /downloads --attribute \
    LanguageISO="en" \
    Format="Digital" \
    --clean-archive \
    --no-recursive \
    -v
```

**Result:**
- ✓ `temp_comic_1.cbz` processed
- ✓ `temp_comic_2.cbz` processed
- ✗ `already_sorted/` untouched
- ✗ `to_review/` untouched

## Combining with Other Features

### With Update-Only

```bash
# Fix existing metadata in root directory only
./comic_info_modifier.py /comics --attribute \
    Publisher="Marvel Comics" \
    --update-only \
    --no-recursive
```

### With Clean Archives

```bash
# Clean junk files only from specific directory
./comic_info_modifier.py /comics/series_name --attribute \
    Series="Corrected Name" \
    --clean-archive \
    --no-recursive
```

### With Multiple Attributes

```bash
# Update multiple fields in one directory only
./comic_info_modifier.py /comics/new --attribute \
    LanguageISO="en" \
    Format="Digital" \
    Volume=1 \
    --no-recursive
```

## Technical Details

### Implementation

The flag changes the file discovery behavior:

**Recursive (default):**
```python
# Uses rglob (recursive glob)
comic_files.extend(path.rglob('*.cbz'))
```

**Non-recursive:**
```python
# Uses glob (non-recursive glob)
comic_files.extend(path.glob('*.cbz'))
```

### Performance

Non-recursive mode is slightly faster when:
- You have many subdirectories you don't need to scan
- Your directory tree is very deep
- You're processing a small subset of files

However, the difference is usually negligible unless you have thousands of subdirectories.

## Tips

1. **Use verbose mode** (`-v`) to see which files are found:
   ```bash
   ./comic_info_modifier.py /comics --attribute Series="Test" --no-recursive -v
   ```

2. **Test first** with `--no-recursive` before running on full tree:
   ```bash
   # Safe test on one directory
   ./comic_info_modifier.py /comics/test --attribute Publisher="Marvel" --no-recursive
   
   # Then run on all if satisfied
   ./comic_info_modifier.py /comics --attribute Publisher="Marvel"
   ```

3. **Combine with explicit file lists** when you need even more control:
   ```bash
   # Process specific files only
   ./comic_info_modifier.py file1.cbz file2.cbz --attribute Volume=1
   ```

## Common Mistakes

### ❌ Wrong: Using --no-recursive with file arguments
```bash
# This flag only affects directory processing
./comic_info_modifier.py comic.cbz --attribute Series="Test" --no-recursive
# The flag is ignored since you specified a file, not a directory
```

### ✓ Correct: Use --no-recursive with directories
```bash
./comic_info_modifier.py /comics --attribute Series="Test" --no-recursive
```

### ❌ Wrong: Expecting it to skip specific subdirectories
```bash
# This will process /comics but not subdirectories
./comic_info_modifier.py /comics --attribute Series="Test" --no-recursive
# It doesn't let you pick which subdirectories to skip
```

### ✓ Correct: Process specific subdirectories individually
```bash
./comic_info_modifier.py /comics/series_a --attribute Series="A" --no-recursive
./comic_info_modifier.py /comics/series_b --attribute Series="B" --no-recursive
```

## Testing

Run the demo to see the difference:

```bash
./demo_no_recursive.sh
```

This creates a test directory structure and shows:
- How many files are found in recursive mode
- How many files are found in non-recursive mode
- The difference in behavior

## FAQ

**Q: Can I process multiple directories non-recursively?**  
A: Yes! Specify multiple directories:
```bash
./comic_info_modifier.py /comics/dir1 /comics/dir2 --attribute Series="Test" --no-recursive
```

**Q: Does --no-recursive work with file arguments?**  
A: The flag is ignored for file arguments since there's nothing to recurse into. It only affects directory processing.

**Q: How do I process all directories at one level without their subdirectories?**  
A: You need to call the script separately for each directory with `--no-recursive`:
```bash
for dir in /comics/*/; do
    ./comic_info_modifier.py "$dir" --attribute LanguageISO="en" --no-recursive
done
```

**Q: Is there a way to exclude specific subdirectories?**  
A: Not directly, but you can use shell globbing or process directories individually with `--no-recursive`.

**Q: Does this affect file search patterns?**  
A: No, it only affects directory recursion. It still finds all `.cbz` and `.cbr` files at the level it's searching.

## Summary

- **Default:** Recursive processing (all subdirectories)
- **`--no-recursive`:** Current directory only
- **Best for:** Selective processing, testing, per-directory organization
- **Works with:** All other flags (update-only, clean-archive, etc.)

The `--no-recursive` flag gives you fine-grained control over which comics to process, making it safer and more flexible for complex library organization tasks.