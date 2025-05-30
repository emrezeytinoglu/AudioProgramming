import serial
from pythonosc.udp_client import SimpleUDPClient
import time

ser = serial.Serial('/dev/ttyACM0', 115200, timeout=1)
time.sleep(2)

client = SimpleUDPClient("127.0.0.1", 57120)

while True:
    try:
        line = ser.readline().decode('utf-8', errors='ignore').strip()
        if not line:
            continue

        parts = line.split(',')

        if len(parts) != 13:
            print("Invalid data:", parts)
            continue

        dryWet      = float(parts[0])
        character   = float(parts[1])
        length      = float(parts[2])
        air         = float(parts[3])
        noiseAmp    = float(parts[4])
        delayMix    = float(parts[5])
        delayTime   = int(float(parts[6]))
        delayFB     = float(parts[7])
        pitchRate   = float(parts[8])
        pitchAmount = float(parts[9])
        pitchMix    = float(parts[10])

        presetStr   = parts[11].strip()
        lfoShape    = parts[12].strip()


        client.send_message("/dryWet", dryWet)
        client.send_message("/character", character)
        client.send_message("/length", length)
        client.send_message("/air", air)
        client.send_message("/noise/amp", noiseAmp)

        client.send_message("/delay/mix", delayMix)
        client.send_message("/delay/time", delayTime)
        client.send_message("/delay/feedback", delayFB)

        client.send_message("/pitchshift/rate", pitchRate)
        client.send_message("/pitchshift/amount", pitchAmount)
        client.send_message("/pitchshift/mix", pitchMix)

        if presetStr in ["Room", "Hall", "Cathedral"]:
            client.send_message("/jpverb/preset", presetStr)

        if lfoShape in ["sine", "triangle", "square"]:
            client.send_message("/pitchshift/lfo", lfoShape)

        print("OSC sent:", parts)

    except Exception as e:
        print("Error:", e)
