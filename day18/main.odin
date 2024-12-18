package aoc2024_day18

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
        if i % grid.width == 0 && i != 0 {
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

find_path :: proc(grid: Grid) -> int {
    context.allocator = context.temp_allocator
    stack := make([dynamic][2]int)
    min_distance := make([]int, grid.width*grid.height)
    slice.fill(min_distance, 0x7fff_ffff_ffff_ffff)

    append(&stack, [2]int { 0, 0 })
    min_distance[0] = 0

    for len(stack) > 0 {
        pos := stack[0]
        pos_i := 0
        dist := min_distance[grid_index(grid, pos)]
        for p, i in stack {
            d := min_distance[grid_index(grid, p)]
            if d < dist {
                pos = p
                pos_i = i
                dist = d
                break
            }
        }

        unordered_remove(&stack, pos_i)

        if pos == { grid.width - 1, grid.height - 1 } {
            break
        }

        DIRS :: [4][2]int { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, }
        for d in DIRS {
            new_pos := pos + d
            if grid_out_of_bound(grid, new_pos) { continue }
            if grid_get(grid, new_pos) == '#' { continue }
            i := grid_index(grid, new_pos)
            if min_distance[i] <= dist + 1 { continue }

            min_distance[i] = dist + 1
            append(&stack, new_pos)
        }
    }

    last_dist := min_distance[len(min_distance) - 1]
    free_all(context.temp_allocator)

    return last_dist
}


process_file :: proc(filename: string, size, fall_num: int) -> (int, string) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    grid: Grid
    grid.width = size
    grid.height = size
    grid.data = make([]byte, grid.width*grid.height)
    slice.fill(grid.data, '.')
    ans1: int
    ans2: string
    for line, i in lines {
        if i == fall_num {
            ans1 = find_path(grid)
        }
        spl := strings.split(line, ",")
        x, x_ok := strconv.parse_int(spl[0])
        y, y_ok := strconv.parse_int(spl[1])
        assert(x_ok)
        assert(y_ok)
        grid_set(&grid, { x, y }, '#')
        if find_path(grid) == 0x7fff_ffff_ffff_ffff {
            grid_print(grid)
            ans2 = line
            break
        }
    }

    return ans1, ans2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt", 7, 12))
        fmt.println(process_file("input.txt", 71, 1024))
    }
}

