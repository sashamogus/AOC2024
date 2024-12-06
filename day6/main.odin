package aoc2024_day6

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"

Guard :: struct {
    pos: [2]int,
    dir: int,
}

dir_to_vec := [4][2]int {
    {  0, -1 },
    {  1,  0 },
    {  0,  1 },
    { -1,  0 },
}

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

guard_tick :: proc(guard: ^Guard, grid: Grid) {
    if grid_get(grid, guard.pos + dir_to_vec[guard.dir]) == '#' {
        guard.dir = (guard.dir + 1) % 4
    } else {
        guard.pos += dir_to_vec[guard.dir]
    }
}

main :: proc() {
    data, os_ok := os.read_entire_file("input.txt")
    assert(os_ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    guard: Guard

    grid: Grid
    grid.width = len(lines[0])
    grid.height = len(lines)
    assert(grid.width == 130)
    assert(grid.height == 130)
    grid.data = make([]byte, grid.width*grid.height)
    for line, i in lines {
        assert(line != "")
        for c, j in transmute([]byte)line {
            grid_set(&grid, { j, i }, c)
            if c == '^' {
                guard.pos = { j, i }
                guard.dir = 0
            }
        }
    }
    grid_obstacles := grid
    grid_obstacles.data = slice.clone(grid.data)
    guard_map := make([][4]bool, grid.width*grid.height)

    explored: int
    obstacles: int
    for limit in 0..=100000 {
        assert(limit < 100000)

        if grid_get(grid, guard.pos) != 'X' {
            grid_set(&grid, guard.pos, 'X')
            explored += 1
        }

        ob_pos := guard.pos + dir_to_vec[guard.dir]
        ob_get := grid_get(grid_obstacles, ob_pos)
        if !grid_out_of_bound(grid, ob_pos) && ob_get != '#' && ob_get != '^' && ob_get != 'O' {
            slice.fill(guard_map, false)
            g := guard
            g.dir = (g.dir + 1) % 4
            grid_set(&grid_obstacles, ob_pos, '#')
            for limit in 0..=100000 {
                assert(limit < 100000)
                i := grid_index(grid, g.pos)
                if guard_map[i][g.dir] {
                    obstacles += 1
                    break
                }
                guard_map[i][g.dir] = true
                guard_tick(&g, grid_obstacles)
                if grid_out_of_bound(grid, g.pos) {
                    break
                }
            }
            grid_set(&grid_obstacles, ob_pos, 'O')
        }


        guard_tick(&guard, grid)

        if grid_out_of_bound(grid, guard.pos) {
            break
        }
    }
    fmt.println(explored)
    fmt.println(obstacles)
}

