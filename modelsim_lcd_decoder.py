from tqdm import tqdm
from PIL import Image

# Indices for a line.
TIME = 0
DELTA = 1
CLOCK = 2
X = 3
Y = 4
COLOR = 5
PLOT = 6

# Data.
FRAME_LENGTH = 1666664000


def modelsim_lcd_decoder(file_name: str):
    image = Image.new("RGB", (320, 240))
    frame_count = 0
    pbar = tqdm(total=FRAME_LENGTH, unit="ps",
                desc="Processing frame {}".format(frame_count + 1))
    with open(file_name) as f:
        for line in f:
            try:
                data = parse_line(line, image)
            except IndexError:
                continue
            if data and int(data[TIME]) > frame_count * FRAME_LENGTH:
                new_val = int(data[TIME]) - frame_count * FRAME_LENGTH
                pbar.update(new_val - pbar.n)
                if pbar.total < pbar.n:
                    pbar.total = pbar.n
            if data and int(data[TIME]) > (frame_count + 1) * FRAME_LENGTH:
                pbar.close()
                frame_count += 1
                image.save("{:05d}.bmp".format(frame_count), "BMP")
                pbar = tqdm(total=FRAME_LENGTH, unit="ps",
                            desc="Processing frame {}".format(frame_count + 1))

    pbar.total = pbar.n
    pbar.close()
    frame_count += 1
    image.save("{:05d}.bmp".format(frame_count), "BMP")


def parse_line(line: str, image: Image):
    data = line.split()
    location = parse_location(data[X], data[Y])
    color = parse_color(data[COLOR])

    if data[PLOT] == 0 or not location or not color:
        return

    if (0, 0) <= location < (319, 239):
        # print(location)
        image.putpixel(location, color)

    return data


def parse_color(color_data: str):
    try:
        r = int(color_data[0]) * 255
        g = int(color_data[1]) * 255
        b = int(color_data[2]) * 255
    except ValueError:
        return None
    else:
        return r, g, b


def parse_location(x: str, y: str):
    try:
        x = int(x)
        y = int(y)
    except ValueError:
        return None
    else:
        return x, y


modelsim_lcd_decoder("list.lst")
