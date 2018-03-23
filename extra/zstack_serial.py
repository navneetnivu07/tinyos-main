import serial
import time
import urllib
ser = serial.Serial(
    port='/dev/ttyUSB0', # for windows use COM1
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)
host = "localhost"
while 1:
    a = ser.readline()
    ary = a.split(',')
    print(a)
    #"http://localhost/wsn/ins.php?pc=1&sa=1&nsln=1&lq=1&id=1&temp=1&lux=1&hum=1&co=1&co2=1"
    if(len(ary) > 5):
        sense = ary[5]
        print(sense[1:2])
        if(sense[1:2] == 'T'):
            query = "http://" +host+"/wsn/ins.php?pc=" + ary[0] + "&sa=" + ary[1] + "&nsln=" + ary[2] + "&lq=" + ary[3] + "&id=" + ary[4] + "&temp=" + ary[5] + "&lux=" + ary[6] + "&hum=" + ary[7] + "&co=" + '--' + "&co2=" + '--'
            query = query.replace(" ", "")
            query = query.replace("T", "")
            query = query.replace("L", "")
            query = query.replace("H", "")
            print(query)
            contents = urllib.urlopen(query).read()
            print(contents)
        elif(sense[1:2] == 'C'):
            query = "http://" +host+"/wsn/ins.php?pc=" + ary[0] + "&sa=" + ary[1] + "&nsln=" + ary[2] + "&lq=" + ary[3] + "&id=" + ary[4] + "&temp=" + '--' + "&lux=" + '--' + "&hum=" + '--' + "&co=" + ary[5] + "&co2=" + ary[6]
            query = query.replace(" ", "")
            query = query.replace("C", "")
            query = query.replace("O", "")
            contents = urllib.urlopen(query).read()
            print(contents)
        time.sleep(1)

