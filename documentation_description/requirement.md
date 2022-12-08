# Requirement

This document list the common requirement for the whole project

## Behavior

The behavior of the MIPS code will be a replication of the behavior of the C code. Changes can be
made in case no alternative translation is possible to preserve the C code behavior within MARS MIPS.

## Signedness

It is assumed that all arithmetic operation used will be unsigned, so that no exception is created.

But comparison will assumed that all operand to be signed (with 2-complement representation).

## Data segment

For the display, a small memory range will be allocated at the start of the data segment, the size
is bounded to changed with the bitmap display implementation. Any static data must be placed after
the display memory range.

Label used should be carefully chosen so no collsion occurs.

## Function ABI

Every function will have its paramenter passed in with register $a0, $a1, $a2,...

Return value (if exist) will be stored in $v0, $v1, $v2,...

Assumption on temporary and saved register is preserved, changed to saved register requires the
function the save the original value to the stack.

## Bitmap display

The bitmap display used data in memory (each word will store color RGB value in the lowest bit).
The size of the display can be change.

Beside the display memory range requirement, not much else is required.

Function will be provided to abstract away the bitmap display control.

## Subpart and job distribution

All the function that need to be call is listed (can be found in the C program).

The program will be divided into 3 subparts, with many function categoried into said subparts.

### Print and user input (file `print_and_ask.asm`)

Function that within this subpart is

```{.c}
// PRINT AND USER INPUT
// ____________________________________________________________________________
// various print function
void print_welcome_prompt(void);
void print_current_player_prompt(void);
void print_placement_column_prompt(void);
void print_ending_prompt(void);
// ask the player that will go first
byte_t ask_for_first_player(void);
// ask the column to place the next piece, with check for full column
word_t ask_for_new_piece_column(void);
```

All the printing and user input will be done with MARS MIPS syscall. Each function is required
to conform to the function ABI listed above.

### Bitmap display (file `update_display.asm`)

```{.c}
// BITMAP DISPLAY FUNCTION
// ____________________________________________________________________________
// clear display
void update_display_clear(void);
// update display with new piece
void update_display_add_new_piece(word_t column, byte_t player);
```

Function within this part controls the bitmap display (note the display memory range requirement).

The memory range will be declared within `main.asm` because there is no link option to specify
where a label will be placed in memory.

### Game state changing and helper function (file `game_state.asm`)

```{.c}
// GAME STATE CHANGING AND HELPER FUNCTION
// ____________________________________________________________________________
// initialize display and global var
void initialize(void);
// check column if there is still space
byte_t check_column_has_space(word_t column);
// place piece into specified column, with said piece belonging to specified player
void place_piece_into_column(word_t column, byte_t player);
// check current board and update the game state (win, tie)
void update_game_state(word_t column);
// update current_player to be the other player
void change_to_next_player_turn(void);
```

This is potentially the longest (and most error prone) part of the project, function requirement
listed above applies.
