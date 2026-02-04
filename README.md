# TrackMyCard

A simple iOS application to track credit card benefits and credits (like Uber Cash, Dining Credits, etc.).

## Features

- **Benefit Tracking**: Keep track of various recurring benefits across multiple cards.
- **Grouping**: Similar benefits are grouped together for a cleaner overview.
- **Widget Support**: View upcoming benefits directly from your home screen.
- **Auto-Reset**: Benefits automatically reset based on their frequency (Monthly, Quarterly, etc.).

## Xcode Cloud Integration

This project is prepared for Xcode Cloud.

### Setup Instructions

1.  **App Group**: Ensure the App Group `group.sevenBillionYou.TrackMyCard` is registered in your Apple Developer account and added to the app's capabilities in Xcode.
2.  **Shared Schemes**: Ensure the `TrackMyCard` scheme is marked as **Shared** in Xcode (**Product > Scheme > Manage Schemes...**).
3.  **Automatic Signing**: Ensure "Automatically manage signing" is enabled for all targets.

### CI Scripts

Custom setup can be added to `ci_scripts/ci_post_clone.sh`.
