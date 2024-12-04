# Adventist Hymnarium

An iOS application for accessing Seventh-day Adventist hymns and sheet music.

## Project Structure

This repository contains only the essential project files:

- `src/` - Main iOS application source code
- `adventist-hymnarium-tests/` - Unit tests
- `adventist-hymnarium-uitests/` - UI tests

## Required Resources (Not in Repository)

The application requires additional resources that are not tracked in the repository. These must be obtained separately:

### Firebase Configuration
The app uses Firebase for analytics, remote configuration, and storage. You'll need to:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an iOS app to your Firebase project
3. Download the `GoogleService-Info.plist` configuration file
4. Place it in the project root directory
   - Note: A template file `GoogleService-Info.template.plist` is provided as reference
5. Set up Firebase Storage for hymn audio and sheet music files
   - Audio files should be organized by hymnal year (e.g. "1985/001.mp3")
   - Sheet music PDFs should follow the same structure (e.g. "1985/001.pdf")

### Data Files
Place these JSON files in `src/Resources/Assets/`:
- `new-hymnal-en.json` - Data for the 1985 hymnal
- `new-hymnal-thematic-list-en.json` - Thematic index for 1985 hymnal
- `old-hymnal-en.json` - Data for the 1941 hymnal
- `old-hymnal-thematic-list-en.json` - Thematic index for 1941 hymnal
- `responsive_readings.json` - Responsive readings

### Utility Scripts
The `scripts` directory (available separately) contains utilities for:
- Downloading and processing hymn data
- Managing sheet music files
- Fixing file names and permissions

## Getting Started

1. Clone this repository
2. Contact the project maintainers to obtain:
   - Required JSON data files
   - Utility scripts (if needed for development)
3. Place the data files in their respective directories as described above
4. Set up Firebase:
   - Create a Firebase project
   - Add your iOS app to the project
   - Download and add `GoogleService-Info.plist`
   - Configure Firebase Storage with proper media files
5. Open `adventist-hymnarium.xcodeproj` in Xcode
6. Build and run the project

## Development

This is an iOS application built using Xcode. Make sure you have:
- Xcode installed
- Firebase configuration in place
- All required data files in place
- Firebase Storage configured with audio and sheet music files

## License

This project uses a dual licensing approach:

### Application Source Code
The application source code is licensed under the GNU General Public License v3 (GPLv3). 
See the [LICENSE](LICENSE) file for details.

### Hymnal Content
The hymns, lyrics, music, and sheet music content are copyrighted by the General Conference 
Corporation of Seventh-day Adventists®. All rights reserved. These materials are not covered 
by the GPL license and require proper authorization for use.

## Contact

For access to data files or development resources, please contact the project maintainers.

For permissions regarding hymnal content usage, contact:
General Conference Corporation of Seventh-day Adventists
12501 Old Columbia Pike
Silver Spring, Maryland 20904
