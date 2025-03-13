// Logger
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license


#pragma once

#include <chrono>
#include <deque>
#include <filesystem>
#include <string>

#include "../common/text.h"

#include "types.h"

#define WIDTH 800
#define HEIGHT 480

class Logger {
    LoggerParams _config;
    std::deque<ScreenMessage> _messages_queue;

    std::unique_ptr<TextDrawer> _drawer = nullptr;
    int _fb_descriptor = 0;
    void *_fbp = nullptr;

public:
    explicit Logger(LoggerParams config);
    ~Logger();

    void process_stream(std::istream &input_stream);

private:
    void _add_to_queue(LogLevel level, const std::string &message);
    void _send_to_screen(const std::deque<ScreenMessage> &messages);

    void _init_drawer();
};
