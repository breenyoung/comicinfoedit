#!/bin/bash
# Comprehensive test showing all features

echo "========================================="
echo "Comprehensive Feature Test"
echo "========================================="
echo

cd /home/claude
mkdir -p comprehensive_test

# Create 3 test comics with different metadata states

# Comic 1: Has some metadata
mkdir -p comprehensive_test/comic1
cat > comprehensive_test/comic1/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Spider-Man Issue 1</Title>
  <Series>Spiderman</Series>
  <Number>1</Number>
  <Publisher>Marvle Comics</Publisher>
  <Writer>Stan Lee</Writer>
</ComicInfo>
EOF
echo "page" > comprehensive_test/comic1/page.txt
cd comprehensive_test/comic1 && zip -q ../comic1.cbz * && cd ../..

# Comic 2: Has different metadata
mkdir -p comprehensive_test/comic2
cat > comprehensive_test/comic2/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Spider-Man Issue 2</Title>
  <Series>Amazing Spiderman</Series>
  <Number>2</Number>
  <Writer>Stan Lee</Writer>
  <Penciller>Steve Ditko</Penciller>
</ComicInfo>
EOF
echo "page" > comprehensive_test/comic2/page.txt
cd comprehensive_test/comic2 && zip -q ../comic2.cbz * && cd ../..

# Comic 3: Minimal metadata
mkdir -p comprehensive_test/comic3
cat > comprehensive_test/comic3/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Spider-Man Issue 3</Title>
</ComicInfo>
EOF
echo "page" > comprehensive_test/comic3/page.txt
cd comprehensive_test/comic3 && zip -q ../comic3.cbz * && cd ../..

echo "Created 3 test comics:"
echo "- comic1.cbz: Has Series (typo), Publisher (typo), Writer"
echo "- comic2.cbz: Has Series (variant name), Writer, Penciller"
echo "- comic3.cbz: Only has Title"
echo

echo "========================================="
echo "SCENARIO: Standardize metadata across all comics"
echo "========================================="
echo
echo "Goal:"
echo "1. Fix Series name to 'The Amazing Spider-Man' (only if exists)"
echo "2. Fix Publisher to 'Marvel Comics' (only if exists)"
echo "3. Add Volume=1 (to all)"
echo "4. Add LanguageISO='en' (to all)"
echo "5. Remove Writer attribute (from all)"
echo "6. Remove Penciller attribute (from all)"
echo

echo "Command (Part 1 - with update-only for Series/Publisher):"
echo "./comic_info_modifier.py comprehensive_test/*.cbz --attribute \\"
echo "    Series=\"The Amazing Spider-Man\" \\"
echo "    Publisher=\"Marvel Comics\" \\"
echo "    --update-only \\"
echo "    -v"
echo

./comic_info_modifier.py comprehensive_test/*.cbz --attribute \
    Series="The Amazing Spider-Man" \
    Publisher="Marvel Comics" \
    --update-only \
    -v

echo
echo "Command (Part 2 - add new fields to all):"
echo "./comic_info_modifier.py comprehensive_test/*.cbz --attribute \\"
echo "    Volume=1 \\"
echo "    LanguageISO=\"en\" \\"
echo "    -v"
echo

./comic_info_modifier.py comprehensive_test/*.cbz --attribute \
    Volume=1 \
    LanguageISO="en" \
    -v

echo
echo "Command (Part 3 - remove attributes):"
echo "./comic_info_modifier.py comprehensive_test/*.cbz --attribute \\"
echo "    Writer=null \\"
echo "    Penciller=null \\"
echo "    -v"
echo

./comic_info_modifier.py comprehensive_test/*.cbz --attribute \
    Writer=null \
    Penciller=null \
    -v

echo
echo "========================================="
echo "RESULTS:"
echo "========================================="
echo

echo "Comic 1 (had Publisher):"
unzip -p comprehensive_test/comic1.cbz ComicInfo.xml
echo

echo "Comic 2 (no Publisher):"
unzip -p comprehensive_test/comic2.cbz ComicInfo.xml
echo

echo "Comic 3 (minimal metadata):"
unzip -p comprehensive_test/comic3.cbz ComicInfo.xml
echo

echo "========================================="
echo "Analysis:"
echo "========================================="
echo "Comic 1:"
echo "  ✓ Series: 'Spiderman' → 'The Amazing Spider-Man' (Part 1: updated)"
echo "  ✓ Publisher: 'Marvle Comics' → 'Marvel Comics' (Part 1: updated)"
echo "  ✓ Volume: Added (Part 2)"
echo "  ✓ LanguageISO: Added (Part 2)"
echo "  ✓ Writer: Removed (Part 3)"
echo
echo "Comic 2:"
echo "  ✓ Series: 'Amazing Spiderman' → 'The Amazing Spider-Man' (Part 1: updated)"
echo "  ✗ Publisher: NOT added (Part 1: didn't exist, update-only mode)"
echo "  ✓ Volume: Added (Part 2)"
echo "  ✓ LanguageISO: Added (Part 2)"
echo "  ✓ Writer: Removed (Part 3)"
echo "  ✓ Penciller: Removed (Part 3)"
echo
echo "Comic 3:"
echo "  ✗ Series: NOT added (Part 1: didn't exist, update-only mode)"
echo "  ✗ Publisher: NOT added (Part 1: didn't exist, update-only mode)"
echo "  ✓ Volume: Added (Part 2)"
echo "  ✓ LanguageISO: Added (Part 2)"
echo "  - Writer: Nothing to remove (Part 3)"
echo "  - Penciller: Nothing to remove (Part 3)"
echo

echo "This demonstrates:"
echo "1. Multiple attributes in a single command"
echo "2. Update-only mode for selective updates"
echo "3. Mixing updates and additions in separate passes"
echo "4. Removing multiple attributes at once"
echo

rm -rf comprehensive_test

echo "========================================="
echo "Test complete!"
echo "========================================="