#!/bin/bash

# Touch the file to update its timestamp
touch "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985/en_468.mp3"

# Remove any extended attributes
xattr -c "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985/en_468.mp3"

# Verify file permissions
chmod 644 "/Users/benjaminslingo/SDA Hymnal/SDA Hymnal/SDA Hymnal/Resources/Assets/Audio/1985/en_468.mp3"
