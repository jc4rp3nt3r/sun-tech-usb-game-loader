SUN TECH UNLIMITED  ///  GAME GRID
=================================================================

  WINDOWS   Double-click  START.bat
  MAC       Double-click  START.command

That's it. A window opens with every game on the drive.

If macOS refuses to open START.command, right-click it and choose
Open, then Open again. You only have to do that once.


-----------------------------------------------------------------
PLAYING
-----------------------------------------------------------------

  Up / Down  or  W / S ....... move through the list
  Enter  or  Space ........... launch the selected game
  Esc ........................ back to the menu, from anywhere
  R .......................... refresh the list
  A .......................... add a game

Esc always works, even in the middle of a game. There is also a
"Back to grid" button in the top bar if you would rather click.


-----------------------------------------------------------------
ADDING A GAME
-----------------------------------------------------------------

1. Copy the game into the  games  folder on this drive.

     One file?           Drop  my-game.html  straight in.
     Images and sounds?  Put everything in a folder and name the
                         starting file  index.html .

2. Start the Game Grid and click "Add a game" in the top bar.

The form writes the entry into games.json for you. You can also
edit that file by hand - see  games/_TEMPLATE/README.txt .

Any HTML file in the games folder shows up whether or not it has
an entry. Nobody's game ever disappears; an unlisted one just has
no title, cover or credit until someone adds it.


-----------------------------------------------------------------
FOR WHOEVER SETS THE DRIVE UP
-----------------------------------------------------------------

Run  SETUP-RUNTIME.bat  (Windows) or  setup-runtime.command  (Mac)
ONCE, on a computer with internet. It copies the official Node
build onto the drive so the Game Grid runs on locked-down school
machines with nothing installed and no network.

You can skip it. On Windows the Game Grid falls back to
PowerShell, which every machine already has. It is slower but it
works with no setup at all.

There is an autorun.inf on the drive. Do not count on it - Windows
disabled AutoRun for USB sticks in 2011 and it is only there as a
best effort, plus it gives the drive a proper name and icon.


-----------------------------------------------------------------
WHAT IS ON THE DRIVE
-----------------------------------------------------------------

  START.bat / START.command ....... what students double-click
  SETUP-RUNTIME.* ................. one-time, puts Node on the drive
  games/ .......................... every game lives here
    games.json .................... titles, covers, credits
    _TEMPLATE/ .................... starter game + how-to
  system/ ......................... the launcher itself
    server.js ..................... Node server
    server.ps1 .................... PowerShell fallback
    ui/ ........................... the Game Grid interface
    runtime/ ...................... Node, once setup has been run


-----------------------------------------------------------------
IF SOMETHING GOES WRONG
-----------------------------------------------------------------

Nothing happens when I double-click START.bat
  Some school machines block .bat files. Open the  system  folder,
  right-click server.ps1, and choose "Run with PowerShell".

A game is missing from the list
  Check it is inside the  games  folder and that the file ends in
  .html or .htm. Press R to refresh.

The menu shows a red error card
  games.json has a typo. The card names the line and character.
  Nine times out of ten it is a comma before a } or a ], or curly
  quotes pasted in from a word processor.

A game loads but the keyboard does nothing
  Click once inside the game area to give it focus.

Esc will not leave a game
  Use the "Back to grid" button in the top bar. This happens if a
  game opens a page from the internet rather than from the drive.

The window is black for a long time on a new computer
  The browser is building its profile in that computer's temp
  folder. It happens once per machine and takes a few seconds;
  every launch after that on the same machine is instant.

  If you have a folder called  system\.browser-profile  on this
  drive, it is left over from an older version. Delete it - it is
  tens of megabytes of dead weight, and it was the reason the Game
  Grid used to take minutes to open from a USB stick.


-----------------------------------------------------------------
SUN Tech Unlimited - a club of SUN Area Technical Institute
815 Market St., New Berlin, PA 17855
Built with MoJo Active.
