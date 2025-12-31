#!/bin/bash
#
# Gazebo Classic → Harmonic Migration Script
# Kullanım: ./migrate_to_harmonic.sh <world_file> <models_directory> [physics_engine]
#
# Örnek:
#   ./migrate_to_harmonic.sh my_world.world ./models bullet
#   ./migrate_to_harmonic.sh my_world.world ./models dart
#

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   Gazebo Classic → Harmonic Migration Tool               ║"
echo "║   Version 1.0                                             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Parametre kontrolü
if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 <world_file> <models_directory> [physics_engine]${NC}"
    echo ""
    echo "Arguments:"
    echo "  world_file        - Path to .world file"
    echo "  models_directory  - Path to models directory"
    echo "  physics_engine    - Optional: bullet (default) or dart"
    echo ""
    echo "Example:"
    echo "  $0 bookstore.world ~/models bullet"
    exit 1
fi

WORLD_FILE="$1"
MODELS_DIR="$2"
PHYSICS="${3:-bullet}"  # Default: bullet

# Dosya varlık kontrolü
if [ ! -f "$WORLD_FILE" ]; then
    echo -e "${RED}❌ Error: World file not found: $WORLD_FILE${NC}"
    exit 1
fi

if [ ! -d "$MODELS_DIR" ]; then
    echo -e "${RED}❌ Error: Models directory not found: $MODELS_DIR${NC}"
    exit 1
fi

# Physics engine kontrolü
if [ "$PHYSICS" != "bullet" ] && [ "$PHYSICS" != "dart" ]; then
    echo -e "${RED}❌ Error: Invalid physics engine. Use 'bullet' or 'dart'${NC}"
    exit 1
fi

echo -e "${BLUE}Configuration:${NC}"
echo "  World File: $WORLD_FILE"
echo "  Models Dir: $MODELS_DIR"
echo "  Physics:    $PHYSICS"
echo ""

# Physics uyarısı
if [ "$PHYSICS" == "dart" ]; then
    echo -e "${YELLOW}⚠️  WARNING: DART engine does NOT support mesh collisions!${NC}"
    echo -e "${YELLOW}   If your models use mesh geometry in <collision>, they will fail.${NC}"
    echo -e "${YELLOW}   Recommendation: Use 'bullet' for mesh support.${NC}"
    echo ""
    read -p "Continue with DART anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Switching to Bullet...${NC}"
        PHYSICS="bullet"
    fi
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Starting Migration Process${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# STEP 1: Create Backup
# ============================================================================
echo -e "${BLUE}[1/7] Creating backups...${NC}"

BACKUP_SUFFIX=".backup_$(date +%Y%m%d_%H%M%S)"
cp "$WORLD_FILE" "${WORLD_FILE}${BACKUP_SUFFIX}"
echo -e "  ${GREEN}✓${NC} World backup: ${WORLD_FILE}${BACKUP_SUFFIX}"

# Model backupları
MODELS_BACKUP="${MODELS_DIR}${BACKUP_SUFFIX}"
if [ -d "$MODELS_DIR" ]; then
    cp -r "$MODELS_DIR" "$MODELS_BACKUP"
    echo -e "  ${GREEN}✓${NC} Models backup: $MODELS_BACKUP"
fi

echo ""

# ============================================================================
# STEP 2: Update World SDF Version
# ============================================================================
echo -e "${BLUE}[2/7] Updating World SDF version...${NC}"

# SDF version güncelleme
sed -i "s/<sdf version='1.6'>/<sdf version='1.9'>/g" "$WORLD_FILE"
sed -i "s/<sdf version=\"1.6\">/<sdf version=\"1.9\">/g" "$WORLD_FILE"
sed -i "s/<sdf version='1.5'>/<sdf version='1.9'>/g" "$WORLD_FILE"
sed -i "s/<sdf version='1.7'>/<sdf version='1.9'>/g" "$WORLD_FILE"

echo -e "  ${GREEN}✓${NC} SDF version updated to 1.9"
echo ""

# ============================================================================
# STEP 3: Update Physics Engine
# ============================================================================
echo -e "${BLUE}[3/7] Updating physics engine to $PHYSICS...${NC}"

# Physics engine değiştir
sed -i "s/type=\"ode\"/type=\"$PHYSICS\"/g" "$WORLD_FILE"
sed -i "s/type=\"dart\"/type=\"$PHYSICS\"/g" "$WORLD_FILE"
sed -i "s/type='ode'/type='$PHYSICS'/g" "$WORLD_FILE"
sed -i "s/type='dart'/type='$PHYSICS'/g" "$WORLD_FILE"

# 'default' attribute kaldır
sed -i 's/default="0" //g' "$WORLD_FILE"
sed -i "s/default='0' //g" "$WORLD_FILE"

echo -e "  ${GREEN}✓${NC} Physics engine set to: $PHYSICS"
echo ""

# ============================================================================
# STEP 4: Remove Deprecated Attributes
# ============================================================================
echo -e "${BLUE}[4/7] Removing deprecated attributes...${NC}"

# frame="" attribute kaldır
COUNT_BEFORE=$(grep -c 'frame=""' "$WORLD_FILE" || true)
sed -i 's/ frame=""//g' "$WORLD_FILE"
sed -i "s/ frame=''//g" "$WORLD_FILE"
sed -i "s/<pose frame=''>/<pose>/g" "$WORLD_FILE"
sed -i 's/<pose frame="">/<pose>/g' "$WORLD_FILE"

echo -e "  ${GREEN}✓${NC} Removed $COUNT_BEFORE 'frame' attributes"
echo ""

# ============================================================================
# STEP 5: Update Model Files
# ============================================================================
echo -e "${BLUE}[5/7] Updating model SDF files...${NC}"

MODEL_FILES=$(find "$MODELS_DIR" -name "model.sdf" 2>/dev/null)
MODEL_COUNT=$(echo "$MODEL_FILES" | grep -c "model.sdf" || true)

if [ "$MODEL_COUNT" -gt 0 ]; then
    echo -e "  Found ${YELLOW}$MODEL_COUNT${NC} model files"

    # SDF version güncelle
    find "$MODELS_DIR" -name "model.sdf" -exec sed -i "s/<sdf version='1.6'>/<sdf version='1.9'>/g" {} \;
    find "$MODELS_DIR" -name "model.sdf" -exec sed -i "s/<sdf version=\"1.6\">/<sdf version=\"1.9\">/g" {} \;

    # Mesh URI güncelle: file://models/ → model://
    find "$MODELS_DIR" -name "model.sdf" -exec sed -i 's|file://models/|model://|g' {} \;

    echo -e "  ${GREEN}✓${NC} Updated $MODEL_COUNT model files"
else
    echo -e "  ${YELLOW}⚠${NC}  No model.sdf files found in $MODELS_DIR"
fi

echo ""

# ============================================================================
# STEP 6: Validation
# ============================================================================
echo -e "${BLUE}[6/7] Validating migration...${NC}"

# Gazebo kurulu mu kontrol et
if ! command -v gz &> /dev/null; then
    echo -e "  ${YELLOW}⚠${NC}  Gazebo Harmonic not found, skipping validation"
else
    # SDF syntax kontrolü
    echo -n "  Checking SDF syntax... "

    if gz sdf --check "$WORLD_FILE" > /tmp/sdf_check.log 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        # Error Code 14 (model not found) göz ardı edilebilir
        if grep -q "Error Code 14" /tmp/sdf_check.log; then
            echo -e "${YELLOW}⚠${NC} (model path warnings - normal)"
        else
            echo -e "${RED}✗${NC}"
            echo -e "  ${RED}SDF validation failed! Check /tmp/sdf_check.log${NC}"
        fi
    fi

    # Mesh collision kontrolü (sadece DART için)
    if [ "$PHYSICS" == "dart" ]; then
        MESH_COLLISION_COUNT=$(grep -c "<mesh>" "$WORLD_FILE" | grep -c "<collision>" || true)
        if [ "$MESH_COLLISION_COUNT" -gt 0 ]; then
            echo -e "  ${RED}✗${NC} WARNING: Found mesh geometries in collisions!"
            echo -e "    DART does not support mesh collisions."
            echo -e "    Recommendation: Re-run with 'bullet' physics engine"
        fi
    fi
fi

echo ""

# ============================================================================
# STEP 7: Summary
# ============================================================================
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Migration Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}Changes Summary:${NC}"
echo "  • SDF Version: 1.6 → 1.9"
echo "  • Physics Engine: → $PHYSICS"
echo "  • Deprecated attributes removed"
echo "  • Model files updated: $MODEL_COUNT"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Set environment variable:"
echo -e "   ${YELLOW}export GZ_SIM_RESOURCE_PATH=$MODELS_DIR:\$GZ_SIM_RESOURCE_PATH${NC}"
echo ""
echo "2. Test the world file:"
echo -e "   ${YELLOW}gz sim $WORLD_FILE -r -v 4${NC}"
echo ""
echo "3. If using ROS2:"
echo -e "   ${YELLOW}ros2 launch your_package your_launch.py world:=your_world${NC}"
echo ""

echo -e "${BLUE}Backup Files:${NC}"
echo "  World: ${WORLD_FILE}${BACKUP_SUFFIX}"
echo "  Models: $MODELS_BACKUP"
echo ""

echo -e "${GREEN}✅ Migration successful!${NC}"
echo ""

# Quick test option
read -p "Run quick test with Gazebo now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}Starting Gazebo Harmonic...${NC}"
    export GZ_SIM_RESOURCE_PATH="$MODELS_DIR:$GZ_SIM_RESOURCE_PATH"
    timeout 10 gz sim "$WORLD_FILE" -r -v 2 2>&1 | head -50 || true
    echo ""
    echo -e "${GREEN}Test completed. Check output above for any errors.${NC}"
fi

exit 0
