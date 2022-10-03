# SONICS
*Specialised Operations Notably Implemented in Csound*

The UDO files in this directory are a slimmed excerpt from the SONICS collection. The full collection will be made available in the future.
SONICS is a framework of frontends, Csound UDOs and PostgreSQL database functionality allowing for easier sound processing, sequencing and live performance.
The frontend components consist of elements using SDL, Qt and HTML, while audio engines can utilise Pyo, Puredata and Csound. Data is stored on disk and in databases (of which PostgreSQL, MySQL/MariaDB and SQLite are supported).
Only the Csound UDO and PostgreSQL database components are featured in the extract for Partial Emergence, and those are mainly limited to the required functionality for the installation but may have some reuse potential.

## Key concepts

### Sequencing and time
sequencing.udo contains opcodes to maintain a master clock on which other opcodes rely.


### Melodic progressions
sequencing_melodic.udo features a system of chord progression management based around set and stochastic rules.
The f-tables defined at the top of the file contain details of the current chord notes.

sequencing_melodic_persistence.udo deals with loading and saving chord progressions to/from disk or database.

sequencing_melodic_portamento.udo makes the current chord note frequencies available in f-tables with an applied portamento based on a time that can be set globally.


### Sound DB
sounddb.udo provides a way to load sounds to f-tables stored on disk and defined in the database. Sounds are allocated collections which can be of a regular or melodic type. Melodic sounds also have the corresponding MIDI note number stored in the database and thus can then be retrieved based on the requested note. Functions in the database handle the retrieval and calculation of the pitch ratio adjustment required to make the sound match the requested note. 

soundxdb.udo provides the same interface as sounddb.udo, but utilises a database extract to allow for offline sound retrieval.


### Bussing
bussing.udo provides stereo wrappers around chnset/chnget/chnmix opcodes to allow for easier bussing, and a default master bus which has a global amplitude control.


### Instruments
While SONICS is mainly a control framework, there are also extension opcodes which use the framework to provide audio processing and generation; the UDO files are prepended with *instrument_*

