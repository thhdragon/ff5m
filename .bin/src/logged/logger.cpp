// Logger impl
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license

#include "logger.h"

#include <deque>
#include <fcntl.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <unistd.h>
#include <vector>
#include <sys/mman.h>

#include "types.h"
#include "utils.h"

#include "../common/text.h"
#include "../common/fonts/JetBrainsMono8ptb4.h"

Logger::Logger(LoggerParams config): _config(std::move(config)) {
    if (_config.send_to_screen) _init_drawer();
}

Logger::~Logger() {
    if (_config.send_to_screen) {
        _drawer = nullptr;

        munmap(_fbp, WIDTH * HEIGHT * 4);
        close(_fb_descriptor);

        _fbp = nullptr;
        _fb_descriptor = 0;
    }
}

void Logger::process_stream(std::istream &input_stream) {
    auto pid = getppid();
    const auto exec_name = get_exe_name(pid);

    if (_config.send_to_screen && _config.screen_followup) {
        auto loaded = load_array_from_file(_config.screen_follow_up_file);
        const int count = (int) std::min(loaded.size(), _config.screen_queue_max);
        _messages_queue.assign(loaded.begin(), loaded.begin() + count);
    }

    std::string line;
    while (std::getline(input_stream, line)) {
        auto date_str = current_date_time();

        std::string level_str = "DEBUG";
        LogLevel level = _config.print_level;

        // Check log levels
        if (line.starts_with("@@")) {
            level_str = "ERROR";
            level = LogLevel::ERROR;
            line = line.substr(2);
        } else if (line.starts_with("??")) {
            level_str = "WARN ";
            level = LogLevel::WARN;
            line = line.substr(2);
        } else if (line.starts_with("//")) {
            level_str = "INFO ";
            level = LogLevel::INFO;
            line = line.substr(2);
        }

        line.erase(0, line.find_first_not_of(" \t"));

        auto formatted_message = _config.log_format;
        replace_placeholder(formatted_message, "%date%", date_str);
        replace_placeholder(formatted_message, "%level%", level_str);
        replace_placeholder(formatted_message, "%pid%", std::to_string(pid));
        replace_placeholder(formatted_message, "%script%", exec_name);
        replace_placeholder(formatted_message, "%message%", line);

        if (_config.print && level >= _config.print_level) {
            if (_config.print_formatted) {
                std::cout << formatted_message << std::endl;
            } else {
                std::cout << line << std::endl;
            }
        }

        if (_config.send_to_screen && !line.empty() && level >= _config.screen_level) {
            _add_to_queue(level, line);
            _send_to_screen(_messages_queue);
        }

        if (_config.log && level >= _config.log_level) {
            std::ofstream log_stream(_config.log_file, std::ios_base::app);
            log_stream << formatted_message << std::endl;
        }
    }

    if (_config.send_to_screen && _config.screen_followup) {
        save_array_to_file({_messages_queue.begin(), _messages_queue.end()}, _config.screen_follow_up_file);
    }
}

void Logger::_add_to_queue(LogLevel level, const std::string &message) {
    if (_messages_queue.size() >= _config.screen_queue_max) {
        _messages_queue.pop_front();
    }

    _messages_queue.push_back({level, message});
}

void Logger::_send_to_screen(const std::deque<ScreenMessage> &messages) {
    constexpr int line_height = 22;
    constexpr int bottom_offset = 460;

    int y_clear = bottom_offset - (int) _config.screen_queue_max * line_height;
    _drawer->fillRect(0, y_clear, WIDTH, (_config.screen_queue_max + 1) * line_height, 0xff000000);

    _drawer->setHorizontalAlignment(HorizontalAlign::LEFT);
    _drawer->setVerticalAlignment(VerticalAlignment::MIDDLE);

    const int height = ((int) messages.size() - 1) * line_height;
    int y_offset = bottom_offset - height;
    for (const auto &message: messages) {


        _drawer->setColor(message.color());
        _drawer->setPosition(10, y_offset);
        _drawer->print(message.str.c_str());
        y_offset += line_height;
    }

    _drawer->setColor(0xff00ffff);
    _drawer->setPosition(WIDTH - 10, bottom_offset);
    _drawer->setHorizontalAlignment(HorizontalAlign::RIGHT);

    timespec t{};
    clock_gettime(CLOCK_BOOTTIME, &t);
    _drawer->print(std::format("<< {:.2f}", t.tv_sec + t.tv_nsec / 1e+9f).c_str());

    _drawer->flush();
}


void Logger::_init_drawer() {
    int fbfd = open("/dev/fb0", O_RDWR);
    if (fbfd == -1) {
        throw std::runtime_error("Error: cannot open framebuffer device.");
    }

    auto *fbp = (uint32_t *) mmap(nullptr, WIDTH * HEIGHT * 4, PROT_WRITE, MAP_SHARED, fbfd, 0);
    if (fbp == MAP_FAILED) {
        close(fbfd);
        throw std::runtime_error("Error: failed to map framebuffer device to memory.");
    }
    _fb_descriptor = fbfd;
    _fbp = fbp;
    _drawer = std::make_unique<TextDrawer>(fbp, WIDTH, HEIGHT);

    _drawer->setDoubleBuffered(true);
    _drawer->setFont(&JetBrainsMono8ptb4);
}
