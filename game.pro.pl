/*
  This is a little adventure game.  There are three
  entities: you, a treasure, and an ogre.  There are
  six places: a valley, a path, a cliff, a fork, a maze,
  and a mountaintop.  Your goal is to get the treasure
  without being killed first.
*/

/*
  First, text descriptions of all the places in
  the game.

Modified by Destiny Gaines
*/

:- dynamic i_am_at/1, at/2.

description(valley,
  'You are in a pleasant valley, with a trail ahead.').
description(path,
  'You are on a path, with ravines on both sides.').
description(cliff,
  'You are teetering on the edge of a cliff.').
description(fork,
  'You are at a fork in the path.').
description(maze(_),
  'You are in a maze of twisty trails, all alike.').
description(gate,
  'You are at a gate. Looks like you need a key').
description(gate_entrance,
	    'Walking through the gate').
description(mountaintop,
  'You are on the mountaintop.').
description(meadow,
	    'You are by a meadow').


/*
  report prints the description of your current
  location.
*/
report :-
  at(you,X),
  description(X,Y),
  write(Y),
  nl.


/*
  These connect predicates establish the map.
  The meaning of connect(X,Dir,Y) is that if you
  are at X and you move in direction Dir, you
  get to Y.  Recognized directions are
  forward, right, and left.
*/
connect(valley,forward,path).
connect(path,backward,valley).
connect(path,right,meadow).
connect(meadow,backward,path).
connect(meadow,forward,cliff).
connect(path,left,cliff).
connect(path,forward,fork).
connect(fork,backward,path).
connect(fork,left,maze(0)).
connect(maze(0),backward,fork).
connect(fork,right,gate).
connect(gate,backward,fork).
connect(gate,forward,gate).
connect(gate2,forward,gate_entrance).
connect(gate_entrance,backward,gate2).
connect(gate_entrance,forward,mountaintop).

	/*I'm not adding backward function in Maze,
	it's a maze, find your way out*/

connect(maze(0),left,maze(1)).
connect(maze(0),right,maze(3)).
connect(maze(1),left,maze(0)).
connect(maze(1),right,maze(2)).
connect(maze(2),left,fork).
connect(maze(2),right,maze(0)).
connect(maze(3),left,maze(4)).
connect(maze(3),right,maze(4)).

/*
  move(Dir) moves you in direction Dir, then
  prints the description of your new location.
*/
move(Dir) :-
  at(you,Loc),
  connect(Loc,Dir,Next),
  retract(at(you,Loc)),
  assert(at(you,Next)),
  report,
  !.
/*
  But if the argument was not a legal direction,
  print an error message and don't move.
*/
move(_) :-
  write('That is not a legal move.\n'),
  report.

/*
  Shorthand for moves.
*/
forward :- move(forward).
left :- move(left).
right :- move(right).
backward:-move(backward).


/*
  If you and the ogre are at the same place, it
  kills you.
*/
ogre :-

  at(you,maze(4)),
  write('An ogre sucks your brain out through\n'),
  write('your eye sockets, and you die.\n'),
  retract(at(you,maze(4))),
  assert(at(you,done)),
  !.
ogre.
/*Running into the ogre while wearing the magic pants*/

ogre2:-
	at(you,maze(3)),
	at(magic_pants,in_hand),
	write('What''s this?! The magic pants arent ordinary \n'),
	write('magic pants! These are HAMMER pants!\n'),
	write('You challenged the ogre to a dance off, for your life.\n'),
	write('Of course, you win! Defeating the ogre and gaining his bride, \n'),
	write('Princess Fiona!'),
	retract(at(you,maze(3))),
	assert(at(you,done)),
	!.

/*
  But if you and the ogre are not in the same place,
  nothing happens.
*/
ogre2.


/* iF YOU ARE AT THE SAME PLACE AS TREASURE, YOU
    WIN*/


treasure :-
  at(treasure,Loc),
  at(you,Loc),
  write('There is a treasure here.\n'),
  write('Congratulations, you win!\n'),
  retract(at(you,Loc)),
  assert(at(you,done)),
  !.
/*
  But if you and the treasure are not in the same
  place, nothing happens.
*/
treasure.

/*if you are at the same place at the key,
	it tells you */

key:-
	at(key,Loc),
	at(you,Loc),
	write('There is a key here.'),
	!.

/*does nothing if you aren't there */

key.



/*If you are at the same palce as the magic pants*/
magic_pants:-
	at(magic_pants,Loc),
	at(you,Loc),
	write('Magic pants?! I wonder what these do!'),
	!.
/*you are nothing without the pants*/

magic_pants.


/*
  If you are at the cliff, you fall off and die.
*/
cliff :-
  at(you,cliff),
  write('You fall off and die.\n'),
  retract(at(you,cliff)),
  assert(at(you,done)),
  !.
/*
  But if you are not at the cliff nothing happens.
*/
cliff.

/*if you are at the gate with the key*/
gate:-
	at(you,gate),
	at(key, in_hand),
	retract(at(you,gate)),
	assert(at(you,gate2)),
	write('The gate is open'),
	nl.

gate.

/*if you walk through the gate with the key,
	you die*/

gate2:-
	at(you,gate_entrance),
	at(key, in_hand),
	write('You have been killed by lightning.'),
	retract(at(you, gate_entrance)),
	assert(at(you, done)),
	nl.
gate2.



/* How to take an object */

take(X):-
	at(X, in_hand),
	write('You''re already holding it!'),
	nl.

take(X):-
	at(you,Loc),
	at(X, Loc),
	retract(at(X, Loc)),
	assert(at(X, in_hand)),
	write('OK'),
	nl.

take(_):-
	write('I dont''t see it here.'),
	nl.

/* These rules describe how to put down an object. */

drop(X) :-
       at(X, in_hand),
       at(you,Loc),
       retract(at(X, in_hand)),
       assert(at(X, Loc)),
       write('OK.'),
       nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.






/*
  Main loop.  Stop if player won or lost.
*/
main :-
  at(you,done),
  write('Thanks for playing.\n'),
  !.
/*
  Main loop.  Not done, so get a move from the user
  and make it.  Then run all our special behaviors.
  Then repeat.
*/
main :-
  write('\nNext move -- '),
  read(Move),
  call(Move),
  ogre,
  treasure,
  cliff,
  gate,
  gate2,
  key,
  magic_pants,
  ogre2,
  main.

/*
  This is the starting point for the game.  We
  assert the initial conditions, print an initial
  report, then start the main loop.
*/
go :-
  retractall(at(_,_)), % clean up from previous runs
  assert(at(you,valley)),
  assert(at(ogre,maze(3))),
  assert(at(treasure,mountaintop)),
  assert(at(key,maze(2))),
  assert(at(magic_pants,meadow)),
  write('This is an adventure game. \n'),
  write('Legal moves are left, right, forward, or backward.\n'),
  write('To pick up items type ''take(x)". \n'),
  write('To drop items ''drop(x)''. \n'),
  write('End each move with a period.\n\n'),
  report,
  main.
























