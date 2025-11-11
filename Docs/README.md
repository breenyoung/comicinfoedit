# Comic Info Modifier

A Python command-line tool for modifying `ComicInfo.xml` files within CBZ (zip) and CBR (rar) comic book archives.

## Features

- ✅ Supports both CBZ and CBR formats
- ✅ Add, update, or remove XML attributes
- ✅ Automatic backup and restore on failure
- ✅ Process individual files or entire directories
- ✅ Recursive directory scanning
- ✅ Verbose logging option
- ✅ Safe error handling with rollback

## Requirements

- Python 3.6+
- `unrar` command (for CBR files)
- `rar` command (for creating CBR files)

### Installing rar/unrar on Linux

```bash
# Debian/Ubuntu
sudo apt-get install rar unrar

# Fedora/RHEL
sudo dnf install unrar
# rar may need to be downloaded from rarlab.com

# Arch Linux
sudo pacman -S unrar
```

## Usage

```bash
./comic_info_modifier.py [paths...] --attribute KEY=VALUE [options]
```

### Arguments

- `paths`: One or more file paths or directories to process
- `-a, --attribute`: XML attribute(s) to modify in `key=value` format. Can specify multiple attributes.
  - Use `value=null` to remove an attribute
- `-v, --verbose`: Enable detailed logging
- `--update-only`: Only update existing attributes, do not create new ones (ignored when removing attributes)
- `--clean-archive`: Remove non-comic files (SFV, NFO, TXT, etc.) when repackaging archives
- `--keep-backups`: Keep backup files after processing (default: delete)

## Examples

### Update Series for all comics in a directory

```bash
./comic_info_modifier.py /path/to/comics --attribute Series="Amazing Spider-Man"
```

### Remove Writer attribute from specific files

```bash
./comic_info_modifier.py file1.cbz file2.cbr --attribute Writer=null
```

### Set Volume for all comics in current directory (verbose)

```bash
./comic_info_modifier.py . --attribute Volume=2 -v
```

### Process multiple directories

```bash
./comic_info_modifier.py /comics/marvel /comics/dc --attribute Publisher="Marvel Comics"
```

### Update multiple files with backup retention

```bash
./comic_info_modifier.py issue1.cbz issue2.cbz --attribute Number=1 --keep-backups
```

### Only update existing attributes (don't create new ones)

```bash
# This will only update Publisher if it already exists in the ComicInfo.xml
./comic_info_modifier.py /comics --attribute Publisher="Marvel Comics" --update-only
```

### Batch update existing Series names without creating the attribute

```bash
# Useful when you want to fix existing metadata without adding to comics that don't have it
./comic_info_modifier.py . --attribute Series="Corrected Name" --update-only -v
```

### Update multiple attributes at once

```bash
# Set multiple metadata fields in a single pass
./comic_info_modifier.py comic.cbz --attribute Series="Spider-Man" Volume=1 Publisher="Marvel"
```

### Mix updates and removals

```bash
# Update some attributes while removing others
./comic_info_modifier.py *.cbz --attribute Publisher="DC Comics" Writer=null Colorist=null
```

### Batch update multiple fields for an entire collection

```bash
# Standardize metadata across a collection
./comic_info_modifier.py /comics/spider-man --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    LanguageISO="en" \
    -v
```

### Clean archives by removing non-comic files

```bash
# Remove SFV, NFO, TXT, and other junk files that cause issues with comic servers
./comic_info_modifier.py /comics --attribute Series="Batman" --clean-archive -v
```

### Fix Kavita server volume parsing issues

```bash
# Clean archives to ensure images are first (fixes Kavita volume detection)
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --clean-archive
```

## Common ComicInfo.xml Attributes

Here are some commonly used attributes in ComicInfo.xml:

- `Series` - Series name
- `Number` - Issue number
- `Volume` - Volume number
- `Title` - Issue title
- `Writer` - Writer(s)
- `Penciller` - Penciller(s)
- `Inker` - Inker(s)
- `Colorist` - Colorist(s)
- `Letterer` - Letterer(s)
- `Publisher` - Publisher name
- `Genre` - Genre
- `Web` - Web URL
- `Summary` - Description/summary
- `Year` - Publication year
- `Month` - Publication month

For a complete list, refer to the [ComicInfo.xml specification](https://anansi-project.github.io/docs/comicinfo/schemas/v2.0).

## How It Works

1. **Backup**: Creates a backup of each file before processing
2. **Extract**: Extracts the archive to a temporary directory
3. **Modify**: Finds and modifies `ComicInfo.xml`
4. **Repackage**: Recreates the archive with the same format
5. **Replace**: Overwrites the original file
6. **Cleanup**: Removes temporary files and backups (unless `--keep-backups` is used)

If any step fails, the original file is restored from backup.

## Error Handling

- If `ComicInfo.xml` is not found, the file is skipped with an error message
- If extraction/compression fails, the original file is restored
- Backup files are kept in a temporary directory until successful completion
- Use `--keep-backups` to retain backups for inspection

## Exit Codes

- `0` - All files processed successfully
- `1` - One or more files failed to process
- `130` - Interrupted by user (Ctrl+C)

## Limitations

- Requires `unrar` and `rar` commands to be available in PATH
- Only processes files with `.cbz` or `.cbr` extensions
- Archive must contain a `ComicInfo.xml` file
- CBR creation requires the proprietary `rar` utility

## License

Free to use and modify for personal and commercial use.

## Troubleshooting

### "unrar command not found"
Install the `unrar` package for your distribution (see Requirements section).

### "rar command not found"
The `rar` utility is proprietary. Download it from [rarlab.com](https://www.rarlab.com/download.htm) or use CBZ format instead.

### "ComicInfo.xml not found"
The archive doesn't contain a `ComicInfo.xml` file. You can create one manually or use a tool like ComicRack to add metadata.

### Changes not appearing
Make sure you're using the correct attribute name. Attribute names are case-sensitive (e.g., `Series` not `series`).