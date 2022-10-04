# SONICS
*Specialised Operations Notably Implemented in Csound*

The UDO files in this directory are a slimmed excerpt from the SONICS collection. The full collection will be made available in the future.
SONICS is a framework of frontends, Csound UDOs and PostgreSQL database functionality allowing for easier sound processing, sequencing and live performance.
The frontend components consist of elements using SDL, Qt and HTML, while audio engines can utilise Pyo, Puredata and Csound. Data is stored on disk and in 
databases (of which PostgreSQL, MySQL/MariaDB and SQLite are supported).
Only the Csound UDO and PostgreSQL database components are featured in the extract for Partial Emergence, and those are mainly limited to the required 
functionality for the installation but may have some reuse potential.

## Key concepts

### Sequencing and time
sequencing.udo contains opcodes to maintain a master clock on which other opcodes rely.


### Melodic progressions
sequencing_melodic.udo features a system of chord progression management based around set and stochastic rules.
The f-tables defined at the top of the file contain details of the current chord notes.

sequencing_melodic_persistence.udo deals with loading and saving chord progressions to/from disk or database.

sequencing_melodic_portamento.udo makes the current chord note frequencies available in f-tables with an applied portamento based on a time that can be 
set globally.


### Sound DB Extract
soundxdb.udo provides a way to manage sound collections specified in a database extract. The fundamental database access opcodes contained in sounddb.udo
are not included in this slim excerpt, as they rely on [database plugin opcodes](https://git.1bpm.net/csound-sqldb), but will be made available in the 
future. 
The SONICS database provides a way to export data and access with the same interface; the export opcodes are provided herein.
Sounds are allocated collections which can be of a regular or melodic type. Melodic sounds also have the corresponding MIDI note number stored in the 
database and thus can then be retrieved based on the requested note. Functions in the database handle the retrieval and calculation of the pitch ratio 
adjustment required to make the sound match the requested note. 

The extract in [../include/soundexport.xdb](../include/soundexport.xdb) features such a set of arrays and f-tables that mimic what the database would return. 
For each sound collection, *gixdb_pitchreference* stores a reference for all possible MIDI notes (0 to 127) which is accessed by a collection specific offset 
held in *gixdb_pitchrefoffset*. The values returned from *gixdb_pitchreference* then point to the upper and lower bounds in *gixdb_pitchnotes* and 
*gixdb_pitchadjust* which contain the index in *gisounddb* and the pitch adjustment ratio required in order to match the requested note. This fulfillment 
of such a request is carried out by *sounddb_mel_nearestnote* in [soundxdb.udo](soundxdb.udo).


### Bussing
bussing.udo provides stereo wrappers around chnset/chnget/chnmix opcodes to allow for easier bussing, and a default master bus which has a global amplitude 
control.


### Instruments
While SONICS is mainly a control framework, there are also extension opcodes which use the framework to provide audio processing and generation; the UDO 
files are prepended with *instrument_*

