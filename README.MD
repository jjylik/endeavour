# Endeavour

Parse morse code from a wav file using SQLite.

## Prerequisites

* Python 3+
* sqlite3
* a mono wav file containing morse code

## Running

```
python3 ./main.py <wav_file>
```

### Example

```
python3 ./main.py message.wav
# Output:
-- .- -.--/.-- ./- [redacted]
```

## Analyzing the output

Copy-paste the output to https://morsedecoder.com/ to decode to Latin letters

## Motivation

This is a tongue in cheek solution to a Wunderdog programming puzzle.  
https://www.wunderdog.fi/wundernut