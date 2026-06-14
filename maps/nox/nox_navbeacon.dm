// Nox patrol beacons.


//Arrival Shuttle Hallway
/obj/machinery/navbeacon/nox/ARRIVAL1
	location = "ARRIVAL1"
	codes = list("patrol" = 1, "next_patrol" = "ARRIVAL2")

/obj/machinery/navbeacon/nox/ARRIVAL2
	location = "ARRIVAL2"
	codes = list("patrol" = 1, "next_patrol" = "ARRIVAL3")

/obj/machinery/navbeacon/nox/ARRIVAL3
	location = "ARRIVAL3"
	codes = list("patrol" = 1, "next_patrol" = "ARRIVAL4")

/obj/machinery/navbeacon/nox/ARRIVAL4
	location = "ARRIVAL4"
	codes = list("patrol" = 1, "next_patrol" = "PORT2")


//Port Primary Hallway - Checkpoint
/obj/machinery/navbeacon/nox/PORT1
	location = "PORT1"
	codes = list("patrol" = 1, "next_patrol" = "ARRIVAL1")

/obj/machinery/navbeacon/nox/PORT2
	location = "PORT2"
	codes = list("patrol" = 1, "next_patrol" = "PORT3")

/obj/machinery/navbeacon/nox/PORT3
	location = "PORT3"
	codes = list("patrol" = 1, "next_patrol" = "CARGO")


//Central Primary Hallway (five) - Cargo
/obj/machinery/navbeacon/nox/CARGO
	location = "CARGO"
	codes = list("patrol" = 1, "next_patrol" = "HOP1")


//Central Primary Hallway (fore) - HoP
/obj/machinery/navbeacon/nox/HOP1
	location = "HOP1"
	codes = list("patrol" = 1, "next_patrol" = "ENG")

/obj/machinery/navbeacon/nox/HOP2
	location = "HOP2"
	codes = list("patrol" = 1, "next_patrol" = "AI")


//Aft Primary Hallway - Engineering
/obj/machinery/navbeacon/nox/ENG
	location = "ENG"
	codes = list("patrol" = 1, "next_patrol" = "HOP2")


//Central Primary Hallway (three) - AI
/obj/machinery/navbeacon/nox/AI
	location = "AI"
	codes = list("patrol" = 1, "next_patrol" = "PND")


//Central Primary Hallway (six) - R&D
/obj/machinery/navbeacon/nox/PND
	location = "PND"
	codes = list("patrol" = 1, "next_patrol" = "ROBOTIST")


//Central Primary Hallway (two) - Robotist
/obj/machinery/navbeacon/nox/ROBOTIST
	location = "ROBOTIST"
	codes = list("patrol" = 1, "next_patrol" = "FORE1")


//Fore Primary Hallway
/obj/machinery/navbeacon/nox/FORE1
	location = "FORE1"
	codes = list("patrol" = 1, "next_patrol" = "STAR")

/obj/machinery/navbeacon/nox/FORE2
	location = "FORE2"
	codes = list("patrol" = 1, "next_patrol" = "FORE_POD")

/obj/machinery/navbeacon/nox/FORE3
	location = "FORE3"
	codes = list("patrol" = 1, "next_patrol" = "VAULT1")


//Starboard Primary Hallway - Checkpoint
/obj/machinery/navbeacon/nox/STAR
	location = "STAR"
	codes = list("patrol" = 1, "next_patrol" = "ESC")


//Escape Shuttle Hallway
/obj/machinery/navbeacon/nox/ESC
	location = "ESC"
	codes = list("patrol" = 1, "next_patrol" = "FORE2")


//Fore Primary Hallway - Pods
/obj/machinery/navbeacon/nox/FORE_POD
	location = "FORE_POD"
	codes = list("patrol" = 1, "next_patrol" = "FORE3")


//Security Lobby
/obj/machinery/navbeacon/nox/SEC1
	location = "SEC1"
	codes = list("patrol" = 1, "next_patrol" = "SEC2")

/obj/machinery/navbeacon/nox/SEC2
	location = "SEC2"
	codes = list("patrol" = 1, "next_patrol" = "SEC3")

/obj/machinery/navbeacon/nox/SEC3
	location = "SEC3"
	codes = list("patrol" = 1, "next_patrol" = "SEC4")

/obj/machinery/navbeacon/nox/SEC4
	location = "SEC4"
	codes = list("patrol" = 1, "next_patrol" = "SEC5")

/obj/machinery/navbeacon/nox/SEC5
	location = "SEC5"
	codes = list("patrol" = 1, "next_patrol" = "VAULT1")


//Central Primary Hallway (one) - Vault
/obj/machinery/navbeacon/nox/VAULT1
	location = "VAULT1"
	codes = list("patrol" = 1, "next_patrol" = "SEC1")

/obj/machinery/navbeacon/nox/VAULT2
	location = "VAULT2"
	codes = list("patrol" = 1, "next_patrol" = "PORT1")
