# offsetaudiotrack
Offsets one track of a video using FFMPEG

- **ffmpeg is required on your global path**
- This script uses and deletes temporary files based on the name of the provided file. If you handle precious data, take the time to check the first few lines of the script in order to avoid conflicts with your own files.

Usage:
`offsetaudiotrack  <file.mp4> <ms> [microphone_track] [audio_track]`
