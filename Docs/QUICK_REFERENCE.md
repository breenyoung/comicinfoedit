# Comic Info Modifier - Quick Reference

## Basic Commands

```bash
# Single file, single attribute
./comic_info_modifier.py comic.cbz --attribute Series="Spider-Man"

# Multiple files
./comic_info_modifier.py file1.cbz file2.cbr --attribute Publisher="Marvel"

# Entire directory (recursive)
./comic_info_modifier.py /comics --attribute LanguageISO="en"

# Multiple attributes at once
./comic_info_modifier.py comic.cbz --attribute Series="X-Men" Volume=1 Publisher="Marvel"

# Remove attribute
./comic_info_modifier.py comic.cbz --attribute Writer=null

# Update only if exists (don't create)
./comic_info_modifier.py comics/ --attribute Publisher="Marvel" --update-only

# Verbose mode (see all changes)
./comic_info_modifier.py comics/ --attribute Series="Batman" -v

# Keep backup files
./comic_info_modifier.py comic.cbz --attribute Title="New Title" --keep-backups

# Remove non-comic files (SFV, NFO, etc.) when repackaging
./comic_info_modifier.py comics/ --attribute Publisher="Marvel" --clean-archive -v

# Process only current directory (no subdirectories)
./comic_info_modifier.py /comics --attribute Series="Batman" --no-recursive
```

## Common Scenarios

### Fix typo across collection
```bash
./comic_info_modifier.py /comics --attribute Publisher="Marvel Comics" --update-only -v
```

### Add metadata to all comics
```bash
./comic_info_modifier.py /comics --attribute LanguageISO="en" Volume=1
```

### Standardize series name
```bash
./comic_info_modifier.py /comics/spiderman --attribute Series="The Amazing Spider-Man"
```

### Remove multiple fields
```bash
./comic_info_modifier.py /comics --attribute Writer=null Penciller=null Colorist=null
```

### Complete metadata update
```bash
./comic_info_modifier.py comic.cbz --attribute \
    Series="Batman" \
    Number=1 \
    Volume=1 \
    Publisher="DC Comics" \
    Year=2024 \
    LanguageISO="en"
```

### Clean archives (remove SFV, NFO, etc.)
```bash
# Fix Kavita server volume parsing issues
./comic_info_modifier.py /comics --attribute Publisher="Marvel" --clean-archive -v
```

### Process only one directory level
```bash
# Only process files in specified directory, skip subdirectories
./comic_info_modifier.py /comics/series --attribute Volume=1 --no-recursive
```

## Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `-a`, `--attribute` | Specify attribute(s) to modify | `--attribute Series="X-Men"` |
| `-v`, `--verbose` | Show detailed logging | `-v` |
| `--update-only` | Only update existing attributes | `--update-only` |
| `--clean-archive` | Remove non-comic files (SFV, NFO, etc.) | `--clean-archive` |
| `--no-recursive` | Don't process subdirectories | `--no-recursive` |
| `--keep-backups` | Don't delete backup files | `--keep-backups` |

## Attribute Format

- Set/Update: `Key=Value`
- Remove: `Key=null`
- Multiple: Space-separated
- Example: `Series="X-Men" Volume=1 Writer=null`

## Common ComicInfo Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| `Series` | Series name | `"The Amazing Spider-Man"` |
| `Number` | Issue number | `1` or `"1"` |
| `Volume` | Volume number | `1` |
| `Title` | Issue title | `"The Dark Knight Returns"` |
| `Publisher` | Publisher name | `"Marvel Comics"` |
| `Writer` | Writer name(s) | `"Stan Lee"` |
| `Penciller` | Penciller name(s) | `"Jack Kirby"` |
| `Year` | Publication year | `2024` |
| `Month` | Publication month | `1-12` |
| `LanguageISO` | Language code | `"en"` |
| `Genre` | Genre | `"Superhero"` |
| `Web` | Web URL | `"https://..."` |
| `Summary` | Description | `"..."` |

## Testing

```bash
# Run basic tests
./test_script.sh

# Test update-only
./demo_update_only.sh

# Test multiple attributes
./demo_multi_attributes.sh

# Comprehensive test
./comprehensive_test.sh
```

## Tips

✓ Use `-v` first to verify behavior  
✓ Start with `--update-only` for safety  
✓ Test on backup copies first  
✓ Process large collections in batches  
✓ Attribute names are case-sensitive  

## Exit Codes

- `0` = Success
- `1` = Failure
- `130` = Interrupted (Ctrl+C)

## Requirements

- Python 3.6+
- `unrar` for CBR extraction
- `rar` for CBR creation
- `zip` for CBZ (built-in)

## Installation

```bash
# Make executable
chmod +x comic_info_modifier.py

# Install dependencies (if needed)
sudo apt-get install unrar rar  # Debian/Ubuntu
```

## Help

```bash
./comic_info_modifier.py --help
```

## Documentation

- `README.md` - Complete documentation
- `FEATURES_GUIDE.md` - All features explained
- `UPDATE_ONLY_FEATURE.md` - Update-only details
- `MULTIPLE_ATTRIBUTES_FEATURE.md` - Multiple attributes details