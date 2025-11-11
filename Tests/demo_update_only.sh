#!/bin/bash
# Simple demo of --update-only flag

echo "====================================="
echo "Update-Only Feature Demo"
echo "====================================="

cd /home/claude

# Create two test comics
mkdir -p demo_test

# Comic 1: HAS Publisher attribute
mkdir -p demo_test/with_pub
cat > demo_test/with_pub/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic A</Title>
  <Publisher>Old Publisher</Publisher>
</ComicInfo>
EOF
echo "page" > demo_test/with_pub/page.txt
cd demo_test/with_pub && zip -q ../comic_has_publisher.cbz * && cd ../..

# Comic 2: MISSING Publisher attribute
mkdir -p demo_test/without_pub
cat > demo_test/without_pub/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic B</Title>
</ComicInfo>
EOF
echo "page" > demo_test/without_pub/page.txt
cd demo_test/without_pub && zip -q ../comic_missing_publisher.cbz * && cd ../..

echo
echo "BEFORE: Comic with Publisher attribute"
unzip -p demo_test/comic_has_publisher.cbz ComicInfo.xml

echo
echo "BEFORE: Comic without Publisher attribute"
unzip -p demo_test/comic_missing_publisher.cbz ComicInfo.xml

echo
echo "================================================"
echo "Running with --update-only flag:"
echo "./comic_info_modifier.py demo_test/*.cbz --attribute Publisher=\"New Publisher\" --update-only -v"
echo "================================================"
echo

./comic_info_modifier.py demo_test/*.cbz --attribute Publisher="New Publisher" --update-only -v

echo
echo "================================================"
echo "RESULTS:"
echo "================================================"

echo
echo "Comic A (had Publisher - should be UPDATED):"
unzip -p demo_test/comic_has_publisher.cbz ComicInfo.xml

echo
echo "Comic B (no Publisher - should be UNCHANGED):"
unzip -p demo_test/comic_missing_publisher.cbz ComicInfo.xml

echo
echo "================================================"
echo "As you can see:"
echo "- Comic A: Publisher updated to 'New Publisher'"
echo "- Comic B: Still has NO Publisher (was skipped)"
echo "================================================"

rm -rf demo_test