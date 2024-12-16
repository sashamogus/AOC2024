package aoc2024_day16

import "core:fmt"
import "core:os"
import "core:strings"
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

Raindeer :: struct {
    pos: [2]int,
    dir: int,
    score: int,
}

dir_to_vec := [4][2]int {
    { 1, 0 },
    { 0, 1 },
    { -1, 0 },
    { 0, -1 },
}

raindeer_step :: proc(rd: Raindeer, rotate: int) -> Raindeer {
    ret := rd
    if rotate != 0 {
        ret.dir = (ret.dir + rotate) %% 4
        ret.score += 1000
    } else {
        ret.pos += dir_to_vec[ret.dir]
        ret.score += 1
    }
    return ret
}

// mostly ported u/chickenthechicken's code.
// https://github.com/PaigePalisade/AdventOfCode2024/blob/main/Solutions/day16part2.c
search_lowest :: proc(grid: Grid, rd: Raindeer) -> (int, [][4]int) {
    min_distance := make([][4]int, grid.width*grid.height)
    slice.fill(min_distance, 0x7FFF_FFFF_FFFF_FFFF)
    stack := make([dynamic]Raindeer)
    append(&stack, rd)
    for len(stack) > 0 {
        best := stack[0]
        best_index := 0
        for r, i in stack {
            if r.score < best.score {
                best = r
                best_index = i
            }
        }
        unordered_remove(&stack, best_index)

        best_pos := grid_index(grid, best.pos)
        if best.score >= min_distance[best_pos][best.dir] {
            continue
        }
        min_distance[best_pos][best.dir] = best.score

        if grid_get(grid, best.pos) == 'E' {
            return best.score, min_distance
        }
        if grid_get(grid, best.pos) == '#' {
            continue
        }

        for i in -1..=1 {
            new_rd := raindeer_step(best, i)
            append(&stack, new_rd)
        }
    }

    return -1, min_distance
}

// Use DFS to mark all best paths.
// This function is also ported.
mark_seats :: proc(grid: Grid, grid_mark: ^Grid, rd: Raindeer, min_distance: [][4]int, target: int) -> bool {
    if rd.score == target && grid_get(grid, rd.pos) == 'E' {
        grid_set(grid_mark, rd.pos, 'O') // Goal was not marked lmao.
        return true
    }
    if grid_get(grid, rd.pos) == '#' {
        return false
    }
    if rd.score >= target {
        return false
    }

    rd_pos := grid_index(grid, rd.pos)
    if rd.score > min_distance[rd_pos][rd.dir] {
        return false
    }
    min_distance[rd_pos][rd.dir] = rd.score

    // If any branch can reach to goal, it is part of a best path.
    is_best_path: bool
    for i in -1..=1 {
        new_rd := raindeer_step(rd, i)
        if mark_seats(grid, grid_mark, new_rd, min_distance, target) {
            is_best_path = true
        }
    }

    // Mark best path on grid.
    if is_best_path {
        grid_set(grid_mark, rd.pos, 'O')
    }
    return is_best_path
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    context.allocator = context.temp_allocator

    rd: Raindeer
    grid: Grid
    grid.width = len(lines[0])
    grid.height = len(lines)
    grid.data = make([]byte, grid.width*grid.height)
    for line, i in lines {
        for c, j in line {
            if c == 'S' {
                rd = Raindeer {
                    pos = { j, i },
                    dir = 0,
                    score = 0,
                }
            }
            grid_set(&grid, { j, i }, byte(c))
        }
    }

    score1, min_distance := search_lowest(grid, rd)
    grid_mark := grid
    grid_mark.data = slice.clone(grid.data)
    mark_seats(grid, &grid_mark, rd, min_distance, score1)
    grid_print(grid_mark)

    seats: int
    for y in 0..<grid_mark.height {
        for x in 0..<grid_mark.width {
            if grid_get(grid_mark, { x, y }) == 'O' {
                seats += 1
            }
        }
    }

    return score1, seats
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

