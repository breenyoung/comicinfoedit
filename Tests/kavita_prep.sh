#!/bin/bash
# Real-world example: Preparing a comic collection for Kavita server

echo "========================================="
echo "Real-World Example: Kavita Preparation"
echo "========================================="
echo
echo "Scenario: You've downloaded a Spider-Man collection with:"
echo "  - Inconsistent series names"
echo "  - Missing metadata"
echo "  - Junk files (SFV, NFO, etc.) causing Kavita issues"
echo
echo "Goal: Clean and standardize for Kavita server"
echo

cd /home/claude
mkdir -p kavita_example

# Create example comics with various issues
echo "Creating sample comics..."

# Comic 1: Has junk files and wrong series name
mkdir -p kavita_example/comic1
cat > kavita_example/comic1/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Issue 1</Title>
  <Series>Spiderman</Series>
  <Number>1</Number>
</ComicInfo>
EOF
echo "image" > kavita_example/comic1/page01.jpg
echo "image" > kavita_example/comic1/page02.jpg
echo "SFV data" > kavita_example/comic1/comic.sfv
echo "NFO data" > kavita_example/comic1/release.nfo
cd kavita_example/comic1 && zip -q ../spider01.cbz * && cd ../..

# Comic 2: Missing publisher, has junk
mkdir -p kavita_example/comic2
cat > kavita_example/comic2/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Issue 2</Title>
  <Series>Amazing Spiderman</Series>
  <Number>2</Number>
  <Writer>Stan Lee</Writer>
</ComicInfo>
EOF
echo "image" > kavita_example/comic2/page01.jpg
echo "image" > kavita_example/comic2/page02.jpg
echo "README" > kavita_example/comic2/README.txt
cd kavita_example/comic2 && zip -q ../spider02.cbz * && cd ../..

# Comic 3: Minimal metadata
mkdir -p kavita_example/comic3
cat > kavita_example/comic3/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Issue 3</Title>
</ComicInfo>
EOF
echo "image" > kavita_example/comic3/page01.jpg
cd kavita_example/comic3 && zip -q ../spider03.cbz * && cd ../..

echo "Created 3 sample comics with various issues"
echo

echo "========================================="
echo "BEFORE: Checking current state"
echo "========================================="
echo

echo "Comic 1 contents:"
unzip -l kavita_example/spider01.cbz | grep -E '\.(jpg|xml|sfv|nfo)$' | awk '{print "  " $4}'
echo "Metadata:"
unzip -p kavita_example/spider01.cbz ComicInfo.xml | grep -E '<(Series|Publisher)>'
echo

echo "Comic 2 contents:"
unzip -l kavita_example/spider02.cbz | grep -E '\.(jpg|xml|txt)$' | awk '{print "  " $4}'
echo "Metadata:"
unzip -p kavita_example/spider02.cbz ComicInfo.xml | grep -E '<(Series|Publisher|Writer)>'
echo

echo "Comic 3 contents:"
unzip -l kavita_example/spider03.cbz | grep -E '\.(jpg|xml)$' | awk '{print "  " $4}'
echo "Metadata:"
unzip -p kavita_example/spider03.cbz ComicInfo.xml | grep -E '<(Series|Publisher|Title)>'
echo

echo "========================================="
echo "SOLUTION: Two-pass approach"
echo "========================================="
echo
echo "Pass 1: Fix existing Series names and remove Writer (update-only)"
echo "./comic_info_modifier.py kavita_example/*.cbz --attribute \\"
echo "    Series=\"The Amazing Spider-Man\" \\"
echo "    Publisher=\"Marvel Comics\" \\"
echo "    Writer=null \\"
echo "    --update-only \\"
echo "    --clean-archive \\"
echo "    -v"
echo

./comic_info_modifier.py kavita_example/*.cbz --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    Writer=null \
    --update-only \
    --clean-archive \
    -v

echo
echo "Pass 2: Add standard fields to all comics"
echo "./comic_info_modifier.py kavita_example/*.cbz --attribute \\"
echo "    LanguageISO=\"en\" \\"
echo "    Volume=1 \\"
echo "    -v"
echo

./comic_info_modifier.py kavita_example/*.cbz --attribute \
    LanguageISO="en" \
    Volume=1 \
    -v

echo
echo "========================================="
echo "AFTER: Verifying results"
echo "========================================="
echo

echo "Comic 1 contents (cleaned):"
unzip -l kavita_example/spider01.cbz | grep -E '\.(jpg|xml)$' | awk '{print "  " $4}'
echo "Metadata (standardized):"
unzip -p kavita_example/spider01.cbz ComicInfo.xml | grep -E '<(Series|Publisher|Volume|LanguageISO)>'
echo

echo "Comic 2 contents (cleaned):"
unzip -l kavita_example/spider02.cbz | grep -E '\.(jpg|xml)$' | awk '{print "  " $4}'
echo "Metadata (standardized, Writer removed):"
unzip -p kavita_example/spider02.cbz ComicInfo.xml | grep -E '<(Series|Publisher|Volume|LanguageISO|Writer)>' || echo "  (Writer successfully removed)"
echo

echo "Comic 3 contents (cleaned):"
unzip -l kavita_example/spider03.cbz | grep -E '\.(jpg|xml)$' | awk '{print "  " $4}'
echo "Metadata (new fields added):"
unzip -p kavita_example/spider03.cbz ComicInfo.xml | grep -E '<(Series|Publisher|Volume|LanguageISO|Title)>'
echo

echo "========================================="
echo "Summary of Changes:"
echo "========================================="
echo
echo "Pass 1 (update-only + clean-archive):"
echo "  - Fixed existing Series names"
echo "  - Removed Writer attribute where present"
echo "  - Cleaned all junk files (SFV, NFO, TXT)"
echo
echo "Pass 2 (add fields):"
echo "  - Added LanguageISO=en to all comics"
echo "  - Added Volume=1 to all comics"
echo
echo "Comic 1 (spider01.cbz):"
echo "  ✓ Series: 'Spiderman' → 'The Amazing Spider-Man'"
echo "  ✗ Publisher: Not added (didn't exist, update-only in pass 1)"
echo "  ✓ Volume: Added = 1 (pass 2)"
echo "  ✓ LanguageISO: Added = en (pass 2)"
echo "  ✓ Removed: comic.sfv, release.nfo (pass 1)"
echo
echo "Comic 2 (spider02.cbz):"
echo "  ✓ Series: 'Amazing Spiderman' → 'The Amazing Spider-Man'"
echo "  ✗ Publisher: Not added (didn't exist, update-only in pass 1)"
echo "  ✓ Volume: Added = 1 (pass 2)"
echo "  ✓ LanguageISO: Added = en (pass 2)"
echo "  ✓ Writer: Removed (pass 1)"
echo "  ✓ Removed: README.txt (pass 1)"
echo
echo "Comic 3 (spider03.cbz):"
echo "  ✗ Series: Not added (didn't exist, update-only in pass 1)"
echo "  ✗ Publisher: Not added (didn't exist, update-only in pass 1)"
echo "  ✓ Volume: Added = 1 (pass 2)"
echo "  ✓ LanguageISO: Added = en (pass 2)"
echo
echo "Result: Collection ready for Kavita server!"
echo "  ✓ No junk files to cause parsing issues"
echo "  ✓ Consistent series names where they existed"
echo "  ✓ Standard metadata fields added to all"
echo

rm -rf kavita_example

echo "========================================="
echo "Example complete!"
echo "========================================="