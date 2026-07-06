module main

import gg
import gx

// --- Core data types ---

// ComicPanel represents one cell in the comic grid.
// Immutable by default - a value of this type cannot be modified
// unless the binding holding it is declared `mut`.
struct ComicPanel {
pub mut:
    // pub: visible outside module, mut: fields are mutable
    x        f32
    y        f32
    w        f32
    h        f32
    selected bool
    sticker  int = -1   // index into AppState.stickers; -1 = none
}

// SpeechBubble: a text overlay anchored to a panel.
struct SpeechBubble {
pub mut:
    panel_idx int
    text      string
    editing   bool
}

// AppState is the single source of truth for the entire application.
// @[heap] tells the compiler: always allocate this on the heap,
// never copy it onto the stack. Critical for structs passed as
// user_data voidptr to C callbacks - stack addresses become invalid.
@[heap]
struct AppState {
pub mut:
    ctx            &gg.Context = unsafe { nil }
    panels         []ComicPanel
    bubbles        []SpeechBubble
    stickers       []string      // file paths or embedded asset IDs
    selected_panel int
    active_bubble  int
    drag_start_x   f32
    drag_start_y   f32
    is_dragging    bool
    status_msg     string
}

// --- Initializer callback ---

// app_init is called once by gg after the GL context is ready.
// Signature must match gg.FNCb = fn(voidptr).
// We recover our typed pointer from the voidptr via unsafe cast.
fn app_init(mut ctx gg.Context) {
    // ctx.user_data is voidptr. Cast it back to our concrete type.
    // unsafe{} blocks are explicit - V forces you to acknowledge risk.
    mut app := unsafe { &AppState(ctx.user_data) }
    app.init_panels()
    app.status_msg = 'Click a panel to select it. Press B to add a speech bubble.'
}

// init_panels populates the 2x3 comic grid layout.
// Method receiver `mut app` = mutable reference to the struct.
fn (mut app AppState) init_panels() {
    // V array literal: []Type{} - strongly typed, zero-init
    app.panels = []ComicPanel{}

    cols := 3
    rows := 2
    pad  := f32(12)
    pw   := f32(260)
    ph   := f32(270)

    // V for loops over ranges: start..end (exclusive upper bound)
    for r in 0..rows {
        for c in 0..cols {
            // Struct literal - field names required, order free
            app.panels << ComicPanel{
                x: pad + f32(c) * (pw + pad)
                y: f32(60) + f32(r) * (ph + pad)
                w: pw
                h: ph
            }
        }
    }
}