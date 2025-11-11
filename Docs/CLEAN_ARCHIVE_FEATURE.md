# Clean Archive Feature

## Overview

The `--clean-archive` flag removes non-comic files (SFV, NFO, TXT, etc.) when repackaging archives. This is particularly useful for fixing issues with comic book server software like Kavita, which can incorrectly parse volumes when non-image files appear first in the archive.

## Why You Need This

### The Problem

Many downloaded comic archives contain extra files:
- **SFV files** - Simple File Verification checksums
- **NFO files** - Release information
- **TXT files** - Readme files
- **URL files** - Website shortcuts
- **MD5/PAR files** - Checksums and recovery data

These files can cause issues:
1. **Kavita server** may fail to detect the correct volume if a non-image file is first
2. **Comic readers** may display these files as pages
3. **Unnecessary bloat** in your collection
4. **Metadata confusion** from multiple info sources

### The Solution

The `--clean-archive` flag keeps only:
- ✅ Image files (JPG, JPEG, PNG, GIF, WEBP, BMP, TIFF)
- ✅ Metadata files (ComicInfo.xml)

Everything else is removed:
- ❌ SFV (Simple File Verification)
- ❌ NFO (Info files)
- ❌ TXT (Text/Readme files)
- ❌ URL (URL shortcuts)
- ❌ MD5, PAR, PAR2 (Verification/repair files)
- ❌ System files (Thumbs.db, .DS_Store)

## Usage

### Basic Syntax

```bash
./comic_info_modifier.py [files/dirs] --attribute [attrs] --clean-archive
```

### Examples

#### Fix Kavita Volume Detection

```bash
# Clean all comics in a directory
./comic_info_modifier.py /comics/batman --attribute Publisher="DC Comics" --clean-archive -v
```

#### Clean Without Modifying Metadata

If you just want to clean archives without changing metadata, you can update an attribute to itself or use a harmless attribute:

```bash
# Add or update a harmless attribute
./comic_info_modifier.py /comics --attribute Format="Digital" --clean-archive
```

#### Clean Entire Collection

```bash
# Process all comics and remove junk files
./comic_info_modifier.py /comics --attribute LanguageISO="en" --clean-archive -v
```

#### Clean with Multiple Operations

```bash
# Update metadata, remove attributes, and clean junk files all at once
./comic_info_modifier.py /comics --attribute \
    Series="Spider-Man" \
    Publisher="Marvel Comics" \
    Writer=null \
    --clean-archive \
    -v
```

## Before and After

### Before (Messy Archive)
```
comic_issue_01.cbz contents:
  - ComicInfo.xml
  - page01.jpg
  - page02.jpg
  - page03.jpg
  - comic.sfv          ← causes issues
  - info.nfo           ← causes issues
  - README.txt         ← causes issues
  - website.url        ← causes issues
  - checksums.md5      ← causes issues
```

### After (Clean Archive)
```
comic_issue_01.cbz contents:
  - ComicInfo.xml
  - page01.jpg
  - page02.jpg
  - page03.jpg
```

## What Gets Kept

### Image Files
All standard image formats used in comics:
- `.jpg`, `.jpeg` - JPEG images
- `.png` - PNG images
- `.gif` - GIF images (including animated)
- `.webp` - WebP images
- `.bmp` - Bitmap images
- `.tiff`, `.tif` - TIFF images

### Metadata Files
- `.xml` - ComicInfo.xml and other metadata files

## What Gets Removed

### Verification Files
- `.sfv` - Simple File Verification
- `.md5` - MD5 checksums
- `.sha1`, `.sha256` - SHA checksums
- `.crc` - CRC checksums

### Info Files
- `.nfo` - Info/release information
- `.diz` - Description files

### Text Files
- `.txt` - Text/readme files
- `.doc`, `.docx` - Word documents
- `.pdf` - PDF documents (unless they're part of the comic)

### Other Files
- `.url` - URL shortcuts
- `.par`, `.par2` - Parity/recovery files
- `.exe`, `.bat` - Executable files
- `.ini`, `.cfg` - Configuration files
- `Thumbs.db` - Windows thumbnail cache
- `.DS_Store` - macOS folder info

## Verbose Output

With the `-v` flag, you'll see exactly what's being removed:

```bash
./comic_info_modifier.py comic.cbz --attribute Series="Test" --clean-archive -v
```

Output:
```
[INFO] Processing: comic.cbz
[INFO] Extracted CBZ: comic.cbz
[INFO] Updated Series: 'Old' -> 'Test'
[INFO] Excluding non-comic file: comic.sfv
[INFO] Excluding non-comic file: info.nfo
[INFO] Excluding non-comic file: README.txt
[INFO] Excluding non-comic file: website.url
[INFO] Excluding non-comic file: checksums.md5
[INFO] Cleaned archive: removed 5 non-comic file(s)
[INFO] Created CBZ: comic.cbz
[INFO] Successfully updated: comic.cbz
```

## Common Use Cases

### 1. Fix Kavita Server Issues

Kavita and other servers may misparse comics when non-image files appear first:

```bash
# Clean all comics in a series
./comic_info_modifier.py /comics/series_name --attribute Publisher="Marvel" --clean-archive
```

### 2. Prepare for Comic Server Import

Clean your collection before importing to any comic server:

```bash
# Clean and standardize metadata
./comic_info_modifier.py /new_comics --attribute \
    LanguageISO="en" \
    Format="Digital" \
    --clean-archive \
    -v
```

### 3. Reduce Archive Size

Remove unnecessary files to save space:

```bash
# Clean all comics
./comic_info_modifier.py /comics --attribute Series="Current" --clean-archive --update-only
```

### 4. Fix Downloaded Comics

Many downloaded comics contain scene release files:

```bash
# Clean downloads folder
./comic_info_modifier.py ~/Downloads/*.cbz --attribute LanguageISO="en" --clean-archive -v
```

## Safety

- **Backups are created** before any changes
- **Original restored** if cleaning fails
- **Can be combined** with `--keep-backups` for extra safety
- **Verbose mode** shows exactly what's being removed

## Performance

Cleaning adds minimal overhead:
- Files are filtered during repackaging
- No additional extraction needed
- Same single-pass efficiency

## Combining Features

All features work together:

```bash
# Update existing metadata, remove Writer, clean junk files
./comic_info_modifier.py /comics --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    Writer=null \
    --update-only \
    --clean-archive \
    -v
```

This command will:
1. Update Series and Publisher (only if they exist)
2. Remove Writer attribute
3. Remove all non-comic files
4. Show detailed logging

## When Not to Use

Don't use `--clean-archive` if:
- Archives contain legitimate PDF comic pages
- You need to preserve release info (NFO files)
- Archives have important documentation you want to keep

In these cases, clean manually or use the script without the flag.

## Testing

Run the demo to see it in action:

```bash
./demo_clean_archive.sh
```

This creates a test comic with junk files and shows the before/after.

## Allowed Extensions Reference

The script keeps files with these extensions:

**Images:**
- .jpg, .jpeg
- .png
- .gif
- .webp
- .bmp
- .tiff, .tif

**Metadata:**
- .xml

Everything else is removed when `--clean-archive` is used.

## FAQ

**Q: Will this remove PDF files?**  
A: Yes, PDFs are not considered standard comic image files. If your comic uses PDFs, don't use `--clean-archive`.

**Q: What if I want to keep some text files?**  
A: Don't use `--clean-archive`, or manually edit the archive after processing.

**Q: Does it work with CBR files?**  
A: Yes, works with both CBZ and CBR formats.

**Q: Can I run this on my entire collection?**  
A: Yes, but test on a few files first with `-v` to see what gets removed.

**Q: Will this fix all Kavita issues?**  
A: It fixes volume detection issues caused by non-image files appearing first in archives. Other Kavita issues may have different causes.

**Q: Is it reversible?**  
A: Use `--keep-backups` to preserve originals, or keep your own backups before running.