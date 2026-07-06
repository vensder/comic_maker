// module declaration - every .v file must declare its module
module main

// V imports: no "." imports, no circular deps allowed
import gg        // sokol-backed 2D graphics context
import gx        // color constants and helpers
import os        // file system (for loading sticker assets)

// Entry point. V requires exactly one fn main() in module main.
fn main() {
    // mut: this variable needs to be mutated after declaration
    // &AppState{}: allocate AppState on the heap, get a pointer back
    // All struct fields not listed here get their zero value (0, '', false, etc.)
    mut app := &AppState{
        selected_panel: -1
        active_bubble:  -1
    }

    // gg.new_context() uses a struct-literal config - no positional args.
    // fn references are passed as first-class values (no lambdas needed here).
    // user_data: stores our app pointer so callbacks can recover it.
    mut ctx := gg.new_context(
        bg_color:     gx.rgb(240, 235, 220)
        width:        900
        height:       650
        window_title: 'Comic Maker'
        user_data:    app          // voidptr - V erases type here
        init_fn:      app_init
        frame_fn:     app_frame
        event_fn:     app_event
    )

    // Store the gg.Context pointer back into our state so draw functions can use it.
    // Must happen before ctx.run() since init_fn fires inside run().
    app.ctx = ctx

    ctx.run()
}