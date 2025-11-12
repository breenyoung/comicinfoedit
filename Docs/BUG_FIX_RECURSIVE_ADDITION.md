# Bug Fix: Recursive Addition in create_cbz()

## The Problem

A critical bug was discovered in the `create_cbz()` method that could cause Python to crash with memory/recursion errors.

### What Was Happening

When creating a new CBZ file, the script:
1. Extracts the archive to a temporary directory
2. Modifies the ComicInfo.xml
3. Creates a new zip file in the **same temporary directory** with a name like `temp_comic.cbz`
4. Uses `os.walk()` to iterate through all files in that directory to add them to the zip

**The Bug:** The `os.walk()` iteration would encounter the `temp_comic.cbz` file being created and try to add it to itself, causing:
- Infinite recursion
- Exponential file size growth
- Python memory exhaustion
- Script crash

### Example of the Bug

```python
# Before the fix
with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zip_ref:
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            file_path = Path(root) / file
            # This would add temp_comic.cbz to itself!
            zip_ref.write(file_path, arcname)
```

When `os.walk()` reached `temp_comic.cbz`, it would:
1. Try to add `temp_comic.cbz` to the zip
2. Which makes `temp_comic.cbz` larger
3. Which `os.walk()` sees and tries to add again
4. Repeat until crash

## The Solution

The fix compares the absolute path of each file against the output file's path and skips it if they match:

```python
# After the fix
# Get the full, absolute path of the output file
abs_output_path = output_path.resolve()

with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zip_ref:
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            file_path = Path(root) / file
            
            # Resolve the current file's path and check if it's the same as the output file
            if file_path.resolve() == abs_output_path:
                self.log(f"Skipping recursive add of target file: {file}")
                continue  # Skip this file
            
            # ... rest of the code
```

### Key Points

1. **`resolve()`** converts both paths to absolute, canonical paths
2. **Comparison** checks if they're the same file
3. **Skip** if they match, preventing recursion
4. **Log** the skip in verbose mode for debugging

## Why This Matters

This bug could cause:
- ❌ Script crashes during normal operation
- ❌ Corrupted archives
- ❌ Loss of data (original file already modified)
- ❌ Wasted processing time
- ❌ Disk space exhaustion (file growing exponentially)

With the fix:
- ✅ Script runs reliably
- ✅ Archives created correctly
- ✅ No data loss
- ✅ No crashes
- ✅ Predictable behavior

## Testing

The fix has been verified with:

1. **demo_clean_archive.sh** - Shows the skip message in verbose output
2. **test_recursive_fix.sh** - Dedicated test for this bug fix
3. All other test scripts continue to work correctly

### Example Output

```
[INFO] Processing: test.cbz
[INFO] Extracted CBZ: test.cbz
[INFO] Updated Series: 'Old' -> 'New'
[INFO] Skipping recursive add of target file: temp_test.cbz  ← The fix in action
[INFO] Created CBZ: temp_test.cbz
[INFO] Successfully updated: test.cbz
```

## Credit

This bug was discovered and fixed by the user (Breen) during testing. The original implementation missed this edge case.

## Related Code

The same issue doesn't affect `create_cbr()` because:
1. RAR uses a different approach (changes directory first)
2. The clean archive mode for RAR uses a separate temporary directory
3. RAR is called as a subprocess, not iterating files directly

However, the CBR method could benefit from similar safety checks in the future.

## Technical Details

### Why `resolve()` is Important

```python
# Without resolve() - could fail
if file_path == output_path:  # May not match due to relative paths
    continue

# With resolve() - always works
if file_path.resolve() == output_path.resolve():  # Compares absolute paths
    continue
```

`resolve()`:
- Converts to absolute path
- Resolves symlinks
- Normalizes path separators
- Ensures reliable comparison

### Where This Occurs

The issue specifically occurs in `process_file()` at this line:

```python
temp_output = Path(temp_dir) / f"temp_{comic_path.name}"
```

This creates the output file **inside** the `temp_dir` that we're about to walk and zip, triggering the bug.

### Alternative Solutions Considered

1. **Create output file outside temp_dir** - Would work but requires more directory management
2. **Filter by filename** - Less reliable than path comparison
3. **Use a different temp directory** - Adds complexity
4. **Check file existence before adding** - Too late, file already being written

The chosen solution (path comparison) is:
- ✅ Simple
- ✅ Reliable
- ✅ Efficient
- ✅ Clear intent

## Lesson Learned

When creating archives programmatically:
- Always be aware of the working directory
- Never add a file to itself
- Use absolute path comparisons for safety
- Test with verbose logging enabled
- Verify archive contents after creation

## Version History

- **v3.0** - Bug introduced with clean-archive feature
- **v3.1** - Bug fixed with path comparison check

## See Also

- `test_recursive_fix.sh` - Test demonstrating the fix
- `demo_clean_archive.sh` - Shows fix in action with verbose output