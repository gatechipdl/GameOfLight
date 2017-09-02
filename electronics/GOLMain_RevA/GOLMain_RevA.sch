EESchema Schematic File Version 2
LIBS:GOLMain_RevA-rescue
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:myParts
LIBS:GOLMain_RevA-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "GOLMain"
Date "2017-03-23"
Rev "A"
Comp "Matthew Swarts"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ESP8266-12E U2
U 1 1 58B0E48D
P 4250 5925
F 0 "U2" H 4250 6375 60  0000 C CNN
F 1 "ESP8266-12E" H 4250 6275 60  0000 C CNN
F 2 "ESP8266:ESP-12E" H 4250 5925 60  0001 C CNN
F 3 "" H 4250 5925 60  0000 C CNN
	1    4250 5925
	1    0    0    -1  
$EndComp
$Comp
L LM1117-3.3-RESCUE-GOLMain_RevA U1
U 1 1 58B0E4BE
P 2700 1125
F 0 "U1" H 2800 875 50  0000 C CNN
F 1 "LM1117-3.3" H 2700 1375 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-223" H 2700 1125 50  0001 C CNN
F 3 "" H 2700 1125 50  0000 C CNN
	1    2700 1125
	1    0    0    -1  
$EndComp
$Comp
L 74LS165 U3
U 1 1 58B0E52D
P 5750 1750
F 0 "U3" H 5900 1700 50  0000 C CNN
F 1 "74LS165" H 5900 1500 50  0000 C CNN
F 2 "Housings_SOIC:SOIC-16_3.9x9.9mm_Pitch1.27mm" H 5750 1750 50  0001 C CNN
F 3 "" H 5750 1750 50  0000 C CNN
	1    5750 1750
	1    0    0    -1  
$EndComp
Text GLabel 4975 5725 2    60   Input ~ 0
TX33
Text GLabel 4975 5875 2    60   Input ~ 0
RX33
Text GLabel 1075 1125 0    60   Input ~ 0
V12
Text GLabel 3425 1125 2    60   Input ~ 0
V33
Text GLabel 2700 1650 3    60   Input ~ 0
GND
$Comp
L C C2
U 1 1 58B0EB4A
P 3075 1325
F 0 "C2" H 3100 1425 50  0000 L CNN
F 1 "10uF" H 3100 1225 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 3113 1175 50  0001 C CNN
F 3 "" H 3075 1325 50  0000 C CNN
	1    3075 1325
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 58B0EB86
P 2300 1325
F 0 "C1" H 2325 1425 50  0000 L CNN
F 1 "10uF" H 2325 1225 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 2338 1175 50  0001 C CNN
F 3 "" H 2300 1325 50  0000 C CNN
	1    2300 1325
	1    0    0    -1  
$EndComp
Text GLabel 5050 2100 0    60   Input ~ 0
ID_LATCH
$Comp
L R R9
U 1 1 58B0F123
P 4900 2350
F 0 "R9" V 4980 2350 50  0000 C CNN
F 1 "10K" V 4900 2350 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 4830 2350 50  0001 C CNN
F 3 "" H 4900 2350 50  0000 C CNN
	1    4900 2350
	0    1    1    0   
$EndComp
Text GLabel 4750 2350 0    60   Input ~ 0
GND
Text GLabel 5050 1150 0    60   Input ~ 0
ID_DATA
Text GLabel 5050 2250 0    60   Input ~ 0
ID_CLOCK
Text GLabel 4650 1250 0    60   Input ~ 0
ID_0
Text GLabel 4650 1350 0    60   Input ~ 0
ID_1
Text GLabel 4650 1450 0    60   Input ~ 0
ID_2
Text GLabel 4650 1550 0    60   Input ~ 0
ID_3
Text GLabel 4650 1650 0    60   Input ~ 0
ID_4
Text GLabel 4650 1750 0    60   Input ~ 0
ID_5
Text GLabel 4650 1850 0    60   Input ~ 0
ID_6
Text GLabel 4650 1950 0    60   Input ~ 0
ID_7
Text GLabel 3375 1000 2    60   Input ~ 0
VCC
Text GLabel 3525 6775 0    60   Input ~ 0
V33
Text GLabel 4975 6775 2    60   Input ~ 0
GND
Text GLabel 8950 2725 0    60   Input ~ 0
LED_DATA
Text GLabel 8950 2825 0    60   Input ~ 0
LED_CLOCK
Text GLabel 9250 2625 0    60   Input ~ 0
GND
Text GLabel 4975 6175 2    60   Input ~ 0
SDA
Text GLabel 4975 6025 2    60   Input ~ 0
SCL
Text GLabel 3525 6325 0    60   Input ~ 0
READER1
Text GLabel 3525 6175 0    60   Input ~ 0
READER2
Text GLabel 1550 7050 2    60   Input ~ 0
ID_LATCH
Text GLabel 1550 7175 2    60   Input ~ 0
ID_CLOCK
Text GLabel 3525 6475 0    60   Input ~ 0
ID_DATA
$Comp
L R R11
U 1 1 58B18FD5
P 3375 6025
F 0 "R11" V 3455 6025 50  0000 C CNN
F 1 "10K" V 3375 6025 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 3305 6025 50  0001 C CNN
F 3 "" H 3375 6025 50  0000 C CNN
	1    3375 6025
	0    1    1    0   
$EndComp
Text GLabel 3225 6025 0    60   Input ~ 0
V33
$Comp
L R R12
U 1 1 58B19516
P 1525 6350
F 0 "R12" V 1605 6350 50  0000 C CNN
F 1 "10K" V 1525 6350 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 1455 6350 50  0001 C CNN
F 3 "" H 1525 6350 50  0000 C CNN
	1    1525 6350
	-1   0    0    1   
$EndComp
Text GLabel 1525 6500 3    60   Input ~ 0
GND
$Comp
L R R10
U 1 1 58B1964A
P 1250 4375
F 0 "R10" V 1330 4375 50  0000 C CNN
F 1 "10K" V 1250 4375 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 1180 4375 50  0001 C CNN
F 3 "" H 1250 4375 50  0000 C CNN
	1    1250 4375
	-1   0    0    1   
$EndComp
Text GLabel 1250 4225 1    60   Input ~ 0
V33
$Comp
L +3.3V #PWR01
U 1 1 58B19A2F
P 3075 950
F 0 "#PWR01" H 3075 800 50  0001 C CNN
F 1 "+3.3V" H 3075 1090 50  0000 C CNN
F 2 "" H 3075 950 50  0000 C CNN
F 3 "" H 3075 950 50  0000 C CNN
	1    3075 950 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 58B19D95
P 2525 1675
F 0 "#PWR02" H 2525 1425 50  0001 C CNN
F 1 "GND" H 2525 1525 50  0000 C CNN
F 2 "" H 2525 1675 50  0000 C CNN
F 3 "" H 2525 1675 50  0000 C CNN
	1    2525 1675
	1    0    0    -1  
$EndComp
$Comp
L +12V #PWR03
U 1 1 58B19DE8
P 2300 1025
F 0 "#PWR03" H 2300 875 50  0001 C CNN
F 1 "+12V" H 2300 1165 50  0000 C CNN
F 2 "" H 2300 1025 50  0000 C CNN
F 3 "" H 2300 1025 50  0000 C CNN
	1    2300 1025
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR04
U 1 1 58B1A133
P 3275 950
F 0 "#PWR04" H 3275 800 50  0001 C CNN
F 1 "VCC" H 3275 1100 50  0000 C CNN
F 2 "" H 3275 950 50  0000 C CNN
F 3 "" H 3275 950 50  0000 C CNN
	1    3275 950 
	1    0    0    -1  
$EndComp
Text GLabel 1850 4925 3    60   Input ~ 0
GND
Text GLabel 1250 4925 3    60   Input ~ 0
GND
$Comp
L BSS138-RESCUE-GOLMain_RevA Q1
U 1 1 58B1C347
P 7650 2375
F 0 "Q1" H 7850 2450 50  0000 L CNN
F 1 "BSS138" H 7850 2375 50  0000 L CNN
F 2 "TO_SOT_Packages_SMD:SOT-23" H 7850 2300 50  0001 L CIN
F 3 "" H 7650 2375 50  0000 L CNN
	1    7650 2375
	0    1    1    0   
$EndComp
Text GLabel 7925 2475 2    60   Input ~ 0
LED_CLOCK
Text GLabel 7925 3475 2    60   Input ~ 0
LED_DATA
Text GLabel 7375 2475 0    60   Input ~ 0
SCL
Text GLabel 7375 3475 0    60   Input ~ 0
SDA
$Comp
L R R13
U 1 1 58B1CE8C
P 7400 2275
F 0 "R13" V 7480 2275 50  0000 C CNN
F 1 "1K" V 7400 2275 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 7330 2275 50  0001 C CNN
F 3 "" H 7400 2275 50  0000 C CNN
	1    7400 2275
	-1   0    0    1   
$EndComp
$Comp
L R R15
U 1 1 58B1CF07
P 7900 2275
F 0 "R15" V 7980 2275 50  0000 C CNN
F 1 "1K" V 7900 2275 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 7830 2275 50  0001 C CNN
F 3 "" H 7900 2275 50  0000 C CNN
	1    7900 2275
	-1   0    0    1   
$EndComp
Text GLabel 7400 2075 1    60   Input ~ 0
V33
Text GLabel 7900 2125 1    60   Input ~ 0
V50
$Comp
L BSS138-RESCUE-GOLMain_RevA Q2
U 1 1 58B1DEC3
P 7650 3375
F 0 "Q2" H 7850 3450 50  0000 L CNN
F 1 "BSS138" H 7850 3375 50  0000 L CNN
F 2 "TO_SOT_Packages_SMD:SOT-23" H 7850 3300 50  0001 L CIN
F 3 "" H 7650 3375 50  0000 L CNN
	1    7650 3375
	0    1    1    0   
$EndComp
$Comp
L R R14
U 1 1 58B1DEC9
P 7400 3275
F 0 "R14" V 7480 3275 50  0000 C CNN
F 1 "1K" V 7400 3275 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 7330 3275 50  0001 C CNN
F 3 "" H 7400 3275 50  0000 C CNN
	1    7400 3275
	-1   0    0    1   
$EndComp
$Comp
L R R16
U 1 1 58B1DECF
P 7900 3275
F 0 "R16" V 7980 3275 50  0000 C CNN
F 1 "1K" V 7900 3275 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 7830 3275 50  0001 C CNN
F 3 "" H 7900 3275 50  0000 C CNN
	1    7900 3275
	-1   0    0    1   
$EndComp
Text GLabel 7400 3075 1    60   Input ~ 0
V33
Text GLabel 7900 3125 1    60   Input ~ 0
V50
$Comp
L CP1 C3
U 1 1 58B1EE60
P 1800 1325
F 0 "C3" H 1825 1425 50  0000 L CNN
F 1 "100uF 50V" H 1825 1225 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L13_P3.8" H 1800 1325 50  0001 C CNN
F 3 "" H 1800 1325 50  0000 C CNN
	1    1800 1325
	1    0    0    -1  
$EndComp
$Comp
L SP3485CN U4
U 1 1 58B21144
P 7950 5250
F 0 "U4" H 7650 5600 50  0000 L CNN
F 1 "SP3485CN" H 8050 5600 50  0000 L CNN
F 2 "Power_Integrations:SO-8" H 7950 5250 50  0000 C CIN
F 3 "" H 7950 5250 50  0000 C CNN
	1    7950 5250
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X04 P5
U 1 1 58C2BBCA
P 1525 3500
F 0 "P5" H 1525 3750 50  0000 C CNN
F 1 "CONN_MAIN1" V 1625 3500 50  0000 C CNN
F 2 "Connect:AK300-4" H 1525 3500 50  0001 C CNN
F 3 "" H 1525 3500 50  0000 C CNN
	1    1525 3500
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X04 P6
U 1 1 58C2BC53
P 2500 3475
F 0 "P6" H 2500 3725 50  0000 C CNN
F 1 "CONN_MAIN2" V 2600 3475 50  0000 C CNN
F 2 "Connect:AK300-4" H 2500 3475 50  0001 C CNN
F 3 "" H 2500 3475 50  0000 C CNN
	1    2500 3475
	1    0    0    -1  
$EndComp
Text GLabel 1325 3350 0    60   Input ~ 0
GND
Text GLabel 2300 3325 0    60   Input ~ 0
GND
Text GLabel 1325 3650 0    60   Input ~ 0
V12
Text GLabel 2300 3625 0    60   Input ~ 0
V12
$Comp
L CP1 C4
U 1 1 58C2F64D
P 1325 1325
F 0 "C4" H 1350 1425 50  0000 L CNN
F 1 "100uF 50V" H 1350 1225 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L13_P3.8" H 1325 1325 50  0001 C CNN
F 3 "" H 1325 1325 50  0000 C CNN
	1    1325 1325
	1    0    0    -1  
$EndComp
Text GLabel 1325 3450 0    60   Input ~ 0
A
Text GLabel 1325 3550 0    60   Input ~ 0
B
Text GLabel 2300 3425 0    60   Input ~ 0
A
Text GLabel 2300 3525 0    60   Input ~ 0
B
Text GLabel 8350 5150 2    60   Input ~ 0
A
Text GLabel 8350 5350 2    60   Input ~ 0
B
Text GLabel 7950 4850 1    60   Input ~ 0
V33
$Comp
L BSS138-RESCUE-GOLMain_RevA Q3
U 1 1 58C34185
P 10350 2850
F 0 "Q3" H 10550 2925 50  0000 L CNN
F 1 "BSS138" H 10550 2850 50  0000 L CNN
F 2 "TO_SOT_Packages_SMD:SOT-23" H 10550 2775 50  0001 L CIN
F 3 "" H 10350 2850 50  0000 L CNN
	1    10350 2850
	0    1    1    0   
$EndComp
$Comp
L R R17
U 1 1 58C3418D
P 10100 2750
F 0 "R17" V 10180 2750 50  0000 C CNN
F 1 "10K" V 10100 2750 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 10030 2750 50  0001 C CNN
F 3 "" H 10100 2750 50  0000 C CNN
	1    10100 2750
	-1   0    0    1   
$EndComp
$Comp
L R R19
U 1 1 58C34193
P 10600 2750
F 0 "R19" V 10680 2750 50  0000 C CNN
F 1 "10K" V 10600 2750 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 10530 2750 50  0001 C CNN
F 3 "" H 10600 2750 50  0000 C CNN
	1    10600 2750
	-1   0    0    1   
$EndComp
Text GLabel 10100 2550 1    60   Input ~ 0
V33
Text GLabel 10600 2600 1    60   Input ~ 0
V50
Text GLabel 10075 2950 0    60   Input ~ 0
TX33
Text GLabel 10625 2950 2    60   Input ~ 0
TX50
$Comp
L BSS138-RESCUE-GOLMain_RevA Q4
U 1 1 58C3545B
P 10350 4150
F 0 "Q4" H 10550 4225 50  0000 L CNN
F 1 "BSS138" H 10550 4150 50  0000 L CNN
F 2 "TO_SOT_Packages_SMD:SOT-23" H 10550 4075 50  0001 L CIN
F 3 "" H 10350 4150 50  0000 L CNN
	1    10350 4150
	0    1    1    0   
$EndComp
$Comp
L R R18
U 1 1 58C35461
P 10100 4050
F 0 "R18" V 10180 4050 50  0000 C CNN
F 1 "10K" V 10100 4050 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 10030 4050 50  0001 C CNN
F 3 "" H 10100 4050 50  0000 C CNN
	1    10100 4050
	-1   0    0    1   
$EndComp
$Comp
L R R20
U 1 1 58C35467
P 10600 4050
F 0 "R20" V 10680 4050 50  0000 C CNN
F 1 "10K" V 10600 4050 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 10530 4050 50  0001 C CNN
F 3 "" H 10600 4050 50  0000 C CNN
	1    10600 4050
	-1   0    0    1   
$EndComp
Text GLabel 10100 3850 1    60   Input ~ 0
V33
Text GLabel 10600 3900 1    60   Input ~ 0
V50
Text GLabel 10075 4250 0    60   Input ~ 0
EN_MAX
Text GLabel 10625 4250 2    60   Input ~ 0
EN_MAX50
Text GLabel 7550 5050 0    60   Input ~ 0
RX33
Text GLabel 7550 5450 0    60   Input ~ 0
TX33
Text GLabel 7350 5350 0    60   Input ~ 0
EN_MAX
Text GLabel 7950 5650 3    60   Input ~ 0
GND
Text Notes 4775 1025 0    60   ~ 0
2-6V Supply for SN74HC165D
Text Notes 3750 5375 0    60   ~ 0
ESP8266\nGPIO15 pull down\nGPIO0 pull up, switch to gnd\nGPIO2 pull up\n0,2,15 Only as Outputs\nCan't use SPI
$Comp
L R R21
U 1 1 58C3DD84
P 1525 5800
F 0 "R21" V 1605 5800 50  0000 C CNN
F 1 "10K" V 1525 5800 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 1455 5800 50  0001 C CNN
F 3 "" H 1525 5800 50  0000 C CNN
	1    1525 5800
	-1   0    0    1   
$EndComp
Text GLabel 1525 5650 1    60   Input ~ 0
V33
$Comp
L R R22
U 1 1 58C3E628
P 1850 4375
F 0 "R22" V 1930 4375 50  0000 C CNN
F 1 "10K" V 1850 4375 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 1780 4375 50  0001 C CNN
F 3 "" H 1850 4375 50  0000 C CNN
	1    1850 4375
	-1   0    0    1   
$EndComp
Text GLabel 1850 4225 1    60   Input ~ 0
V33
Text GLabel 4975 6325 2    60   Input ~ 0
GPIO0
Text GLabel 1800 4575 0    60   Input ~ 0
GPIO0
$Comp
L SW_PUSH_SMALL_H SW2
U 1 1 58C3F97C
P 1850 4775
F 0 "SW2" H 1930 4885 50  0000 C CNN
F 1 "SW_PROG" H 2210 4715 50  0000 C CNN
F 2 "Buttons_Switches_ThroughHole:SW_PUSH_SMALL" H 1850 4975 50  0001 C CNN
F 3 "" H 1850 4975 50  0000 C CNN
	1    1850 4775
	0    1    1    0   
$EndComp
Text GLabel 1200 4575 0    60   Input ~ 0
RESET
$Comp
L SW_PUSH_SMALL_H SW1
U 1 1 58C421D0
P 1250 4775
F 0 "SW1" H 1330 4885 50  0000 C CNN
F 1 "SW_RESET" H 1610 4715 50  0000 C CNN
F 2 "Buttons_Switches_ThroughHole:SW_PUSH_SMALL" H 1250 4975 50  0001 C CNN
F 3 "" H 1250 4975 50  0000 C CNN
	1    1250 4775
	0    1    1    0   
$EndComp
Text GLabel 3525 5725 0    60   Input ~ 0
RESET
Text GLabel 4975 6475 2    60   Input ~ 0
GPIO2
Text GLabel 1475 6000 0    60   Input ~ 0
GPIO2
Text GLabel 1575 6000 2    60   Input ~ 0
GPIO2_OUT
Text GLabel 4975 6625 2    60   Input ~ 0
GPIO15
Text GLabel 1475 6150 0    60   Input ~ 0
GPIO15
Text GLabel 1575 6150 2    60   Input ~ 0
GPIO15_OUT
Text GLabel 1500 7175 0    60   Input ~ 0
GPIO2_OUT
Text GLabel 1500 7325 0    60   Input ~ 0
GPIO15_OUT
Text GLabel 1900 4575 2    60   Input ~ 0
GPIO0_OUT
Text Notes 7425 4600 0    60   ~ 0
SP3485 is 3.3V\nLOW is Receive\nGPIO15 is already default LOW\nBut need to pull high\nfor 5V Level Shifting
Text GLabel 1500 7050 0    60   Input ~ 0
GPIO0_OUT
$Comp
L CONN_01X04 P12
U 1 1 58C52A29
P 9450 2775
F 0 "P12" H 9450 3025 50  0000 C CNN
F 1 "CONN_LED" V 9550 2775 50  0000 C CNN
F 2 "Connect:AK300-4" H 9450 2775 50  0001 C CNN
F 3 "" H 9450 2775 50  0000 C CNN
	1    9450 2775
	1    0    0    -1  
$EndComp
Text GLabel 9250 2925 0    60   Input ~ 0
V12
$Comp
L MAX485Module U5
U 1 1 58C552A4
P 10375 1475
F 0 "U5" H 10375 1725 60  0000 C CNN
F 1 "MAX485Module" H 10375 1225 60  0000 C CNN
F 2 "Housings_DIP:DIP-8_W7.62mm_LongPads" H 10375 1475 60  0001 C CNN
F 3 "" H 10375 1475 60  0001 C CNN
	1    10375 1475
	1    0    0    -1  
$EndComp
Text GLabel 9975 1625 0    60   Input ~ 0
TX50
Text GLabel 9975 1325 0    60   Input ~ 0
RX50
Text GLabel 9775 1525 0    60   Input ~ 0
EN_MAX50
Text Notes 9850 1150 0    60   ~ 0
MAX485 Module is 5V\nHIGH is 3.5V\nCan't use GPIO15\n  due to MOSFET pull up
$Comp
L BSS138-RESCUE-GOLMain_RevA Q5
U 1 1 58C5DEBC
P 10350 5475
F 0 "Q5" H 10550 5550 50  0000 L CNN
F 1 "BSS138" H 10550 5475 50  0000 L CNN
F 2 "TO_SOT_Packages_SMD:SOT-23" H 10550 5400 50  0001 L CIN
F 3 "" H 10350 5475 50  0000 L CNN
	1    10350 5475
	0    1    1    0   
$EndComp
$Comp
L R R23
U 1 1 58C5DEC2
P 10100 5375
F 0 "R23" V 10180 5375 50  0000 C CNN
F 1 "10K" V 10100 5375 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 10030 5375 50  0001 C CNN
F 3 "" H 10100 5375 50  0000 C CNN
	1    10100 5375
	-1   0    0    1   
$EndComp
$Comp
L R R24
U 1 1 58C5DEC8
P 10600 5375
F 0 "R24" V 10680 5375 50  0000 C CNN
F 1 "10K" V 10600 5375 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 10530 5375 50  0001 C CNN
F 3 "" H 10600 5375 50  0000 C CNN
	1    10600 5375
	-1   0    0    1   
$EndComp
Text GLabel 10100 5175 1    60   Input ~ 0
V33
Text GLabel 10600 5225 1    60   Input ~ 0
V50
Text GLabel 10075 5575 0    60   Input ~ 0
RX33
Text GLabel 10625 5575 2    60   Input ~ 0
RX50
Text GLabel 3525 6625 0    60   Input ~ 0
EN_MAX
Text GLabel 10775 1525 2    60   Input ~ 0
A
Text GLabel 10775 1425 2    60   Input ~ 0
B
Text GLabel 10775 1625 2    60   Input ~ 0
GND
Text GLabel 10775 1325 2    60   Input ~ 0
V50
$Comp
L CONN_01X03 P1
U 1 1 58C6A2F7
P 5050 2850
F 0 "P1" H 5050 3050 50  0000 C CNN
F 1 "CONN_ID_0" V 5150 2850 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5050 2850 50  0001 C CNN
F 3 "" H 5050 2850 50  0000 C CNN
	1    5050 2850
	1    0    0    -1  
$EndComp
Text GLabel 4850 2750 0    60   Input ~ 0
GND
Text GLabel 4850 2950 0    60   Input ~ 0
V33
Text GLabel 4850 2850 0    60   Input ~ 0
ID_0
$Comp
L CONN_01X03 P2
U 1 1 58C6B715
P 5050 3300
F 0 "P2" H 5050 3500 50  0000 C CNN
F 1 "CONN_ID_1" V 5150 3300 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5050 3300 50  0001 C CNN
F 3 "" H 5050 3300 50  0000 C CNN
	1    5050 3300
	1    0    0    -1  
$EndComp
Text GLabel 4850 3200 0    60   Input ~ 0
GND
Text GLabel 4850 3400 0    60   Input ~ 0
V33
Text GLabel 4850 3300 0    60   Input ~ 0
ID_1
$Comp
L CONN_01X03 P4
U 1 1 58C6BB9C
P 5050 3750
F 0 "P4" H 5050 3950 50  0000 C CNN
F 1 "CONN_ID_2" V 5150 3750 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5050 3750 50  0001 C CNN
F 3 "" H 5050 3750 50  0000 C CNN
	1    5050 3750
	1    0    0    -1  
$EndComp
Text GLabel 4850 3650 0    60   Input ~ 0
GND
Text GLabel 4850 3850 0    60   Input ~ 0
V33
Text GLabel 4850 3750 0    60   Input ~ 0
ID_2
$Comp
L CONN_01X03 P7
U 1 1 58C6BBA5
P 5050 4200
F 0 "P7" H 5050 4400 50  0000 C CNN
F 1 "CONN_ID_3" V 5150 4200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5050 4200 50  0001 C CNN
F 3 "" H 5050 4200 50  0000 C CNN
	1    5050 4200
	1    0    0    -1  
$EndComp
Text GLabel 4850 4100 0    60   Input ~ 0
GND
Text GLabel 4850 4300 0    60   Input ~ 0
V33
Text GLabel 4850 4200 0    60   Input ~ 0
ID_3
$Comp
L CONN_01X03 P8
U 1 1 58C6C5F2
P 5825 2850
F 0 "P8" H 5825 3050 50  0000 C CNN
F 1 "CONN_ID_4" V 5925 2850 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5825 2850 50  0001 C CNN
F 3 "" H 5825 2850 50  0000 C CNN
	1    5825 2850
	1    0    0    -1  
$EndComp
Text GLabel 5625 2750 0    60   Input ~ 0
GND
Text GLabel 5625 2950 0    60   Input ~ 0
V33
Text GLabel 5625 2850 0    60   Input ~ 0
ID_4
$Comp
L CONN_01X03 P9
U 1 1 58C6C5FB
P 5825 3300
F 0 "P9" H 5825 3500 50  0000 C CNN
F 1 "CONN_ID_5" V 5925 3300 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5825 3300 50  0001 C CNN
F 3 "" H 5825 3300 50  0000 C CNN
	1    5825 3300
	1    0    0    -1  
$EndComp
Text GLabel 5625 3200 0    60   Input ~ 0
GND
Text GLabel 5625 3400 0    60   Input ~ 0
V33
Text GLabel 5625 3300 0    60   Input ~ 0
ID_5
$Comp
L CONN_01X03 P10
U 1 1 58C6C604
P 5825 3750
F 0 "P10" H 5825 3950 50  0000 C CNN
F 1 "CONN_ID_6" V 5925 3750 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5825 3750 50  0001 C CNN
F 3 "" H 5825 3750 50  0000 C CNN
	1    5825 3750
	1    0    0    -1  
$EndComp
Text GLabel 5625 3650 0    60   Input ~ 0
GND
Text GLabel 5625 3850 0    60   Input ~ 0
V33
Text GLabel 5625 3750 0    60   Input ~ 0
ID_6
$Comp
L CONN_01X03 P11
U 1 1 58C6C60D
P 5825 4200
F 0 "P11" H 5825 4400 50  0000 C CNN
F 1 "CONN_ID_7" V 5925 4200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 5825 4200 50  0001 C CNN
F 3 "" H 5825 4200 50  0000 C CNN
	1    5825 4200
	1    0    0    -1  
$EndComp
Text GLabel 5625 4100 0    60   Input ~ 0
GND
Text GLabel 5625 4300 0    60   Input ~ 0
V33
Text GLabel 5625 4200 0    60   Input ~ 0
ID_7
$Comp
L CONN_01X06 P13
U 1 1 58C406F2
P 6400 5975
F 0 "P13" H 6400 6325 50  0000 C CNN
F 1 "CONN_FTDI" V 6500 5975 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x06" H 6400 5975 50  0001 C CNN
F 3 "" H 6400 5975 50  0000 C CNN
	1    6400 5975
	1    0    0    -1  
$EndComp
Text GLabel 6200 5925 0    60   Input ~ 0
V33
Text GLabel 6200 6125 0    60   Input ~ 0
TX33
Text GLabel 6200 6025 0    60   Input ~ 0
RX33
Text GLabel 6200 5725 0    60   Input ~ 0
GND
Text GLabel 6200 5825 0    60   Input ~ 0
CTS
Text GLabel 6200 6225 0    60   Input ~ 0
RTS
Text GLabel 1075 2275 0    60   Input ~ 0
V12
Text GLabel 1475 2725 3    60   Input ~ 0
GND
Text GLabel 1975 2275 2    60   Input ~ 0
V50
$Comp
L R R25
U 1 1 58C45A90
P 3175 2600
F 0 "R25" V 3255 2600 50  0000 C CNN
F 1 "56" V 3175 2600 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 3105 2600 50  0001 C CNN
F 3 "" H 3175 2600 50  0000 C CNN
	1    3175 2600
	-1   0    0    1   
$EndComp
$Comp
L R R26
U 1 1 58C45CBB
P 3175 3000
F 0 "R26" V 3255 3000 50  0000 C CNN
F 1 "39" V 3175 3000 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 3105 3000 50  0001 C CNN
F 3 "" H 3175 3000 50  0000 C CNN
	1    3175 3000
	-1   0    0    1   
$EndComp
Text GLabel 3225 2800 2    60   Input ~ 0
V50D
Text GLabel 3175 2450 1    60   Input ~ 0
V12
Text GLabel 3175 3150 3    60   Input ~ 0
GND
$Comp
L C C5
U 1 1 58C48F61
P 3325 1325
F 0 "C5" H 3350 1425 50  0000 L CNN
F 1 "0.1uF" H 3350 1225 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 3363 1175 50  0001 C CNN
F 3 "" H 3325 1325 50  0000 C CNN
	1    3325 1325
	1    0    0    -1  
$EndComp
$Comp
L C C6
U 1 1 58C49942
P 1925 2475
F 0 "C6" H 1950 2575 50  0000 L CNN
F 1 "0.1uF" H 1950 2375 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 1963 2325 50  0001 C CNN
F 3 "" H 1925 2475 50  0000 C CNN
	1    1925 2475
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P14
U 1 1 58C4BB8E
P 3850 2500
F 0 "P14" H 3850 2650 50  0000 C CNN
F 1 "CONN_V50SEL" V 3950 2500 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 3850 2500 50  0001 C CNN
F 3 "" H 3850 2500 50  0000 C CNN
	1    3850 2500
	1    0    0    -1  
$EndComp
Text GLabel 3650 2550 0    60   Input ~ 0
V50D
Text GLabel 3650 2450 0    60   Input ~ 0
V50
Text Notes 3325 3150 0    60   ~ 0
Voltage Divider\nFor 5V supply\nif needed
Text Notes 7350 1750 0    60   ~ 0
ESP8266 GPIO\nMax Current is 12mA\n3.3/12mA = 275 Ohm\n1K Ohm OK
Text GLabel 3375 4250 0    60   Input ~ 0
V33
Text GLabel 3375 3950 0    60   Input ~ 0
GND
Text GLabel 3375 4050 0    60   Input ~ 0
READER1
Text GLabel 3375 4150 0    60   Input ~ 0
READER2
$Comp
L R_PACK4 RP1
U 1 1 58C5A67D
P 4850 1600
F 0 "RP1" H 4850 2050 50  0000 C CNN
F 1 "R_PACK4_10K" H 4850 1550 50  0000 C CNN
F 2 "Resistors_SMD:R_Array_Convex_4x1206" H 4850 1600 50  0001 C CNN
F 3 "" H 4850 1600 50  0000 C CNN
	1    4850 1600
	1    0    0    -1  
$EndComp
$Comp
L R_PACK4 RP2
U 1 1 58C5BA25
P 4850 2000
F 0 "RP2" H 4850 2450 50  0000 C CNN
F 1 "R_PACK4_10K" H 4850 1950 50  0000 C CNN
F 2 "Resistors_SMD:R_Array_Convex_4x1206" H 4850 2000 50  0001 C CNN
F 3 "" H 4850 2000 50  0000 C CNN
	1    4850 2000
	1    0    0    -1  
$EndComp
$Comp
L LM78L05ACZ U6
U 1 1 58C5E0E0
P 1475 2325
F 0 "U6" H 1275 2525 50  0000 C CNN
F 1 "LM78L05ACZ" H 1475 2525 50  0000 L CNN
F 2 "TO_SOT_Packages_THT:TO-92_Rugged" H 1475 2425 50  0000 C CIN
F 3 "" H 1475 2325 50  0000 C CNN
	1    1475 2325
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 58CB26FC
P 9100 2725
F 0 "R1" V 9180 2725 50  0000 C CNN
F 1 "470" V 9100 2725 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 9030 2725 50  0001 C CNN
F 3 "" H 9100 2725 50  0000 C CNN
	1    9100 2725
	0    -1   -1   0   
$EndComp
$Comp
L R R2
U 1 1 58CB2B2A
P 9100 2825
F 0 "R2" V 9180 2825 50  0000 C CNN
F 1 "470" V 9100 2825 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 9030 2825 50  0001 C CNN
F 3 "" H 9100 2825 50  0000 C CNN
	1    9100 2825
	0    -1   -1   0   
$EndComp
$Comp
L CONN_01X02 P16
U 1 1 58CB3E5B
P 1100 1775
F 0 "P16" H 1100 1925 50  0000 C CNN
F 1 "CONN_V12V50" V 1200 1775 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 1100 1775 50  0001 C CNN
F 3 "" H 1100 1775 50  0000 C CNN
	1    1100 1775
	1    0    0    -1  
$EndComp
Text GLabel 900  1725 0    60   Input ~ 0
V12
Text GLabel 900  1825 0    60   Input ~ 0
V50
Text Notes 1275 1900 0    60   ~ 0
Bridge 12V to 5V\nIf Input Voltage\nis actually 5V
$Comp
L CONN_01X02 P17
U 1 1 58CB5C30
P 8750 2250
F 0 "P17" H 8750 2400 50  0000 C CNN
F 1 "CONN_LEDCLK" V 8850 2250 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 8750 2250 50  0001 C CNN
F 3 "" H 8750 2250 50  0000 C CNN
	1    8750 2250
	1    0    0    -1  
$EndComp
Text GLabel 8550 2200 0    60   Input ~ 0
SCL
Text GLabel 8550 2300 0    60   Input ~ 0
LED_CLOCK
$Comp
L CONN_01X02 P18
U 1 1 58CB7A09
P 8750 3275
F 0 "P18" H 8750 3425 50  0000 C CNN
F 1 "CONN_LEDDATA" V 8850 3275 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 8750 3275 50  0001 C CNN
F 3 "" H 8750 3275 50  0000 C CNN
	1    8750 3275
	1    0    0    -1  
$EndComp
Text GLabel 8550 3225 0    60   Input ~ 0
SDA
Text GLabel 8550 3325 0    60   Input ~ 0
LED_DATA
$Comp
L CONN_01X02 P19
U 1 1 58CBC4C9
P 10800 2200
F 0 "P19" H 10800 2350 50  0000 C CNN
F 1 "CONN_TX3350" V 10900 2200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 10800 2200 50  0001 C CNN
F 3 "" H 10800 2200 50  0000 C CNN
	1    10800 2200
	1    0    0    -1  
$EndComp
Text GLabel 10600 2150 0    60   Input ~ 0
TX33
Text GLabel 10600 2250 0    60   Input ~ 0
TX50
$Comp
L CONN_01X02 P20
U 1 1 58CBDB31
P 10800 3550
F 0 "P20" H 10800 3700 50  0000 C CNN
F 1 "CONN_EN3350" V 10900 3550 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 10800 3550 50  0001 C CNN
F 3 "" H 10800 3550 50  0000 C CNN
	1    10800 3550
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P21
U 1 1 58CBDCA8
P 10800 4875
F 0 "P21" H 10800 5025 50  0000 C CNN
F 1 "CONN_RX3350" V 10900 4875 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 10800 4875 50  0001 C CNN
F 3 "" H 10800 4875 50  0000 C CNN
	1    10800 4875
	1    0    0    -1  
$EndComp
Text GLabel 10600 3500 0    60   Input ~ 0
EN_MAX
Text GLabel 10600 3600 0    60   Input ~ 0
EN_MAX50
Text GLabel 10600 4825 0    60   Input ~ 0
RX33
Text GLabel 10600 4925 0    60   Input ~ 0
RX50
$Comp
L CONN_01X04 P3
U 1 1 58CC0F96
P 3575 4100
F 0 "P3" H 3575 4350 50  0000 C CNN
F 1 "CONN_READERS" V 3675 4100 50  0000 C CNN
F 2 "Sockets_MOLEX_KK-System:Socket_MOLEX-KK-RM2-54mm_Lock_4pin_straight" H 3575 4100 50  0001 C CNN
F 3 "" H 3575 4100 50  0000 C CNN
	1    3575 4100
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 58CC3668
P 8675 5275
F 0 "R3" V 8755 5275 50  0000 C CNN
F 1 "100" V 8675 5275 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 8605 5275 50  0001 C CNN
F 3 "" H 8675 5275 50  0000 C CNN
	1    8675 5275
	-1   0    0    1   
$EndComp
Text GLabel 8675 5025 1    60   Input ~ 0
A
Text GLabel 8675 5425 3    60   Input ~ 0
B
$Comp
L CONN_01X02 P15
U 1 1 58CC5B1E
P 8875 5075
F 0 "P15" H 8875 5225 50  0000 C CNN
F 1 "CONN_AB_RES" V 8975 5075 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 8875 5075 50  0001 C CNN
F 3 "" H 8875 5075 50  0000 C CNN
	1    8875 5075
	1    0    0    -1  
$EndComp
Text Notes 8775 5600 0    60   ~ 0
END Node should\nuse a resistor to\ndecrease reflections
$Comp
L C C7
U 1 1 58CB8BD3
P 6825 5375
F 0 "C7" H 6850 5475 50  0000 L CNN
F 1 "0.1uF" H 6850 5275 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 6863 5225 50  0001 C CNN
F 3 "" H 6825 5375 50  0000 C CNN
	1    6825 5375
	1    0    0    -1  
$EndComp
Text GLabel 6825 5525 3    60   Input ~ 0
GND
Text GLabel 6825 5225 1    60   Input ~ 0
V33
Wire Wire Line
	1075 1125 2400 1125
Wire Wire Line
	2300 1025 2300 1175
Connection ~ 2300 1125
Wire Wire Line
	3000 1125 3425 1125
Wire Wire Line
	3075 950  3075 1175
Connection ~ 3075 1125
Wire Wire Line
	2700 1425 2700 1650
Wire Wire Line
	2300 1550 2300 1475
Wire Wire Line
	1325 1550 3325 1550
Connection ~ 2700 1550
Wire Wire Line
	3075 1550 3075 1475
Wire Wire Line
	3075 1000 3375 1000
Connection ~ 3075 1000
Wire Wire Line
	2525 1675 2525 1550
Connection ~ 2525 1550
Wire Wire Line
	3275 950  3275 1000
Connection ~ 3275 1000
Wire Wire Line
	7400 2075 7400 2125
Wire Wire Line
	7400 2100 7600 2100
Wire Wire Line
	7600 2100 7600 2175
Connection ~ 7400 2100
Wire Wire Line
	7400 2425 7400 2475
Wire Wire Line
	7375 2475 7450 2475
Wire Wire Line
	7850 2475 7925 2475
Wire Wire Line
	7900 2475 7900 2425
Wire Wire Line
	7400 3075 7400 3125
Wire Wire Line
	7400 3100 7600 3100
Wire Wire Line
	7600 3100 7600 3175
Connection ~ 7400 3100
Wire Wire Line
	7400 3425 7400 3475
Wire Wire Line
	7375 3475 7450 3475
Wire Wire Line
	7850 3475 7925 3475
Wire Wire Line
	7900 3475 7900 3425
Connection ~ 7400 2475
Connection ~ 7900 2475
Connection ~ 7400 3475
Connection ~ 7900 3475
Wire Wire Line
	1800 1125 1800 1175
Connection ~ 1800 1125
Wire Wire Line
	1800 1475 1800 1550
Connection ~ 2300 1550
Wire Wire Line
	1325 1550 1325 1475
Connection ~ 1800 1550
Wire Wire Line
	1325 1175 1325 1125
Connection ~ 1325 1125
Wire Wire Line
	10100 2550 10100 2600
Wire Wire Line
	10100 2575 10300 2575
Wire Wire Line
	10300 2575 10300 2650
Connection ~ 10100 2575
Wire Wire Line
	10100 2900 10100 2950
Wire Wire Line
	10075 2950 10150 2950
Wire Wire Line
	10550 2950 10625 2950
Wire Wire Line
	10600 2950 10600 2900
Connection ~ 10100 2950
Connection ~ 10600 2950
Wire Wire Line
	10100 3850 10100 3900
Wire Wire Line
	10100 3875 10300 3875
Wire Wire Line
	10300 3875 10300 3950
Connection ~ 10100 3875
Wire Wire Line
	10100 4200 10100 4250
Wire Wire Line
	10075 4250 10150 4250
Wire Wire Line
	10550 4250 10625 4250
Wire Wire Line
	10600 4250 10600 4200
Connection ~ 10100 4250
Connection ~ 10600 4250
Wire Wire Line
	7350 5350 7550 5350
Wire Wire Line
	7550 5150 7450 5150
Wire Wire Line
	7450 5150 7450 5350
Connection ~ 7450 5350
Wire Wire Line
	1800 4575 1900 4575
Wire Wire Line
	1850 4525 1850 4625
Connection ~ 1850 4575
Wire Wire Line
	1250 4525 1250 4625
Wire Wire Line
	1200 4575 1250 4575
Connection ~ 1250 4575
Wire Wire Line
	1475 6000 1575 6000
Wire Wire Line
	1525 5950 1525 6000
Connection ~ 1525 6000
Wire Wire Line
	1475 6150 1575 6150
Wire Wire Line
	1525 6200 1525 6150
Connection ~ 1525 6150
Wire Wire Line
	1500 7175 1550 7175
Wire Wire Line
	1500 7325 1550 7325
Wire Wire Line
	1500 7050 1550 7050
Wire Wire Line
	10100 5175 10100 5225
Wire Wire Line
	10100 5200 10300 5200
Wire Wire Line
	10300 5200 10300 5275
Connection ~ 10100 5200
Wire Wire Line
	10100 5525 10100 5575
Wire Wire Line
	10075 5575 10150 5575
Wire Wire Line
	10550 5575 10625 5575
Wire Wire Line
	10600 5575 10600 5525
Connection ~ 10100 5575
Connection ~ 10600 5575
Wire Wire Line
	9975 1425 9875 1425
Wire Wire Line
	9875 1425 9875 1525
Wire Wire Line
	9775 1525 9975 1525
Connection ~ 9875 1525
Wire Wire Line
	3175 2750 3175 2850
Wire Wire Line
	3225 2800 3175 2800
Connection ~ 3175 2800
Wire Wire Line
	1475 2575 1475 2725
Wire Wire Line
	1875 2275 1975 2275
Wire Wire Line
	1925 2325 1925 2275
Connection ~ 1925 2275
Wire Wire Line
	1925 2625 1925 2675
Wire Wire Line
	1925 2675 1475 2675
Connection ~ 1475 2675
Wire Wire Line
	3325 1175 3325 1125
Connection ~ 3325 1125
Wire Wire Line
	3325 1550 3325 1475
Connection ~ 3075 1550
Wire Notes Line
	3025 2150 3025 3475
Wire Notes Line
	3025 3475 4075 3475
Wire Notes Line
	4075 3475 4075 2150
Wire Notes Line
	4075 2150 3025 2150
Wire Wire Line
	8550 2200 8550 2300
Wire Wire Line
	8550 3225 8550 3325
Text Notes 8475 3600 0    60   ~ 0
Default\nDirectly Connected
Text Notes 8475 2050 0    60   ~ 0
Default\nDirectly Connected
$Comp
L CONN_01X01 P22
U 1 1 58D373E5
P 675 2925
F 0 "P22" H 675 3025 50  0000 C CNN
F 1 "CONN_GND" V 775 2925 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_1-5mmDrill" H 675 2925 50  0001 C CNN
F 3 "" H 675 2925 50  0000 C CNN
	1    675  2925
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P23
U 1 1 58D37FCA
P 675 3125
F 0 "P23" H 675 3225 50  0000 C CNN
F 1 "CONN_A" V 775 3125 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_0-8mmDrill" H 675 3125 50  0001 C CNN
F 3 "" H 675 3125 50  0000 C CNN
	1    675  3125
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P24
U 1 1 58D380CA
P 675 3325
F 0 "P24" H 675 3425 50  0000 C CNN
F 1 "CONN_B" V 775 3325 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_0-8mmDrill" H 675 3325 50  0001 C CNN
F 3 "" H 675 3325 50  0000 C CNN
	1    675  3325
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P25
U 1 1 58D381B5
P 675 3525
F 0 "P25" H 675 3625 50  0000 C CNN
F 1 "CONN_V12" V 775 3525 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_1-5mmDrill" H 675 3525 50  0001 C CNN
F 3 "" H 675 3525 50  0000 C CNN
	1    675  3525
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P26
U 1 1 58D386A7
P 675 3850
F 0 "P26" H 675 3950 50  0000 C CNN
F 1 "CONN_GND" V 775 3850 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_1-5mmDrill" H 675 3850 50  0001 C CNN
F 3 "" H 675 3850 50  0000 C CNN
	1    675  3850
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P27
U 1 1 58D386AD
P 675 4050
F 0 "P27" H 675 4150 50  0000 C CNN
F 1 "CONN_A" V 775 4050 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_0-8mmDrill" H 675 4050 50  0001 C CNN
F 3 "" H 675 4050 50  0000 C CNN
	1    675  4050
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P28
U 1 1 58D386B3
P 675 4250
F 0 "P28" H 675 4350 50  0000 C CNN
F 1 "CONN_B" V 775 4250 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_0-8mmDrill" H 675 4250 50  0001 C CNN
F 3 "" H 675 4250 50  0000 C CNN
	1    675  4250
	-1   0    0    1   
$EndComp
$Comp
L CONN_01X01 P29
U 1 1 58D386B9
P 675 4450
F 0 "P29" H 675 4550 50  0000 C CNN
F 1 "CONN_V12" V 775 4450 50  0000 C CNN
F 2 "Wire_Pads:SolderWirePad_single_1-5mmDrill" H 675 4450 50  0001 C CNN
F 3 "" H 675 4450 50  0000 C CNN
	1    675  4450
	-1   0    0    1   
$EndComp
Text GLabel 875  2925 2    60   Input ~ 0
GND
Text GLabel 875  3125 2    60   Input ~ 0
A
Text GLabel 875  3325 2    60   Input ~ 0
B
Text GLabel 875  3525 2    60   Input ~ 0
V12
Text GLabel 875  3850 2    60   Input ~ 0
GND
Text GLabel 875  4050 2    60   Input ~ 0
A
Text GLabel 875  4250 2    60   Input ~ 0
B
Text GLabel 875  4450 2    60   Input ~ 0
V12
$EndSCHEMATC
