package aoc2024_day4

import "core:fmt"
import "core:os"
import "core:strings"

Grid :: struct {
    data: []byte,
    width, height: int,
}

grid_set :: proc(grid: ^Grid, x, y: int, s: byte) {
    grid.data[y*grid.width + x] = s
}

grid_get :: proc(grid: Grid, x, y: int) -> byte {
    if x < 0 || y < 0 || x >= grid.width || y >= grid.height {
        return '.'
    }
    return grid.data[y*grid.width + x]
}

match :: proc(grid: Grid, x, y, dx, dy: int) -> bool {
    x := x
    y := y
    text := "XMAS"
    for i in 0..<4 {
        if grid_get(grid, x, y) != text[i] {
            return false
        }
        x += dx
        y += dy
    }
    return true
}

match_mas :: proc(grid: Grid, x, y, dx, dy: int) -> bool {
    x := x
    y := y
    text := "MAS"
    for i in 0..<3 {
        if grid_get(grid, x, y) != text[i] {
            return false
        }
        x += dx
        y += dy
    }
    return true
}

match_xmas :: proc(grid: Grid, x, y: int) -> bool {
    if grid_get(grid, x, y) != 'A' { return false }

    d1 := match_mas(grid, x - 1, y - 1,  1,  1)
    d2 := match_mas(grid, x + 1, y + 1, -1, -1)
    d3 := match_mas(grid, x + 1, y - 1, -1,  1)
    d4 := match_mas(grid, x - 1, y + 1,  1, -1)

    return (d1 || d2) && (d3 || d4)
}

main :: proc() {
    data, ok := os.read_entire_file("input.txt")

    lines := strings.split_lines(string(data))
    grid := Grid {
        width = len(lines[0]),
        height = len(lines),
    }
    grid.data = make([]byte, grid.width*grid.height)
    for line, i in lines {
        for c, j in transmute([]byte)line {
            grid_set(&grid, j, i, c)
        }
    }

    count: int
    for i in 0..<grid.height {
        for j in 0..<grid.width {
            //if match(grid, i, j,  1, 0) { count += 1 }
            //if match(grid, i, j, -1, 0) { count += 1 }
            //if match(grid, i, j, 0,  1) { count += 1 }
            //if match(grid, i, j, 0, -1) { count += 1 }
            //if match(grid, i, j,  1,  1) { count += 1 }
            //if match(grid, i, j,  1, -1) { count += 1 }
            //if match(grid, i, j, -1,  1) { count += 1 }
            //if match(grid, i, j, -1, -1) { count += 1 }
            if match_xmas(grid, i, j) { count += 1 }
        }
    }
    fmt.println(count)
}
