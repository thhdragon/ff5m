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


#include "../common/fonts/JetBrainsMono12pt.h"
#include "../common/fonts/JetBrainsMono16pt.h"
#include "../common/fonts/JetBrainsMono20pt.h"
#include "../common/fonts/JetBrainsMono28pt.h"
#include "../common/fonts/JetBrainsMonoBold12pt.h"
#include "../common/fonts/JetBrainsMonoBold16pt.h"
#include "../common/fonts/JetBrainsMonoBold20pt.h"
#include "../common/fonts/JetBrainsMonoBold28pt.h"
#include "../common/fonts/JetBrainsMonoThin12ptb4.h"
#include "../common/fonts/JetBrainsMonoThin16ptb2.h"
#include "../common/fonts/JetBrainsMonoThin20ptb2.h"
#include "../common/fonts/JetBrainsMonoThin28ptb2.h"
#include "../common/fonts/Roboto12pt.h"
#include "../common/fonts/Roboto16pt.h"
#include "../common/fonts/Roboto20pt.h"
#include "../common/fonts/Roboto28pt.h"
#include "../common/fonts/RobotoBold12pt.h"
#include "../common/fonts/RobotoBold16pt.h"
#include "../common/fonts/RobotoBold20pt.h"
#include "../common/fonts/RobotoBold28pt.h"
#include "../common/fonts/RobotoThin12ptb4.h"
#include "../common/fonts/RobotoThin16ptb2.h"
#include "../common/fonts/RobotoThin20ptb2.h"
#include "../common/fonts/RobotoThin28ptb2.h"

#define WIDTH 800
#define HEIGHT 480

std::map<std::string, const Font *> fonts{
    {Roboto12pt.name, &Roboto12pt},
    {Roboto16pt.name, &Roboto16pt},
    {Roboto20pt.name, &Roboto20pt},
    {Roboto28pt.name, &Roboto28pt},
    {RobotoBold12pt.name, &RobotoBold12pt},
    {RobotoBold16pt.name, &RobotoBold16pt},
    {RobotoBold20pt.name, &RobotoBold20pt},
    {RobotoBold28pt.name, &RobotoBold28pt},
    {RobotoThin12ptb4.name, &RobotoThin12ptb4},
    {RobotoThin16ptb2.name, &RobotoThin16ptb2},
    {RobotoThin20ptb2.name, &RobotoThin20ptb2},
    {RobotoThin28ptb2.name, &RobotoThin28ptb2},

    {JetBrainsMono12pt.name, &JetBrainsMono12pt},
    {JetBrainsMono16pt.name, &JetBrainsMono16pt},
    {JetBrainsMono20pt.name, &JetBrainsMono20pt},
    {JetBrainsMono28pt.name, &JetBrainsMono28pt},
    {JetBrainsMonoBold12pt.name, &JetBrainsMonoBold12pt},
    {JetBrainsMonoBold16pt.name, &JetBrainsMonoBold16pt},
    {JetBrainsMonoBold20pt.name, &JetBrainsMonoBold20pt},
    {JetBrainsMonoBold28pt.name, &JetBrainsMonoBold28pt},
    {JetBrainsMonoThin12ptb4.name, &JetBrainsMonoThin12ptb4},
    {JetBrainsMonoThin16ptb2.name, &JetBrainsMonoThin16ptb2},
    {JetBrainsMonoThin20ptb2.name, &JetBrainsMonoThin20ptb2},
    {JetBrainsMonoThin28ptb2.name, &JetBrainsMonoThin28ptb2},
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
