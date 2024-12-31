--[[
PLAN

- maintain queue / table of items / buffers with line positions
- create a "stack" of floating windows with min height
- tab to cycle through them
- once "centered" we now shift all floating windows up by one
- we shift until we run out, then we just show the last one at the bottom
- <s-tab> to go back, should maintain state of centered until we reach the top

]]
