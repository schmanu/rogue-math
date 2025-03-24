# Rogue Math - Calculator Card Game

A retro-style card game where you play cards to perform calculator operations. Built with LÖVE (Love2D).

## Setup Instructions

1. Install LÖVE (Love2D) from https://love2d.org/
2. Clone this repository
3. Run the game using LÖVE with this directory as the source

## Game Rules

- The game starts with a deck containing numbers 1-9 and two plus operators
- Draw cards to your hand
- Drag cards from your hand to the calculator display to play them
- Playing a number card is equivalent to pressing that number on a calculator
- Playing a plus operator card is equivalent to pressing the plus button on a calculator
- Each level has a target number you need to reach
- Target numbers follow the sequence: 16, 32, 64, 128, 256, etc.
- Click the "End Turn" button to evaluate your expression and check if it matches the target
- Successfully matching the target gives you 100 points and advances to the next level
- Failing to match the target costs you 50 points
- Try to create valid mathematical expressions!

## Controls

- Left mouse button: Drag and drop cards
- Right mouse button: Draw new cards
- Enter: Evaluate the current expression
- C: Clear the calculator display
- ESC: Quit game 