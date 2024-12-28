For now, this README will just be a copy-paste of all the text in the file "notes.nt" (which is where I keep my notes on this project).
---
#### [12/20/24]
I'm starting work on a random Godot game, to avoid burning out on GraphX and just for fun! I'm currently implementing a GenericState and StateMachine in GDScript. All states will derive GenericState, which will have a Tick function that should be called on every physics tick. It also takes an integer argument called "current_tick" but if none is given, it takes Global.current_tick as its value. Global.current_tick is updated every physics tick and will count up to the project tickrate (in my case, 70), then reset to 0.

Also, GenericState's Tick function always returns an integer value, mimicking C++'s main function, so I can (hopefully) handle exceptions.

Okay, in order to handle switching States, here's my first idea:
	The StateMachine has its own Tick function that just handles the current State's Tick function. Either the State's Tick function or another function in State will return some value that both tells the StateMachine it's time to switch states, and which state to switch to. Perhaps I can even keep a "previous_state" value either in StateMachine or State (probably should be StateMachine)

First idea for the swapping states mechanic is to return a State; the StateMachine then checks if that returned State matches the current state. If the two match, nothing happens and we continue; however, if they do match, the current state is stored in a "previous_state" variable and the StateMachine switches to the returned State.

Also the Tick function having a "current_tick" argument is redundant since I have a global current_tick variable.

The system works! However, I had to make the return value ambiguous because you can't return a ChildState if the function is set to return a State. Which is weird, but I don't wanna spend an hour in the weeds of a simple syntax thing. The simple joys of high level scripting languages (which turn into sharp knives in your back down the road).

Ah, you can actually supply a child type instead of the expected parent, as long as you use the "as" keyword; for example: if the Tick function returns a State, but you want to change to a TestState, you would write "return TestState as State" and all would be well. I just hope that it doesn't slice the child class.

I don't think GDScript is actually capable of (or, rather, is designed to not allow) class slicing! Yippee (for now)!

It all seems to work so far!

Hmm, wait, states don't just change to one specific state; the state they switch to depends on the input stimuli. This will need some tweaking.

Maybe StateMachine will be a generic type/have a function that can be overwritten and that function will, depending on various inputs, switch states. The states themselves will have all the logic that... hmm...

Actually, I think I might abandon this state machine idea and swap to a different version more similar to that one state machine I saw and used to use (but probably a lot simpler and a bit more flexible).

I might forgo these examples and my original idea and keep things simple:
	Why not just give everyone some "get_state" or "get_movement_state" functions that will then compute what the current state should be instead of updating various state variables every tick?

Yeah because like, if an enemy wanted to check if the player is moving, for instance, the check would be something like, "hey is the player's movement_state equal to Player.MOVEMENT_STATES.MOVING?" which is just... fucking dumb. Instead, that kind of state could be for internal state machines (i.e: the player needs to know when it's moving up versus down) and actual state will be handled by functions first and variables second (specifically where functions would be overkill/the desired return value is too complex)

Idea!!:
	Could I make the gravity changer idea work by changing how I do movement and gravity? Instead of adding separate scalars to separate indices of the velocity vector, what if I multiplied/added scaled versions of changeable "orientation" vectors? I got this idea when I was reminded that Godot has a default "down" vector in the project settings; currently, gravity works by checking if the player is on the ground and lerping velocity[1] towards 0.0. However, if I instead only touched velocity once per tick and had it be affected by a normalized "movement" vector (scaled by speed variables either before or during this process), I could just change the orientation vectors used to create the normalized movement vector! Or something simpler, but still in that same idea.

#### [12/27/24]
Big idea!! You should be able to surprise enemies with gravity changes! This means that if enemies are not aware of you (and/or your abilities?) when you change gravity, they should not re-orient themselves (perhaps some enemy types can be more reactive and still re-orient themselves but not as well?). It could also affect enemy accuracy!

On this note: when gravity gets changed, it should affect the project gravity scalar and gravity direction vector in order to affect rigidbody props. This also means that however I decide to affect and calculate movement and gravity in the player and other actors, it should use the project gravity and gravity direction, and also perhaps their own "down" vector in cases where the two will not be the same (i.e: surprised by gravity change).

I want to use billboarded sprites for enemies in my game, like DOOM. This means I also want the sprite to change depending on how the player is viewing the actor. To do this, I'll need to write some code to get the angle the player is viewing the actor at and swap to the corresponding sprite.