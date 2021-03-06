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
LIBS:myParts
LIBS:LO_Necklet_RevA-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "LO_Necklet"
Date "2017-06-23"
Rev "A"
Comp "Light Orchard"
Comment1 "Matthew Swarts"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L SAMD20G18A-A U1
U 1 1 594D0E0B
P 3200 3100
F 0 "U1" H 1550 4750 50  0000 C CNN
F 1 "SAMD20G18A-A" H 4650 1450 50  0000 C CNN
F 2 "Housings_QFP:TQFP-48_7x7mm_Pitch0.5mm" H 3200 1950 50  0000 C CIN
F 3 "" H 3200 3350 50  0000 C CNN
	1    3200 3100
	1    0    0    -1  
$EndComp
$Comp
L C_Small C2
U 1 1 594D137B
P 5150 1300
F 0 "C2" H 5160 1370 50  0000 L CNN
F 1 "22pF" H 5160 1220 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5150 1300 50  0001 C CNN
F 3 "" H 5150 1300 50  0000 C CNN
	1    5150 1300
	1    0    0    -1  
$EndComp
$Comp
L Crystal_Small Y1
U 1 1 594D13A0
P 5400 1450
F 0 "Y1" H 5400 1550 50  0000 C CNN
F 1 "32.768" H 5400 1350 50  0000 C CNN
F 2 "" H 5400 1450 50  0001 C CNN
F 3 "" H 5400 1450 50  0000 C CNN
	1    5400 1450
	1    0    0    -1  
$EndComp
$Comp
L C_Small C3
U 1 1 594D13D8
P 5650 1300
F 0 "C3" H 5660 1370 50  0000 L CNN
F 1 "22pF" H 5660 1220 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5650 1300 50  0001 C CNN
F 3 "" H 5650 1300 50  0000 C CNN
	1    5650 1300
	1    0    0    -1  
$EndComp
Text GLabel 5150 1200 1    60   Input ~ 0
GND
Text GLabel 5650 1200 1    60   Input ~ 0
GND
Wire Wire Line
	5150 1650 5050 1650
Wire Wire Line
	5150 1400 5150 1650
Wire Wire Line
	5150 1450 5300 1450
Connection ~ 5150 1450
Wire Wire Line
	5500 1450 5650 1450
Wire Wire Line
	5650 1400 5650 1750
Wire Wire Line
	5650 1750 5050 1750
Connection ~ 5650 1450
Text GLabel 1350 1650 0    60   Input ~ 0
RESET
Text GLabel 3450 1350 1    60   Input ~ 0
V33
Text GLabel 2600 1350 1    60   Input ~ 0
V33
Text GLabel 3000 1350 1    60   Input ~ 0
V33
Text GLabel 3100 1350 1    60   Input ~ 0
V33
$Comp
L C_Small C1
U 1 1 594D1F1A
P 2800 1250
F 0 "C1" H 2810 1320 50  0000 L CNN
F 1 "1uF" H 2810 1170 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2800 1250 50  0001 C CNN
F 3 "" H 2800 1250 50  0000 C CNN
	1    2800 1250
	1    0    0    -1  
$EndComp
Text GLabel 2800 1150 1    60   Input ~ 0
GND
Text GLabel 2900 4850 3    60   Input ~ 0
GND
Text GLabel 3000 4850 3    60   Input ~ 0
GND
Text GLabel 3100 4850 3    60   Input ~ 0
GND
Text GLabel 3450 4850 3    60   Input ~ 0
GND
Text GLabel 5050 4050 2    60   Input ~ 0
D-
Text GLabel 5050 4150 2    60   Input ~ 0
D+
Text GLabel 5050 3850 2    60   Input ~ 0
SDA1
Text GLabel 5050 3950 2    60   Input ~ 0
SCL1
Text GLabel 5050 4450 2    60   Input ~ 0
SWCLK
Text GLabel 5050 4550 2    60   Input ~ 0
SWDIO
$Comp
L TEST_1P W1
U 1 1 594D2B8A
P 5525 4475
F 0 "W1" H 5525 4745 50  0000 C CNN
F 1 "TEST_1P" H 5525 4675 50  0000 C CNN
F 2 "" H 5725 4475 50  0001 C CNN
F 3 "" H 5725 4475 50  0000 C CNN
	1    5525 4475
	0    1    1    0   
$EndComp
$Comp
L TEST_1P W2
U 1 1 594D2BF1
P 5525 4550
F 0 "W2" H 5525 4820 50  0000 C CNN
F 1 "TEST_1P" H 5525 4750 50  0000 C CNN
F 2 "" H 5725 4550 50  0001 C CNN
F 3 "" H 5725 4550 50  0000 C CNN
	1    5525 4550
	0    1    1    0   
$EndComp
Text GLabel 5050 1850 2    60   Input ~ 0
A0
Text GLabel 5050 1950 2    60   Input ~ 0
AREF
Text GLabel 5050 2050 2    60   Input ~ 0
A3
Text GLabel 5050 2150 2    60   Input ~ 0
A4
Text GLabel 5050 2250 2    60   Input ~ 0
D8
Text GLabel 5050 2350 2    60   Input ~ 0
D9
Text GLabel 5050 2450 2    60   Input ~ 0
D4
Text GLabel 5050 2550 2    60   Input ~ 0
D3
Text GLabel 5050 2650 2    60   Input ~ 0
D1
Text GLabel 5050 2750 2    60   Input ~ 0
D0
Text GLabel 5050 2850 2    60   Input ~ 0
MISO1
Text GLabel 5050 3050 2    60   Input ~ 0
D2
Text GLabel 5050 3150 2    60   Input ~ 0
D5
Text GLabel 5050 3250 2    60   Input ~ 0
D11
Text GLabel 5050 3350 2    60   Input ~ 0
D13
Text GLabel 5050 3450 2    60   Input ~ 0
D10
Text GLabel 5050 3550 2    60   Input ~ 0
D12
Text GLabel 5050 3650 2    60   Input ~ 0
D6
Text GLabel 5050 3750 2    60   Input ~ 0
D7
Text GLabel 1350 1850 0    60   Input ~ 0
A5
Text GLabel 1350 1950 0    60   Input ~ 0
RXLED
Text GLabel 1350 2050 0    60   Input ~ 0
A1
Text GLabel 1350 2150 0    60   Input ~ 0
A2
Text GLabel 1350 2250 0    60   Input ~ 0
MOSI1
Text GLabel 1350 2350 0    60   Input ~ 0
SK1
Text GLabel 1350 2450 0    60   Input ~ 0
TXD1
Text GLabel 1350 2550 0    60   Input ~ 0
RXD1
Text GLabel 5050 4250 2    60   Input ~ 0
TXLED
Text GLabel 5050 4350 2    60   Input ~ 0
USBHOSTEN
$Comp
L VS18388 U2
U 1 1 594D4067
P 8450 1300
F 0 "U2" H 8450 1350 60  0000 C CNN
F 1 "VS18388" H 8450 1000 60  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 8450 1300 60  0001 C CNN
F 3 "" H 8450 1300 60  0000 C CNN
	1    8450 1300
	1    0    0    -1  
$EndComp
$Comp
L C_Small C4
U 1 1 594D409E
P 7575 1525
F 0 "C4" H 7585 1595 50  0000 L CNN
F 1 "100uF" H 7585 1445 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 7575 1525 50  0001 C CNN
F 3 "" H 7575 1525 50  0000 C CNN
	1    7575 1525
	1    0    0    -1  
$EndComp
$Comp
L R_Small R1
U 1 1 594D41CC
P 7375 1375
F 0 "R1" H 7405 1395 50  0000 L CNN
F 1 "100" H 7405 1335 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 7375 1375 50  0001 C CNN
F 3 "" H 7375 1375 50  0000 C CNN
	1    7375 1375
	0    -1   -1   0   
$EndComp
$Comp
L R_Small R2
U 1 1 594D428F
P 8425 1150
F 0 "R2" H 8455 1170 50  0000 L CNN
F 1 "10K" H 8455 1110 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 8425 1150 50  0001 C CNN
F 3 "" H 8425 1150 50  0000 C CNN
	1    8425 1150
	0    -1   -1   0   
$EndComp
$Comp
L C_Small C5
U 1 1 594D4508
P 7825 1525
F 0 "C5" H 7835 1595 50  0000 L CNN
F 1 "0.1uF" H 7835 1445 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 7825 1525 50  0001 C CNN
F 3 "" H 7825 1525 50  0000 C CNN
	1    7825 1525
	1    0    0    -1  
$EndComp
Wire Wire Line
	7475 1375 8050 1375
Wire Wire Line
	7825 1425 7825 1375
Connection ~ 7825 1375
Wire Wire Line
	7575 1425 7575 1375
Connection ~ 7575 1375
Wire Wire Line
	8050 1475 7975 1475
Wire Wire Line
	7975 1475 7975 1675
Wire Wire Line
	7975 1675 7275 1675
Wire Wire Line
	7825 1675 7825 1625
Wire Wire Line
	7575 1675 7575 1625
Connection ~ 7825 1675
Wire Wire Line
	8325 1150 7975 1150
Wire Wire Line
	7975 1150 7975 1375
Connection ~ 7975 1375
Wire Wire Line
	8525 1150 8875 1150
Wire Wire Line
	8875 1150 8875 1425
Wire Wire Line
	8825 1425 8925 1425
Text GLabel 7275 1375 0    60   Input ~ 0
V33
Text GLabel 7275 1675 0    60   Input ~ 0
GND
Connection ~ 7575 1675
Text GLabel 8925 1425 2    60   Input ~ 0
IRIN1
Connection ~ 8875 1425
$Comp
L VS18388 U3
U 1 1 594D6075
P 8450 2050
F 0 "U3" H 8450 2100 60  0000 C CNN
F 1 "VS18388" H 8450 1750 60  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 8450 2050 60  0001 C CNN
F 3 "" H 8450 2050 60  0000 C CNN
	1    8450 2050
	1    0    0    -1  
$EndComp
$Comp
L C_Small C6
U 1 1 594D607B
P 7575 2275
F 0 "C6" H 7585 2345 50  0000 L CNN
F 1 "100uF" H 7585 2195 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 7575 2275 50  0001 C CNN
F 3 "" H 7575 2275 50  0000 C CNN
	1    7575 2275
	1    0    0    -1  
$EndComp
$Comp
L R_Small R3
U 1 1 594D6081
P 7375 2125
F 0 "R3" H 7405 2145 50  0000 L CNN
F 1 "100" H 7405 2085 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 7375 2125 50  0001 C CNN
F 3 "" H 7375 2125 50  0000 C CNN
	1    7375 2125
	0    -1   -1   0   
$EndComp
$Comp
L R_Small R6
U 1 1 594D6087
P 8425 1900
F 0 "R6" H 8455 1920 50  0000 L CNN
F 1 "10K" H 8455 1860 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 8425 1900 50  0001 C CNN
F 3 "" H 8425 1900 50  0000 C CNN
	1    8425 1900
	0    -1   -1   0   
$EndComp
$Comp
L C_Small C9
U 1 1 594D608D
P 7825 2275
F 0 "C9" H 7835 2345 50  0000 L CNN
F 1 "0.1uF" H 7835 2195 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 7825 2275 50  0001 C CNN
F 3 "" H 7825 2275 50  0000 C CNN
	1    7825 2275
	1    0    0    -1  
$EndComp
Wire Wire Line
	7475 2125 8050 2125
Wire Wire Line
	7825 2175 7825 2125
Connection ~ 7825 2125
Wire Wire Line
	7575 2175 7575 2125
Connection ~ 7575 2125
Wire Wire Line
	8050 2225 7975 2225
Wire Wire Line
	7975 2225 7975 2425
Wire Wire Line
	7975 2425 7275 2425
Wire Wire Line
	7825 2425 7825 2375
Wire Wire Line
	7575 2425 7575 2375
Connection ~ 7825 2425
Wire Wire Line
	8325 1900 7975 1900
Wire Wire Line
	7975 1900 7975 2125
Connection ~ 7975 2125
Wire Wire Line
	8525 1900 8875 1900
Wire Wire Line
	8875 1900 8875 2175
Wire Wire Line
	8825 2175 8925 2175
Text GLabel 7275 2125 0    60   Input ~ 0
V33
Text GLabel 7275 2425 0    60   Input ~ 0
GND
Connection ~ 7575 2425
Text GLabel 8925 2175 2    60   Input ~ 0
IRIN2
Connection ~ 8875 2175
$Comp
L VS18388 U4
U 1 1 594D65AD
P 8450 2800
F 0 "U4" H 8450 2850 60  0000 C CNN
F 1 "VS18388" H 8450 2500 60  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 8450 2800 60  0001 C CNN
F 3 "" H 8450 2800 60  0000 C CNN
	1    8450 2800
	1    0    0    -1  
$EndComp
$Comp
L C_Small C7
U 1 1 594D65B3
P 7575 3025
F 0 "C7" H 7585 3095 50  0000 L CNN
F 1 "100uF" H 7585 2945 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 7575 3025 50  0001 C CNN
F 3 "" H 7575 3025 50  0000 C CNN
	1    7575 3025
	1    0    0    -1  
$EndComp
$Comp
L R_Small R4
U 1 1 594D65B9
P 7375 2875
F 0 "R4" H 7405 2895 50  0000 L CNN
F 1 "100" H 7405 2835 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 7375 2875 50  0001 C CNN
F 3 "" H 7375 2875 50  0000 C CNN
	1    7375 2875
	0    -1   -1   0   
$EndComp
$Comp
L R_Small R7
U 1 1 594D65BF
P 8425 2650
F 0 "R7" H 8455 2670 50  0000 L CNN
F 1 "10K" H 8455 2610 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 8425 2650 50  0001 C CNN
F 3 "" H 8425 2650 50  0000 C CNN
	1    8425 2650
	0    -1   -1   0   
$EndComp
$Comp
L C_Small C10
U 1 1 594D65C5
P 7825 3025
F 0 "C10" H 7835 3095 50  0000 L CNN
F 1 "0.1uF" H 7835 2945 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 7825 3025 50  0001 C CNN
F 3 "" H 7825 3025 50  0000 C CNN
	1    7825 3025
	1    0    0    -1  
$EndComp
Wire Wire Line
	7475 2875 8050 2875
Wire Wire Line
	7825 2925 7825 2875
Connection ~ 7825 2875
Wire Wire Line
	7575 2925 7575 2875
Connection ~ 7575 2875
Wire Wire Line
	8050 2975 7975 2975
Wire Wire Line
	7975 2975 7975 3175
Wire Wire Line
	7975 3175 7275 3175
Wire Wire Line
	7825 3175 7825 3125
Wire Wire Line
	7575 3175 7575 3125
Connection ~ 7825 3175
Wire Wire Line
	8325 2650 7975 2650
Wire Wire Line
	7975 2650 7975 2875
Connection ~ 7975 2875
Wire Wire Line
	8525 2650 8875 2650
Wire Wire Line
	8875 2650 8875 2925
Wire Wire Line
	8825 2925 8925 2925
Text GLabel 7275 2875 0    60   Input ~ 0
V33
Text GLabel 7275 3175 0    60   Input ~ 0
GND
Connection ~ 7575 3175
Text GLabel 8925 2925 2    60   Input ~ 0
IRIN3
Connection ~ 8875 2925
$Comp
L VS18388 U5
U 1 1 594D65E1
P 8450 3550
F 0 "U5" H 8450 3600 60  0000 C CNN
F 1 "VS18388" H 8450 3250 60  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 8450 3550 60  0001 C CNN
F 3 "" H 8450 3550 60  0000 C CNN
	1    8450 3550
	1    0    0    -1  
$EndComp
$Comp
L C_Small C8
U 1 1 594D65E7
P 7575 3775
F 0 "C8" H 7585 3845 50  0000 L CNN
F 1 "100uF" H 7585 3695 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 7575 3775 50  0001 C CNN
F 3 "" H 7575 3775 50  0000 C CNN
	1    7575 3775
	1    0    0    -1  
$EndComp
$Comp
L R_Small R5
U 1 1 594D65ED
P 7375 3625
F 0 "R5" H 7405 3645 50  0000 L CNN
F 1 "100" H 7405 3585 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 7375 3625 50  0001 C CNN
F 3 "" H 7375 3625 50  0000 C CNN
	1    7375 3625
	0    -1   -1   0   
$EndComp
$Comp
L R_Small R8
U 1 1 594D65F3
P 8425 3400
F 0 "R8" H 8455 3420 50  0000 L CNN
F 1 "10K" H 8455 3360 50  0000 L CNN
F 2 "Resistors_SMD:R_1206" H 8425 3400 50  0001 C CNN
F 3 "" H 8425 3400 50  0000 C CNN
	1    8425 3400
	0    -1   -1   0   
$EndComp
$Comp
L C_Small C11
U 1 1 594D65F9
P 7825 3775
F 0 "C11" H 7835 3845 50  0000 L CNN
F 1 "0.1uF" H 7835 3695 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 7825 3775 50  0001 C CNN
F 3 "" H 7825 3775 50  0000 C CNN
	1    7825 3775
	1    0    0    -1  
$EndComp
Wire Wire Line
	7475 3625 8050 3625
Wire Wire Line
	7825 3675 7825 3625
Connection ~ 7825 3625
Wire Wire Line
	7575 3675 7575 3625
Connection ~ 7575 3625
Wire Wire Line
	8050 3725 7975 3725
Wire Wire Line
	7975 3725 7975 3925
Wire Wire Line
	7975 3925 7275 3925
Wire Wire Line
	7825 3925 7825 3875
Wire Wire Line
	7575 3925 7575 3875
Connection ~ 7825 3925
Wire Wire Line
	8325 3400 7975 3400
Wire Wire Line
	7975 3400 7975 3625
Connection ~ 7975 3625
Wire Wire Line
	8525 3400 8875 3400
Wire Wire Line
	8875 3400 8875 3675
Wire Wire Line
	8825 3675 8925 3675
Text GLabel 7275 3625 0    60   Input ~ 0
V33
Text GLabel 7275 3925 0    60   Input ~ 0
GND
Connection ~ 7575 3925
Text GLabel 8925 3675 2    60   Input ~ 0
IRIN4
Connection ~ 8875 3675
$EndSCHEMATC
