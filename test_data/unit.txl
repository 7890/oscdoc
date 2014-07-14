/-this is a txl file
/-see https://github.com/7890/txl
/-
/-cat thisfile.txl | txl2xml > thisfile.xml
/-oscdoc thisfile.xml /tmp

//see https://github.com/7890/oschema
//see https://github.com/7890/oscdoc

osc_unit::
format_version 1.0

=meta
.name a_prog
.uri http://unique.uri/for/that/prog/ending_with_slash/
.doc_origin http://where.to/?find=this&xml_file
.url http://a.b
.url http://c.d
..//end meta

=doc
.h2 a_prog - doing this and that
.p how it works

=div
class ascii
.pre \\
|
| << >>  :o)
| \
|  \
|   \
|
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

=message_in
pattern /sub/*
typetag *
uri http://kind.of/namespace/for_semantics/y/
doc_origin http://fetch.it/here.xml
.desc reuse already defined aspect, sorting in below /sub

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

