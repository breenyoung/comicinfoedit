#!/bin/bash
# Demo of enhanced verbose summary with unchanged file count

echo "====================================="
echo "Enhanced Summary Demo"
echo "====================================="
echo
echo "This demo shows the improved summary that includes"
echo "a count of files that didn't need modification."
echo

cd /home/claude
mkdir -p summary_demo

# Create comic 1: Will need modification (no Publisher)
mkdir -p summary_demo/comic1
cat > summary_demo/comic1/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic 1</Title>
  <Series>Test Series</Series>
</ComicInfo>
EOF
echo "page" > summary_demo/comic1/page.jpg
cd summary_demo/comic1 && zip -q ../comic1.cbz * && cd ../..

# Create comic 2: Will need modification (no Publisher)
mkdir -p summary_demo/comic2
cat > summary_demo/comic2/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic 2</Title>
  <Series>Test Series</Series>
</ComicInfo>
EOF
echo "page" > summary_demo/comic2/page.jpg
cd summary_demo/comic2 && zip -q ../comic2.cbz * && cd ../..

# Create comic 3: Already has Publisher (no change needed)
mkdir -p summary_demo/comic3
cat > summary_demo/comic3/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic 3</Title>
  <Series>Test Series</Series>
  <Publisher>Marvel Comics</Publisher>
</ComicInfo>
EOF
echo "page" > summary_demo/comic3/page.jpg
cd summary_demo/comic3 && zip -q ../comic3.cbz * && cd ../..

# Create comic 4: Already has Publisher (no change needed)
mkdir -p summary_demo/comic4
cat > summary_demo/comic4/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic 4</Title>
  <Series>Test Series</Series>
  <Publisher>Marvel Comics</Publisher>
</ComicInfo>
EOF
echo "page" > summary_demo/comic4/page.jpg
cd summary_demo/comic4 && zip -q ../comic4.cbz * && cd ../..

# Create comic 5: Wrong publisher (will be modified)
mkdir -p summary_demo/comic5
cat > summary_demo/comic5/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic 5</Title>
  <Series>Test Series</Series>
  <Publisher>DC Comics</Publisher>
</ComicInfo>
EOF
echo "page" > summary_demo/comic5/page.jpg
cd summary_demo/comic5 && zip -q ../comic5.cbz * && cd ../..

echo "Created 5 test comics:"
echo "  - comic1.cbz: No Publisher (will be added)"
echo "  - comic2.cbz: No Publisher (will be added)"
echo "  - comic3.cbz: Already has Publisher=Marvel Comics (no change)"
echo "  - comic4.cbz: Already has Publisher=Marvel Comics (no change)"
echo "  - comic5.cbz: Has Publisher=DC Comics (will be changed)"
echo

echo "====================================="
echo "Running with verbose mode:"
echo "====================================="
echo "Command: --attribute Publisher=\"Marvel Comics\" -v"
echo

./comic_info_modifier.py summary_demo/*.cbz --attribute Publisher="Marvel Comics" -v 2>&1 | grep -A10 "Processing complete:"

echo
echo "====================================="
echo "Verification - Run again to see unchanged count:"
echo "====================================="
echo "All files now have Publisher=Marvel Comics"
echo "Running same command again..."
echo

./comic_info_modifier.py summary_demo/*.cbz --attribute Publisher="Marvel Comics" -v 2>&1 | grep -A10 "Processing complete:"

echo
echo "====================================="
echo "What This Shows:"
echo "====================================="
echo
echo "First run (files need modification):"
echo "  ✓ Successfully modified: 3 files"
echo "  ✓ No changes needed: 2 files (already correct)"
echo "  ✓ Failed: 0 files"
echo
echo "Second run (all files already correct):"
echo "  ✓ Successfully modified: 0 files"
echo "  ✓ No changes needed: 5 files (all already correct)"
echo "  ✓ Failed: 0 files"
echo
echo "Benefits of the enhanced summary:"
echo "  • See exactly how many files were changed"
echo "  • See how many were already correct"
echo "  • Understand if your filters are working properly"
echo "  • Know if you're processing the right files"
echo
echo "Note: The 'No changes needed' count only appears"
echo "      when using -v (verbose) mode."
echo

rm -rf summary_demo

echo "====================================="
echo "Demo complete!"
echo "====================================="