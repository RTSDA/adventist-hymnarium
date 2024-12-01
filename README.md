# Adventist Hymnarium

An iOS application for accessing Seventh-day Adventist hymns and sheet music.

## Project Structure

- `src/` - Main iOS application source code
- `scripts/` - Utility scripts for data processing and maintenance
- `data/` - Hymnal data files in JSON format
- `media/` - Media assets (not tracked in git)
  - `audio/` - Hymn audio files
  - `sheet-music/` - Sheet music files
    - `1941/` - 1941 hymnal sheet music
    - `1985/` - 1985 hymnal sheet music
- `adventist-hymnarium-tests/` - Unit tests
- `adventist-hymnarium-uitests/` - UI tests

## Development

This is an iOS application built using Xcode. To get started:

1. Open `adventist-hymnarium.xcodeproj` in Xcode
2. Build and run the project

### Media Files

The application requires media files (audio and sheet music) that are not tracked in git due to their size. These files should be placed in the `media/` directory with the following structure:

```
media/
├── audio/
│   └── 1985/          # Audio files for 1985 hymnal
└── sheet-music/
    ├── 1941/          # Sheet music from 1941 hymnal
    └── 1985/          # Sheet music from 1985 hymnal
```

Contact the project maintainers to obtain the necessary media files.

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
