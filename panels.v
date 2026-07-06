module main

// hit_test is a pure predicate on an immutable panel reference.
fn (p &ComicPanel) hit_test(px f32, py f32) bool {
	return px >= p.x && px <= p.x + p.w && py >= p.y && py <= p.y + p.h
}

fn (mut app AppState) select_panel(idx int) {
	// V: `for mut p in app.panels` iterates by mutable reference -
	// changes to p modify the element in-place inside the slice.
	for mut p in app.panels {
		p.selected = false
	}
	if idx >= 0 && idx < app.panels.len {
		app.panels[idx].selected = true
		app.selected_panel = idx
		app.status_msg = 'Panel ${idx + 1} selected. B = bubble, S = sticker, Esc = deselect.'
	} else {
		app.selected_panel = -1
		app.status_msg = 'Click a panel. B = add bubble. S = cycle sticker. Esc = deselect.'
	}
}

fn (mut app AppState) clear_panel() {
	idx := app.selected_panel
	if idx < 0 {
		app.status_msg = 'Select a panel first.'
		return
	}
	app.panels[idx].sticker = -1
	// array.filter() returns a new slice; the closure captures idx by value.
	app.bubbles = app.bubbles.filter(it.panel_idx != idx)
	if app.active_bubble >= app.bubbles.len {
		app.active_bubble = -1
	}
	app.status_msg = 'Panel ${idx + 1} cleared.'
}

fn (mut app AppState) add_sticker() {
	idx := app.selected_panel
	if idx < 0 {
		app.status_msg = 'Select a panel first.'
		return
	}
	// Cycle through 5 placeholder IDs; wrap with modulo
	app.panels[idx].sticker = (app.panels[idx].sticker + 1) % 5
	app.status_msg = 'Sticker #${app.panels[idx].sticker} placed in panel ${idx + 1}.'
}
