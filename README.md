# GameOfLight
Game of Light Installation


## Requirements
- 36 stations
- each station 1m in lenght covered in leds
- 5 sections of lamp to create a 'species'
- automatic identification of each lamp 'species'

## Location
- Hyatt Regency Denver at Co Convention Center
    - [Floorplans](https://denver.regency.hyatt.com/hyatt/images/hotels/dencc/floorplan.pdf)

## Main Power Supply
- 12,24V power supply recommended with a buck converter (for leds and mcu) or linear regulator (if for just mcu) at each location
- typical computer psu will have several 12V rails. A [modular](https://www.amazon.com/EVGA-Supernova-120-G1-1000-VR-Modular-Supply/dp/B00CGYCNG2) psu would be best for ensuring enough 12V rails without extra wiring.
- if there is 5m of leds with 30 leds/meter wrapped around a tube, then that is 150 leds. 150 leds at 60mA is 9A running at around 3V. This is around 27-30W assuming an efficient local conversion of power, which is likely embedded within the addressable chip.
- 36 stations of 30W is a total max draw of 1080W. So a 800W-1000W-1200W power supply should be fine.

## Local Power Regulation
- Switch mode power supply for high current, such as this [300W Step Down Regulator](https://www.aliexpress.com/item/DC-CC-12A-300W-Step-Down-Buck-Converter-7-32V-To-0-8-28V-Power-module/32247251105.html)
- Linear regulator for low current needs (eg. if using 12V main power supply and 12V leds)

## Power Distribution Connectors
- ribbon cable (40 pin), using most pins for power and ground
- RJ45 can only handle up to 1A
- RJ11 can only handle up to 1A
- 5557 molex need to crimp; not designed to be removed often;
- DC Barrel Jack 5.5mm, most connectors designed for 3A, but can get special ones for laptaps that can handle 8A
- [6 pin Pluggable Screw Terminal](https://www.aliexpress.com/item/Free-shipping-5-sets-ht5-08-6pin-Terminal-plug-type-300V-10A-5-08mm-pitch-connector/32667091061.html)
    - 12V - GND - DataMinus - DataPlus - GND - 12V
- [7 pin Pluggable Screw Terminal](https://www.aliexpress.com/item/Free-shipping-5-sets-ht5-08-7pin-Terminal-plug-type-300V-10A-5-08mm-pitch-connector/32665369867.html)
    - 12V - GND - DataMinus - GND - DataPlus - GND - 12V
    - extra ground in middle is for connecting ground to the main controller in the case that the main controller is not using the same ground as the stations' ground from the main power supply. For example if the main controller is run by or powered by a laptop.

## Power Distribution Wiring
- [$27 100 ft. 14/2 White Solid SIMpull NM-B Wire](http://www.homedepot.com/p/Romex-100-ft-14-2-White-Solid-SIMpull-NM-B-Wire-28827428/202316379)
- [$38 100 ft. 14-2 Black Stranded Landscape Lighting Cable](http://www.homedepot.com/p/Southwire-100-ft-14-2-Black-Stranded-Landscape-Lighting-Cable-55213243/202316247)
- [$16 100' Feet 14 Gauge Red Black Stranded 2 Conductor Speaker Wire Car Home Audio Ga](https://www.amazon.com/Gauge-Black-Stranded-Conductor-Speaker/dp/B00J36SUWC)
- [$26 eXtreme Products 2 Conductor 14 Gauge Stranded Copper Core Speaker Wire (No Aluminum Core) for Home Theater Speakers Radio Speakers Car Audio or Any Audio Interface - 100 Foot Clear Coat](https://www.amazon.com/eXtreme-Conductor-Speaker-Wire-Interface/dp/B01HBWJ1HM)

## Signal Distribution Wiring
- for RS485 we need overall impedance of 120 ohms. For our distances, lighter gauges are fine, but [this](http://www.chipkin.com/rs485-cables-why-you-need-3-wires-for-2-two-wire-rs485/) recommends 24AWG or heavier. [Here are more recommendations](http://www.bb-elec.com/Learning-Center/All-White-Papers/Serial/Cable-Selection-for-RS422-and-RS485-Systems/Cable-Selection-for-RS-422-and-RS-485-Systems.PDF).
- Two wire or Three wire. May need three wire to include an additional ground in the case that the main controller is not using the same ground as the stations' power ground from the main power supply. This could be the case with a laptop for example.
- [$13 Ethernet Cable (100 Feet)](https://www.amazon.com/Mediabridge-Ethernet-Cable-100-Feet/dp/B003RCEAB8), cut and pull out twisted pair wires
- [$23 100-Feet 24-Gauge 4 Pair Cat 5e](https://www.amazon.com/Southwire-56917643-100-Feet-Outdoor-CMR-75-Degree/dp/B005V0BJ1S)

## LEDs
- addressable color leds
- could use 1 2m strip folded over
- could use 1 5m strip wrapped around a pole (this will provide more light)
- WS2811 with 3 color leds on each section, each led is rgb, but in clusters of 3. This is fine for our applications. Also these are 12V, which is better for current draw. [$8-10 per 5m strip](https://www.aliexpress.com/item/best-price-5m-DC12V-ws2811ic-5050-RGB-SMD-individually-addressable-ws2811-led-pixels-strip/32385533484.html)

## Control
- recommended individual controller for each station; otherwise refresh rate is likely to be very slow
- attiny85 possible? may not have enough pins; but might
- atmega328p?
- arduino pro mini clone ($1-2)
- 1 master device with 36 other devices. The master controls the CA simulation and dictates the animation colors and patterns to each of the 36 stations.
    - however, it is possible to have the 36 devices run the simulation themselves, with each device getting data about it's neighbors, and computing the next step and selecting it's own animation. This would also require that they all synchronize, to some degree on an update algorithm. This could be done. Would be really nice to have. This is something we could first develop in the master/slave configuration, and then later spend time developing the slave-only method if there is time. The slave-only would really connect conceptually rather than having any kind of single master.

## Recognition
- manual input (what a drag)
- infrared linear quadrature encoder or similar to recognize the lamp 'species' as a barcode when the lamp shade is slide over the rod
    - this would argue for a separate controller on each station
- IR Distance Sensor
    - [XK-GK-5010A](https://www.aliexpress.com/item/Hot-Sale-Short-Distance-Sensor-Induction-Switch-Dual-Functions-Ir-Sensor-Switch-Active-Performance-Modules-Board/32769983297.html)
    - [TCRT5000 Sensor](https://www.aliexpress.com/item/20-pcs-TCRT5000L-TCRT5000-Reflective-Optical-Sensor-Infrared-IR-Photoelectric-Switch/1909098476.html)
    - [TCRT5000 Module with Pot](https://www.aliexpress.com/item/Free-shipping-Line-Track-Sensor-TCRT5000-Infrared-Reflective-IR-Photoelectric-Switch-Barrier/32517344067.html) [3D model](http://www.stlfinder.com/model/line-finder-tcrt5000/4505787) 32mmx14mm
    - [TCRT5000 Module Digital Only](https://www.aliexpress.com/item/New-TCRT5000-Line-Track-Sensor-Module-Reflection-Infrared-Sensor-Switch-Module-For-Arduino-5pcs-lot-Free/32359412782.html)
    - [TCRT5000 Module Analog Only](https://www.aliexpress.com/item/10PCS-IR-Infrared-Line-Track-Follower-Sensor-TCRT5000-Obstacle-Avoidanc-For-Arduino/32672744833.html)
    - [4 Channel Line Follower](https://www.aliexpress.com/item/Free-shipping-4-way-infrared-tracing-line-follow-tracking-obatacle-avoidance-Sensor-Module-for-Aduino-Robot/32645816426.html)
    - [8 Channel Line Follower](https://www.aliexpress.com/item/8-Channel-High-Precision-Infrared-Detection-Tracking-Sensor-Moudle-For-Arduino-Raspberry-Pi-Car-Robot-TCRT5000/32714804808.html)

## Communication
- if using multiple controllers, one on each station, using a [multidrop bus](https://en.wikipedia.org/wiki/Multidrop_bus) rather than a shift/ring topology
- I2C can go about [20ft](http://forum.arduino.cc/index.php?topic=57604.0) without additional driver or buffers
- RS-232 can go about [50ft](https://www.lammertbies.nl/comm/info/RS-232_specs.html)
- RS-422 can go about 5000ft, but is single driver/master, and up to 10 receivers. It is differential, so it's more noise immune than rs232, but the primary downside is it is one directional communcation
- RS-485 can go about [4000ft](http://www.bb-elec.com/Learning-Center/All-White-Papers/Serial/Basics-of-the-RS-485-Standard.aspx)
    - RS-485 to ttl converter using the MAX485CSA
    - $0.38 [Module](https://www.aliexpress.com/item/MAX485-Module-RS-485-TTL-to-RS485-MAX485CSA-Converter-Module-For-Arduino-Integrated-Circuits-Products/32667981058.html)
    - needs twisted pair wire (same as RS422); actually can go without twisted pair if run is shorter, so this isn't completely necessary
    - downside is that RS485 supports up to 32 devices. But I don't think that is built into the protocol. We should be able to go over that. As each device will have it's own way of identifying itself. I think 32 devices is more of a guideline.
    - RS-485 might need a 3.3V version like the [SP3485 Module](https://www.aliexpress.com/item/3-3V-UART-serial-to-RS485-SP3485-Transceiver-Converter-Communication-Module/32224154908.html). This board is lower cost than if we were to purchase just the chip and integrate it into our own design.
