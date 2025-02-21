// Text drawing
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license

#pragma once

#include <limits>
#include <string_view>

#include "./fonts/types.h"

struct TextBoundary {
    typedef std::pair<int32_t, int32_t> Size;

    int32_t left;
    int32_t top;
    int32_t right;
    int32_t bottom;

    int32_t start;
    int32_t baseline;

    void offset(int32_t x, int32_t y);
    [[nodiscard]] Size size() const;
};

enum class HorizontalAlign: uint8_t {
    LEFT   = 0,
    CENTER = 1,
    RIGHT  = 2,
};

enum class VerticalAlignment: uint8_t {
    TOP      = 0,
    MIDDLE   = 1,
    BASELINE = 2,
    BOTTOM   = 3,
};

class TextDrawer {
    struct Rect {
        int32_t left = std::numeric_limits<int32_t>::max();
        int32_t right = std::numeric_limits<int32_t>::min();
        int32_t top = std::numeric_limits<int32_t>::max();
        int32_t bottom = std::numeric_limits<int32_t>::min();
    };

    uint32_t *_screen;
    uint32_t _width;
    uint32_t _height;

    uint32_t *_backBuffer = nullptr;
    Rect _affectedArea = {};

    uint32_t _color = 0xffffffff;
    uint32_t _backgroundColor = 0;
    const Font *_font = nullptr;

    int32_t _cursorX = 0;
    int32_t _cursorY = 0;

    uint8_t _scaleX = 1;
    uint8_t _scaleY = 1;

    HorizontalAlign _horizontalAlign = HorizontalAlign::LEFT;
    VerticalAlignment _verticalAlign = VerticalAlignment::BASELINE;

    uint8_t _bpp = 0;
    uint8_t _pixelMask = 0;

    bool _debug = false;

public:
    TextDrawer(uint32_t *screen, uint32_t width, uint32_t height):
        _screen(screen), _width(width), _height(height) {}

    ~TextDrawer();

    [[nodiscard]] const Font *font() const;

    void setFont(const Font *font);
    void setFontScale(int32_t scaleX, int32_t scaleY);

    void setPosition(int32_t x, int32_t y);
    void setHorizontalAlignment(HorizontalAlign align);
    void setVerticalAlignment(VerticalAlignment align);

    void setColor(uint32_t color);
    void setBackgroundColor(uint32_t color);

    void setDoubleBuffered(bool enable);
    void setDebug(bool enable);

    void print(const char *text);
    void breakLine();

    void flush();

    [[nodiscard]] TextBoundary calcTextBoundaries(const std::string_view &text, int32_t x = 0, int32_t y = 0) const;
    [[nodiscard]] TextBoundary calcTextBoundaries(const char *text, int32_t x = 0, int32_t y = 0) const;

private:
    typedef std::pair<int32_t, int32_t> Point;

    int32_t _drawChar(char symbol, int32_t cursorX, int32_t cursorY);
    [[nodiscard]] Point _getAlignmentOffset(const TextBoundary &boundary) const;

    void _setPixel(int32_t x, int32_t y, uint32_t color);
    void _fillRect(const TextBoundary &b, uint32_t color);
    void _fillRect(int32_t x, int32_t y, uint32_t width, uint32_t height, uint32_t color);


    static uint32_t _mixColor(uint32_t a, uint32_t b, uint8_t factor);
};
