// Utils
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license

#pragma once

#include <vector>
#include <chrono>
#include <fstream>
#include <ranges>

#include "types.h"

inline std::string current_date_time() {
    using namespace std::chrono;
    auto now = system_clock::now();
    return std::format("{:%F %T}", std::chrono::floor<seconds>(now));
}

inline std::string &replace_placeholder(std::string &str, const std::string &placeholder, const std::string &value) {
    size_t pos = str.find(placeholder);
    while (pos != std::string::npos) {
        str.replace(pos, placeholder.length(), value);
        pos = str.find(placeholder, pos + value.length());
    }

    return str;
}

inline std::vector<ScreenMessage> load_array_from_file(const std::string &file_name) {
    std::vector<ScreenMessage> array;

    if (std::ifstream infile(file_name); infile) {
        std::string line;
        while (std::getline(infile, line)) {
            size_t delimiterPos = line.find(";;");
            if (delimiterPos != std::string::npos) {
                std::string integerPart = line.substr(0, delimiterPos);
                std::string stringPart = line.substr(delimiterPos + 2);

                LogLevel level = LogLevel::DEBUG;

                try {
                    level = (LogLevel) std::stoi(integerPart);
                } catch (const std::invalid_argument &e) {
                    std::cerr << "Failed to parse log level:  \"" << integerPart << "\"; " << e.what() << std::endl;
                }

                array.emplace_back(level, stringPart);
            } else {
                throw std::runtime_error("Invalid line format: " + line);
            }
        }
    }

    return array;
}

inline void save_array_to_file(const std::vector<ScreenMessage> &array, const std::string &file_name) {
    std::ofstream outfile(file_name);
    for (const auto &message: array) {
        outfile << (int) message.log_level << ";;" << message.str << '\n';
    }
}

inline std::string get_exe_name(int pid) {
    if (std::filesystem::exists("/proc/" + std::to_string(pid) + "/comm")) {
        std::string result;
        std::ifstream("/proc/" + std::to_string(pid) + "/comm") >> result;

        return result;
    }

    if (std::filesystem::exists("/proc/" + std::to_string(pid) + "/cmdline")) {
        std::string result;
        std::ifstream("/proc/" + std::to_string(pid) + "/cmdline") >> result;

        auto pos = result.find('\0');
        if (pos != std::string::npos) result = result.substr(0, pos);

        pos = result.rfind('/');
        if (pos != std::string::npos) result = result.substr(pos + 1);


        if (!result.empty()) return result;
    }

    return "N/A";
}
