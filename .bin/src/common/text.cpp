// Text drawing
//
// Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
//
// This file may be distributed under the terms of the GNU GPLv3 license


#include "text.h"

#include <algorithm>
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
    const Glyph &glyph = font.glyphs[symbol - font.codeFrom];

    if (symbol < font.codeFrom || symbol > font.codeTo) {
        return;
    }

    int32_t offsetX = _cursorX + glyph.offsetX;
    int32_t offsetY = _cursorY + glyph.offsetY;

    for (uint8_t gy = 0; gy < glyph.height; ++gy) {
        for (uint8_t gx = 0; gx < glyph.width; ++gx) {
            auto index = gy * glyph.width + gx;
            auto byteOffset = glyph.offset + index / 8;
            auto bitOffset = 7 - index % 8;

            auto bit = (font.buffer[byteOffset] >> bitOffset) & 1;
            auto color = bit ? _color : _backgroundColor;

            if (_scaleX == 1 && _scaleY == 1) {
                _setPixel(offsetX + gx, offsetY + gy, color);
            } else {
                _fillRect(offsetX + gx * _scaleX, offsetY + gy * _scaleY, _scaleX, _scaleY, color);
            }
        }
    }

    // Advance the cursor
    _cursorX += glyph.advanceX * _scaleX;
}

void TextDrawer::_setPixel(int32_t x, int32_t y, uint32_t color) {
    if (color & 0xff000000 == 0) return; // Skip fully transparent colors
    if (x < 0 || x >= _width || y < 0 || y >= _height) return;

    _screen[y * _width + x] = color;
}

void TextDrawer::_fillRect(int32_t x, int32_t y, uint32_t width, uint32_t height, uint32_t color) {
    if (color & 0xff000000 == 0) return; // Skip fully transparent colors

    auto fromX = std::max(0, x);
    auto toX = std::min(x + width, _width);

    if (fromX >= toX) return;

    auto fromY = std::max(0, y);
    auto toY = std::min(y + height, _height);

    for (int j = fromY; j < toY; ++j) {
        auto *pRow = _screen + j * _width;
        std::fill(pRow + fromX, pRow + toX, color);
    }
}
