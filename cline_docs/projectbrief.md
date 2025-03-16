# Project Brief

# Pulse Oximeter iOS App Project Brief

## Project Overview
This project involves the development of an iOS application designed to connect with a Bluetooth pulse oximeter (Wellue Model FS20F), record readings, and visualize the data. The application will provide surfing athletes with a tool to monitor and analyze their blood oxygen levels and heart rate during breath training sessions.

## Project Objectives
The primary objective is to create a functional iOS application that:
- Connects to a Bluetooth pulse oximeter device
- Records blood oxygen and heart rate data without preset routines
- Visualizes the recorded data for analysis
- Stores historical session data for future reference

This application will address the limitation of existing freediving apps that only record readings as part of preset routines, providing more flexibility for surfing breath training sessions.

## Target Users
- Primary user: The developer (surfing athlete based in San Francisco)
- Future potential users: Surfing coach (based in Hawaii) and potentially other surfing athletes

## Technical Environment
- Development device: Macbook Air running macOS 14
- Target device: iPhone running iOS 18.31
- Development tools:
  - VS Code Version 1.98.1
  - AI auto-coder (Cline)
  - Xcode Version 16.1 (16B40)
  - Python (for any auxiliary development needs)
- Hardware: Wellue Model FS20F pulse oximeter (Bluetooth-enabled, runs on 2 AAA batteries)

## Core Functionality (In Priority Order)
1. **Device Scanning and Connection**
   - Ability to discover and connect to the Wellue FS20F pulse oximeter
   - Management of existing connections
   - Display connection status

2. **Recording Start/Stop Functionality**
   - Clear UI controls to start and stop recording sessions
   - Visual indicators showing recording status
   - Seamless transition between recording and visualization states

3. **Real-time Data Display**
   - Display current blood oxygen level (SpO2 as a percentage)
   - Display current heart rate
   - Update in real-time while device is connected

4. **Data Storage**
   - Store recorded session data locally on the device
   - Associate timestamp information with readings
   - Implement session management functionality

5. **Data Visualization**
   - Initial implementation: Tabular display with datetime, SpO2 (%), and heart rate columns
   - Second iteration: Two line graphs (one for SpO2, one for heart rate) with time on the x-axis
   - Future enhancement: Interactive controls for zooming, expanding, and navigating within graphs

6. **Recording Management**
   - Interface to view session history
   - Functionality to delete and archive sessions
   - Search capability to find sessions by date

## Success Criteria
The MVP will be considered successful when the user can:
- Install and run the app on an iPhone
- Connect to the Wellue pulse oximeter or find the device if not connected
- View current readings when the device is connected
- Start and stop recording sessions with clear visual indicators
- View recorded data in line graph format
- Access and manage session history

## Timeline
- Development timeline: 1-2 days using AI auto-coding tools to accelerate development

## Future Considerations
While not part of the initial MVP, the following features should be considered for future iterations:
- Functionality to share data with a remote surfing coach
- Integration with video streaming for interactive coaching sessions
- Implementation of advanced data visualization features (interactive controls)
- Cloud storage for session data to facilitate sharing and backup

## Design Notes
- The application should prioritize simplicity and usability
- Interface should be clear and intuitive, allowing for operation during training sessions
- Visualization should focus on clarity and readability of data

## Technical Implementation Considerations
- Utilize Core Bluetooth framework for device connectivity
- Implement a local database for session storage
- Ensure the app handles background/foreground transitions appropriately
- Consider battery efficiency in the implementation
