SUN TECH UNLIMITED  ///  GAME GRID
=================================================================

  WINDOWS   Double-click  START.bat
  MAC       Double-click  START.command  (see the two Mac sections below)

That's it. A window opens with every game on the drive.

ON A MAC, THE FIRST RUN NEEDS TWO EXTRA STEPS. See the next two
sections. It takes about a minute, once per stick.


-----------------------------------------------------------------
MAC: "CANNOT BE OPENED BECAUSE IT IS FROM AN UNIDENTIFIED
DEVELOPER"
-----------------------------------------------------------------

macOS tags anything arriving from an unfamiliar drive, and refuses
to run it until a person vouches for it. Nothing is wrong with the
file.

IMPORTANT: on macOS Sequoia and newer, right-clicking and choosing
Open NO LONGER WORKS. Apple removed that shortcut. Do this instead.

  1. Open Terminal.  (Press Command-Space, type Terminal, Return.)

  2. Type this, but do not press Return yet - note the trailing
     space:

       xattr -dr com.apple.quarantine

  3. Drag the USB drive's icon from Finder into the Terminal
     window. It fills in the path for you. Now press Return.

  4. Then run this, dragging the drive in the same way:

       chmod +x /Volumes/YOUR-DRIVE/START.command

  5. Double-click START.command. It opens.

The alternative, if you would rather not use Terminal: double-click
START.command, let it be refused, then go to

  System Settings > Privacy & Security

scroll down to Security, and click "Open Anyway" next to the note
about START.command. That approves one file on one Mac, so you
would repeat it on every machine.

PREPARING STICKS FOR A GROUP? Clear the tag on the master stick
before you make copies. Doing it in front of a room of waiting kids
is not fun.


-----------------------------------------------------------------
MAC: THE LOADER NEEDS NODE
-----------------------------------------------------------------

Windows can fall back to PowerShell, which every PC already has.
macOS has no equivalent built in, so the Game Grid needs Node.

If it is missing, START.command will say so and offer to download
it - about 50 MB, once - and will save it onto the drive so every
Mac after that starts straight away. Just say yes.

To set this up ahead of time, run setup-runtime.command on a Mac
with internet. Do it before an event, not during one.


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

Nothing happens when I double-click START.command on a Mac
  See the two Mac sections near the top of this file. Ninety-nine
  times out of a hundred it is the quarantine tag, and the fix is
  the xattr command.

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
