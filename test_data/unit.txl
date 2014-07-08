//this is a txl file
//see https://github.com/7890/txl
//
//cat thisfile.txl | txl2xml > thisfile.xml
//oscdoc thisfile.xml /tmp

osc_unit::
format_version 1.0

=meta
.name a_prog
.uri http://unique.uri/for/that/prog/ending_with_slash/
.doc_origin http://where.to/?find=this&xml_file
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

=message_out
pattern /button
typetag i

=condition
type on_change
.desc This message is sent whenever the button status changed
..

=target
type configured
proto UDP
..

=param_i
symbol button_status

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

//close document
::

