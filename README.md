# Adventist Hymnarium

An iOS application for accessing Seventh-day Adventist hymns and sheet music.

## Project Structure

- `src/` - Main iOS application source code
- `scripts/` - Utility scripts for data processing and maintenance
- `data/` - Hymnal data files in JSON format
- `1941-sheet-music/` - Sheet music files from the 1941 hymnal
- `adventist-hymnarium-tests/` - Unit tests
- `adventist-hymnarium-uitests/` - UI tests

## Development

This is an iOS application built using Xcode. To get started:

1. Open `adventist-hymnarium.xcodeproj` in Xcode
2. Build and run the project

## Scripts

The `scripts/` directory contains various utility scripts for:
- Downloading and processing hymn data
- Managing sheet music files
- Fixing file names and permissions
- Analyzing hymnal data

## Data

The `data/` directory contains:
- `1941_hymnal.json` - Data for the 1941 hymnal
- `hymn_sheet_data.json` - Sheet music metadata
- `responsive_readings.json` - Responsive readings
