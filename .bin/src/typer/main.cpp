// Screen typer
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license

#include <cstring>
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <ranges>
#include <string>
#include <unistd.h>
#include <vector>
#include <map>
#include <sys/mman.h>
#include <sys/stat.h>

#include "../../lib/argparse/argparse.hpp"

#include "../common/text.h"


#include "../common/fonts/JetBrainsMonoThin24pt.h"
#include "../common/fonts/JetBrainsMonoThin18pt.h"
#include "../common/fonts/JetBrainsMonoThin12pt.h"
#include "../common/fonts/JetBrainsMonoBold24pt.h"
#include "../common/fonts/JetBrainsMonoBold18pt.h"
#include "../common/fonts/JetBrainsMonoBold12pt.h"
#include "../common/fonts/JetBrainsMonoBold9pt.h"
#include "../common/fonts/JetBrainsMono24pt.h"
#include "../common/fonts/JetBrainsMono18pt.h"
#include "../common/fonts/JetBrainsMono12pt.h"
#include "../common/fonts/JetBrainsMono9pt.h"
#include "../common/fonts/RobotoThin24pt.h"
#include "../common/fonts/RobotoThin18pt.h"
#include "../common/fonts/RobotoThin12pt.h"
#include "../common/fonts/RobotoBold24pt.h"
#include "../common/fonts/RobotoBold18pt.h"
#include "../common/fonts/RobotoBold12pt.h"
#include "../common/fonts/RobotoBold9pt.h"
#include "../common/fonts/Roboto24pt.h"
#include "../common/fonts/Roboto18pt.h"
#include "../common/fonts/Roboto12pt.h"
#include "../common/fonts/Roboto9pt.h"

#define WIDTH 800
#define HEIGHT 480

std::map<std::string, const Font *> fonts{
    {JetBrainsMonoThin24pt.name, &JetBrainsMonoThin24pt},
    {JetBrainsMonoThin18pt.name, &JetBrainsMonoThin18pt},
    {JetBrainsMonoThin12pt.name, &JetBrainsMonoThin12pt},
    {JetBrainsMonoBold24pt.name, &JetBrainsMonoBold24pt},
    {JetBrainsMonoBold18pt.name, &JetBrainsMonoBold18pt},
    {JetBrainsMonoBold12pt.name, &JetBrainsMonoBold12pt},
    {JetBrainsMonoBold9pt.name, &JetBrainsMonoBold9pt},
    {JetBrainsMono24pt.name, &JetBrainsMono24pt},
    {JetBrainsMono18pt.name, &JetBrainsMono18pt},
    {JetBrainsMono12pt.name, &JetBrainsMono12pt},
    {JetBrainsMono9pt.name, &JetBrainsMono9pt},
    {RobotoThin24pt.name, &RobotoThin24pt},
    {RobotoThin18pt.name, &RobotoThin18pt},
    {RobotoThin12pt.name, &RobotoThin12pt},
    {RobotoBold24pt.name, &RobotoBold24pt},
    {RobotoBold18pt.name, &RobotoBold18pt},
    {RobotoBold12pt.name, &RobotoBold12pt},
    {RobotoBold9pt.name, &RobotoBold9pt},
    {Roboto24pt.name, &Roboto24pt},
    {Roboto18pt.name, &Roboto18pt},
    {Roboto12pt.name, &Roboto12pt},
    {Roboto9pt.name, &Roboto9pt},
};

void drawText(const argparse::ArgumentParser &opts, uint32_t *buffer) {
    auto pos = opts.get<std::vector<int>>("--pos");
    auto color = opts.get<uint32_t>("--color");
    auto bgColor = opts.get<uint32_t>("--bg-color");
    auto text = opts.get<std::string>("--text");
    auto scale = (uint8_t) opts.get<int>("--scale");
    auto fontName = opts.get("--font");

    if (!fonts.contains(fontName)) {
        throw std::invalid_argument("Unknown font name: " + fontName);
    }

    const Font *font = fonts[fontName];

    TextDrawer drawer(buffer,WIDTH, HEIGHT);
    drawer.setPosition(pos[0], pos[1]);
    drawer.setColor(color | 0xff000000);
    drawer.setBackgroundColor(opts.is_used("--bg-color") ? 0xff000000 | bgColor : 0);
    drawer.setFont(font);
    drawer.setFontScale(scale, scale);

    drawer.print(text.c_str());
}

void fill(const argparse::ArgumentParser &opts, uint32_t *buffer) {
    auto pos = opts.get<std::vector<int>>("--pos");
    auto size = opts.get<std::vector<int>>("--size");
    auto color = 0xff000000 | opts.get<uint32_t>("--color");

    auto fromX = std::max(0, pos[0]);
    auto toX = std::min(pos[0] + size[0],WIDTH);

    auto fromY = std::max(0, pos[1]);
    auto toY = std::min(pos[1] + size[1],HEIGHT);

    for (int j = fromY; j < toY; ++j) {
        auto *pRow = buffer + j * WIDTH;
        std::fill(pRow + fromX, pRow + toX, color);
    }
}

void clear(const argparse::ArgumentParser &opts, uint32_t *buffer) {
    auto color = 0xff000000 | opts.get<uint32_t>("--color");
    std::fill_n(buffer, WIDTH * HEIGHT, color);
}


int main(int argc, char *argv[]) {
    argparse::ArgumentParser program("typer");
    program.add_description("Flashforge AD5M screen drawing utility");
    program.add_epilog("Copyright (C) 2025, Alexander K <https://github.com/drA1ex>");

    program.add_argument("--list-fonts").help("List loaded fonts and exit.").flag();

    argparse::ArgumentParser text_command("text");
    text_command.add_description("Prints text at position");

    text_command.add_argument("--pos", "-p")
        .nargs(2)
        .scan<'d', int>()
        .required();

    text_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .required();

    text_command.add_argument("--bg-color", "-b")
        .scan<'X', uint32_t>()
        .default_value(0u);

    text_command.add_argument("--font", "-f")
        .default_value(Roboto12pt.name);

    text_command.add_argument("--scale", "-s")
        .scan<'d', int>()
        .default_value(1);

    text_command.add_argument("--text", "-t").required();
    program.add_subparser(text_command);

    argparse::ArgumentParser fill_command("fill");
    fill_command.add_description("Fill specified region with color");
    fill_command.add_argument("--pos", "-p")
        .nargs(2)
        .scan<'d', int>()
        .required();

    fill_command.add_argument("--size", "-s")
        .nargs(2)
        .scan<'d', int>()
        .required();

    fill_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0u);

    program.add_subparser(fill_command);

    argparse::ArgumentParser clear_command("clear");
    clear_command.add_description("Clear entire screen");

    clear_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0u);

    program.add_subparser(clear_command);

    try {
        program.parse_args(argc, argv);
    } catch (const std::exception &e) {
        std::cerr << "Unable to parse args: " << e.what() << std::endl;

        std::cout << program << std::endl;
        return 1;
    }

    if (program.get<bool>("--list-fonts")) {
        std::cout << "Loaded fonts: " << std::endl;

        const auto keys = std::ranges::views::keys(fonts);
        for (const auto &key: keys) {
            std::cout << "- " << key << std::endl;
        }

        return 1;
    }

    int fbfd = open("/dev/fb0", O_RDWR);
    if (fbfd == -1) {
        std::cerr << "Error: cannot open framebuffer device." << std::endl;
        return 1;
    }

    auto *fbp = (uint32_t *) mmap(nullptr, WIDTH * HEIGHT * 4, PROT_WRITE, MAP_SHARED, fbfd, 0);
    if (fbp == MAP_FAILED) {
        std::cerr << "Error: failed to map framebuffer device to memory." << std::endl;
        close(fbfd);
        return 1;
    }


    if (program.is_subcommand_used("fill")) {
        fill(fill_command, fbp);
    } else if (program.is_subcommand_used("text")) {
        drawText(text_command, fbp);
    } else if (program.is_subcommand_used("clear")) {
        clear(clear_command, fbp);
    } else {
        std::cout << program << std::endl;
        return 1;
    }

    munmap(fbp, WIDTH * HEIGHT * 4);
    close(fbfd);

    return 0;
}
