**Category:** Warmups  
**Author:** John Hammond

![](./files/01%20-%20Maximum%20Sound/01%20-%20Maximum%20Sound.png)

---

I don't know how anyone was expected to figure this out without already knowing what it was. The only reason I did was because I'd already struggled through a very similar challenge years ago on HackTheBox. The attached audio file contained a [Slow-scan Television (SSTV)](https://en.wikipedia.org/wiki/Slow-scan_television) signal.

```
Slow-scan television (SSTV) is a picture transmission method, used mainly by amateur radio operators, to transmit and receive static pictures via radio in monochrome or color. 
```

Using [this project](https://github.com/colaclanth/sstv) from GitHub made it easy enough to decode:

```
$ sstv -d maximum_sound.wav -o maxium_sound.png
[sstv] Searching for calibration header... Found!    
[sstv] Detected SSTV mode Scottie 1
[sstv] Decoding image...                                                                                                         [####################################################################################################]  99%
[sstv] Reached end of audio whilst decoding.
[sstv] Drawing image data...
[sstv] ...Done!
```


![](./files/01%20-%20Maximum%20Sound/maxium_sound.png)

I had no idea what this was and no amount of Googling was helping, so I reluctantly asked ChatGPT for some help.

![](./files/01%20-%20Maximum%20Sound/01.png)

I tried multiple online MaxiCode scanners, but they all failed to decode the image. Eventually I realized that the multicolored background was most likely interfering with the process, so I cropped it out and tried again.

![](./files/01%20-%20Maximum%20Sound/02.png)

Uploading this to https://www.dynamsoft.com/barcode-reader/barcode-types/maxicode/ finally revealed the flag:

![](./files/01%20-%20Maximum%20Sound/03.png)

Flag: **flag{d60ea9faec46c2de1c72533ae3ad11d7}**

---

**Files:**
- [maximum_sound.wav](./files//01%20-%20Maximum%20Sound/maximum_sound.wav)