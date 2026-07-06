module main

import gg

// app_event is the FNEvent callback: fn(e &gg.Event, mut app AppState).
// event_fn receives (event, user_data); V infers the concrete type.
fn app_event(e &gg.Event, mut app AppState) {
	match e.typ {
		.mouse_down {
			// ctx.scale handles HiDPI/retina: raw pixel coords -> logical coords
			app.handle_click(e.mouse_x / app.ctx.scale, e.mouse_y / app.ctx.scale)
		}
		.key_down {
			app.handle_keydown(e)
		}
		.char {
			// .char fires after key_down, carries the decoded unicode codepoint.
			// Only route chars when actively editing a bubble.
			if app.active_bubble >= 0 {
				// utf8 field is the decoded string for the pressed character
				app.type_into_bubble(rune(e.char_code).str(), false)
			}
		}
		else {}
	}
}

fn (mut app AppState) handle_click(mx f32, my f32) {
	// Toolbar zone (y < 52)
	if my < 52 {
		if mx >= 712 && mx <= 852 {
			app.add_sticker()
		} else if mx >= 560 && mx <= 700 {
			app.clear_panel()
		}
		return
	}
	// Hit-test panels
	for i, panel in app.panels {
		if panel.hit_test(mx, my) {
			app.select_panel(i)
			return
		}
	}
	app.select_panel(-1)
}

fn (mut app AppState) handle_keydown(e &gg.Event) {
	match e.key_code {
		.b        { app.add_bubble() }
		.s        { app.add_sticker() }
		.enter    { app.confirm_edit() }
		.backspace {
			if app.active_bubble >= 0 {
				app.type_into_bubble('', true)
			}
		}
		.escape   {
			app.confirm_edit()
			app.select_panel(-1)
		}
		else {}
	}
}
