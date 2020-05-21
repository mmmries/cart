# Cart

A digital dashboard for my golf cart.
Powered by [Nerves](https://www.nerves-project.org/).

## How to Build

Get yourself a micro SD card and plug it into your dev machine.
Now run


```bash
cd firmware
MIX_TARGET=rpi3a mix do deps.get, compile, firmware
MIX_TARGET=rpi3a mix firmware.burn
```

Make sure the command is picking the right drive and then allow permission for the
command to write the SD card.
Then plug that SD card into a raspberry pi 3a and power it on.