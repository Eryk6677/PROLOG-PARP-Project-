/* Projekt, by Eryk Wrzosek, Adam Górski, Andrzej Sawicki. */

:- dynamic i_am_at/1, at/2, holding/1, strength/1, agility/1, health/1, skill_points/1, door_closed/4, in_fight/1, war1_health/1, war2_health/1, mag_health/1, alive/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)), retractall(strength(_)), retractall(health(_)), retractall(agility(_)), retractall(skill_points(_)), retractall(door_closed(_,_,_,_)), retractall(in_fight(_)), retractall(war1_health(_)), retractall(war2_health(_)), retractall(mag_health(_)).

clear :- tty_clear.

/* State of the game */

in_fight(0).

/* Part concerning the skills */

strength(5).
agility(5).
health(10).
skill_points(5).

add_strength :-
        skill_points(Points),
        Points =:= 0 -> write('You have no skill points left!') ; 

        strength(X),
        retract(strength(X)),
        NewX is X+1,
        write('Current Strength value: '), write(NewX), nl,
        assert(strength(NewX)),
        sub_skill_points.

add_agility :-
        skill_points(Points),
        Points =:= 0 -> write('You have no skill points left!') ; 

        agility(X),
        retract(agility(X)),
        NewX is X+1,
        write('Current Agility value: '), write(NewX), nl,
        assert(agility(NewX)),
        sub_skill_points.

add_health :-
        skill_points(Points),
        Points =:= 0 -> write('You have no skill points left!') ; 
        
        health(X),
        retract(health(X)),
        NewX is X+1,
        write('Current Health value: '), write(NewX), nl,
        assert(health(NewX)),
        sub_skill_points.

sub_skill_points :-
        skill_points(Y),
        retract(skill_points(Y)),
        NewY is Y-1,
        assert(skill_points(NewY)),
        write('Skill points left: '), write(NewY), nl.

add_skill_points :-
        skill_points(Y),
        retract(skill_points(Y)),
        NewY is Y+5,
        assert(skill_points(NewY)),
        write('Skill points left: '), write(NewY), nl.
        

/* Current location */

i_am_at(tower).

/* This part describes the paths connecting all the locations */

path(tower, s, armoury).
path(armoury, n, tower).

path(tunnel1, w, tunnel2).
path(tunnel2, e, tunnel1).

path(tunnel2, w, tunnel3).
path(tunnel3, e, tunnel2).

path(tunnel3, w, fork).
path(fork, e, tunnel3).

path(fork, n, fight_room).
path(fork, s, silent_room).

path(fight_room, s, fork).
path(silent_room, n, fork).

path(fight_room, w, tunnel4).
path(tunnel4, e, fight_room).

path(silent_room, w, tunnel5).
path(tunnel5, e, silent_room).

path(tunnel4, s, fork2).
path(fork2, n, tunnel4).

path(tunnel5, n, fork2).
path(fork2, s, tunnel5).

path(fork2, w, tunnel6).
path(tunnel6, e, fork2).

path(tunnel6, w, ending).

at(sword, armoury).
at(torch, tower).
at(artifact, silent_room).

door_closed(door, tower, e, outside).
door_closed(hatch, armoury, d, tunnel1).

/* This part descrives the state of the enemies */

war1_health(8).
war2_health(10).
mag_health(6).

alive(warrior1).
alive(warrior2).
alive(mage).

/* These rules describe how to pick up an object. Object you pick up goes straignt to inventory*/

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(at(X, inventory)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see such thing here.'),
        nl.

/* These rules describe how to take an object from your inventory, currently held object is put back into inventory */

use(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

use(X) :-
        holding(Old) ->
        assert(at(Old, inventory)),
        retract(holding(Old)),
        at(X, inventory),
        retract(at(X, inventory)),
        assert(holding(X)),
        write('OK.'),
        !, nl ;
        retract(at(X, inventory)),
        assert(holding(X)),
        write('OK.'),
        !, nl.

use(_) :-
        write('You don''t have that in inventory.'),
        nl.

/* These rules describe how to put down an object that's in your hand. */

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.

/* These rules describe the insides of your inventory. */

inventory :- notice_objects_at_inventory(inventory).

i :- inventory.

notice_objects_at_inventory(Inv) :-
        at(X, Inv),
        write('There is a '), write(X), write(' in your inventory.'), nl,
        fail.

notice_objects_at_inventory(_).

/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).

d :- go(d).

u :- go(u).

/* This rule tells how to move in a given direction. */

go(Direction) :-
        in_fight(State),
        State =:= 1 -> write('You can''t go anywhere during a fight!'), ! ;

        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :- write('You can''t go that way.').

/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.

/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).

/* This rule allows you to open doors and hatches */

open(X) :-
        i_am_at(Place),
        retract(door_closed(X, Place, Direction, NewPlace)),
        write('You opened the door.'), nl,
        assert(path(Place, Direction, NewPlace)),
        nl, describe(Place),
        !, nl.

open(_) :-
        write('I can''t open such thing!'),
        nl.

/* These rules describe the fighting system */

/* WARRIOR 1 */
attack :-
        in_fight(State),
        State =:= 0 -> write('You are not in a fight.'), !.

attack :-
        alive(warrior1),
        i_am_at(tunnel3),
        holding(sword),

        strength(Str),
        random_between(3, 4, Dmg),
        Damage is round(Str/3)+Dmg,

        war1_health(X),
        retract(war1_health(X)),
        NewX is X-Damage,
        assert(war1_health(NewX)),

        agility(Ag),
        random_between(2, 5, Dmg2),
        Avoid is round(Ag/3),
        health(H),
        retract(health(H)),
        NewH is H-Dmg2+Avoid,
        assert(health(NewH)),

        outcome1,
        !, nl.

attack :-
        alive(warrior1),
        i_am_at(tunnel3),

        strength(Str),
        random_between(0, 2, Dmg),
        Damage is round(Str/3)+Dmg,

        war1_health(X),
        retract(war1_health(X)),
        NewX is X-Damage,
        assert(war1_health(NewX)),

        agility(Ag),
        random_between(2, 4, Dmg2),
        Avoid is round(Ag/3),
        health(H),
        retract(health(H)),
        NewH is H-Dmg2+Avoid,
        assert(health(NewH)),

        outcome1,
        !, nl.

/* MAGE */
attack :-
        alive(mage),
        i_am_at(fight_room),
        holding(sword),

        strength(Str),
        random_between(3, 4, Dmg),
        Damage is round(Str/3)+Dmg,

        mag_health(X),
        retract(mag_health(X)),
        NewX is X-Damage,
        assert(mag_health(NewX)),

        random_between(2, 3, Dmg2),
        health(H),
        retract(health(H)),
        NewH is H-Dmg2,
        assert(health(NewH)),

        outcome2,
        !, nl.

attack :-
        alive(mage),
        i_am_at(fight_room),

        strength(Str),
        random_between(0, 2, Dmg),
        Damage is round(Str/3)+Dmg,

        mag_health(X),
        retract(mag_health(X)),
        NewX is X-Damage,
        assert(mag_health(NewX)),

        random_between(2, 4, Dmg2),
        health(H),
        retract(health(H)),
        NewH is H-Dmg2,
        assert(health(NewH)),

        outcome2,
        !, nl.

/* WARRIOR 2 */
attack :-
        alive(warrior2),
        i_am_at(tunnel6),
        holding(sword),

        strength(Str),
        random_between(3, 4, Dmg),
        Damage is round(Str/3)+Dmg,

        war2_health(X),
        retract(war2_health(X)),
        NewX is X-Damage,
        assert(war2_health(NewX)),

        agility(Ag),
        random_between(2, 5, Dmg2),
        Avoid is round(Ag/3),
        health(H),
        retract(health(H)),
        NewH is H-Dmg2+Avoid,
        assert(health(NewH)),

        outcome3,
        !, nl.

attack :-
        alive(warrior2),
        i_am_at(tunnel6),

        strength(Str),
        random_between(0, 2, Dmg),
        Damage is round(Str/3)+Dmg,

        war2_health(X),
        retract(war2_health(X)),
        NewX is X-Damage,
        assert(war2_health(NewX)),

        agility(Ag),
        random_between(2, 5, Dmg2),
        Avoid is round(Ag/3),
        health(H),
        retract(health(H)),
        NewH is H-Dmg2+Avoid,
        assert(health(NewH)),

        outcome3,
        !, nl.

outcome1 :-
        health(My_h),
        My_h =< 0,
        write('You have been defeated!'), nl,
        die ;
        
        war1_health(En_h),
        En_h =< 0,
        retract(alive(warrior1)),
        write('You defeated the enemy!'), nl,
        describe(tunnel3), ! ;

        health(My_h),
        war1_health(En_h),
        write('After attack - Your Health: '), print(My_h), write(' Enemy Health: '), write(En_h), nl,
        true.

outcome2 :-
        health(My_h),
        My_h =< 0,
        write('You have been defeated!'), nl,
        die ;
        
        mag_health(En_h),
        En_h =< 0,
        retract(alive(mage)),
        write('You defeated the enemy!'), nl,
        write('You got 5 additional skill points from this fight! '), add_skill_points, nl,
        describe(fight_room), ! ;
        
        health(My_h),
        mag_health(En_h),
        write('After attack - Your Health: '), print(My_h), write(' Enemy Health: '), write(En_h), nl,
        true.

outcome3 :-
        health(My_h),
        My_h =< 0,
        write('You have been defeated!'), nl,
        die ;
        
        war2_health(En_h),
        En_h =< 0,
        retract(alive(warrior2)),
        write('You defeated the enemy!'), nl,
        describe(tunnel6), ! ;

        health(My_h),
        war2_health(En_h),
        write('After attack - Your Health: '), print(My_h), write(' Enemy Health: '), write(En_h), nl,
        true.

/* This rule tells how to die. */

die :-
        finish.

/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'), !,
        nl.

/* This rule just writes out stat-setting instructions. */

statInstructions :-
        write('Before the game starts, you have to choose your stats:'), nl,
        write('You can do that by using your 5 skill points that you can add to Strength, Agility or Health'), nl,
        write('To add a point to one category use command add_(name of the stat).'), nl,
        nl,
        write('After you are done, enter: start_game.'), nl,
        nl.

/* This rule just writes out game instructions. */

gameInstructions :-
        write('Enter commands using standard Prolog syntax.'), nl,
        nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('clear              -- to clean the prompt.'), nl,
        nl,
        write('Movement commands:'), nl,
        write('n.                 -- go north.'), nl,
        write('s.                 -- go south.'), nl,
        write('e.                 -- go east.'), nl,
        write('w.                 -- go west.'), nl,
        write('u.                 -- go up.'), nl,
        write('d.                 -- go down.'), nl,
        nl,
        write('Action commands:'), nl,
        write('look.              -- to look around you.'), nl,
        write('open(Doors)        -- to open closed doors.'), nl,
        write('inventory {i}      -- to check your inventory'), nl,
        write('take(Object).      -- to pick up an object, and put it into your inventory.'), nl,
        write('use(Object)        -- to grab an object from your inventory.'), nl,
        write('drop(Object).      -- to put down an Object you are currently holding.'), nl,
        write('attack(Enemy).     -- to attack an enemy with a weapon'), nl,
        nl.


/* This rules print out instructions, story and basic before game starts. */

start :- statInstructions.

start_game :-
        gameInstructions,
        story,
        look.

story :-
        write('---------- STORY ----------'), nl,
        write('The United Empire has been attacked by an evil horde of Ashurbanipal.'), nl,
        write('You are the last alive commander of one of the eastern defense towers.'), nl,
        write('Right now, you are left with only a small dagger as a last resort weapon.'), nl,
        write('You have to make it out of the besiged city and warn the Emperor.'), nl,
        nl.

/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(tower) :- 
        door_closed(door, tower, e, outside),
        write('You are in a surrounded defense tower.'), nl,
        write('From here you can go south and enter tower''s armoury.'), nl, 
        write('There is also the main door to the tower.'), nl,
        !.

describe(tower) :- 
        \+ door_closed(door, tower, e, outside),
        write('You opened the door of the surrounded tower,'), nl,
        write('all of the Ashurbanipal warriors ran inside and slaughtered you...'), nl,
        die.

describe(armoury) :-
        door_closed(hatch, armoury, d, tunnel1),
        write('You are in the armoury of this defense tower.'), nl,
        write('There is a closed hatch on the ground.'), nl,
        !.

describe(armoury) :-
        \+ door_closed(hatch, armoury, d, tunnel1),
        write('You are in the armoury of this tower.'), nl,
        write('The opened hatch shows a hidden tunnel,'), nl,
        write('but the drop is very big, you won''t be able to climb back up.'), nl.

describe(tunnel1) :-
        write('You are in a dark long tunnel.'), nl,
        write('Despite the war above, the tunnel is very silent.'), nl,
        write('There is no going back now,'), nl,
        write('you can only go towards west.'), nl.

describe(tunnel2) :- 
        write('The long tunnel goes on.'), nl,
        write('You can only go towards west.'), nl.

describe(tunnel3) :-
        alive(warrior1),
        retract(in_fight(_)),
        assert(in_fight(1)),
        write('You come across a Ashurbanipal warrior!'), nl,
        write('Now you have to fight!'), nl,
        !.
        
describe(tunnel3) :-
        \+ alive(warrior1),
        retract(in_fight(_)),
        assert(in_fight(0)),
        write('The warrior has been defeated'), nl,
        write('Now you can go further towards the west'), nl.

describe(fork) :-
        write('There is a fork in the road, '), nl,
        write('You now you can go south or north.'), nl.

describe(fight_room) :-
        alive(mage),
        retract(in_fight(_)),
        assert(in_fight(1)),
        write('You come across a Ashurbanipal mage!'), nl,
        write('Mage uses magic, so you can''t avoid his attacks!'), nl,
        write('Now you have to fight!'), nl,
        !.
        
describe(fight_room) :-
        \+ alive(mage),
        retract(in_fight(_)),
        assert(in_fight(0)),
        write('The mage has been defeated'), nl,
        write('Now you can go further towards the west'), nl.

describe(silent_room) :-
        write('Well, this is just another empty room...'), nl,
        write('You should just head west as previously.'), nl.

describe(tunnel4) :-
        write('You can feel it in your bones,'), nl,
        write('You are getting closer to the Emperor.'), nl,
        write('The tunnel now turns towards south.'), nl.

describe(tunnel5) :-
        write('This catacombs are getting cold, and empty,'), nl,
        write('Let''s head to the Emperor.'), nl,
        write('The tunnel now turns towards north.'), nl.

describe(fork2) :-
        write('There is another fork in the road, '), nl,
        write('You now you can go north, to the room where you could expect a mage,'), nl,
        write('you can go south, where is nothing special...,'), nl,
        write('or now you can go west, towards the main objective!,'), nl.

describe(tunnel6) :-
        alive(warrior2),
        retract(in_fight(_)),
        assert(in_fight(1)),
        write('You come across another Ashurbanipal warrior!'), nl,
        write('This seems to be the last fight before meeting with the Emperor.'), nl,
        !.
        
describe(tunnel6) :-
        \+ alive(warrior2),
        retract(in_fight(_)),
        assert(in_fight(0)),
        write('The warrior has been defeated'), nl,
        write('Now you can easily head straight to Emperors castle.'), nl.

describe(ending) :-
        at(artifact, inventory),
        write('--- CONGRATULATIONS! ---'), nl,
        write('You reached the exit from the catacombs,'), nl,
        write('lucky for you, they connect straight to the undergrounds'), nl,
        write('of Emperors castle. The strange artifact, that you found earlier'), nl,
        write('suddenly jumps out of your pocket, and shines with strong red light!'), nl,
        write('Power of the artifact turns all of the Ashurbanipals into dust!'), nl,
        write('You saved your entire City!!!'), nl,
        die, !.

describe(ending) :-
        holding(artifact),
        write('--- CONGRATULATIONS! ---'), nl,
        write('You reached the exit from the catacombs,'), nl,
        write('lucky for you, they connect straight to the undergrounds'), nl,
        write('of Emperors castle. The strange artifact, that you found earlier'), nl,
        write('suddenly jumps out of your hands, and shines with strong red light!'), nl,
        write('Power of the artifact turns all of the Ashurbanipals into dust!'), nl,
        write('You saved your entire City!!!'), nl,
        die, !.

describe(ending) :-
        write('--- CONGRATULATIONS! ---'), nl,
        write('You reached the exit from the catacombs,'), nl,
        write('lucky for you, they connect straight to the undergrounds'), nl,
        write('of Emperors castle. You saved the Emperor!!!'), nl,
        die.