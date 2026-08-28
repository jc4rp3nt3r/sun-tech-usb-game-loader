SUN TECH UNLIMITED — HOW TO ADD YOUR GAME
=========================================

THE FAST WAY
------------
1. Copy your game into the "games" folder on this drive.
   - One file?    Drop  my-game.html  straight in.
   - Several files (images, sounds, extra scripts)?
     Put them all in a folder and name the starting file  index.html .
2. Start the Game Grid.
3. Click "Add a game" in the top bar, fill in the boxes, done.

That's it. The form writes your entry into games.json for you.


THE MANUAL WAY
--------------
If you would rather edit the manifest yourself, open  games/games.json
and add an object to the "games" list:

{
  "club": "SUN Tech Unlimited",
  "games": [
    {
      "title":       "Laser Maze",
      "author":      "Your Name",
      "description": "One or two sentences about what it is.",
      "controls":    "Arrow keys, Space to fire",
      "tags":        ["puzzle", "1-player"],
      "preview":     "laser-maze/cover.png",
      "path":        "laser-maze/index.html"
    }
  ]
}

Only "path" is required. Everything else makes your entry look better.

EVERY PATH IS RELATIVE TO games.json — that is, relative to the games
folder itself. So a game at

    games/laser-maze/index.html

is written as

    "path": "laser-maze/index.html"

Never start a path with a slash, and never use a full path like
C:\Users\... — it will not work on anyone else's computer.


THINGS THAT TRIP PEOPLE UP
--------------------------
* A comma after the LAST item in a list or object breaks the whole file.
  JSON does not allow it. The Grid will tell you the line number.
* Use straight quotes "  not curly quotes “ ”. Word and Google Docs
  swap them silently — write JSON in a code editor, not a word processor.
* File and folder names: lowercase, dashes instead of spaces. Windows
  does not care about capitals but the web does, and the Grid serves your
  game over a tiny local web server.

If games.json ever breaks, the Grid still lists every HTML file it finds
on disk, so nobody's game disappears. It just shows up as "not listed"
without a title or cover until the entry is fixed.


TWO RULES FOR YOUR GAME
-----------------------
1. Leave the Esc key alone. The Grid uses it to take players back to the
   menu from inside your game. Use any other key you like.
2. Size to the frame, not the screen. Your game runs inside a panel below
   the ribbon, so use 100%, vw and vh rather than fixed pixel sizes, and
   handle the window "resize" event. index.html in this folder shows how.
