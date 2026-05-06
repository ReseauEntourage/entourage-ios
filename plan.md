1. **Model Modification (`entourage/Models/Event.swift`)**:
   - Add `var unsubscribed_participants_female: String? = "0"` to `EventMetadata`.
   - Update `CodingKeys` in `EventMetadata` to include `unsubscribed_participants_female`.
   - Update `init(from decoder: Decoder)` in `EventMetadata` to safely decode `unsubscribed_participants_female` just like `ask_for_help` and `offer_help`.
2. **Network Manager Modification**:
   - In `entourage/Network Managers/Endpoints.swift`, update `kAPIUpdateUnsubscribedParticipants` to `"outings/%@/users/unsubscribed_participants?token=%@&offer_help=%d&ask_for_help=%d&female=%d"`.
   - In `entourage/Network Managers/EventService.swift`, update the signature of `updateUnsubscribedParticipants` to include `female: Int`, and update the format string parameters.
3. **Bottom Sheet View Model Modification (`entourage/Scenes/Groups - Neighborhoods/NeighBorhoodEventListUsersViewController.swift`)**:
   - Add `@Published var femaleCount: Int = 0` to `UnsubscribedViewModel`.
   - Update `UnsubscribedBottomSwiftUIView` to display the row for "femmes isolées" (singular: "femme isolée", plural: "femmes isolées") if `femaleCount > 0`.
   - Update `updateUnsubscribedBottomViews()` to parse `unsubscribed_participants_female` from `event.metadata` and set `femaleCount`.
   - Update `EventService.updateUnsubscribedParticipants` call inside the `onValidate` callback of `bottomSheet` to also pass `femaleCount`.
   - Update local state mapping `event?.metadata?.unsubscribed_participants_female` upon successful API response.
4. **Bottom Sheet Controller Modification (`entourage/Scenes/Groups - Neighborhoods/UnsubscribedParticipantsBottomSheet.swift`)**:
   - Add UI components for "femmes isolées": `helpFemaleLabel`, `helpFemaleMinusButton`, `helpFemalePlusButton`, `helpFemaleCountLabel`.
   - Add `initialFemaleCount` and `currentFemaleCount`.
   - Add layout constraints for the new counter, placing it below the existing ones.
   - Update the text of `helpFemaleLabel` to `"Combien de femmes isolées supplémentaires ont rejoint l'événement ?"`.
   - Update `onValidate` signature to `((Int, Int, Int) -> Void)?` and call it with the new `currentFemaleCount`.
5. **Pre-commit step**:
   - Call `pre_commit_instructions` to ensure proper testing, verification, review, and reflection are done.
6. **Submit**:
   - Submit the changes.
