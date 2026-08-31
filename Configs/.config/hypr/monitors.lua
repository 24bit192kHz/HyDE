-- Manually managed monitor layouts
hl.monitor({
    output = "DP-1",
    mode = "2560x1080@99.94",
    position = "0x0",
    scale = 1.0,
    bitdepth = 10,
    transform = 1
})

hl.monitor({
    output = "DP-2",
    mode = "3440x1440@240.09",
    position = "1080x753",
    scale = 1.0,
    bitdepth = 10,
    cm = "hdr",
    sdrbrightness = 1.2,
    sdrsaturation = 1.1,
    sdr_min_luminance = 0.2,
})
