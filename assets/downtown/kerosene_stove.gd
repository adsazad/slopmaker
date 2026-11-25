extends "res://props.gd"

const BLUE := Color("#3e666f")
const INK := Color("#313732")
const BRASS := Color("#a98a54")
const STEEL := Color("#858984")

func build() -> void:
	name = "Kerosene Cookstove"
	var tank := group(self,"Enamel fuel reservoir",Vector3.ZERO)
	cylinder(tank,"Pressed tank wall",Vector3(0,.074,0),.142,.090,BLUE)
	cylinder(tank,"Rounded tank shoulder",Vector3(0,.119,0),.134,.018,BLUE.lightened(.17))
	cylinder(tank,"Rolled lower seam",Vector3(0,.040,0),.147,.015,INK)
	for i in range(3):
		var angle := i*TAU/3
		cylinder(tank,"Rubber foot",Vector3(cos(angle)*.096,.014,sin(angle)*.096),.024,.028,INK)
	var data := box(tank,"Faded enamel badge",Vector3(0,.081,.143),Vector3(.12,.034,.008),INK)
	make_label(data,"PARAFFIN",Vector3(0,0,.005),31,.00065,Color("#d8c5a0"))
	var cap := group(tank,"Fuel filler cap",Vector3(-.084,.125,-.023))
	cylinder(cap,"Filler boss",Vector3(0,.008,0),.025,.019,BRASS.darkened(.16))
	cylinder(cap,"Knurled cap",Vector3(0,.022,0),.026,.016,BRASS)
	for i in range(16):
		var angle := i*TAU/16
		box(cap,"Cap edge rib",Vector3(cos(angle)*.025,.022,sin(angle)*.025),Vector3(.004,.013,.005),BRASS.lightened(.13)).rotation.y = -angle
	var burner := group(self,"Single burner",Vector3(0,.125,0))
	cylinder(burner,"Brass burner riser",Vector3(0,.044,0),.020,.087,BRASS)
	cylinder(burner,"Burner shoulder",Vector3(0,.089,0),.052,.019,BRASS.darkened(.15))
	cylinder(burner,"Blackened burner top",Vector3(0,.104,0),.041,.016,INK)
	for i in range(18):
		var angle := i*TAU/18
		cylinder(burner,"Ring dimple",Vector3(cos(angle)*.035,.113,sin(angle)*.035),.0032,.002,BRASS.darkened(.21))
	var knob := cylinder(self,"Control knob",Vector3(.107,.176,.079),.023,.025,INK)
	knob.rotation.z = PI/2
	cylinder(self,"Control stem",Vector3(.066,.176,.079),.007,.074,BRASS).rotation.z = PI/2
	box(knob,"Index mark",Vector3(.018,.013,0),Vector3(.005,.003,.007),Color("#d5ccb0"))
	var support := group(self,"Cast iron pan support",Vector3(0,.229,0))
	var ring := TorusMesh.new()
	ring.inner_radius = .093
	ring.outer_radius = .106
	mesh(support,"Support ring",ring,Vector3.ZERO,STEEL.darkened(.31))
	for i in range(3):
		var arm := group(support,"Pot support arm",Vector3.ZERO)
		arm.rotation.y = i*TAU/3
		box(arm,"Inner pot ledge",Vector3(0,.004,.076),Vector3(.023,.021,.059),INK)
		box(arm,"Steel upright",Vector3(0,-.051,.116),Vector3(.021,.115,.030),INK)
		box(arm,"Tank foot bracket",Vector3(0,-.101,.113),Vector3(.040,.009,.053),BRASS.darkened(.26))
