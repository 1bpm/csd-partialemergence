# Partial Emergence

Partial Emergence is an installation created as a submission for the [International Csound Conference 2022](https://www.csound.com/icsc2022/).
The abstract and description for the submission are below, followed by some more technical details and information on how to use the files yourself.

## Submission details

### Abstract
Elements considered devoid of musical content are inflated and extrapolated to a macroscopic consonance, while those thought of harmonically are condensed 
and distanced to present a microscopic coherence. Diminishing relationships with time present unexpected pitch, while the exaggeration of time evokes a 
liminal continuity. Points in time are clarified through distant inspection to be steps in pitch.

Sounds prescribed by their organic purity are used to examine these reactions and interactions: water being physically fundamental yields an atonal or 
tonality-ambiguous presence, while a metal idiophonic music box is clearly melodious, with a subtle presence of harmonic content.
Through binding to familiar scales and chords, these malleable components are subject to time and frequency reconstructions while retaining established 
characteristics which regulate the emergence of new permutations of musical sound.

### Description
Partial Emergence presents a lens through which elements considered devoid of musical content are inflated and extrapolated to yield a macroscopic consonance, 
and conversely aspects previously thought of harmonically are condensed and distanced to present a microscopic coherence. Diminishing relationships with time 
present often unexpected pitch, while the exaggeration of time evokes a liminal continuity - points in time are clarified through distant inspection to present 
steps in pitch.

These phenomena are presented through two central groups of sounds: water drops and movements presenting atonal or tonality-ambiguous elements, and clearly 
melodious components from a small idiophonic music box device. The choice of these is prescribed by their organic purity and disposition for transformative 
interaction in and against each other - water being physically fundamental, and the sound of the music box being relatedly pure with a subtle constitution of harmonics.

Through binding to familiar scales, chords, and anchoring notes, these malleable components are subject to granular and spectral manipulations while retaining 
established characteristics which regulate the emergence of new permutations of musical sound.
The sound generation and arrangement featured in Partial Emergence is wholly based in Csound, using a set of reusable user defined opcodes developed by the 
artist to enable sound manipulation among stochastic harmonic arrangement methods.

References to the audio files used are managed with a database which is accessed through a plugin opcode developed by the artist. The main audio sources include 
578 individual water drop sounds, 100 additional water movement sounds and 60 music box sounds.
Arrangement sections are defined, within which stochastic composition and sequencing is performed, with specific thematic detail for each. Section progression 
is defined by a continuation probability and thus evolves autonomously with no interaction.


### Author Biography
Richard Knight is a musician and data artist based in the UK. Known for his no-input mixer practice and computer music which bridges popular and experimental musics, 
Knight is motivated by the disruption of organic by electronic, familiar by unknown, and logic by absurdity.

Using spectral processing, data-driven practice and concatenative resynthesis among other techniques, Knight typically incorporates Csound to his studio workflow 
to create music that exists somewhere in between acousmatic and techno music.

[http://rk.1bpm.net/](http://rk.1bpm.net/)

[http://csound.1bpm.net/](http://csound.1bpm.net/)

[https://git.1bpm.net/](https://git.1bpm.net/)



## Technical details

### Overview
Partial Emergence uses a single entry point CSD which is [init.csd](init.csd). From there, files are included from the *include* and *sonics* directories.
Both contain globals and UDO definitions, with *include* containing files specific to the installation, and *sonics* containing a slim excerpt from the SONICS 
system developed by the author. More details on SONICS are included [in the relevant README.md file](sonics/README.md).

Structurally, the installation cycles among sections defined in [init.csd](init.csd) as *gisections[]*. This array contains a minimum/maximum possible duration 
and then a choice of two sections to move to when the current has completed. Which is chosen depends on a weighted random factor as explained within the comments.

The *sequencer_main* instrument runs continuously and keeps track of the section time, launching new sections appropriately. Each section has a subsequencer, 
defined in the [include/sequence_sections.inc](include/sequence_sections.inc) file. Section subsequencers are named *sequencer_s%d* where %d is the section 
index according to *gisections[]*.
Each subsequencer schedules instruments relevant to the section and may also contain additional stochastic variation.

All instruments are defined in the files in the *include* directory prefixed with *instruments_*. Additionally, global effects are defined in 
[include/effects_global.inc](include/effects_global.inc)


### Sounds
Partial Emergence uses two groups of sounds (water and idiophones), which have two subgroups (droplets, paddling and musicbox, kalimba).
The wave files are located in the *sounds* directory. Sound loading was handled [by database plugin opcodes](https://git.1bpm.net/csound-sqldb) 
utilising PostgreSQL; however for the public release a database extract is provided in the slightly unwieldy but functional [include/soundexport.xdb](include/soundexport.xdb).
The source database tables contain the sound group details, and also notes of the tuned sounds, in order to return the nearest sound in a group to 
a requested note. 
As the groups do not always cater for every available note, and some notes have multiple corresponding sounds available, database logic is used to 
determine the most appropriate sound and calculate the required pitch adjustment ratio. The extract in [include/soundexport.xdb](include/soundexport.xdb)
features a set of arrays and f-tables that mimic what the database would return. For each sound collection, *gixdb_pitchreference* stores a reference
for all possible MIDI notes (0 to 127) which is accessed by a collection specific offset held in *gixdb_pitchrefoffset*. The values returned from
*gixdb_pitchreference* then point to the upper and lower bounds in *gixdb_pitchnotes* and *gixdb_pitchadjust* which contain the index in *gisounddb*
and the pitch adjustment ratio required in order to match the requested note. This fulfillment of such a request is carried out by 
*sounddb_mel_nearestnote* in [sonics/soundxdb.udo](sonics/soundxdb.udo).


### Instruments
Instruments are broadly split into those that use the tuned idiophone parts, and those that use the untuned water droplets. Additionally there are some synthesis 
instruments, and also notably a number of hybrid approaches to tuning/detuning the source sounds, yielding to the installation concept (for example, using 
the *resony* and *pvsmorph* opcodes).


### Harmonic progressions
The [SONICS stochastic chord progression arrangement system](sonics/sequencing_melodic.udo) uses the definitions specified in files within the *progressions* directory.
These are f-table dumps created by ftsave.
