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
