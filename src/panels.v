module main

// hit_test checks if point (px, py) falls inside this panel.
// Pure function on an immutable receiver - no side effects.
fn (p &ComicPanel) hit_test(px f32, py f32) bool {
    return px >= p.x && px <= p.x + p.w && py >= p.y && py <= p.y + p.h
}

// select_panel deselects all panels, then selects the one at index.
fn (mut app AppState) select_panel(idx int) {
    // V: for loop with mutable iteration over slice by reference
    for mut p in app.panels {
        p.selected = false
    }
    if idx >= 0 && idx < app.panels.len {
        app.panels[idx].selected = true
        app.selected_panel = idx
        app.status_msg = 'Panel ${idx + 1} selected. Press B to add a bubble, S to add sticker.'
    } else {
        app.selected_panel = -1
        app.status_msg = 'Click a panel to select it.'
    }
}

// clear_panel removes sticker and bubble from the selected panel.
fn (mut app AppState) clear_panel() {
    idx := app.selected_panel
    if idx < 0 { return }

    app.panels[idx].sticker = -1

    // Filter bubbles: V's filter() on arrays returns a new slice.
    // Closures capture by value unless `mut` is specified.
    app.bubbles = app.bubbles.filter(it.panel_idx != idx)

    // Reset active bubble if it pointed into the cleared panel
    if app.active_bubble >= app.bubbles.len {
        app.active_bubble = -1
    }
    app.status_msg = 'Panel ${idx + 1} cleared.'
}

// add_sticker_to_selected cycles a numeric sticker ID into the selected panel.
fn (mut app AppState) add_sticker_to_selected() {
    idx := app.selected_panel
    if idx < 0 {
        app.status_msg = 'Select a panel first.'
        return
    }
    // Cycle through 5 placeholder sticker IDs
    app.panels[idx].sticker = (app.panels[idx].sticker + 1) % 5
    app.status_msg = 'Sticker #${app.panels[idx].sticker} placed in panel ${idx + 1}.'
}