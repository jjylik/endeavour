import subprocess
import wave, struct
import os
import sys

if len(sys.argv) != 2:
   print('Usage: python3 main.py <filename>')
   sys.exit()


print("Writing amplitude file... ", end="")
wavefile = wave.open(sys.argv[1], 'r')

amplitude_file = open('amplitude.out', 'w')
amplitude_file.write("amplitude"+'\n')
length = wavefile.getnframes()

for i in range(0, length):
    wavedata = wavefile.readframes(1)
    data = struct.unpack("<h", wavedata)
    amplitude_file.write(str(data[0])+'\n')

amplitude_file.close()

print("done")

print("Deciphering the message. This can take several minutes.")

result = subprocess.run([f'sqlite3 < {os.getcwd()}/morsecode.sql'], shell=True, capture_output=True)

print(result.stdout.decode('UTF-8')[1:-2])
