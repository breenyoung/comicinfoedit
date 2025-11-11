#!/bin/bash
# Demo of --clean-archive feature

echo "====================================="
echo "Clean Archive Feature Demo"
echo "====================================="

cd /home/claude
mkdir -p clean_test

# Create a comic with extra junk files
mkdir -p clean_test/messy_comic
cat > clean_test/messy_comic/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Test Comic</Title>
  <Series>Test Series</Series>
  <Number>1</Number>
</ComicInfo>
EOF

# Add image files (should be kept)
echo "Image data" > clean_test/messy_comic/page01.jpg
echo "Image data" > clean_test/messy_comic/page02.jpg
echo "Image data" > clean_test/messy_comic/page03.png

# Add junk files (should be removed)
echo "SFV checksum data" > clean_test/messy_comic/comic.sfv
echo "NFO info data" > clean_test/messy_comic/info.nfo
echo "Some readme text" > clean_test/messy_comic/README.txt
echo "URL shortcut" > clean_test/messy_comic/website.url
echo "MD5 checksum" > clean_test/messy_comic/checksums.md5

# Create the messy archive
cd clean_test/messy_comic && zip -q ../messy_comic.cbz * && cd ../..

echo
echo "BEFORE: Contents of messy archive"
echo "========================================"
unzip -l clean_test/messy_comic.cbz
echo

echo "Files in archive:"
unzip -l clean_test/messy_comic.cbz | grep -E '\.(jpg|png|xml|sfv|nfo|txt|url|md5)$' | awk '{print "  - " $4}'
echo

echo "Notice the non-comic files:"
echo "  - comic.sfv"
echo "  - info.nfo"
echo "  - README.txt"
echo "  - website.url"
echo "  - checksums.md5"
echo

echo "====================================="
echo "TEST 1: Normal mode (keeps all files)"
echo "====================================="
echo

cp clean_test/messy_comic.cbz clean_test/test_normal.cbz

./comic_info_modifier.py clean_test/test_normal.cbz \
    --attribute Publisher="Test Publisher" \
    -v

echo
echo "AFTER (Normal mode): Files still present"
unzip -l clean_test/test_normal.cbz | tail -n +4 | head -n -2 | awk '{print "  - " $4}'
echo

echo "====================================="
echo "TEST 2: Clean mode (removes junk)"
echo "====================================="
echo

cp clean_test/messy_comic.cbz clean_test/test_clean.cbz

./comic_info_modifier.py clean_test/test_clean.cbz \
    --attribute Publisher="Test Publisher" \
    --clean-archive \
    -v

echo
echo "AFTER (Clean mode): Only comic files remain"
unzip -l clean_test/test_clean.cbz | tail -n +4 | head -n -2 | awk '{print "  - " $4}'
echo

echo "====================================="
echo "Comparison:"
echo "====================================="
echo

echo "Normal mode - $(unzip -l clean_test/test_normal.cbz | tail -n 1 | awk '{print $2}') files:"
unzip -l clean_test/test_normal.cbz | grep -v "Archive:" | grep -v "Length" | grep -v "^---" | tail -n +2 | head -n -1 | awk '{print "  " $4}'

echo
echo "Clean mode - $(unzip -l clean_test/test_clean.cbz | tail -n 1 | awk '{print $2}') files:"
unzip -l clean_test/test_clean.cbz | grep -v "Archive:" | grep -v "Length" | grep -v "^---" | tail -n +2 | head -n -1 | awk '{print "  " $4}'

echo
echo "====================================="
echo "Summary:"
echo "====================================="
echo "✓ ComicInfo.xml - KEPT (metadata)"
echo "✓ page01.jpg - KEPT (image)"
echo "✓ page02.jpg - KEPT (image)"
echo "✓ page03.png - KEPT (image)"
echo "✗ comic.sfv - REMOVED (verification file)"
echo "✗ info.nfo - REMOVED (info file)"
echo "✗ README.txt - REMOVED (text file)"
echo "✗ website.url - REMOVED (URL shortcut)"
echo "✗ checksums.md5 - REMOVED (checksum file)"
echo

rm -rf clean_test

echo "====================================="
echo "Clean archive test complete!"
echo "====================================="