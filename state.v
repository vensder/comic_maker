module main

import gg

struct ComicPanel {
pub mut:
	x        f32
	y        f32
	w        f32
	h        f32
	selected bool
	sticker  int = -1
}

struct SpeechBubble {
pub mut:
	panel_idx int
	text      string
	editing   bool
}

// @[heap]: force heap allocation - mandatory when passing this struct
// as user_data voidptr into C callbacks. Stack addresses become dangling
// pointers once main() returns to the sokol event loop.
@[heap]
struct AppState {
pub mut:
	// ctx is stored inside the app, not alongside it.
	// This is the canonical gg pattern: app.ctx.run(), not ctx.run().
	ctx            &gg.Context = unsafe { nil }
	panels         []ComicPanel
	bubbles        []SpeechBubble
	selected_panel int
	active_bubble  int
	status_msg     string
}

fn app_init(mut app AppState) {
	app.init_panels()
	app.status_msg = 'Click a panel. B = add bubble. S = cycle sticker. Esc = deselect.'
}

fn (mut app AppState) init_panels() {
	app.panels = []ComicPanel{}
	cols  := 3
	rows  := 2
	pad   := f32(12)
	pw    := f32(264)
	ph    := f32(270)
	for r in 0 .. rows {
		for c in 0 .. cols {
			app.panels << ComicPanel{
				x: pad + f32(c) * (pw + pad)
				y: f32(60) + f32(r) * (ph + pad)
				w: pw
				h: ph
			}
		}
	}
}
