#!/bin/bash

# Remove all .pyc files and __pycache__ directories
find "/Users/benjaminslingo/SDA Hymnal" -type f -name "*.pyc" -delete
find "/Users/benjaminslingo/SDA Hymnal" -type d -name "__pycache__" -exec rm -rf {} +

# Remove virtual environment directories from the Xcode project directory
rm -rf "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985/venv"
rm -rf "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1941/venv"

# Clean Xcode derived data
rm -rf "/Users/benjaminslingo/Library/Developer/Xcode/DerivedData/SDA_Hymnal-*"
