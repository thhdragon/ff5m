// Screen typer
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license

#include <algorithm>
#include <csignal>
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <map>
#include <ranges>
#include <string>
#include <unistd.h>
#include <vector>
#include <sys/file.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "../../lib/argparse/argparse.hpp"

#include "../common/text.h"


#include "../common/fonts/JetBrainsMono12pt.h"
#include "../common/fonts/JetBrainsMono16pt.h"
#include "../common/fonts/JetBrainsMono20pt.h"
#include "../common/fonts/JetBrainsMono28pt.h"
#include "../common/fonts/JetBrainsMono8ptb4.h"
#include "../common/fonts/JetBrainsMonoBold12pt.h"
#include "../common/fonts/JetBrainsMonoBold16pt.h"
#include "../common/fonts/JetBrainsMonoBold20pt.h"
#include "../common/fonts/JetBrainsMonoBold28pt.h"
#include "../common/fonts/JetBrainsMonoBold8ptb4.h"
#include "../common/fonts/JetBrainsMonoThin12ptb4.h"
#include "../common/fonts/JetBrainsMonoThin16ptb2.h"
#include "../common/fonts/JetBrainsMonoThin20ptb2.h"
#include "../common/fonts/JetBrainsMonoThin28ptb2.h"
#include "../common/fonts/JetBrainsMonoThin8ptb4.h"
#include "../common/fonts/Roboto12pt.h"
#include "../common/fonts/Roboto16pt.h"
#include "../common/fonts/Roboto20pt.h"
#include "../common/fonts/Roboto28pt.h"
#include "../common/fonts/Roboto8ptb4.h"
#include "../common/fonts/RobotoBold12pt.h"
#include "../common/fonts/RobotoBold16pt.h"
#include "../common/fonts/RobotoBold20pt.h"
#include "../common/fonts/RobotoBold28pt.h"
#include "../common/fonts/RobotoBold8ptb4.h"
#include "../common/fonts/RobotoThin12ptb4.h"
#include "../common/fonts/RobotoThin16ptb2.h"
#include "../common/fonts/RobotoThin20ptb2.h"
#include "../common/fonts/RobotoThin28ptb2.h"
#include "../common/fonts/RobotoThin8ptb4.h"
#include "../common/fonts/Typicons12ptb2.h"
#include "../common/fonts/Typicons16ptb2.h"
#include "../common/fonts/Typicons28ptb2.h"
#include "../common/fonts/Typicons36ptb2.h"

#define WIDTH 800
#define HEIGHT 480

bool DEBUG = false;

volatile sig_atomic_t TERMINATED = false;
void terminate_handler(int) {
    std::cerr << "Terminating..." << std::endl;
    TERMINATED = true;
}

std::map<std::string, const Font *> fonts{
    {Roboto8ptb4.name, &Roboto8ptb4},
    {Roboto12pt.name, &Roboto12pt},
    {Roboto16pt.name, &Roboto16pt},
    {Roboto20pt.name, &Roboto20pt},
    {Roboto28pt.name, &Roboto28pt},
    {RobotoBold8ptb4.name, &RobotoBold8ptb4},
    {RobotoBold12pt.name, &RobotoBold12pt},
    {RobotoBold16pt.name, &RobotoBold16pt},
    {RobotoBold20pt.name, &RobotoBold20pt},
    {RobotoBold28pt.name, &RobotoBold28pt},
    {RobotoThin8ptb4.name, &RobotoThin8ptb4},
    {RobotoThin12ptb4.name, &RobotoThin12ptb4},
    {RobotoThin16ptb2.name, &RobotoThin16ptb2},
    {RobotoThin20ptb2.name, &RobotoThin20ptb2},
    {RobotoThin28ptb2.name, &RobotoThin28ptb2},

    {JetBrainsMono8ptb4.name, &JetBrainsMono8ptb4},
    {JetBrainsMono12pt.name, &JetBrainsMono12pt},
    {JetBrainsMono16pt.name, &JetBrainsMono16pt},
    {JetBrainsMono20pt.name, &JetBrainsMono20pt},
    {JetBrainsMono28pt.name, &JetBrainsMono28pt},
    {JetBrainsMonoBold8ptb4.name, &JetBrainsMonoBold8ptb4},
    {JetBrainsMonoBold12pt.name, &JetBrainsMonoBold12pt},
    {JetBrainsMonoBold16pt.name, &JetBrainsMonoBold16pt},
    {JetBrainsMonoBold20pt.name, &JetBrainsMonoBold20pt},
    {JetBrainsMonoBold28pt.name, &JetBrainsMonoBold28pt},
    {JetBrainsMonoThin8ptb4.name, &JetBrainsMonoThin8ptb4},
    {JetBrainsMonoThin12ptb4.name, &JetBrainsMonoThin12ptb4},
    {JetBrainsMonoThin16ptb2.name, &JetBrainsMonoThin16ptb2},
    {JetBrainsMonoThin20ptb2.name, &JetBrainsMonoThin20ptb2},
    {JetBrainsMonoThin28ptb2.name, &JetBrainsMonoThin28ptb2},

    {Typicons12ptb2.name, &Typicons12ptb2},
    {Typicons16ptb2.name, &Typicons16ptb2},
    {Typicons28ptb2.name, &Typicons28ptb2},
    {Typicons36ptb2.name, &Typicons36ptb2},
};

void drawText(const argparse::ArgumentParser &opts, TextDrawer &drawer) {
    auto pos = opts.get<std::vector<int>>("--pos");
    auto color = opts.get<uint32_t>("--color");
    auto bgColor = opts.get<uint32_t>("--bg-color");
    auto text = opts.get<std::string>("--text");
    auto scale = (uint8_t) opts.get<int>("--scale");
    auto fontName = opts.get("--font");
    auto hAlignStr = opts.get("--h-align");
    auto vAlignVStr = opts.get("--v-align");

    HorizontalAlign hAlign;
    if (hAlignStr == "center") {
        hAlign = HorizontalAlign::CENTER;
    } else if (hAlignStr == "right") {
        hAlign = HorizontalAlign::RIGHT;
    } else {
        hAlign = HorizontalAlign::LEFT;
    }

    VerticalAlignment vAlign;
    if (vAlignVStr == "bottom") {
        vAlign = VerticalAlignment::BOTTOM;
    } else if (vAlignVStr == "baseline") {
        vAlign = VerticalAlignment::BASELINE;
    } else if (vAlignVStr == "middle") {
        vAlign = VerticalAlignment::MIDDLE;
    } else {
        vAlign = VerticalAlignment::TOP;
    }


    if (!fonts.contains(fontName)) {
        throw std::invalid_argument("Unknown font name: " + fontName);
    }

    const Font *font = fonts[fontName];

    if (pos.size() == 2) drawer.setPosition(pos[0], pos[1]);
    drawer.setColor(color | 0xff000000);
    drawer.setBackgroundColor(opts.is_used("--bg-color") ? 0xff000000 | bgColor : 0);
    drawer.setFont(font);
    drawer.setFontScale(scale, scale);
    drawer.setHorizontalAlignment(hAlign);
    drawer.setVerticalAlignment(vAlign);

    drawer.print(text.c_str());
}

void fill(const argparse::ArgumentParser &opts, TextDrawer &drawer) {
    auto pos = opts.get<std::vector<int>>("--pos");
    auto size = opts.get<std::vector<int>>("--size");
    auto color = 0xff000000 | opts.get<uint32_t>("--color");

    drawer.fillRect(pos[0], pos[1], size[0], size[1], color);
}

StrokeDirection _parseDirection(const std::string &value) {
    if (value == "outer") return StrokeDirection::OUTER;
    if (value == "middle") return StrokeDirection::MIDDLE;
    if (value == "inner") return StrokeDirection::INNER;

    throw std::invalid_argument("Invalid value for StrokeDirection: " + value);
}

void stroke(const argparse::ArgumentParser &opts, TextDrawer &drawer) {
    auto pos = opts.get<std::vector<int>>("--pos");
    auto size = opts.get<std::vector<int>>("--size");
    auto color = 0xff000000 | opts.get<uint32_t>("--color");
    auto lineWidth = std::max<uint8_t>(1, opts.get<uint8_t>("--line-width"));
    auto strokeDirection = opts.get("--stroke-direction");

    drawer.setStrokeDirection(_parseDirection(strokeDirection));
    drawer.strokeRect(pos[0], pos[1], size[0], size[1], color, lineWidth);
}

void line(const argparse::ArgumentParser &opts, TextDrawer &drawer) {
    auto start = opts.get<std::vector<int>>("--start");
    auto end = opts.get<std::vector<int>>("--end");
    auto color = 0xff000000 | opts.get<uint32_t>("--color");
    auto lineWidth = std::max<uint8_t>(1, opts.get<uint8_t>("--line-width"));

    drawer.drawLine(start[0], start[1], end[0], end[1], color, lineWidth);
}

void clear(const argparse::ArgumentParser &opts, TextDrawer &drawer) {
    auto color = 0xff000000 | opts.get<uint32_t>("--color");
    drawer.clear(color);
}

std::vector<std::vector<std::string>> parse_batch_args(const std::vector<std::string> &args) {
    if (args.empty()) return {};

    std::vector<std::vector<std::string>> result;
    result.emplace_back();
    result.back().emplace_back("--batch");

    for (const auto &arg: args) {
        auto &last = result.back();
        if (arg == "--batch") {
            if (last.size() > 1) {
                result.emplace_back();
                result.back().emplace_back("--batch");
            }

            continue;
        }

        last.push_back(arg);
    }

    if (result.back().size() == 1) result.pop_back();

    return std::move(result);
}

struct ProgramParser {
    argparse::ArgumentParser program;
    argparse::ArgumentParser batch_parser;
    argparse::ArgumentParser text_command;
    argparse::ArgumentParser fill_command;
    argparse::ArgumentParser stroke_command;
    argparse::ArgumentParser line_command;
    argparse::ArgumentParser clear_command;
    argparse::ArgumentParser flush_command;
};

std::unique_ptr<ProgramParser> build_parser(argparse::default_arguments def = argparse::default_arguments::all) {
    auto result = std::unique_ptr<ProgramParser>( // NOLINT(*-make-unique)
        new ProgramParser{
            .program = argparse::ArgumentParser("typer", "1.0", def),
            .batch_parser = argparse::ArgumentParser("batch"),
            .text_command = argparse::ArgumentParser("text"),
            .fill_command = argparse::ArgumentParser("fill"),
            .stroke_command = argparse::ArgumentParser("stroke"),
            .line_command = argparse::ArgumentParser("line"),
            .clear_command = argparse::ArgumentParser("clear"),
            .flush_command = argparse::ArgumentParser("flush"),
        }
    );

    result->program.add_description("Flashforge AD5M screen drawing utility");
    result->program.add_epilog("Copyright (C) 2025, Alexander K <https://github.com/drA1ex>");

    result->program.add_argument("--debug").flag();
    result->program.add_argument("--double-buffered", "-db").flag();
    result->program.add_argument("--list-fonts").help("List loaded fonts and exit.").flag();

    // ************ Batch Parser

    result->batch_parser.add_description("Batch processing");
    result->batch_parser.add_epilog("Example: ./typer batch \\\n"
        "    --batch clear <...> \\\n"
        "    --batch fill <...> \\\n"
        "    --batch text <...>");

    result->batch_parser.add_argument("--pipe")
        .default_value("")
        .help("A pipe with batches to read");

    result->batch_parser.add_argument("--batch")
        .help("Beginning of a batch")
        .remaining();

    result->program.add_subparser(result->batch_parser);

    // ************ Text Parser


    result->text_command.add_description("Prints text at position");

    result->text_command.add_argument("--pos", "-p")
        .nargs(2)
        .scan<'d', int>();

    result->text_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0xffffffff);

    result->text_command.add_argument("--bg-color", "-b")
        .scan<'X', uint32_t>()
        .default_value(0u);

    result->text_command.add_argument("--font", "-f")
        .default_value(Roboto12pt.name);

    result->text_command.add_argument("--scale", "-s")
        .scan<'d', int>()
        .default_value(1);

    result->text_command.add_argument("--text", "-t")
        .default_value("");

    result->text_command.add_argument("--h-align", "-ha")
        .choices("left", "center", "right")
        .default_value("left");

    result->text_command.add_argument("--v-align", "-va")
        .choices("bottom", "baseline", "middle", "top")
        .default_value("baseline");

    result->program.add_subparser(result->text_command);

    // ************ Fill Parser

    result->fill_command.add_description("Fill specified region with color");
    result->fill_command.add_argument("--pos", "-p")
        .nargs(2)
        .scan<'d', int>()
        .required();

    result->fill_command.add_argument("--size", "-s")
        .nargs(2)
        .scan<'d', int>()
        .required();

    result->fill_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0u);

    result->program.add_subparser(result->fill_command);

    // ************ Stroke Parser

    result->stroke_command.add_description("Stroke specified region with color");
    result->stroke_command.add_argument("--pos", "-p")
        .nargs(2)
        .scan<'d', int>()
        .required();

    result->stroke_command.add_argument("--size", "-s")
        .nargs(2)
        .scan<'d', int>()
        .required();

    result->stroke_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0xffffffu);

    result->stroke_command.add_argument("--line-width", "-lw")
        .scan<'d', uint8_t>()
        .default_value((uint8_t) 1);

    result->stroke_command.add_argument("--stroke-direction", "-sd")
        .choices("outer", "middle", "inner")
        .default_value("middle");

    result->program.add_subparser(result->stroke_command);

    // ************ Line Parser

    result->line_command.add_description("Draw line with color");
    result->line_command.add_argument("--start", "-s")
        .nargs(2)
        .scan<'d', int>()
        .required();

    result->line_command.add_argument("--end", "-e")
        .nargs(2)
        .scan<'d', int>()
        .required();

    result->line_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0xffffffu);

    result->line_command.add_argument("--line-width", "-lw")
        .scan<'d', uint8_t>()
        .default_value((uint8_t) 1);

    result->program.add_subparser(result->line_command);

    // ************ Clear Parser

    result->clear_command.add_description("Clear entire screen");

    result->clear_command.add_argument("--color", "-c")
        .scan<'X', uint32_t>()
        .default_value(0u);

    result->program.add_subparser(result->clear_command);

    // ************ Flush Parser
    result->flush_command.add_description("Flush pending changes (for --double-buffered mode)");
    result->program.add_subparser(result->flush_command);

    return result;
}

void run_program(const ProgramParser &args, TextDrawer &drawer) {
    auto &[
        program, batch_parser, text_command, fill_command,
        stroke_command, line_command, clear_command, flush_command
    ] = args;

    if (program.is_subcommand_used("fill")) {
        fill(fill_command, drawer);
    } else if (program.is_subcommand_used("text")) {
        drawText(text_command, drawer);
    } else if (program.is_subcommand_used("stroke")) {
        stroke(stroke_command, drawer);
    } else if (program.is_subcommand_used("line")) {
        line(line_command, drawer);
    } else if (program.is_subcommand_used("clear")) {
        clear(clear_command, drawer);
    } else if (program.is_subcommand_used("flush")) {
        drawer.flush();
    } else {
        std::cerr << "Unknown program: " << program << std::endl;
    }
}

void process_batch(TextDrawer &drawer, const std::vector<std::string> &batch) {
    auto batch_parser = build_parser(argparse::default_arguments::none);

    try {
        batch_parser->program.parse_args(batch);
        run_program(*batch_parser, drawer);
    } catch (const std::exception &e) {
        std::cerr << "Unable to process batch: ";
        for (const auto &str: batch) { std::cerr << "\"" << str << "\" "; }
        std::cerr << std::endl;
        std::cerr << "Error: " << e.what() << std::endl;
    }
}

size_t read_char(int fd, char &out, size_t timeout_usec = 1000000) {
    constexpr auto delay = 10000;

    size_t elapsed = 0;
    while (!read(fd, &out, 1)) {
        if (TERMINATED) return 0;

        usleep(delay);
        elapsed += delay;

        if (elapsed >= timeout_usec) {
            if (DEBUG) std::cerr << "Timed out waiting for char" << std::endl;
            return 0;
        }
    }

    return 1;
}

size_t read_escaped_symbol(int fd, std::string &acc) {
    char ch;
    if (!read_char(fd, ch)) {
        std::cerr << "Failed to read escaped symbol. No data available." << std::endl;
        return 0;
    }

    if (ch == '"' || ch == '\'' || ch == '\\') {
        acc += ch;

        if (DEBUG) {
            std::cout << "Read escaped: \"" << ch << "\"" << std::endl;
        }

        return 1;
    }

    std::cerr << "Failed to read escaped symbol. Invalid symbol: \"" << ch << "\""
        << " (0x" << std::hex << (int) ch << std::dec << ")" << std::endl;
    return 0;
}

size_t read_quoted_string(int fd, char open_quote, std::string &acc) {
    size_t bytesRead = 0;
    char ch;

    while (read_char(fd, ch)) {
        if (ch == '\\') {
            bytesRead += read_escaped_symbol(fd, acc);
        } else if (ch != open_quote) {
            bytesRead += 1;
            acc += ch;
        } else {
            if (DEBUG) {
                std::cout << "Read quoted: \"" << acc << "\"" << std::endl;
            }

            return bytesRead;
        }
    }

    std::cerr << "Failed to read quoted string. No data available." << std::endl;
    return bytesRead;
}

size_t read_token(int fd, std::string &acc) {
    acc.clear();
    size_t bytesRead = 0;

    char ch;
    while (read_char(fd, ch)) {
        if (ch == '"' || ch == '\'') {
            bytesRead += read_quoted_string(fd, ch, acc);
        } else if (ch == '\\') {
            bytesRead += read_escaped_symbol(fd, acc);
        } else if (ch != ' ' && ch != '\t' && ch != '\n' && ch != '\0') {
            bytesRead += 1;
            acc += ch;
        } else if (bytesRead > 0) {
            if (DEBUG) {
                std::cout << "Token end: " << std::hex << (int) ch << std::dec << std::endl;
            }
            break;
        }
    }

    if (DEBUG && bytesRead > 0) {
        std::cout << "Read token: \"" << acc << "\"" << std::endl;
    }

    return bytesRead;
}

size_t read_pipe(int fd, std::vector<std::string> &result, bool &has_next_batch) {
    result.clear();
    if (has_next_batch) {
        result.emplace_back("--batch");
        has_next_batch = false;
    }

    size_t char_read = 0;
    std::string acc;
    while (auto bytes = read_token(fd, acc)) {
        if (acc == "--end") {
            return char_read;
        }

        if (result.empty() && acc != "--batch") {
            std::cout << "Invalid batch! Expected first token --batch. Got: " << acc << std::endl;
            return 0;
        }

        if (!result.empty() && acc == "--batch") {
            has_next_batch = true;
            return char_read;
        }

        char_read += bytes;
        if (!acc.empty()) result.push_back(acc);
    }

    return char_read;
}

void process_pipe_batches(TextDrawer &drawer, const std::string &pipe) {
    if (mkfifo(pipe.c_str(), 0666) == -1) {
        if (errno != EEXIST) {
            // Ignore error if the pipe already exists
            throw std::runtime_error("Failed to create named pipe: " + pipe);
        }
    }

    std::cout << "Pipe mode enabled!" << std::endl;
    std::cout << "Usage:" << std::endl
        << R"(  echo -e --batch clear -c ff0000)" << " > " << pipe << std::endl
        << R"(  echo -e --batch text -p 400 200 -t \"Hello, World.\")" << " > " << pipe << std::endl
        << R"(  echo -e --batch flush)" << " > " << pipe << std::endl
        << R"(  echo -e --end)" << " > " << pipe << std::endl;
    std::cout << std::endl;

    std::cout << "Wait for pipe..." << std::endl;

    int pipeFd = open(pipe.c_str(), O_RDONLY);
    if (pipeFd < 0) {
        std::cerr << "Error opening pipe: " << pipe << std::endl;
        return;
    }

    if (flock(pipeFd, LOCK_EX | LOCK_NB) == -1) {
        std::cerr << "Pipe already in use: " << pipe << std::endl;
        close(pipeFd);
        return;
    }

    signal(SIGTERM, terminate_handler);
    signal(SIGINT, terminate_handler);

    std::cout << "Reading named pipe: " << pipe << std::endl;

    bool has_next_batch = false;
    std::vector<std::string> tokens;
    while (!TERMINATED) {
        auto count = read_pipe(pipeFd, tokens, has_next_batch);
        if (count > 0) {
            std::cout << "Process batch..." << std::endl;

            try {
                process_batch(drawer, tokens);
            } catch (const std::exception &e) {
                std::cerr << "Error while processing batch: " << e.what() << std::endl;
            }

            tokens.clear();
        } else {
            drawer.flush();
        }
    }

    close(pipeFd);
    unlink(pipe.c_str());

    exit(SIGTERM);
}


int main(int argc, char *argv[]) {
    auto main = build_parser();

    try {
        main->program.parse_args(argc, argv);
    } catch (const std::exception &e) {
        std::cerr << "Unable to parse args: " << e.what() << std::endl;

        std::cout << main->program << std::endl;
        return 1;
    }

    if (main->program.get<bool>("--list-fonts")) {
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

    TextDrawer drawer(fbp, WIDTH, HEIGHT);
    drawer.setDoubleBuffered(main->program.get<bool>("--double-buffered"));

    DEBUG = main->program.get<bool>("--debug");
    drawer.setDebug(DEBUG);

    if (main->program.is_subcommand_used("batch")) {
        auto pipe = main->batch_parser.get("--pipe");

        if (pipe.empty()) {
            auto batch_args = main->batch_parser.get<std::vector<std::string>>("--batch");
            auto batches = parse_batch_args(batch_args);

            for (auto &batch: batches) {
                process_batch(drawer, batch);
            }
        } else {
            process_pipe_batches(drawer, pipe);
        }
    } else {
        run_program(*main, drawer);
    }

    drawer.flush();

    munmap(fbp, WIDTH * HEIGHT * 4);
    close(fbfd);

    return 0;
}
