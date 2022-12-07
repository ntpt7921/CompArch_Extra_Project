# Requirement

This document list the common requirement for the whole project

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
