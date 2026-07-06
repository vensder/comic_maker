module main

// gx has been merged into gg as of Jan 2026. Drop the import entirely.
// All colour constants and rgb() now live under gg.*
import gg

fn main() {
	mut app := &AppState{
		selected_panel: -1
		active_bubble:  -1
	}

	// Store the gg.Context inside the app struct before run().
	// The callback functions receive `mut app App` directly - V resolves
	// this from user_data. We do NOT store ctx separately; app.ctx IS
	// the context. Set it here so init_fn can use it.
	app.ctx = gg.new_context(
		bg_color:     gg.rgb(240, 235, 220)
		width:        900
		height:       650
		window_title: 'Comic Maker'
		user_data:    app
		init_fn:      app_init
		frame_fn:     app_frame
		event_fn:     app_event
	)

	app.ctx.run()
}
