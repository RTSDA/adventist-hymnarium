# Adventist Hymnarium

An iOS application for accessing Seventh-day Adventist hymns and sheet music.

## Project Structure

This repository contains only the essential project files:

- `src/` - Main iOS application source code
- `adventist-hymnarium-tests/` - Unit tests
- `adventist-hymnarium-uitests/` - UI tests

## Required Resources (Not in Repository)

The application requires additional resources that are not tracked in the repository. These must be obtained separately:

### Data Files
Place these JSON files in `src/Resources/Assets/`:
- `new-hymnal-en.json` - Data for the 1985 hymnal
- `new-hymnal-thematic-list-en.json` - Thematic index for 1985 hymnal
- `old-hymnal-en.json` - Data for the 1941 hymnal
- `old-hymnal-thematic-list-en.json` - Thematic index for 1941 hymnal
- `responsive_readings.json` - Responsive readings

### Media Files
Create a `media` directory with the following structure:
```
media/
├── audio/
│   └── 1985/          # Audio files for 1985 hymnal (.mp3)
└── sheet-music/
    ├── 1941/          # Sheet music from 1941 hymnal (.pdf)
    └── 1985/          # Sheet music from 1985 hymnal (.pdf)
```

### Utility Scripts
The `scripts` directory (available separately) contains utilities for:
- Downloading and processing hymn data
- Managing sheet music files
- Fixing file names and permissions

## Getting Started

1. Clone this repository
2. Contact the project maintainers to obtain:
   - Required JSON data files
   - Media files (audio and sheet music)
   - Utility scripts (if needed for development)
3. Place the files in their respective directories as described above
4. Open `adventist-hymnarium.xcodeproj` in Xcode
5. Build and run the project

## Development

This is an iOS application built using Xcode. Make sure you have:
- Xcode installed
- All required data files in place
- Media files available if testing audio or sheet music functionality

## Contact

For access to data files, media resources, or scripts, please contact the project maintainers.
