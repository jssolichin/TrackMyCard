# Adding the Widget to TrackMyCard

Since this project was generated via CLI, the Widget Extension target needs to be manually added in Xcode to register it properly.

### Step 1: Add the Target
1.  Open `TrackMyCard.xcodeproj` in Xcode.
2.  Go to **File > New > Target...**.
3.  Search for **Widget Extension**.
4.  Name it: `TrackMyCardWidget`.
5.  **Uncheck** "Include Configuration Intent" (we are using a StaticConfiguration).
6.  Click **Finish**.
7.  If asked to "Activate" the scheme, click **Activate**.

### Step 2: Configure Files
1.  Delete the default `TrackMyCardWidget.swift` that Xcode created in the new folder (move to trash).
2.  Drag the `TrackMyCardWidget.swift` file I created in the `TrackMyCardWidget/` folder into the Xcode project navigator under the yellow `TrackMyCardWidget` folder group.
3.  **Critical:** Select the following files in your Project Navigator:
    *   `CardBenefit.swift`
    *   `UserCard.swift`
    *   `SharedModelContainer.swift`
    *   `CardPresets.swift` (if referenced, though strictly not needed for the widget unless you use it)
4.  In the **File Inspector** (right sidebar), check the box for **"Target Membership"** for `TrackMyCardWidget`.
    *   *Note:* These files must be members of **both** `TrackMyCard` and `TrackMyCardWidget` targets.

### Step 3: Enable App Groups (Shared Data)
To allow the Widget to see the App's data:
1.  Select the project icon in the top left.
2.  Select the **TrackMyCard** target -> **Signing & Capabilities**.
3.  Click **+ Capability** -> **App Groups**.
4.  Click the **+** button to add a new group (e.g., `group.com.yourname.TrackMyCard`).
5.  Repeat this for the **TrackMyCardWidget** target (add the *same* App Group).
6.  **Update Code:** Open `SharedModelContainer.swift` and replace `"group.com.example.TrackMyCard"` with your actual App Group ID.

### Step 4: Run
1.  Select the **TrackMyCard** scheme.
2.  Run the app on a Simulator.
3.  Add some data.
4.  Go to the Home Screen, long press, and add the **TrackMyCard** widget.
