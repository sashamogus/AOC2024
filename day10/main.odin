package aoc2024_day10

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Grid :: struct {
    data: []byte,
    width, height: int,
}

grid_print :: proc(grid: Grid) {
    for c, i in grid.data {
        if i % grid.width == 0 {
            fmt.println()
        }
        fmt.print(rune(c))
    }
    fmt.println()
}

grid_index :: proc(grid: Grid, pos: [2]int) -> int {
    return pos.y*grid.width + pos.x
}

grid_set :: proc(grid: ^Grid, pos: [2]int, v: byte) {
    grid.data[pos.y*grid.width + pos.x] = v
}

grid_get :: proc(grid: Grid, pos: [2]int) -> byte {
    if grid_out_of_bound(grid, pos) {
        return '.'
    }
    return grid.data[pos.y*grid.width + pos.x]
}

grid_out_of_bound :: proc(grid: Grid, pos: [2]int) -> bool {
    return pos.x < 0 || pos.y < 0 || pos.x >= grid.width || pos.y >= grid.height
}

trailhead_score :: proc(grid: Grid, start: [2]int) -> int {
    context.allocator = context.temp_allocator
    explored := grid
    explored.data = slice.clone(grid.data)
    stack := make([dynamic][2]int)

    append(&stack, start)
    grid_set(&explored, start, '#')
    score: int
    for limit in 0..=100000 {
        assert(limit < 100000)
        if len(stack) == 0 { break }

        pos := pop(&stack)
        pos_char := grid_get(grid, pos)
        if pos_char == '9' {
            score += 1
        }

        DIRS :: [4][2]int { { 0, 1 },{ 0, -1 },{ 1, 0 },{ -1, 0 }, }
        for d in DIRS {
            next := pos + d
            if !grid_out_of_bound(grid, next) {
                next_char := grid_get(grid, next)
                e := grid_get(explored, next)
                if next_char - pos_char == 1 && e != '#' {
                    append(&stack, next)
                    grid_set(&explored, next, '#')
                }
            }
        }
    }

    free_all(context.temp_allocator)

    return score
}

total_score :: proc(grid: Grid) -> int {
    sum: int
    for y in 0..<grid.height {
        for x in 0..<grid.width {
            if grid_get(grid, { x, y }) == '0' {
                sum += trailhead_score(grid, { x, y })
            }
        }
    }
    return sum
}

trailhead_routes :: proc(grid: Grid, start: [2]int) -> int {
    context.allocator = context.temp_allocator
    stack := make([dynamic][2]int)

    append(&stack, start)
    score: int
    for limit in 0..=100000 {
        assert(limit < 100000)
        if len(stack) == 0 { break }

        pos := pop(&stack)
        pos_char := grid_get(grid, pos)
        if pos_char == '9' {
            score += 1
        }

        DIRS :: [4][2]int { { 0, 1 },{ 0, -1 },{ 1, 0 },{ -1, 0 }, }
        for d in DIRS {
            next := pos + d
            if !grid_out_of_bound(grid, next) {
                next_char := grid_get(grid, next)
                if next_char - pos_char == 1 {
                    append(&stack, next)
                }
            }
        }
    }

    free_all(context.temp_allocator)

    return score
}

total_routes :: proc(grid: Grid) -> int {
    sum: int
    for y in 0..<grid.height {
        for x in 0..<grid.width {
            if grid_get(grid, { x, y }) == '0' {
                sum += trailhead_routes(grid, { x, y })
            }
        }
    }
    return sum
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    grid: Grid
    grid.width = len(lines[0])
    grid.height = len(lines)
    grid.data = make([]byte, grid.width*grid.height)
    for line, i in lines {
        for c, j in line {
            grid_set(&grid, { j, i }, byte(c))
        }
    }

    score1 := total_score(grid)
    score2 := total_routes(grid)

    return score1, score2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("example2.txt"))
        fmt.println(process_file("input.txt"))
    }
}
