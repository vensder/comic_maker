module main

fn (mut app AppState) add_bubble() {
	idx := app.selected_panel
	if idx < 0 {
		app.status_msg = 'Select a panel first, then press B.'
		return
	}
	// One bubble per panel: remove any existing one for this panel
	app.bubbles = app.bubbles.filter(it.panel_idx != idx)
	app.bubbles << SpeechBubble{
		panel_idx: idx
		text:      ''
		editing:   true
	}
	// << appends; new element is always at len-1
	app.active_bubble = app.bubbles.len - 1
	app.status_msg = 'Type dialogue. Backspace to delete. Enter to confirm.'
}

fn (mut app AppState) type_into_bubble(ch string, is_backspace bool) {
	i := app.active_bubble
	if i < 0 || i >= app.bubbles.len {
		return
	}
	if is_backspace {
		t := app.bubbles[i].text
		if t.len > 0 {
			// V string slice: s[..n] = s[0..n], no allocation if n == s.len
			app.bubbles[i].text = t[..t.len - 1]
		}
	} else {
		app.bubbles[i].text += ch
	}
}

fn (mut app AppState) confirm_edit() {
	i := app.active_bubble
	if i < 0 || i >= app.bubbles.len {
		return
	}
	app.bubbles[i].editing = false
	app.active_bubble = -1
	app.status_msg = 'Bubble saved. Click a panel to continue.'
}
