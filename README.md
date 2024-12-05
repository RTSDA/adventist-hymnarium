# Adventist Hymnarium

An iOS application for accessing Seventh-day Adventist hymns and sheet music.

## Project Structure

This repository contains:

- `src/` - Main iOS application source code
  - `Models/` - Data models for hymns, readings, and app configuration
  - `Services/` - Core services for hymn and reading management
  - `Views/` - SwiftUI views for the user interface
  - `Resources/` - Application resources and assets
- `adventist-hymnarium-tests/` - Unit tests
- `adventist-hymnarium-uitests/` - UI tests

## Required Resources (Not in Repository)

The application requires additional resources that are not tracked in the repository. These must be obtained separately:

### Cloud Storage
The app requires cloud storage for hymn audio and sheet music files. You can use any cloud storage provider (e.g., Cloudflare R2, AWS S3, etc.). Files should be organized as follows:
- Audio files by hymnal year (e.g. "1985/001.mp3")
- Sheet music PDFs following the same structure (e.g. "1985/001.pdf")

### Firebase Configuration
The app uses Firebase for analytics and remote configuration. You'll need to:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an iOS app to your Firebase project
3. Download the `GoogleService-Info.plist` configuration file
4. Place it in the project root directory
   - Note: A template file `GoogleService-Info.template.plist` is provided as reference

## Getting Started

1. Clone this repository
2. Contact the project maintainers to obtain required resources
3. Set up Firebase:
   - Create a Firebase project
   - Add your iOS app to the project
   - Download and add `GoogleService-Info.plist`
4. Open `adventist-hymnarium.xcodeproj` in Xcode
5. Build and run the project

## Recent Updates

### September 2023
- Improved service layer efficiency
  - Optimized HymnalService for better performance
  - Enhanced ResponsiveReadingService with improved data handling
- Enhanced UI components and user experience
  - Refined favorites and history functionality
  - Improved search capabilities
  - Updated thematic index features
- Refactored model structures for better data management
- General performance improvements and bug fixes

## Development

This is an iOS application built using Xcode. Make sure you have:
- Xcode installed
- Firebase configuration in place
- Cloud storage configured with audio and sheet music files

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
