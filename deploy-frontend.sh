#!/bin/bash

echo "📦 Deploying frontend files to nginx..."
echo ""

cd frontend

for file in *.html *.js *.jpg; do
    if [ -f "$file" ]; then
        docker cp "$file" mrit-nginx:/usr/share/nginx/html/
        echo "  ✓ Copied $file"
    fi
done

cd ..

echo ""
echo "✅ Frontend deployment complete!"
echo "Access the application at: http://localhost:8080"
echo ""
