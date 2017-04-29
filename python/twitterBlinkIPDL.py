from tweepy.streaming import StreamListener #tweepy is an external library , may need to be installed 
from tweepy import OAuthHandler
from tweepy import Stream
import json
#import serial
#from phue import Bridge #phue is an external library, may need to be installed 
#import RPi.GPIO as GPIO, time #these libraries are present by default in the adafruit occidentalis OS
#import colorsys

#ser=serial.Serial("/dev/ttyACM0", 28800)

# Import the time module enable sleeps between turning the led on and off.
import time

# Import the GPIOGalileoGen2 class from the wiringx86 module.
from wiringx86 import GPIOGalileoGen2 as GPIO
 
# Create a new instance of the GPIOGalileoGen2 class.
# Setting debug=True gives information about the interaction with sysfs.
gpio = GPIO(debug=False)

gpio.pinMode(9, gpio.OUTPUT)
gpio.pinMode(10, gpio.OUTPUT)
gpio.pinMode(11, gpio.OUTPUT)
gpio.pinMode(12, gpio.OUTPUT)
gpio.pinMode(13, gpio.OUTPUT)

#########################################Twitter Stuff###################################
# Go to http://dev.twitter.com log in and create an app.
# The consumer key and secret will be generated for you after
consumer_key="YY6TtixQVdWjN9LaosSE60fSk"
consumer_secret="bMHvaowJnGRHhd9KNEgNyUZKJjISUv4jHcu8myRs6mcbVSpA4e"
# After the step above, you will be redirected to your app's page.
# Create an access token under the the "Your access token" section
access_token="17581491-NGOf4lAxCWJoEmAF5Olz857J4Pfr2xhR9ihoia3Fn"
access_token_secret="Q1WbfbDkuRo5M0BvPp9Jv5aG87tY0CncggcEsMD4M8giA"

###################################### Hue Blink ########################

#this class handles the "firehose" stream data coming from twitter
class StdOutListener(StreamListener):
    """ A listener handles tweets are the received from the stream.
    This is a basic listener that just prints received tweets to stdout.

    """
	#this function gets called each time one of the keywords specified are found in the twitter stream
    def on_data(self, data):
		try:
			i=0      
			txt= json.loads(data)['text']
			for word in keywords:
				print "looking for :"+word
				if txt.lower().find(word.lower())!=-1:
					#ser.write(letters[i])
					# Write a state to the pin. ON or OFF.
					pin = int(leds[i])
					gpio.digitalWrite(pin, gpio.HIGH)
					time.sleep(.05)					# Toggle the state.
					gpio.digitalWrite(pin, gpio.LOW)

					print "\n\nFound a tweet with the word "+word+":\n"+txt.encode('utf-8')
				i+=1

		
		except KeyboardInterrupt:
			# Leave the led turned off.
			print '\nCleaning up...'
			gpio.digitalWrite(12, gpio.LOW)
			gpio.digitalWrite(11, gpio.LOW)
			gpio.digitalWrite(10, gpio.LOW)
			gpio.digitalWrite(9, gpio.LOW)

			# Do a general cleanup. Calling this function is not mandatory.
			gpio.cleanup()

		except Exception as e:
			print "\n\nError\nn",e
		return True
 


#main execution start
l = StdOutListener() #instantiate the stream class
auth = OAuthHandler(consumer_key, consumer_secret) #authenticate with the twitter api
auth.set_access_token(access_token, access_token_secret) #authenticate with the twitter api
keywords=['apple','intel','microsoft','google','Georgia Tech'] #specify keywords to track in realtime
letters=['a','b','c','d','e']
leds=['9','10','11','12','13']
colors=[(255,0,0), (255,0,225), (255,255,0), (50,255,0), (0,0,255)] #specify colors to associate with each keyword in RGB, WARNING: number of entries in keywords list and the colors list MUST match 
stream = Stream(auth, l)  #assign stream data 
stream.filter(track=keywords) #apply keyword filters to the stream


