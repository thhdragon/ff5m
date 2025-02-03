#!/bin/bash

# Function to write text to /dev/fb0 at a specific position

text="$1"                  # Input text to write
x="$2"                     # X-coordinate of text position
y="$3"                     # Y-coordinate of text position
color="${4:-0xFFFF}"       # Default to white color (RGB565) if not provided

# Framebuffer properties
fb_width=800               # Screen width based on mode "800x480"
fb_height=480              # Screen height based on mode "800x480"
bpp=2                      # Bytes per pixel (16-bit RGB565 = 2 bytes)

# Font dimensions (8x8 pixels per character)
font_width=8
font_height=8

# Ensure position is within bounds
if (( x + ${#text} * font_width > fb_width || y + font_height > fb_height )); then
    echo "Error: Text goes out of framebuffer bounds."
    exit 1
fi

# Convert color to little-endian format (RGB565)
color_le=$(printf "%04x" $((color)) | awk '{print toupper(substr($1,3,2) substr($1,1,2))}')

# A basic ASCII 8x8 font lookup table (only limited chars for demo purposes)
declare -A font_map=(
    [" "]=0000000000000000
    ["!"]=183C3C1818001800
    ["A"]=183C66667E666600
    ["B"]=7E66667E66667E00
    ["C"]=3C66060606663C00
    ["D"]=7E66666666667E00
    ["E"]=7E06067E06067E00
    ["F"]=7E06067E06060600
    ["G"]=3C66067666663C00
    ["H"]=6666667E66666600
    ["I"]=3C18181818183C00
    ["J"]=1C0C0C0C0C6C3800
    ["K"]=666C7870786C6600
    ["L"]=0606060606067E00
    ["M"]=C6EEFED6C6C6C600
    ["N"]=6666766E66666600
    ["O"]=3C66666666663C00
    ["P"]=7E66667E06060600
    ["Q"]=3C6666666E3C0E00
    ["R"]=7E66667E786C6600
    ["S"]=3C66063C60663C00
    ["T"]=7E18181818181800
    ["U"]=6666666666663C00
    ["V"]=66666666663C1800
    ["W"]=C6C6C6D6FEEEC600
    ["X"]=66663C183C666600
    ["Y"]=6666663C18181800
    ["Z"]=7E6030180C067E00
    ["0"]=3C666E7666663C00
    ["1"]=1838181818187E00
    ["2"]=3C66060C18307E00
    ["3"]=3C66061C06663C00
    ["4"]=0C1C3C6C7E0C0C00
    ["5"]=7E06067E60603C00
    ["6"]=3C66067E66663C00
    ["7"]=7E060C1818181800
    ["8"]=3C66663C66663C00
    ["9"]=3C66667E06663C00
)

# Render each character in the text
for (( i = 0; i < ${#text}; i++ )); do
    char="${text:i:1}"  # Get individual character
    font_data=${font_map[$char]:-0000000000000000}  # Fallback to blank for unknown char
    
    # Draw the character pixel-by-pixel
    for (( row = 0; row < font_height; row++ )); do
        for (( col = 0; col < font_width; col++ )); do
            pixel_offset=$(( (y + row) * fb_width + (x + i * font_width + col) ))
            pixel_mask=$(( 0x${font_data:$((row * 2)):2} >> (7 - col) & 1 ))
            
            if (( pixel_mask )); then
                printf "%b" "\x${color_le:2:2}\x${color_le:0:2}" | \
                dd of=/dev/fb0 bs=$bpp seek=$pixel_offset count=1 conv=notrunc status=none
            fi
        done
    done
done
