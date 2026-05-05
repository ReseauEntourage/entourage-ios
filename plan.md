1.  **Refactor `NeighBorhoodEventListUsersViewController` to decouple unsubscribed elements from the table view:**
    - Open `Neighborhood.storyboard` and modify the `users_groupVC` (`NeighBorhoodEventListUsersViewController`) layout.
    - Reduce the bottom anchor constraint of `ui_tableview` to make room for a new stack view.
    - Add a `UIStackView` (e.g. `ui_stack_unsubscribed`) at the bottom of the container view (`ui_view_container`), just above the safe area or fixed offset. This will be an exact replica of the unsubscribed cell logic but statically positioned beneath the `UITableView`.
    - Update the view controller to use UIViews instead of appending them to `tableData`.
    - Remove the enumeration cases `unsubscribedParticipantsHeader`, `unsubscribedParticipantsAskHelpCell`, and `unsubscribedParticipantsOfferHelpCell` from `TableDTO`.
    - Remove the related row/cell logic from `UITableViewDataSource` and `UITableViewDelegate` implementations.
    - Setup the UI views for the bottom area dynamically based on `event?.unsubscribed_participants_ask_for_help` and `event?.unsubscribed_participants_offer_help` values when rebuilding table data. Ensure they only display when these are `> 0`.
    - Remove unused cells: `NeighborhoodUnsubscribedParticipantsCell`, `NeighborhoodUnsubscribedParticipantsHeaderCell`.

2.  **Fix data transfer and refresh issue:**
    - The issue states that when returning from `NeighBorhoodEventListUsersViewController`, the information is lost. This happens because the updated `Event` data isn't fetched when we return.
    - Since `EventDetailFeedViewController`, `EventDetailFullFeedViewController`, and `EventParamsViewController` all open this controller via `present`, we can trigger an event refresh when dismissing `NeighBorhoodEventListUsersViewController`.
    - However, `NeighBorhoodEventListUsersViewController` already does this for bottom sheet! It posts `NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshEventDetail"), object: nil)`.
    - Also, `EventDetailFeedViewController` is the only one listening to `"RefreshEventDetail"`. We need to make sure `EventDetailFullFeedViewController` and `EventParamsViewController` also listen to it and update their event models, or we ensure the updated data is transferred differently. Actually, a better approach is to make sure when the `NeighBorhoodEventListUsersViewController` updates the participants by adding or from floaty, the global `kNotificationEventUpdate` is sent, or `EventService.getEventWithId` is called inside `viewWillAppear` or similar. Let's look at `EventParamsViewController`, it listens to `kNotificationEventUpdate` and reloads. `EventDetailFullFeedViewController` doesn't seem to listen.
    - Let's make `NeighBorhoodEventListUsersViewController` post `kNotificationEventUpdate` upon validating the unsubscribed participants bottom sheet, instead of just `RefreshEventDetail`. Wait, it posts `RefreshEventDetail` when dismissed.
    - Actually, wait, the problem is simpler: when going TO `NeighBorhoodEventListUsersViewController`, the parent injects its *current* `event` object (`vc.event = event`). If the parent hasn't reloaded the event from the API after the last modification, the passed `event` will have old data!
    - To fix this properly, let's make `NeighBorhoodEventListUsersViewController` fetch the event details again upon opening, OR have the parent fetch when appearing.
    - But `NeighBorhoodEventListUsersViewController` already does `EventService.getEventUsers` - it doesn't do `getEventDetail` to get the latest unsubscribed counts!
    - So, in `NeighBorhoodEventListUsersViewController.viewDidLoad` (or `viewWillAppear`), if `isEvent` is true and `event != nil`, let's do a quick `EventService.getEventWithId` to fetch the latest `unsubscribed_participants_offer_help` and `unsubscribed_participants_ask_for_help`, then build the views. Wait, that would require passing `eventId` which we do have.
    - Or even simpler: the issue description says: "Actuellement, ces vues ne s'affiche que lorsqu'on vient d'ajouter des membre, si on retourne ca s'affiche plus. Il faudrait transférer l'info de eventDetail a MemberList, quand on envoi dessus, pour que ca se set bien. Egalement, quand on part de Memberlist, re init la vue EventDetail, relancer l'appel et reset la view. pour que quand on renvoi on ait bien les champs."
    - This translates directly to:
        1. When going from EventDetail -> MemberList (`NeighBorhoodEventListUsersViewController`), ensure we transfer the fields (it is done by `vc.event = event`).
        2. When leaving MemberList -> EventDetail, trigger a refresh of EventDetail so it gets the new fields (post a notification that EventDetail listens to).
        3. Make sure EventDetail's event parsing actually saves those fields properly. Looking at `Event.swift`, `unsubscribed_participants_offer_help` is decoded but wait - the default custom `init(from decoder: Decoder)` in `Event` doesn't decode `unsubscribed_participants_offer_help` or `unsubscribed_participants_ask_for_help`! Wait! I checked `init(from decoder:)` and it's ONLY for `EventMetadata`! No, `Event` doesn't have a custom init. Wait, `Event` has `CodingKeys`.
        4. Ah, wait. `EventService.getEventWithId` uses `parseData` -> which uses standard Decodable. Does `Event` decode it properly? Let's verify `CodingKeys` in `Event`. Yes, they are in `CodingKeys`.
        5. Let's make sure that when `NeighBorhoodEventListUsersViewController` disappears or updates, it notifies `EventDetailFeedViewController` to update.

3.  **Execute the fixes:**
    - I'll create a sticky bottom view in `NeighBorhoodEventListUsersViewController`.
    - I'll make sure to trigger `kNotificationEventUpdate` or call the appropriate refresh function when `NeighBorhoodEventListUsersViewController` updates the values or disappears, and make sure `EventDetailFeedViewController` catches it and calls `getEventDetail(hasToRefreshLists: true)`.

4.  **Pre commit check**
