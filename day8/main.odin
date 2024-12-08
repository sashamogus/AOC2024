package aoc2024_day8

import "core:os"
import "core:fmt"
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

map_antinodes :: proc(grid_antennas: Grid, grid_antinodes: ^Grid) -> int {
    context.allocator = context.temp_allocator
    antennas: map[byte][dynamic][2]int

    // Add all antennas
    for y in 0..<grid_antennas.height {
        for x in 0..<grid_antennas.width {
            c := grid_get(grid_antennas, { x, y })
            if c != '.' {
                if c not_in antennas {
                    antennas[c] = make([dynamic][2]int)
                }
                array := &antennas[c]
                append(array, [2]int { x, y })
            }
        }
    }

    antinodes: int
    for key, array in antennas {
        for i in 0..<len(array) {
            ipos := array[i]
            for j in i + 1..<len(array) {
                jpos := array[j]
                diff := ipos - jpos
                anti1 := ipos + diff
                anti2 := jpos - diff
                if !grid_out_of_bound(grid_antinodes^, anti1) && grid_get(grid_antinodes^, anti1) != '#' {
                    grid_set(grid_antinodes, anti1, '#')
                    antinodes += 1
                }
                if !grid_out_of_bound(grid_antinodes^, anti2) && grid_get(grid_antinodes^, anti2) != '#' {
                    grid_set(grid_antinodes, anti2, '#')
                    antinodes += 1
                }
            }
        }
    }

    free_all(context.temp_allocator)
    return antinodes
}

map_antinodes_line :: proc(grid_antennas: Grid, grid_antinodes: ^Grid) -> int {
    context.allocator = context.temp_allocator
    antennas: map[byte][dynamic][2]int

    // Add all antennas
    for y in 0..<grid_antennas.height {
        for x in 0..<grid_antennas.width {
            c := grid_get(grid_antennas, { x, y })
            if c != '.' {
                if c not_in antennas {
                    antennas[c] = make([dynamic][2]int)
                }
                array := &antennas[c]
                append(array, [2]int { x, y })
            }
        }
    }

    antinodes: int
    for key, array in antennas {
        for i in 0..<len(array) {
            ipos := array[i]
            for j in i + 1..<len(array) {
                jpos := array[j]
                diff := ipos - jpos
                fw := ipos
                for !grid_out_of_bound(grid_antinodes^, fw) {
                    if grid_get(grid_antinodes^, fw) != '#' {
                        grid_set(grid_antinodes, fw, '#')
                        antinodes += 1
                    }
                    fw += diff
                }
                bw := jpos
                for !grid_out_of_bound(grid_antinodes^, bw) {
                    if grid_get(grid_antinodes^, bw) != '#' {
                        grid_set(grid_antinodes, bw, '#')
                        antinodes += 1
                    }
                    bw -= diff
                }
            }
        }
    }

    free_all(context.temp_allocator)
    return antinodes
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
    grid_antinodes := grid
    grid_antinodes.data = slice.clone(grid.data)

    antinodes := map_antinodes(grid, &grid_antinodes)

    copy(grid_antinodes.data, grid.data)
    antinodes2 := map_antinodes_line(grid, &grid_antinodes)

    return antinodes, antinodes2
}

main :: proc() {
    {
        fmt.println(process_file("input.txt"))
    }
}

