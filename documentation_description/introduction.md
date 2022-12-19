# Introduction

This is a implementation of the game "Connect four" for two player. In this game the players will
each take turn to place a piece into a game board.  The game board have 7 column, each have 6 row.

Below is s textual representation of the game board with call the column and row numbered from 0.
Each dot is a position into which player's pieces can be put.

```
5   .   .   .   .   .   .   .
4   .   .   .   .   .   .   .
3   .   .   .   .   .   .   .
2   .   .   .   .   .   .   .
1   .   .   .   .   .   .   .
0   .   .   .   .   .   .   .
    0   1   2   3   4   5   6
```

On a player's turn, the player will choose a column (number 0 to 6) to put the new piece. The new
piece will fall down to the lowest space available as if there is gravity pulling the piece down.
Pieces will stack higher and higher within a column. If there is no more space within the column (6
pieces stacked already), then more piece can not be placed into such column.

The objective of the game is placing pieces such that 4 pieces create a line (horizontal, vertical
or diagonal) - thus 'connect four'. The first player to attain such a configuration is the winner.

The game end when a winner is determined, or there is no more space to place new piece. In case the
board is full, the result will be a draw.

When starting the game, a prompt will ask for a player to go first. Answer to that can be 1 - player
#1 or 2 - player #2. Then each player will take turn entering the (valid, non-full) column that they
want to place their piece. After a successful placement, a bitmap display will be updated to reflect
the game board state.

# Overall design and module

We will describe the design of the program in C code for brevity and comprehensibility. All variable
and function mentioned will be translated into MIPS to try best replicate the behavior of the C
function.

## Global data and constant

```{.c}
#define COLUMN_NUM 7
#define ROW_NUM 6

byte_t end_game;       // boolean
byte_t current_player; // can be 1 or 2 for player #1 or #2
byte_t winner;         // can be 1 or 2 for player #1 or #2, 0 when tie

// store the state of all position within the game
// a position can have 3 value: 0 (empty), 1 (player #1 piece), 2 (player #2 piece)
byte_t piece_position[COLUMN_NUM][ROW_NUM];
// since pieces stack, each column will have a height value
// this is used to find the position for the next piece
byte_t column_height[COLUMN_NUM];
// piece count is used to determine if there is still space left
// the maximum value is COLUMN_NUM * ROW_NUM
word_t piece_count;
```

We will need to store the state of each position within the board. As such, the 2-dimensional array
`piece_position` will be used. The array will be indexed by row-major order (row first, then
column).

Each column will have a stack of piece with a certain height. We need to store this height so that
finding the top of the stack is easy. Stack height is stored in a array `column_height` (which
is indexed by column number).

`piece_count` is used to stored the number of piece placed into the board already. It is used to
check whether the board is full.

# Main program and sub-module categorization

We have the main game code as such, hopefully the function name is descriptive enough to not warrant
a immediate description for each of them. Each function will be described in their respective module
subsection.

```{.c}
int main(void)
{
    initialize();
    print_welcome_prompt();
    current_player = ask_for_first_player();

    // start main loop, with each iteration being a player turn
    while (!end_game)
    {
        // print the current player turn
        print_current_player_prompt();
        // ask where the player want to place the next piece
        word_t next_piece_column = ask_for_new_piece_column();

        // place piece into the requested place
        place_piece_into_column(next_piece_column, current_player);
        piece_count++;

        // update the display with the new piece
        // piece added will be colored corresponding to the player
        update_display_add_new_piece(next_piece_column, current_player);

        // check the state of the game with the new piece
        // we know that the most recent piece is on top of next_piece_column
        // also check piece count so that the game end when there is no more space
        update_game_state(next_piece_column);

        change_to_next_player_turn();
    }

    // reach this when:
    // - player #1 or #2 win (winner == 1 or 2)
    // - there is a tie (i.e, run out of place to put new piece) (winner == 0)
    print_ending_prompt();
}
```
Function used can be categorized into 3 separate module:

- Print and user input

- Bitmap display update

- Game state management and helper

# Implementation

Since the jobs is to translate the code into MIPS assembly. We must first set forth some rule on how
to translate the code.

Each module mentioned above is implemented in three separate file. And we will utilized the MARS
MIPS option "Settings/Assemble all files in directory" to call functions from different file. See this
\href{https://stackoverflow.com/questions/47004779/mips-how-to-run-multiple-files-in-mars}{Stackoverflow answer}
for more detail.

## Translation rule

### Behavior

The behavior of the MIPS code will be a replication of the behavior of the C code. Changes can be
made to other rule in case no alternative translation is possible to preserve the C code behavior
within MARS MIPS.

### Signed-ness of variable

It is assumed that all arithmetic operation used will be of the unsigned type, so that no exception
is created.

But comparison will assumed that all operand to be signed (with 2-complement representation).

### Function ABI

Every function will have its parameter passed in with register `$a0`, `$a1`, `$a2`,... (in that
order).

Return value (if exist) will be stored in `$v0`, `$v1`, `$v2`,... (in that order).

Assumption on temporary and saved register is preserved. Meaning that changes to saved register
requires the function the save the original value to the stack and that temporary register is free
to use without backing up their value.

