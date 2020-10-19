

Project Structure:
---------

Targets (app instances):
- One target for each app instance: so far one for entourage and one for ...

Configurations:
- Two configurations for each target [one for staging (preprod), one for production]

Folders:
---------
- Shared: this folder contains the shared code between all the apps/targets. It contains all the entourage app code (even if not all the features are reused across other targets/apps)
- Entourage: this contain entourage only specifc code, configuration files and resources

Entourage specific:
- "Entourage/Resources/Entourage.xcassets" - all entourage specific images/icons

Whitelabeling:
---------
Each (new)app instance has to be configured by updating these specific files:

- "Shared/ApiKeys.plist" - contains the api keys for each app identified by bundle id
- "Shared/AppConfigurations.plist" - contains all the third party libs credentials/secret keys for each app identified by bundle id
- "Shared/Classes/Settings/EnvironmentConfigurations.swift" - configures each app target/configuration based on environment and credentials loaded from the above .plist files
- "Shared/Classes/Settings/ApplicationTheme.swift" - configures the colors for each app (primary color (blue or orange), secondary color (white), title colors, background colors ..etc)
- "Shared/Classes/Settings/OTAppAppearance.h/m" - configures colors, texts or images which are different based on app type
- "Shared/Classes/Settings/OTAppConfiguration.h/m" - configures how the app should behave and enables/disables features/actions based on app type
- "Shared/Classes/Settings/OTAppState.h/m" - class which acts as a "state machine" for the app flows, navigations between screens not configured in storyboards, or user actions which are different for each app
- "Shared/Resources/Localisable.strings" - all entourage localised strings and all reused across all apps 
- "Shared/Resources/SharedImages.xcassets" - all images reused across the apps
- "Shared/Classes/Service/OTLocalisationService.h/m" - returns specific localised string for each app

Rules:
---------
No class/file from the Shared folder should "know" about the app type (entourage or ...), it should read configurations from the OTAppConfiguration file/class.
Each text or image which is different based on each app type should be handled through OTAppAppearance file/class


