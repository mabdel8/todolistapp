# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS application built with SwiftUI and StoreKit that appears to be a subscription-based app template. The app includes onboarding, paywall functionality, and in-app purchase integration.

## Architecture

### Core Components

- **ApptemplateApp.swift**: Main app entry point managing app lifecycle, onboarding flow, and initial paywall presentation
- **ContentView.swift**: Main content view showing subscription status (Premium/Free account)
- **OnboardingView.swift**: Initial user onboarding experience
- **PaywallView.swift**: Subscription paywall with multiple plan options (Weekly with 3-day trial, Lifetime)
- **StoreManager.swift**: Handles all StoreKit operations including purchases, subscription status, and transaction management
- **Item.swift**: SwiftData model (currently minimal implementation)

### In-App Purchase Structure

The app uses StoreKit 2 with two subscription products:
- `template_weekly`: Weekly subscription with 3-day free trial ($3.99/week)
- `template_lifetime`: One-time lifetime purchase ($19.99)

Configuration is stored in `apptemplatestorekit.storekit` for local testing.

## Development Commands

### Building and Running

```bash
# Open in Xcode
open Apptemplate.xcodeproj

# Build from command line
xcodebuild -project Apptemplate.xcodeproj -scheme Apptemplate -configuration Debug build

# Run on simulator
xcodebuild -project Apptemplate.xcodeproj -scheme Apptemplate -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Testing In-App Purchases

The project includes a StoreKit configuration file (`apptemplatestorekit.storekit`) for testing purchases locally without App Store Connect.

## Key Implementation Details

### State Management
- Uses `@AppStorage` for persistent storage (e.g., onboarding completion)
- `@StateObject` and `@EnvironmentObject` for StoreManager dependency injection
- Reactive UI updates based on subscription status changes

### StoreKit Integration
- Implements StoreKit 2 async/await patterns
- Handles transaction verification and finishing
- Includes purchase restoration functionality
- Monitors transaction updates in real-time

### UI Flow
1. User sees OnboardingView on first launch
2. After onboarding, paywall is presented if not subscribed
3. Main ContentView shows subscription status
4. Users can upgrade/manage subscription from ContentView

## Current TODOs

The PaywallView has placeholder TODOs for:
- Terms of Service link handler (line 198)
- Privacy Policy link handler (line 207)

## Project Structure

```
TodoListApp/
├── Apptemplate.xcodeproj/    # Xcode project files
├── Apptemplate/               # Main app source code
│   ├── ApptemplateApp.swift  # App entry point
│   ├── ContentView.swift     # Main content
│   ├── OnboardingView.swift  # Onboarding flow
│   ├── PaywallView.swift     # Subscription paywall
│   ├── StoreManager.swift    # StoreKit manager
│   ├── Item.swift            # Data model
│   └── Assets.xcassets/      # Images and colors
└── apptemplatestorekit.storekit  # StoreKit configuration
```

## Important Notes

- The app currently shows a template/placeholder UI and would need actual feature implementation beyond the subscription system
- The Item.swift file suggests SwiftData integration but is minimally implemented
- The app name "Apptemplate" and generic text suggest this is a template for building subscription-based iOS apps