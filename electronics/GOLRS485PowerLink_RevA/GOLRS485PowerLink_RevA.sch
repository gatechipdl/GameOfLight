EESchema Schematic File Version 2
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
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "GOL RS485 Power Link"
Date "2017-04-18"
Rev "A"
Comp "Matthew Swarts"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CONN_01X04 P1
U 1 1 58F615C4
P 4325 3050
F 0 "P1" H 4325 3300 50  0000 C CNN
F 1 "CONN_MAIN1" V 4425 3050 50  0000 C CNN
F 2 "Connect:AK300-4" H 4325 3050 50  0001 C CNN
F 3 "" H 4325 3050 50  0000 C CNN
	1    4325 3050
	1    0    0    -1  
$EndComp
$Comp
L LM1117-3.3 U1
U 1 1 58F615F2
P 4350 1400
F 0 "U1" H 4450 1150 50  0000 C CNN
F 1 "LM1117-3.3" H 4350 1650 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-223" H 4350 1400 50  0001 C CNN
F 3 "" H 4350 1400 50  0000 C CNN
	1    4350 1400
	1    0    0    -1  
$EndComp
Text GLabel 4125 3200 0    60   Input ~ 0
V12
Text GLabel 4125 3100 0    60   Input ~ 0
B
Text GLabel 4125 3000 0    60   Input ~ 0
A
Text GLabel 4125 2900 0    60   Input ~ 0
GND
Text GLabel 3600 1400 0    60   Input ~ 0
V12
$Comp
L C C1
U 1 1 58F616D5
P 3800 1600
F 0 "C1" H 3825 1700 50  0000 L CNN
F 1 "10uF" H 3825 1500 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 3838 1450 50  0001 C CNN
F 3 "" H 3800 1600 50  0000 C CNN
	1    3800 1600
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 58F61713
P 4750 1600
F 0 "C2" H 4775 1700 50  0000 L CNN
F 1 "10uF" H 4775 1500 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 4788 1450 50  0001 C CNN
F 3 "" H 4750 1600 50  0000 C CNN
	1    4750 1600
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 58F61743
P 5100 1600
F 0 "C3" H 5125 1700 50  0000 L CNN
F 1 "0.1uF" H 5125 1500 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5138 1450 50  0001 C CNN
F 3 "" H 5100 1600 50  0000 C CNN
	1    5100 1600
	1    0    0    -1  
$EndComp
Text GLabel 5275 1400 2    60   Input ~ 0
V33
Text GLabel 4350 2150 3    60   Input ~ 0
GND
$Comp
L CONN_01X02 P3
U 1 1 58F6187D
P 5575 2875
F 0 "P3" H 5575 3025 50  0000 C CNN
F 1 "CONN_RS485_USB" V 5675 2875 50  0000 C CNN
F 2 "Connect:AK300-2" H 5575 2875 50  0001 C CNN
F 3 "" H 5575 2875 50  0000 C CNN
	1    5575 2875
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P2
U 1 1 58F618B6
P 5100 3675
F 0 "P2" H 5100 3825 50  0000 C CNN
F 1 "CONN_33PWR" V 5200 3675 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 5100 3675 50  0001 C CNN
F 3 "" H 5100 3675 50  0000 C CNN
	1    5100 3675
	1    0    0    -1  
$EndComp
Text GLabel 5375 2825 0    60   Input ~ 0
A
Text GLabel 5375 2925 0    60   Input ~ 0
B
$Comp
L R R1
U 1 1 58F61B4B
P 6475 2350
F 0 "R1" V 6555 2350 50  0000 C CNN
F 1 "560" V 6475 2350 50  0000 C CNN
F 2 "Resistors_Universal:Resistor_SMD+THTuniversal_1206_RM10_HandSoldering" V 6405 2350 50  0001 C CNN
F 3 "" H 6475 2350 50  0000 C CNN
	1    6475 2350
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 58F61B90
P 6475 2750
F 0 "R2" V 6555 2750 50  0000 C CNN
F 1 "120" V 6475 2750 50  0000 C CNN
F 2 "Resistors_Universal:Resistor_SMD+THTuniversal_1206_RM10_HandSoldering" V 6405 2750 50  0001 C CNN
F 3 "" H 6475 2750 50  0000 C CNN
	1    6475 2750
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 58F61BE1
P 6475 3150
F 0 "R3" V 6555 3150 50  0000 C CNN
F 1 "560" V 6475 3150 50  0000 C CNN
F 2 "Resistors_Universal:Resistor_SMD+THTuniversal_1206_RM10_HandSoldering" V 6405 3150 50  0001 C CNN
F 3 "" H 6475 3150 50  0000 C CNN
	1    6475 3150
	1    0    0    -1  
$EndComp
Text GLabel 6475 2150 1    60   Input ~ 0
V33
Text GLabel 6425 2550 0    60   Input ~ 0
A
Text GLabel 6425 2950 0    60   Input ~ 0
B
Text GLabel 6475 3350 3    60   Input ~ 0
GND
Text GLabel 4900 3625 0    60   Input ~ 0
GND
Text GLabel 4900 3725 0    60   Input ~ 0
V33
$Comp
L R R5
U 1 1 58F63007
P 5100 2575
F 0 "R5" V 5180 2575 50  0000 C CNN
F 1 "0" V 5100 2575 50  0000 C CNN
F 2 "Resistors_Universal:Resistor_SMD+THTuniversal_1206_RM10_HandSoldering" V 5030 2575 50  0001 C CNN
F 3 "" H 5100 2575 50  0000 C CNN
	1    5100 2575
	0    1    1    0   
$EndComp
Text GLabel 4950 2575 0    60   Input ~ 0
A
Text GLabel 5250 2575 2    60   Input ~ 0
A
$Comp
L R R4
U 1 1 58F63321
P 4350 2000
F 0 "R4" V 4430 2000 50  0000 C CNN
F 1 "0" V 4350 2000 50  0000 C CNN
F 2 "Resistors_Universal:Resistor_SMD+THTuniversal_2512_RM10_HandSoldering" V 4280 2000 50  0001 C CNN
F 3 "" H 4350 2000 50  0000 C CNN
	1    4350 2000
	-1   0    0    1   
$EndComp
Wire Wire Line
	6475 2150 6475 2200
Wire Wire Line
	6475 2500 6475 2600
Wire Wire Line
	6475 2550 6425 2550
Connection ~ 6475 2550
Wire Wire Line
	6475 2900 6475 3000
Wire Wire Line
	6475 2950 6425 2950
Connection ~ 6475 2950
Wire Wire Line
	6475 3300 6475 3350
Wire Wire Line
	3600 1400 4050 1400
Wire Wire Line
	3800 1400 3800 1450
Connection ~ 3800 1400
Wire Wire Line
	3800 1750 3800 1800
Wire Wire Line
	3800 1800 5100 1800
Wire Wire Line
	4350 1700 4350 1850
Connection ~ 4350 1800
Wire Wire Line
	5100 1800 5100 1750
Wire Wire Line
	4750 1750 4750 1800
Connection ~ 4750 1800
Wire Wire Line
	4650 1400 5275 1400
Wire Wire Line
	5100 1450 5100 1400
Connection ~ 5100 1400
Wire Wire Line
	4750 1450 4750 1400
Connection ~ 4750 1400
Wire Wire Line
	4350 2150 4450 2150
Wire Wire Line
	4450 2150 4450 1850
Wire Wire Line
	4450 1850 4350 1850
$EndSCHEMATC
