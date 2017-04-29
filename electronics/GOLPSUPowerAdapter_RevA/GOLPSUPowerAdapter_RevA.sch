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
Title "GOL PSU Power Adapter"
Date "2017-04-28"
Rev "A"
Comp "Matthew Swarts"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CONN_01X04 P2
U 1 1 590401F8
P 2900 3275
F 0 "P2" H 2900 3525 50  0000 C CNN
F 1 "CONN_01X04" V 3000 3275 50  0000 C CNN
F 2 "Connect:AK300-4" H 2900 3275 50  0001 C CNN
F 3 "" H 2900 3275 50  0000 C CNN
	1    2900 3275
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X09 P1
U 1 1 59040245
P 2850 1925
F 0 "P1" H 2850 2425 50  0000 C CNN
F 1 "CONN_01X09" V 2950 1925 50  0000 C CNN
F 2 "Terminal_Blocks:TerminalBlock_Pheonix_PT-3.5mm_9pol" H 2850 1925 50  0001 C CNN
F 3 "" H 2850 1925 50  0000 C CNN
	1    2850 1925
	1    0    0    -1  
$EndComp
Text GLabel 2700 3125 0    60   Input ~ 0
GND
Text GLabel 2700 3225 0    60   Input ~ 0
A
Text GLabel 2700 3325 0    60   Input ~ 0
B
Text GLabel 2700 3425 0    60   Input ~ 0
V12
Text GLabel 2650 1525 0    60   Input ~ 0
GND
Text GLabel 2650 1625 0    60   Input ~ 0
GND
Text GLabel 2650 1725 0    60   Input ~ 0
GND
Text GLabel 2650 1825 0    60   Input ~ 0
GND
Text GLabel 2650 1925 0    60   Input ~ 0
GND
Text GLabel 2650 2025 0    60   Input ~ 0
GND
Text GLabel 2650 2125 0    60   Input ~ 0
GND
Text GLabel 2650 2225 0    60   Input ~ 0
GND
Text GLabel 2650 2325 0    60   Input ~ 0
GND
$Comp
L CONN_01X09 P4
U 1 1 59040484
P 3475 1925
F 0 "P4" H 3475 2425 50  0000 C CNN
F 1 "CONN_01X09" V 3575 1925 50  0000 C CNN
F 2 "Terminal_Blocks:TerminalBlock_Pheonix_PT-3.5mm_9pol" H 3475 1925 50  0001 C CNN
F 3 "" H 3475 1925 50  0000 C CNN
	1    3475 1925
	1    0    0    -1  
$EndComp
Text GLabel 3275 1525 0    60   Input ~ 0
GND
Text GLabel 3275 1625 0    60   Input ~ 0
GND
Text GLabel 3275 1725 0    60   Input ~ 0
GND
Text GLabel 3275 1825 0    60   Input ~ 0
GND
Text GLabel 3275 1925 0    60   Input ~ 0
GND
Text GLabel 3275 2025 0    60   Input ~ 0
GND
Text GLabel 3275 2125 0    60   Input ~ 0
GND
Text GLabel 3275 2225 0    60   Input ~ 0
GND
Text GLabel 3275 2325 0    60   Input ~ 0
GND
$Comp
L CONN_01X09 P7
U 1 1 590404D8
P 4125 1925
F 0 "P7" H 4125 2425 50  0000 C CNN
F 1 "CONN_01X09" V 4225 1925 50  0000 C CNN
F 2 "Terminal_Blocks:TerminalBlock_Pheonix_PT-3.5mm_9pol" H 4125 1925 50  0001 C CNN
F 3 "" H 4125 1925 50  0000 C CNN
	1    4125 1925
	1    0    0    -1  
$EndComp
Text GLabel 3925 1525 0    60   Input ~ 0
V12
Text GLabel 3925 1625 0    60   Input ~ 0
V12
Text GLabel 3925 1725 0    60   Input ~ 0
V12
Text GLabel 3925 1825 0    60   Input ~ 0
V12
Text GLabel 3925 1925 0    60   Input ~ 0
V12
Text GLabel 3925 2025 0    60   Input ~ 0
V12
Text GLabel 3925 2125 0    60   Input ~ 0
V12
Text GLabel 3925 2225 0    60   Input ~ 0
V12
Text GLabel 3925 2325 0    60   Input ~ 0
V12
$Comp
L CONN_01X09 P10
U 1 1 5904057E
P 4725 1925
F 0 "P10" H 4725 2425 50  0000 C CNN
F 1 "CONN_01X09" V 4825 1925 50  0000 C CNN
F 2 "Terminal_Blocks:TerminalBlock_Pheonix_PT-3.5mm_9pol" H 4725 1925 50  0001 C CNN
F 3 "" H 4725 1925 50  0000 C CNN
	1    4725 1925
	1    0    0    -1  
$EndComp
Text GLabel 4525 1525 0    60   Input ~ 0
V12
Text GLabel 4525 1625 0    60   Input ~ 0
V12
Text GLabel 4525 1725 0    60   Input ~ 0
V12
Text GLabel 4525 1825 0    60   Input ~ 0
V12
Text GLabel 4525 1925 0    60   Input ~ 0
V12
Text GLabel 4525 2025 0    60   Input ~ 0
V12
Text GLabel 4525 2125 0    60   Input ~ 0
V12
Text GLabel 4525 2225 0    60   Input ~ 0
V12
Text GLabel 4525 2325 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P5
U 1 1 5904068F
P 3575 3275
F 0 "P5" H 3575 3525 50  0000 C CNN
F 1 "CONN_01X04" V 3675 3275 50  0000 C CNN
F 2 "Connect:AK300-4" H 3575 3275 50  0001 C CNN
F 3 "" H 3575 3275 50  0000 C CNN
	1    3575 3275
	1    0    0    -1  
$EndComp
Text GLabel 3375 3125 0    60   Input ~ 0
GND
Text GLabel 3375 3225 0    60   Input ~ 0
A
Text GLabel 3375 3325 0    60   Input ~ 0
B
Text GLabel 3375 3425 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P8
U 1 1 590406D3
P 4250 3275
F 0 "P8" H 4250 3525 50  0000 C CNN
F 1 "CONN_01X04" V 4350 3275 50  0000 C CNN
F 2 "Connect:AK300-4" H 4250 3275 50  0001 C CNN
F 3 "" H 4250 3275 50  0000 C CNN
	1    4250 3275
	1    0    0    -1  
$EndComp
Text GLabel 4050 3125 0    60   Input ~ 0
GND
Text GLabel 4050 3225 0    60   Input ~ 0
A
Text GLabel 4050 3325 0    60   Input ~ 0
B
Text GLabel 4050 3425 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P11
U 1 1 590406DD
P 4925 3275
F 0 "P11" H 4925 3525 50  0000 C CNN
F 1 "CONN_01X04" V 5025 3275 50  0000 C CNN
F 2 "Connect:AK300-4" H 4925 3275 50  0001 C CNN
F 3 "" H 4925 3275 50  0000 C CNN
	1    4925 3275
	1    0    0    -1  
$EndComp
Text GLabel 4725 3125 0    60   Input ~ 0
GND
Text GLabel 4725 3225 0    60   Input ~ 0
A
Text GLabel 4725 3325 0    60   Input ~ 0
B
Text GLabel 4725 3425 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P3
U 1 1 59040803
P 2900 3900
F 0 "P3" H 2900 4150 50  0000 C CNN
F 1 "CONN_01X04" V 3000 3900 50  0000 C CNN
F 2 "Connect:AK300-4" H 2900 3900 50  0001 C CNN
F 3 "" H 2900 3900 50  0000 C CNN
	1    2900 3900
	1    0    0    -1  
$EndComp
Text GLabel 2700 3750 0    60   Input ~ 0
GND
Text GLabel 2700 3850 0    60   Input ~ 0
A
Text GLabel 2700 3950 0    60   Input ~ 0
B
Text GLabel 2700 4050 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P6
U 1 1 5904080D
P 3575 3900
F 0 "P6" H 3575 4150 50  0000 C CNN
F 1 "CONN_01X04" V 3675 3900 50  0000 C CNN
F 2 "Connect:AK300-4" H 3575 3900 50  0001 C CNN
F 3 "" H 3575 3900 50  0000 C CNN
	1    3575 3900
	1    0    0    -1  
$EndComp
Text GLabel 3375 3750 0    60   Input ~ 0
GND
Text GLabel 3375 3850 0    60   Input ~ 0
A
Text GLabel 3375 3950 0    60   Input ~ 0
B
Text GLabel 3375 4050 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P9
U 1 1 59040817
P 4250 3900
F 0 "P9" H 4250 4150 50  0000 C CNN
F 1 "CONN_01X04" V 4350 3900 50  0000 C CNN
F 2 "Connect:AK300-4" H 4250 3900 50  0001 C CNN
F 3 "" H 4250 3900 50  0000 C CNN
	1    4250 3900
	1    0    0    -1  
$EndComp
Text GLabel 4050 3750 0    60   Input ~ 0
GND
Text GLabel 4050 3850 0    60   Input ~ 0
A
Text GLabel 4050 3950 0    60   Input ~ 0
B
Text GLabel 4050 4050 0    60   Input ~ 0
V12
$Comp
L CONN_01X04 P12
U 1 1 59040821
P 4925 3900
F 0 "P12" H 4925 4150 50  0000 C CNN
F 1 "CONN_01X04" V 5025 3900 50  0000 C CNN
F 2 "Connect:AK300-4" H 4925 3900 50  0001 C CNN
F 3 "" H 4925 3900 50  0000 C CNN
	1    4925 3900
	1    0    0    -1  
$EndComp
Text GLabel 4725 3750 0    60   Input ~ 0
GND
Text GLabel 4725 3850 0    60   Input ~ 0
A
Text GLabel 4725 3950 0    60   Input ~ 0
B
Text GLabel 4725 4050 0    60   Input ~ 0
V12
$EndSCHEMATC
