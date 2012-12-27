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
