/-this is a txl file
/-see https://github.com/7890/txl
/-
/-cat thisfile.txl | txl2xml > thisfile.xml
/-oscdoc thisfile.xml /tmp

//see https://github.com/7890/oschema
//see https://github.com/7890/oscdoc

osc_unit::
format_version 1.1

=meta
.name a_prog
.uri http://lowres.ch/osc/units/a_prog/
.doc_origin http://lowres.ch/oscdoc/unit.xml
..//end meta

=doc
.h2 a_prog - doing this and that
.p how it works

=div
class ascii
.pre \\

 << >>  :o)
 \
  \
   \

http://en.wikipedia.org/wiki/Monospace_font#Use_in_ASCII_art
┌─┐ ┌┬┐ [example of line drawing characters]
│ │ ├┼┤ [requires fixed-width, especially with spaces]
└─┘ └┴┘ 

\\.
.*

//first message_in

=message_in
pattern /sub/*
typetag *
=aspect
.uri http://lowres.ch/osc/aspects/example_ascpect2/
.doc_origin http://lowres.ch/oscdoc/aspect2.xml
.xpath //message_in[not(@pattern='/non_use')]
..
.desc reuse already defined aspect, sorting in below /sub
//params don't make sense here
//.param_i
//symbol aaa

.*

=message_in
pattern /*
typetag *
=aspect
//uri is optional
//.uri http://lowres.ch/osc/aspects/example_ascpect/
.doc_origin http://lowres.ch/oscdoc/aspect.xml
.xpath //message_in[not(@pattern='/non_use')]
..
.desc mixed sort-in

.*


=message_in
pattern /set/temperature
typetag f
.desc An example message description

=param_f
symbol temperature
units celsius degrees

=range_min_inf
min -273.15
lmin [

=hints
.point 0 Fahrenheit
symbol zero_f
value -17.78

.point Freezing/melting point of water
symbol zero_c
value 0

.point Average body temperature
symbol body
value 36.8

.point Boiling point of water
symbol boil
value 100

.*

//===============================

=message_out
pattern /*
typetag *
=aspect
.uri http://lowres.ch/osc/aspects/example_ascpect/
.doc_origin http://lowres.ch/oscdoc/aspect.xml
.xpath //message_out
..
.desc mixed sort-in

.*

=message_out
pattern /switch
typetag ii

=condition
type on_change
.desc This message is sent whenever the switch status changed
..

=target
type configured
proto UDP
..

=param_i
symbol switch_number

=range_min_max
min 1
max 3

=grid
.point Turbo Boost
symbol s1
value 1

.point Light
symbol s2
value 2

.point Emergency
symbol s2
value 3

_message_out

=param_i
symbol switch_status

=range_min_max
min 0
max 1

=grid
.point Off
symbol off
value 0

.point On
symbol on
value 1

.*

=message_out
pattern /*/*/that
typetag s
.desc dynamically built message path, following rule x
=param_s
symbol name
max_length 8

//close document
::

