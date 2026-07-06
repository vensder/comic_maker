module main

import gg

// app_event is the unified input callback. gg routes all sokol events here.
// The event carries type (.mouse_down, .key_down, .char, etc.) plus coordinates.
fn app_event(e &gg.Event, mut ctx gg.Context) {
    mut app := unsafe { &AppState(ctx.user_data) }

    // V match is exhaustive on enums when all cases are covered,
    // otherwise `else` is required. Unlike Go's switch, no fallthrough.
    match e.typ {
        .mouse_down {
            app.handle_click(e.mouse_x / ctx.scale, e.mouse_y / ctx.scale)
        }
        .key_down {
            app.handle_keydown(e)
        }
        .char {
            // .char events carry the unicode codepoint as a u32
            // We only route chars when a bubble is actively being edited
            if app.active_bubble >= 0 {
                ch := e.char_code.str()
                app.type_into_active_bubble(ch, false)
            }
        }
        else {}
    }
}

// handle_click interprets a mouse_down event by region.
fn (mut app AppState) handle_click(mx f32, my f32) {
    // Check toolbar buttons first (y < 52)
    if my < 52 {
        if mx >= 700 && mx <= 840 {
            app.add_sticker_to_selected()
        } else if mx >= 548 && mx <= 688 {
            app.clear_panel()
        }
        return
    }

    // Hit-test panels. Panels are drawn below y=60.
    for i, panel in app.panels {
        if panel.hit_test(mx, my) {
            app.select_panel(i)
            return
        }
    }

    // Click in empty space: deselect
    app.select_panel(-1)
}

// handle_keydown processes keyboard input.
fn (mut app AppState) handle_keydown(e &gg.Event) {
    // gg.KeyCode is an enum; .b, .s, .enter, .backspace, .escape are variants
    match e.key_code {
        .b {
            app.add_bubble_to_selected()
        }
        .s {
            app.add_sticker_to_selected()
        }
        .enter {
            app.confirm_bubble_edit()
        }
        .backspace {
            if app.active_bubble >= 0 {
                app.type_into_active_bubble('', true)
            }
        }
        .escape {
            // Escape deselects and stops editing
            app.confirm_bubble_edit()
            app.select_panel(-1)
        }
        else {}
    }
}