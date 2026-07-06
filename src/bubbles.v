module main

// add_bubble_to_selected creates a new SpeechBubble for the active panel.
fn (mut app AppState) add_bubble_to_selected() {
    idx := app.selected_panel
    if idx < 0 {
        app.status_msg = 'Select a panel first (click it), then press B.'
        return
    }

    // Remove existing bubble for this panel (one bubble per panel in this demo)
    app.bubbles = app.bubbles.filter(it.panel_idx != idx)

    // << is the append operator for arrays
    app.bubbles << SpeechBubble{
        panel_idx: idx
        text:      ''
        editing:   true
    }

    // Set active bubble to the last appended index
    app.active_bubble = app.bubbles.len - 1
    app.status_msg = 'Type your dialogue. Backspace to delete. Enter to confirm.'
}

// type_into_active_bubble appends or removes a character from the active bubble's text.
fn (mut app AppState) type_into_active_bubble(ch string, is_backspace bool) {
    i := app.active_bubble
    if i < 0 || i >= app.bubbles.len { return }

    if is_backspace {
        // V string slicing: s[..n] is equivalent to s[0..n]
        // strings.Builder is more efficient for repeated concat in loops,
        // but for interactive typing, direct slice is fine.
        if app.bubbles[i].text.len > 0 {
            app.bubbles[i].text = app.bubbles[i].text[..app.bubbles[i].text.len - 1]
        }
    } else {
        app.bubbles[i].text += ch
    }
}

// confirm_bubble_edit stops editing mode on the active bubble.
fn (mut app AppState) confirm_bubble_edit() {
    i := app.active_bubble
    if i < 0 || i >= app.bubbles.len { return }
    app.bubbles[i].editing = false
    app.active_bubble = -1
    app.status_msg = 'Bubble saved. Click a panel to continue.'
}