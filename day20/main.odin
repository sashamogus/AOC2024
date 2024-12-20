package aoc2024_day20

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

DIRS :: [4][2]int { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, }

map_distance :: proc(grid: Grid, start, end: [2]int) -> ([]int, [][2]int) {
    min_distance := make([]int, grid.width*grid.height)
    slice.fill(min_distance, 0x7fff_ffff_ffff_ffff)
    path := make([dynamic][2]int)

    pos := start
    dist := 0
    for limit in 0..=100000 {
        assert(limit < 100000)
        pos_index := grid_index(grid, pos)
        min_distance[pos_index] = dist
        append(&path, pos)

        if pos == end {
            break
        }

        for d in DIRS {
            next := pos + d
            if grid_get(grid, next) != '#' {
                next_index := grid_index(grid, next)
                if dist + 1 < min_distance[next_index] {
                    pos = next
                    dist += 1
                    break
                }
            }
        }
    }
    return min_distance, path[:]
}

count_all_skips :: proc(grid: Grid, distance: []int, path: [][2]int, start, end: [2]int, cheat_steps: int) -> map[int]int {
    skips_count := make(map[int]int)

    for pos in path {
        pos_index := grid_index(grid, pos)
        dist := distance[pos_index]

        for y in -cheat_steps..=cheat_steps {
            for x in -cheat_steps..=cheat_steps {
                cheat_d := abs(x) + abs(y)
                if cheat_d > cheat_steps {
                    continue
                }
                cheat := pos + { x, y }
                if grid_out_of_bound(grid, cheat) {
                    continue
                }

                if grid_get(grid, cheat) == '#' {
                    continue
                }

                cheat_index := grid_index(grid, cheat)
                skip := distance[cheat_index] - dist - cheat_d
                if skip > 0 {
                    if skip in skips_count {
                        skips_count[skip] += 1
                    } else {
                        skips_count[skip] = 1
                    }
                }
            }
        }

    }
    return skips_count
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
    start, end: [2]int
    for line, i in lines {
        for c, j in line {
            if c == 'S' {
                start = { j, i }
            }
            if c == 'E' {
                end = { j, i }
            }
            grid_set(&grid, { j, i }, byte(c))
        }
    }
    distance, path := map_distance(grid, start, end)
    skips  := count_all_skips(grid, distance, path, start, end, 2)
    skips2 := count_all_skips(grid, distance, path, start, end, 20)
    if filename == "example.txt" {
        fmt.println(skips2)
        assert(skips2[76] == 3)
        assert(skips2[74] == 4)
        assert(skips2[72] == 22)
        assert(skips2[70] == 12)
        assert(skips2[68] == 14)
        assert(skips2[66] == 12)
        assert(skips2[64] == 19)
        assert(skips2[62] == 20)
        assert(skips2[60] == 23)
        assert(skips2[58] == 25)
        assert(skips2[56] == 39)
        assert(skips2[54] == 29)
        assert(skips2[52] == 31)
        assert(skips2[50] == 32)
    }

    over_100: int
    for k, v in skips {
        if k >= 100 {
            over_100 += v
        }
    }

    over_100_2: int
    for k, v in skips2 {
        if k >= 100 {
            over_100_2 += v
        }
    }
    return over_100, over_100_2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

