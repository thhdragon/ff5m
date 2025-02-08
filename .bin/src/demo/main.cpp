#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstring> // For memset
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <linux/fb.h>
#include <sys/ioctl.h>
#include <sys/mman.h> // For mmap, munmap, and related constants
#include <unistd.h>
#include <vector>

#define WIDTH 800
#define HEIGHT 480
#define BPP 32

#define SIZE 500

struct Point3D {
  float x, y, z;
};

struct Point2D {
  int x, y;
};

void rotateX(Point3D &p, float angle) {
  float rad = angle * M_PI / 180.0f;
  float y = p.y * cos(rad) - p.z * sin(rad);
  float z = p.y * sin(rad) + p.z * cos(rad);
  p.y = y;
  p.z = z;
}

void rotateY(Point3D &p, float angle) {
  float rad = angle * M_PI / 180.0f;
  float x = p.x * cos(rad) + p.z * sin(rad);
  float z = -p.x * sin(rad) + p.z * cos(rad);
  p.x = x;
  p.z = z;
}

void rotateZ(Point3D &p, float angle) {
  float rad = angle * M_PI / 180.0f;
  float x = p.x * cos(rad) - p.y * sin(rad);
  float y = p.x * sin(rad) + p.y * cos(rad);
  p.x = x;
  p.y = y;
}

Point2D project(Point3D p) {
  Point2D p2d;
  p2d.x = static_cast<int>((p.x * SIZE) / (p.z + 5) + WIDTH / 2);
  p2d.y = static_cast<int>((p.y * SIZE) / (p.z + 5) + HEIGHT / 2);
  return p2d;
}

void drawLine(char *fb, Point2D p1, Point2D p2, uint32_t color) {
  int dx = abs(p2.x - p1.x), sx = p1.x < p2.x ? 1 : -1;
  int dy = -abs(p2.y - p1.y), sy = p1.y < p2.y ? 1 : -1;
  int err = dx + dy, e2;

  while (true) {
    if (p1.x >= 0 && p1.x < WIDTH && p1.y >= 0 && p1.y < HEIGHT) {
      *((uint32_t *)(fb + (p1.y * WIDTH + p1.x) * 4)) = color;
    }
    if (p1.x == p2.x && p1.y == p2.y)
      break;
    e2 = 2 * err;
    if (e2 >= dy) {
      err += dy;
      p1.x += sx;
    }
    if (e2 <= dx) {
      err += dx;
      p1.y += sy;
    }
  }
}

void fillPolygon(char *fb, Point2D *points, int numPoints, uint32_t color) {
  // Determine the vertical bounds of the polygon
  int minY = HEIGHT, maxY = 0;
  for (int i = 0; i < numPoints; i++) {
    if (points[i].y < minY)
      minY = points[i].y;
    if (points[i].y > maxY)
      maxY = points[i].y;
  }

  // Iterate over each scanline within the vertical bounds
  for (int y = minY; y <= maxY; y++) {
    std::vector<int> intersections;

    // Find intersections of the polygon edges with the current scanline
    for (int i = 0; i < numPoints; i++) {
      int next = (i + 1) % numPoints;
      int y1 = points[i].y;
      int y2 = points[next].y;
      int x1 = points[i].x;
      int x2 = points[next].x;

      // Skip horizontal edges
      if (y1 == y2)
        continue;

      // Ensure y1 <= y2 for consistent intersection calculation
      if (y1 > y2) {
        std::swap(y1, y2);
        std::swap(x1, x2);
      }

      // Check if the scanline intersects the edge
      if (y >= y1 && y < y2) {
        // Compute intersection point's x-coordinate
        float t = (float)(y - y1) / (y2 - y1);
        int x = x1 + t * (x2 - x1);

        intersections.push_back(x);
      }
    }

    // Sort the intersection points
    std::sort(intersections.begin(), intersections.end());

    // Fill pixels between pairs of intersections
    for (size_t i = 0; i + 1 < intersections.size(); i += 2) {
      int x1 = intersections[i];
      int x2 = intersections[i + 1];

      // Draw horizontal line between x1 and x2
      for (int x = x1; x <= x2; x++) {
        if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT) {
          *((uint32_t *)(fb + (y * WIDTH + x) * 4)) = color;
        }
      }
    }
  }
}

int main() {
  // Open the framebuffer
  int fbfd = open("/dev/fb0", O_RDWR);
  if (fbfd == -1) {
    std::cerr << "Error: cannot open framebuffer device." << std::endl;
    return 1;
  }

  // Map the framebuffer into memory
  char *fbp = (char *)mmap(0, WIDTH * HEIGHT * 4, PROT_READ | PROT_WRITE,
                           MAP_SHARED, fbfd, 0);
  if (fbp == MAP_FAILED) {
    std::cerr << "Error: failed to map framebuffer device to memory."
              << std::endl;
    close(fbfd);
    return 1;
  }

  // Create a back buffer
  char *buffer = new char[WIDTH * HEIGHT * 4];

  Point3D cube[8] = {{-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1},
                     {-1, -1, 1},  {1, -1, 1},  {1, 1, 1},  {-1, 1, 1}};

  uint32_t colors[] = {
      0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00,
      0xFFFF00FF, 0xFFFFFFFF, 0xFF00FFFF,
  };

  int surfaces[6][4] = {
      {0, 1, 2, 3}, // Front
      {4, 5, 6, 7}, // Back
      {0, 1, 5, 4}, // Bottom
      {2, 3, 7, 6}, // Top
      {0, 3, 7, 4}, // Left
      {1, 2, 6, 5}  // Right
  };

  float angleX = 0, angleY = 0, angleZ = 0;

  while (true) {
    // Clear the back buffer
    memset(buffer, 0, WIDTH * HEIGHT * 4);

    // Rotate the cube
    for (auto &p : cube) {
      rotateX(p, angleX);
      rotateY(p, angleY);
      rotateZ(p, angleZ);
    }

    // Draw the cube faces
    for (size_t i = 0; i < std::size(surfaces); i++) {
      Point2D projectedPoints[4];
      for (int j = 0; j < 4; j++) {
        projectedPoints[j] = project(cube[surfaces[i][j]]);
      }

      // Calculate the normal vector of the surface
      Point3D v1 = {cube[surfaces[i][1]].x - cube[surfaces[i][0]].x,
                    cube[surfaces[i][1]].y - cube[surfaces[i][0]].y,
                    cube[surfaces[i][1]].z - cube[surfaces[i][0]].z};
      Point3D v2 = {cube[surfaces[i][2]].x - cube[surfaces[i][0]].x,
                    cube[surfaces[i][2]].y - cube[surfaces[i][0]].y,
                    cube[surfaces[i][2]].z - cube[surfaces[i][0]].z};
      Point3D normal = {v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
                        v1.x * v2.y - v1.y * v2.x};

      // Check if the surface is facing the camera
      // if (normal.z < 0) {

      fillPolygon(buffer, projectedPoints, 4, colors[i % std::size(colors)]);
      //}
    }

    // Copy the back buffer to the framebuffer
    memcpy(fbp, buffer, WIDTH * HEIGHT * 4);

    // Increment rotation angles
    angleX = 5;
    angleY = 3;
    angleZ = 1;

    usleep(1000000 / 60);
  }

  // Clean up
  delete[] buffer;
  munmap(fbp, WIDTH * HEIGHT * 4);
  close(fbfd);

  return 0;
}
