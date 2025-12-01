`ifndef TETRIS_STATES_VH
`define TETRIS_STATES_VH

// --- game state definition ---
`define INITIAL        3'b000
`define GENERATE_PIECE 3'b001
`define ROTATE_PIECE   3'b010
`define COLLISION      3'b011
`define LOSE           3'b100
`define CLEAR_ROW      3'b101
`define MOVE           3'b110
`define TOBOTTOM       3'b111

// --- block type definition ---
`define SQUARE 3'b000
`define BAR    3'b001
`define S      3'b010
`define Z      3'b011
`define L      3'b100
`define J      3'b101
`define T      3'b110

// --- basic color definition (12-bit RGB) ---
`define C_BLACK  12'h000
`define C_WHITE  12'hFFF
`define C_GREY   12'h555
`define C_RED    12'hF00
`define C_GREEN  12'h0F0
`define C_BLUE   12'h00F
`define C_CYAN   12'h0FF
`define C_ORANGE 12'hF80
`define C_YELLOW 12'hFF0
`define C_PURPLE 12'hA0F
`define C_GRID   12'h111

// --- block corner shading (base/highlight/shadow) ---
// Square (Yellow)
`define CY_BASE 12'hFF0
`define CY_HI   12'hFFF
`define CY_LO   12'hAA0
// Bar (Cyan)
`define CC_BASE 12'h0FF
`define CC_HI   12'h8FF
`define CC_LO   12'h088
// S (Green)
`define CG_BASE 12'h0F0
`define CG_HI   12'h8F8
`define CG_LO   12'h080
// Z (Red)
`define CR_BASE 12'hF00
`define CR_HI   12'hF66
`define CR_LO   12'h800
// L (Orange)
`define CO_BASE 12'hF80
`define CO_HI   12'hFA4
`define CO_LO   12'hA40
// J (Blue)
`define CB_BASE 12'h00F
`define CB_HI   12'h66F
`define CB_LO   12'h008
// T (Purple)
`define CP_BASE 12'hA0F
`define CP_HI   12'hD4F
`define CP_LO   12'h608

// --- block size ---
`define BLOCK_SIZE  20   // block size (pixels)
`define BEVEL_WIDTH 2    // bevel width

// --- main game area (Main Board) ---
`define BOARD_W      200 // width
`define BOARD_H      400 // height
`define BORDER       4   // border thickness
`define OFFSET_X 50  // horizontal offset from left
`define OFFSET_Y 50 // vertical offset from top

// --- next piece area (Next Piece) ---
`define NEXT_X_OFF   310  // horizontal offset from left
`define NEXT_Y_OFF   70  // vertical offset from top

// --- score area (Score) ---
`define SCORE_X_OFF  340  // horizontal offset from left
`define SCORE_Y_OFF  290 // vertical offset from top
`define CHAR_SCALE   4   // character scale factor
`define CHAR_SPACE   4   // character spacing

//LOGO area
`define LOGO_W 120
`define LOGO_H 120
`define LOGO_X 480
`define LOGO_Y 300
`endif