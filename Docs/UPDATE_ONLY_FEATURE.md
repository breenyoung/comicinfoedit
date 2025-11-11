# Update-Only Feature Summary

## New Flag: `--update-only`

The `--update-only` flag changes the behavior when setting attribute values. Instead of creating new attributes when they don't exist, it will only update attributes that are already present in the ComicInfo.xml file.

## When to Use

This is useful when you want to:
- Fix or standardize existing metadata without adding new fields
- Update specific comics that already have certain attributes
- Avoid cluttering ComicInfo.xml with unnecessary fields

## Behavior

### Without `--update-only` (default):
```bash
./comic_info_modifier.py comic.cbz --attribute Publisher="Marvel"
```
- If `Publisher` exists: **Updates the value**
- If `Publisher` doesn't exist: **Creates it with the new value**

### With `--update-only`:
```bash
./comic_info_modifier.py comic.cbz --attribute Publisher="Marvel" --update-only
```
- If `Publisher` exists: **Updates the value**
- If `Publisher` doesn't exist: **Skips the file (no changes)**

## Examples

### Example 1: Fix Publisher for comics that have it

You have a collection where some comics have Publisher="Marel" (typo). You want to fix it to "Marvel", but only for comics that already have the Publisher field.

```bash
./comic_info_modifier.py /comics/marvel --attribute Publisher="Marvel" --update-only -v
```

**Result:**
- Comics with Publisher="Marel" → Updated to "Marvel"
- Comics with Publisher="Marvel" → No change (already correct)
- Comics without Publisher → Skipped (attribute not added)

### Example 2: Standardize Series names

You want to change "Amazing Spider-Man" to "The Amazing Spider-Man", but only for comics that already have the Series field populated.

```bash
./comic_info_modifier.py . --attribute Series="The Amazing Spider-Man" --update-only
```

**Result:**
- Comics with Series="Amazing Spider-Man" → Updated
- Comics with Series="Spider-Man" → Updated
- Comics without Series → Skipped

### Example 3: Remove attributes (--update-only ignored)

When removing attributes with `value=null`, the `--update-only` flag is ignored (since you can't remove what doesn't exist anyway).

```bash
./comic_info_modifier.py *.cbz --attribute Writer=null --update-only
```

**Result:**
- Comics with Writer → Attribute removed
- Comics without Writer → No change (nothing to remove)

## Demo Output

Here's what the verbose output looks like:

```
[INFO] Found 2 comic file(s) to process

Processing: comic_has_publisher.cbz
[INFO] Updated Publisher: 'Old Publisher' -> 'New Publisher'
[INFO] Successfully updated: comic_has_publisher.cbz

Processing: comic_missing_publisher.cbz
[INFO] Attribute Publisher not found (update-only mode, skipping)
[INFO] No changes needed for comic_missing_publisher.cbz

Processing complete:
  Successfully processed: 2
  Failed: 0
  Total: 2
```

## Important Notes

1. **The flag only affects setting values**, not removing them
2. **Files are still counted as "successfully processed"** even if skipped due to missing attributes
3. **Use with `-v` (verbose) to see which files were skipped**
4. **Backups are still created** for all processed files (even skipped ones)

## Testing

Run the included demo script to see it in action:

```bash
./demo_update_only.sh
```

This creates two test comics:
- One WITH Publisher (gets updated)
- One WITHOUT Publisher (gets skipped)