// Text drawing
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license


#include "text.h"

#include <algorithm>
#include <limits>
#include <stdexcept>


void TextDrawer::setFont(const Font *font) {
    _font = font;
}

const Font *TextDrawer::font() const {
    if (_font == nullptr) throw std::runtime_error("Font not set");

    return _font;
}

void TextDrawer::setColor(uint32_t color) {
    _color = color;
}

void TextDrawer::setBackgroundColor(uint32_t color) {
    _backgroundColor = color;
}

void TextDrawer::setPosition(int32_t x, int32_t y) {
    _cursorX = _positionX = x;
    _cursorY = y;
}

void TextDrawer::setFontScale(int32_t scaleX, int32_t scaleY) {
    _scaleX = std::max(1, scaleX);
    _scaleY = std::max(1, scaleY);
}

void TextDrawer::print(const char *text) {
    if (_backgroundColor & 0xff000000) {
        auto b = calcTextBoundaries(text);
        _fillRect(b, _backgroundColor);
    }

    for (int i = 0; text[i] != '\0'; ++i) {
        char symbol = text[i];

        if (symbol == '\n') {
            breakLine();
        } else {
            _drawChar(symbol);
        }
    }
}

void TextDrawer::breakLine() {
    _cursorX = _positionX;
    _cursorY += font()->advanceY * _scaleY;
}

void TextDrawer::_drawChar(char symbol) {
    const auto &font = *this->font();
    if (symbol < font.codeFrom || symbol > font.codeTo) {
        return;
    }

    const Glyph &glyph = font.glyphs[symbol - font.codeFrom];

    int32_t offsetX = _cursorX + glyph.offsetX * _scaleX;
    int32_t offsetY = _cursorY + glyph.offsetY * _scaleY;

    for (uint8_t gy = 0; gy < glyph.height; ++gy) {
        for (uint8_t gx = 0; gx < glyph.width; ++gx) {
            auto index = gy * glyph.width + gx;
            auto byteOffset = glyph.offset + index / 8;
            auto bitOffset = 7 - index % 8;

            if ((font.buffer[byteOffset] >> bitOffset & 1) == 0) continue;

            if (_scaleX == 1 && _scaleY == 1) {
                _setPixel(offsetX + gx, offsetY + gy, _color);
            } else {
                _fillRect(offsetX + gx * _scaleX, offsetY + gy * _scaleY, _scaleX, _scaleY, _color);
            }
        }
    }

    // Advance the cursor
    _cursorX += glyph.advanceX * _scaleX;
}

void TextDrawer::_setPixel(int32_t x, int32_t y, uint32_t color) {
    if ((color & 0xff000000) == 0) return; // Skip fully transparent colors
    if (x < 0 || x >= _width || y < 0 || y >= _height) return;

    _screen[y * _width + x] = color;
}

void TextDrawer::_fillRect(const Boundary &b, uint32_t color) {
    _fillRect(
        b.left, b.top,
        std::max(b.right - b.left, 0),
        std::max(b.bottom - b.top, 0),
        color
    );
}

void TextDrawer::_fillRect(int32_t x, int32_t y, uint32_t width, uint32_t height, uint32_t color) {
    if ((color & 0xff000000) == 0) return; // Skip fully transparent colors

    uint32_t fromX = std::max(0, x);
    auto toX = std::min<uint32_t>(x + (int32_t) width, _width);

    if (fromX >= toX) return;

    uint32_t fromY = std::max(0, y);
    auto toY = std::min<uint32_t>(fromY + (int32_t) height, _height);

    for (uint32_t j = fromY; j < toY; ++j) {
        auto *pRow = _screen + j * _width;
        std::fill(pRow + fromX, pRow + toX, color);
    }
}

Boundary TextDrawer::calcTextBoundaries(const char *text) const {
    Boundary boundary = {
        .left = std::numeric_limits<int32_t>::max(),
        .top = std::numeric_limits<int32_t>::max(),
        .right = std::numeric_limits<int32_t>::min(),
        .bottom = std::numeric_limits<int32_t>::min(),
    };

    auto cursorX = _cursorX;
    auto cursorY = _cursorY;

    const auto &font = *this->font();
    for (int i = 0; text[i] != '\0'; ++i) {
        char symbol = text[i];

        if (symbol == '\n') {
            cursorY += font.advanceY * _scaleY;
        } else if (symbol < font.codeFrom || symbol > font.codeTo) {
            continue;
        }

        const Glyph &glyph = font.glyphs[symbol - font.codeFrom];

        auto left = cursorX + glyph.offsetX * _scaleX;
        auto top = cursorY + glyph.offsetY * _scaleY;

        if (left <= boundary.left) boundary.left = left;
        if (top <= boundary.top) boundary.top = top;

        auto right = left + glyph.width * _scaleX;
        auto bottom = top + glyph.height * _scaleY;

        if (right >= boundary.right) boundary.right = right;
        if (bottom >= boundary.bottom) boundary.bottom = bottom;

        cursorX += glyph.advanceX * _scaleX;
    }

    if (boundary.left > boundary.right || boundary.top > boundary.bottom) {
        boundary.left = boundary.top = boundary.right = boundary.bottom = 0;
    }

    return boundary;
}
