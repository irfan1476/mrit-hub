#!/bin/bash

echo "🔍 MRIT Hub - Phase 0 Verification"
echo "===================================="
echo ""

# Check Docker
echo "1. Checking Docker..."
if command -v docker &> /dev/null; then
    echo "   ✅ Docker installed: $(docker --version)"
else
    echo "   ❌ Docker not found"
    exit 1
fi

# Check Docker Compose
echo "2. Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    echo "   ✅ Docker Compose installed: $(docker-compose --version)"
else
    echo "   ❌ Docker Compose not found"
    exit 1
fi

# Check .env file
echo "3. Checking .env file..."
if [ -f .env ]; then
    echo "   ✅ .env file exists"
else
    echo "   ❌ .env file not found"
    exit 1
fi

# Check project structure
echo "4. Checking project structure..."
REQUIRED_DIRS=("backend" "database" "nginx" "docs")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir/ exists"
    else
        echo "   ❌ $dir/ not found"
        exit 1
    fi
done

# Check key files
echo "5. Checking key files..."
REQUIRED_FILES=(
    "docker-compose.yml"
    "backend/Dockerfile"
    "backend/package.json"
    "database/init/01-schema.sql"
    "database/init/02-seed.sql"
    "nginx/nginx.conf"
)
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file not found"
        exit 1
    fi
done

# Check if services are running
echo "6. Checking Docker services..."
if docker-compose ps | grep -q "Up"; then
    echo "   ✅ Services are running"
    docker-compose ps
else
    echo "   ⚠️  Services not running (run ./start.sh to start)"
fi

echo ""
echo "===================================="
echo "✅ Phase 0 Verification Complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .env with your credentials"
echo "  2. Run: ./start.sh"
echo "  3. Verify: docker-compose ps"
echo "  4. Ready for Phase 1!"
echo ""
