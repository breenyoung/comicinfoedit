# Multiple Attributes Feature

## Overview

You can now modify multiple XML attributes in a single script execution. This is much more efficient than running the script multiple times.

## Basic Syntax

```bash
./comic_info_modifier.py [files/dirs] --attribute KEY1=VALUE1 KEY2=VALUE2 KEY3=VALUE3
```

## Examples

### Update Multiple Fields

```bash
# Set multiple metadata fields at once
./comic_info_modifier.py comic.cbz --attribute \
    Series="The Amazing Spider-Man" \
    Volume=1 \
    Publisher="Marvel Comics" \
    LanguageISO="en"
```

**Before:**
```xml
<ComicInfo>
  <Title>Test Comic</Title>
  <Series>Old Name</Series>
</ComicInfo>
```

**After:**
```xml
<ComicInfo>
  <Title>Test Comic</Title>
  <Series>The Amazing Spider-Man</Series>
  <Volume>1</Volume>
  <Publisher>Marvel Comics</Publisher>
  <LanguageISO>en</LanguageISO>
</ComicInfo>
```

### Mix Updates and Removals

You can update some attributes while removing others:

```bash
./comic_info_modifier.py *.cbz --attribute \
    Publisher="DC Comics" \
    Writer=null \
    Colorist=null
```

This will:
- Update `Publisher` to "DC Comics"
- Remove `Writer` attribute
- Remove `Colorist` attribute

### With Update-Only Mode

The `--update-only` flag applies to ALL attributes:

```bash
./comic_info_modifier.py comics/ --attribute \
    Series="New Series" \
    Publisher="New Publisher" \
    Volume=2 \
    --update-only
```

**Behavior:**
- `Series`: Updated if exists, skipped if missing
- `Publisher`: Updated if exists, skipped if missing  
- `Volume`: Updated if exists, skipped if missing

### Real-World Use Cases

**Clean up and standardize a collection:**
```bash
./comic_info_modifier.py /comics/spider-man --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    Writer=null \
    Penciller=null \
    Inker=null \
    -v
```

**Add complete metadata to new comics:**
```bash
./comic_info_modifier.py new_comic.cbz --attribute \
    Series="Batman" \
    Number=1 \
    Volume=1 \
    Publisher="DC Comics" \
    Year=2024 \
    LanguageISO="en"
```

**Fix typos across multiple fields:**
```bash
./comic_info_modifier.py . --attribute \
    Publisher="Marvel Comics" \
    Series="X-Men" \
    --update-only
```

## Performance Benefits

### Before (multiple runs):
```bash
./comic_info_modifier.py comics/ --attribute Series="Spider-Man"
./comic_info_modifier.py comics/ --attribute Volume=1
./comic_info_modifier.py comics/ --attribute Publisher="Marvel"
./comic_info_modifier.py comics/ --attribute Writer=null
```

**Issues:**
- 4 separate extractions
- 4 separate compressions
- 4 times the I/O
- Much slower for large collections

### After (single run):
```bash
./comic_info_modifier.py comics/ --attribute \
    Series="Spider-Man" \
    Volume=1 \
    Publisher="Marvel" \
    Writer=null
```

**Benefits:**
- Single extraction per file
- Single compression per file
- Much faster execution
- Only one backup needed

## Order of Operations

Attributes are processed in the order you specify:

```bash
--attribute Series="X-Men" Title="Issue 1" Number=1
```

1. Updates/adds `Series`
2. Updates/adds `Title`
3. Updates/adds `Number`

This order doesn't usually matter, but it can be useful for debugging with verbose mode.

## Verbose Output

With `-v` flag, you'll see each attribute operation:

```bash
./comic_info_modifier.py comic.cbz --attribute \
    Series="New Series" \
    Volume=1 \
    Writer=null \
    -v
```

Output:
```
[INFO] Updated Series: 'Old Series' -> 'New Series'
[INFO] Added attribute Volume = '1'
[INFO] Removed attribute: Writer
[INFO] Successfully updated: comic.cbz
```

## Combining Features

You can combine multiple attributes with all other features:

```bash
# Multiple attributes + update-only + verbose + keep backups
./comic_info_modifier.py /comics --attribute \
    Series="New Name" \
    Publisher="New Publisher" \
    Volume=2 \
    --update-only \
    --verbose \
    --keep-backups
```

## Demo

Run the included demo to see it in action:

```bash
./demo_multi_attributes.sh
```

This demonstrates:
1. Adding and updating multiple attributes
2. Mixing updates and removals
3. Using update-only mode with multiple attributes