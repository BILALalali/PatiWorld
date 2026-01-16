#!/bin/bash

# Script to start Flask API Server
# Usage: ./START_SERVER.sh

echo "🚀 Starting Animal Similarity API Server..."
echo ""

# Check if python3 exists
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 not found!"
    echo "   Please install Python 3 first"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "api_server.py" ]; then
    echo "❌ Error: api_server.py not found!"
    echo "   Please run this script from model_project directory"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    # Try Python 3.12 first (best for TensorFlow), fallback to python3
    if command -v python3.12 &> /dev/null; then
        echo "   Using Python 3.12 (recommended for TensorFlow)"
        python3.12 -m venv venv
    else
        echo "   Using Python 3 (may have compatibility issues)"
        python3 -m venv venv
    fi
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Check if requirements are installed
echo "📦 Checking dependencies..."
if ! python -c "import flask" 2>/dev/null; then
    echo "⚠️  Dependencies not found. Installing requirements..."
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "✅ Dependencies installed"
fi

# Start the server
echo ""
echo "✅ Starting Flask API Server..."
echo "   Server will run on http://localhost:5000"
echo "   Press Ctrl+C to stop"
echo ""
python api_server.py
