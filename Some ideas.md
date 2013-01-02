Some ideas, in no particular order.
==========

# Gameplay ideas #

User level and stat information should be hidden; knowing your character's
numerical value for a given stat breaks the verisimilitude of the game, so
... hide it all.



# Stat storage and usage #

Different stats develop differently, so don't have them all tied to an
overarching character level.  Each stat should develop separately, and most
importantly, in a manner related to how it is used.

Internally, to avoid needing to track "experience points" for each stat, its
development can be tracked as a floating-point value, with the mantissa storing
how far towards the next point you are—applying the stat in practice is just a
floor operation away.

# A magic system #

Part of the system is a big system of overlapping/conflicting components
("elements", "forces", pick some terms.)  Casting a spell will involve stringing
together words and syllables—each of which is related to some domain of magic,
and multiple can exist in each domain (perhaps with different purposes).  The
number of syllables (and thus the complexity of a spell you can use) is dictated
by one of your magic scores (there are *at least* two, since the power of your
spells and the complexity are unrelated, or only somewhat related) and the
strength of the resulting spell is dictated by another.  I would think it handy
to have multiple different scores to track your character's powers in each type
of magic, as well.

# Meta-game syntax #

Since there is always a need to find out information about what your character
is carrying—and other such details—there will be a set of meta-game commands,
all generally of the form `(verb noun)`, such as `(list items)`.  There will be
more of these, certainly, but for the moment that's the only one I can think of.

# Ranging #

I had thought about this before, and in the context of combat I think it's a
good idea—even for other stuff, though.  Most of these MUDs are based around a
complete description of a room, before you've even started to act on the
information.  Instead, I'd suggest having a delineation of ranges: 0-2m being
very close, 3-4 being moderate range, 5-8 being far range, and 9-16 being very
long range (with anything outside of that being much more difficult to make
out/have limited ways of interacting with).  Basically, this provides a context
for combat and non-combat interactions; simple conversation is only intelligible
in close range, while shouts are intelligible through far range, and yells
through very long range—after all, you don't usually hear someone talking 16m
away.  Combat would have similar restrictions—outside of very long range, you're
not likely to see or hear an opponent, let alone have much to hit them with
(excepting some very powerful equipment, but we might come up with a "mêlée" and a
"distance" definition of ranging, especially since magical combat at a distance
could be excellent.)

David's very solid idea for ranging, at least in exploring rooms, is to have the
map set up as nodes in a graph, with spacing nodes between areas (and distance
decorations on the edges between nodes); this would result in a sense of space.
Combat, I think, would need to be handled differently.

# Code organization #

There's a few directions the organization of the code can go in:
- One Game module, with a separate interface module
- Modules separating out game infrastructure, player actions, interface, and
  other components.
  
Re-thinking this, the first one is a better idea, we'll just need to stick to
some namespace-ish conventions to keep the modules distinct.  Shame OCaml
doesn't have namespaces.

Now, here's where David claims we should use modules instead of the object
system; instead, I'm going to withhold judgement on which of the two I'd rather
use at the moment, and instead consider simply the necessary divisions of
constructs necessary, as that may in part dictate the choice of device.


# Arrangement of data constructs #

- Character
  * Playable Character
  * Non-player character (possibly divided into noncombatant and combatant)
- Item
  * Food
  * Good
  * Luxury
  * Tool
  * Offensive
    - Mêlée weapon
    - Ranged weapon
  * Defensive
    - Armour
    - Shield
  * Preparation (alchemical, etc.)
    - Buff
    - Debuff
    - Healing
    - Attacking
    - Miscellaneous (most difficult to determine)
- Some unit of map space, which needs to be worked out in more detail.

# Spell structure #

We've talked about spells being formed out of syllables and words; there needs
to be some sort of pattern to this.

There's a few components to consider:
- Strength of spells
- Spell effects
  * Number of effects (elements) of a spell
  * Strength of each effect (element)
  * Contradictory effects/elements—how well can they be combined?
- Failure possibility? (I would think there's lower limits on when a spell might
  fail; someone with a great enough control of magic isn't likely to flub a
  single-element spell.)

## Magic stats ##

I've been considering how we can split up the stats applied to magic; the most
basic division is between strength and control, but I think there needs to be a
resilience/magical defence stat.  In that case, there would be the following:
- Magical Strength: Enforces how powerful a spell will be, in general (with a
  floor, which varies with the level of strength.)
- Magical Control: Defines how many components of a spell can be combined, as
  well as how "variable" the components are; a spell which combines multiple
  contradictory or at least generally hard-to-relate components will require far
  more control than one which uses only those from one genre.
- Magical Defence: How well you survive against others' spells.

# Wound code #

As of how we have it now, wounds will work like so:

    (* Defines the levels of damage that can be taken *)
    type severity = Minor | Serious | Critical
    (* Collects wounds into different categories *)
    let minor, serious, critical = List.fold_left (fun (a,b,c) (sev, _) -> match
    sev with Minor -> (a+1,b,c) | Serious -> (a,b+1,c) | Critical -> (a,b,c+1))
    (0,0,0) wounds
    (* Removes wounds which have healed *)
    let heal character = character.wounds <- List.filter (fun (_, t) -> t <> 0)
    (List.map (fun (w, t) -> w, t - 1) character.wounds)

Some of this should be implemented in a Wound module, with the following type
definition: `type wounds.t = (severity * int) list`
    
# Implementing traits #

Traits fall into one of three categories: Attributes, physical and mental
characteristics; Skills, related to crafting and other non-combat activities;
and Affinities, related to branches of magic. (Later, an expansion of this will
include weapons.)

Each of the categories, then, can be defined as an enumerated type, and any
function related to it can use the variant type in order to avoid specifying too
much.
