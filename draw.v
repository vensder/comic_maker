module main

import gg

// app_frame is the FNCb callback: fn(mut app AppState).
// V resolves the concrete type from user_data automatically.
fn app_frame(mut app AppState) {
	app.ctx.begin()
	app.draw_toolbar()
	app.draw_panels()
	app.draw_bubbles()
	app.draw_status()
	app.ctx.end()
}

fn (mut app AppState) draw_toolbar() {
	app.ctx.draw_rect_filled(0, 0, 900, 52, gg.rgb(50, 50, 60))
	app.ctx.draw_text(20, 16, 'COMIC MAKER', size: 20, color: gg.white)

	// Sticker button - green when a panel is selected, grey otherwise
	sticker_col := if app.selected_panel >= 0 { gg.rgb(70, 150, 70) } else { gg.rgb(75, 75, 85) }
	app.ctx.draw_rect_filled(712, 8, 140, 36, sticker_col)
	app.ctx.draw_text(724, 18, '+ Sticker', size: 15, color: gg.white)

	// Clear button
	app.ctx.draw_rect_filled(560, 8, 140, 36, gg.rgb(150, 55, 55))
	app.ctx.draw_text(574, 18, 'Clear Panel', size: 15, color: gg.white)
}

fn (mut app AppState) draw_panels() {
	for i, panel in app.panels {
		border := if panel.selected { gg.rgb(255, 200, 0) } else { gg.rgb(30, 30, 30) }
		app.ctx.draw_rect_filled(panel.x, panel.y, panel.w, panel.h, gg.white)
		app.ctx.draw_rect_empty(panel.x, panel.y, panel.w, panel.h, border)

		// Panel index label (top-left corner)
		app.ctx.draw_text(int(panel.x) + 6, int(panel.y) + 6, '${i + 1}',
			size:  13
			color: gg.rgb(180, 180, 180)
		)

		// Sticker placeholder: a filled coloured rect with a label.
		// Replace with ctx.draw_image() once you load real PNGs.
		if panel.sticker >= 0 {
			app.ctx.draw_rect_filled(
				panel.x + 20, panel.y + 50, panel.w - 40, panel.h - 100,
				gg.rgb(255, 220, 150)
			)
			app.ctx.draw_text(int(panel.x) + 28, int(panel.y) + 140,
				'[sticker #${panel.sticker}]',
				size:  14
				color: gg.rgb(100, 60, 10)
			)
		}
	}
}

fn (mut app AppState) draw_bubbles() {
	for bi, bubble in app.bubbles {
		pidx := bubble.panel_idx
		if pidx < 0 || pidx >= app.panels.len {
			continue
		}
		panel := app.panels[pidx]

		bx := panel.x + 8
		by := panel.y + panel.h - 72
		bw := panel.w - 16
		bh := f32(58)

		app.ctx.draw_rect_filled(bx, by, bw, bh, gg.rgb(255, 255, 240))
		app.ctx.draw_rect_empty(bx, by, bw, bh, gg.rgb(20, 20, 20))

		// Blinking cursor via appended underscore when editing
		display := if bubble.editing { '${bubble.text}_' } else { bubble.text }
		app.ctx.draw_text(int(bx) + 7, int(by) + 9, display,
			size:  13
			color: gg.black
		)

		// Orange outline on the active (being-edited) bubble
		if app.active_bubble == bi {
			app.ctx.draw_rect_empty(bx - 2, by - 2, bw + 4, bh + 4, gg.rgb(255, 100, 0))
		}
	}
}

// Immutable receiver: draw_status only reads state, never mutates it.
// &AppState passes a pointer without mutation rights - cheaper and
// communicates intent to the next person reading this.
fn (app &AppState) draw_status() {
	app.ctx.draw_rect_filled(0, 615, 900, 35, gg.rgb(40, 40, 50))
	app.ctx.draw_text(12, 623, app.status_msg, size: 13, color: gg.rgb(200, 200, 200))
}
