module main

import gg
import gx

// --- Frame draw callback ---

// app_frame fires ~60 times/second. All rendering goes here.
// gg calls this as a C function pointer - we recover our state pointer.
fn app_frame(mut ctx gg.Context) {
    mut app := unsafe { &AppState(ctx.user_data) }

    ctx.begin()   // starts the sokol render pass, clears bg_color

    app.draw_toolbar(mut ctx)
    app.draw_panels(mut ctx)
    app.draw_bubbles(mut ctx)
    app.draw_status(mut ctx)

    ctx.end()     // submits the draw calls to GPU, swaps buffers
}

// draw_toolbar renders the top button bar.
// Receiver is `mut app` - we update state (button hover highlights etc.)
fn (mut app AppState) draw_toolbar(mut ctx gg.Context) {
    // draw_rect_filled(x, y, w, h, color)
    ctx.draw_rect_filled(0, 0, 900, 52, gx.rgb(50, 50, 60))

    // draw_text(x, y, text, cfg) - uses the default embedded font
    ctx.draw_text(20, 16, 'COMIC MAKER',
        size:  20
        color: gx.white
    )

    // "Add Sticker" button region
    btn_color := if app.selected_panel >= 0 { gx.rgb(80, 160, 80) } else { gx.rgb(80, 80, 80) }
    ctx.draw_rect_filled(700, 8, 140, 36, btn_color)
    ctx.draw_text(712, 18, '+ Sticker',
        size:  15
        color: gx.white
    )

    // "Clear" button
    ctx.draw_rect_filled(548, 8, 140, 36, gx.rgb(160, 60, 60))
    ctx.draw_text(562, 18, 'Clear Panel',
        size:  15
        color: gx.white
    )
}

// draw_panels renders each comic cell.
fn (mut app AppState) draw_panels(mut ctx gg.Context) {
    // V range-for over a slice of structs.
    // `i, panel` gives index + value copy. We need the index for selection logic.
    for i, panel in app.panels {
        border := if panel.selected { gx.rgb(255, 200, 0) } else { gx.rgb(30, 30, 30) }

        // Panel background
        ctx.draw_rect_filled(panel.x, panel.y, panel.w, panel.h, gx.white)

        // Border: draw_rect_empty draws outline only
        ctx.draw_rect_empty(panel.x, panel.y, panel.w, panel.h, border)

        // Panel number label
        ctx.draw_text(int(panel.x) + 6, int(panel.y) + 6, '${i + 1}',
            size:  13
            color: gx.rgb(180, 180, 180)
        )

        // If a sticker index is assigned, draw a colored placeholder rect.
        // Real impl: ctx.draw_image() with a loaded gg.Image - see Section 4 notes.
        if panel.sticker >= 0 {
            ctx.draw_rect_filled(panel.x + 20, panel.y + 40, panel.w - 40,
                panel.h - 60, gx.rgb(255, 230, 180))
            ctx.draw_text(int(panel.x) + 30, int(panel.y) + 130, 'Sticker #${panel.sticker}',
                size:  14
                color: gx.rgb(100, 60, 10)
            )
        }
    }
}

// draw_bubbles renders speech bubbles overlaid on panels.
fn (mut app AppState) draw_bubbles(mut ctx gg.Context) {
    for bubble in app.bubbles {
        if bubble.panel_idx < 0 || bubble.panel_idx >= app.panels.len {
            continue  // V: `continue` skips to next loop iteration
        }
        panel := app.panels[bubble.panel_idx]

        bx := panel.x + 10
        by := panel.y + panel.h - 70
        bw := panel.w - 20
        bh := f32(55)

        // Bubble background + border
        ctx.draw_rect_filled(bx, by, bw, bh, gx.rgb(255, 255, 240))
        ctx.draw_rect_empty(bx, by, bw, bh, gx.rgb(20, 20, 20))

        // Cursor blink indicator if this bubble is being edited
        display := if bubble.editing { '${bubble.text}_' } else { bubble.text }
        ctx.draw_text(int(bx) + 8, int(by) + 10, display,
            size:  13
            color: gx.black
        )

        // Active bubble indicator
        if app.active_bubble >= 0 && app.bubbles[app.active_bubble].panel_idx == bubble.panel_idx {
            ctx.draw_rect_empty(bx - 2, by - 2, bw + 4, bh + 4, gx.rgb(255, 100, 0))
        }
    }
}

// draw_status renders the bottom status bar.
fn (app &AppState) draw_status(mut ctx gg.Context) {
    // Immutable receiver (&AppState) - no mutation, cheaper semantics
    ctx.draw_rect_filled(0, 615, 900, 35, gx.rgb(40, 40, 50))
    ctx.draw_text(12, 623, app.status_msg,
        size:  13
        color: gx.rgb(200, 200, 200)
    )
}