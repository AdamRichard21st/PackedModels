/*
	Feel free to edit this model QC as needed.
	Good luck!

	Adam Richard.
*/

$modelname "weapons.mdl"
$cd ".\"
$cdtexture ".\textures"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$bodygroup "weapons" {
	blank
	studio "geometry/p228"
	blank
	studio "geometry/scout"
	studio "geometry/hegrenade"
	studio "geometry/xm1014"
	studio "geometry/c4"
	studio "geometry/mac10"
	studio "geometry/aug"
	studio "geometry/smokegrenade"
	studio "geometry/elite"
	studio "geometry/fiveseven"
	studio "geometry/ump45"
	studio "geometry/sg550"
	studio "geometry/galil"
	studio "geometry/famas"
	studio "geometry/usp"
	studio "geometry/glock18"
	studio "geometry/awp"
	studio "geometry/mp5navy"
	studio "geometry/m249"
	studio "geometry/m3"
	studio "geometry/m4a1"
	studio "geometry/tmp"
	studio "geometry/g3sg1" 
	studio "geometry/flashbang"
	studio "geometry/deagle"
	studio "geometry/sg552"
	studio "geometry/ak47"
	studio "geometry/knife"
	studio "geometry/p90"
}


// 1 attachment(s)
$attachment 0 "usp flash" 0.000000 0.000000 0.000000


// 1 animation sequence(s)
$sequence "player" "animations/player" fps 30 
$sequence "world" "animations/world" fps 30
