package aoc2024_day15

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

can_move_box :: proc(grid: Grid, box, move: [2]int) -> bool {
    new_box := box + move
    get := grid_get(grid, new_box)
    if get == '.' {
        return true
    }
    if get == 'O' {
        return can_move_box(grid, new_box, move)
    }
    return false
}

move_box :: proc(grid: ^Grid, box, move: [2]int) {
    new_box := box + move
    get := grid_get(grid^, new_box)
    if get == 'O' {
        move_box(grid, new_box, move)
    }
    grid_set(grid, box, '.')
    grid_set(grid, new_box, 'O')
}

is_big_box :: proc(char: byte) -> bool {
    return char == '[' || char == ']'
}

can_move_big_box :: proc(grid: Grid, box, move: [2]int) -> bool {
    if move.y != 0 {
        new_box := box + move
        get1 := grid_get(grid, new_box)
        get2 := grid_get(grid, new_box + { 1, 0 })
        if get1 == '.' && get2 == '.' {
            return true
        }
        if get1 == '#' || get2 == '#' {
            return false
        }

        if is_big_box(get1) {
            box_test := new_box
            if get1 == ']' {
                box_test -= { 1, 0 }
            }
            if !can_move_big_box(grid, box_test, move) {
                return false
            } else if get1 == '[' {
                return true
            }
        }
        if get2 == '[' {
            box_test := new_box + { 1, 0 }
            if !can_move_big_box(grid, box_test, move) {
                return false
            }
        }
        return true
    } else {
        check := box + move
        if move.x == 1 {
            check.x += 1
        }
        get := grid_get(grid, check)
        if get == '.' {
            return true
        }
        if get == '#' {
            return false
        }
        if is_big_box(get) {
            box_test := check
            if get == ']' {
                box_test.x -= 1
            }
            return can_move_big_box(grid, box_test, move)
        }
    }
    
    return false
}

move_big_box :: proc(grid: ^Grid, box, move: [2]int) {
    if move.y != 0 {
        new_box := box + move
        get1 := grid_get(grid^, new_box)
        if is_big_box(get1) {
            box_move := new_box
            if get1 == ']' {
                box_move.x -= 1
            }
            move_big_box(grid, box_move, move)
        }
        get2 := grid_get(grid^, new_box + { 1, 0 })
        if is_big_box(get2) {
            box_move := new_box + { 1, 0 }
            if get2 == ']' {
                box_move.x -= 1
            }
            move_big_box(grid, box_move, move)
        }
    } else {
        check := box + move
        if move.x == 1 {
            check.x += 1
        }
        get := grid_get(grid^, check)
        if is_big_box(get) {
            box_move := check
            if get == ']' {
                box_move.x -= 1
            }
            move_big_box(grid, box_move, move)
        }
    }

    grid_set(grid, box, '.')
    grid_set(grid, box + { 1, 0 }, '.')
    new_box := box + move
    grid_set(grid, new_box, '[')
    grid_set(grid, new_box + { 1, 0 }, ']')
}

robot_move :: proc(grid: ^Grid, robot: ^[2]int, move: [2]int) {
    new_robot := robot^ + move
    get := grid_get(grid^, new_robot)
    if get == '.' {
        grid_set(grid, robot^, '.')
        grid_set(grid, new_robot, '@')
        robot^ = new_robot
        return
    }
    if get == 'O' {
        if can_move_box(grid^, new_robot, move) {
            move_box(grid, new_robot, move)
            grid_set(grid, robot^, '.')
            grid_set(grid, new_robot, '@')
            robot^ = new_robot
            return
        }
    }
    if is_big_box(get) {
        big_box := new_robot
        if get == ']' {
            big_box.x -= 1
        }
        if can_move_big_box(grid^, big_box, move) {
            move_big_box(grid, big_box, move)
            grid_set(grid, robot^, '.')
            grid_set(grid, new_robot, '@')
            robot^ = new_robot
            return
        }
    }
}

gps_count :: proc(grid: Grid) -> int {
    sum: int
    for y in 0..<grid.height {
        for x in 0..<grid.width {
            get := grid_get(grid, { x, y }) 
            if get == 'O' || get == '[' {
                sum += y*100 + x
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

    empty_line, found := slice.linear_search(lines, "")
    assert(found)
    str_grid, str_move := slice.split_at(lines, empty_line)

    robot: [2]int
    grid: Grid
    grid.width = len(str_grid[0])
    grid.height = len(str_grid)
    grid.data = make([]byte, grid.width*grid.height)
    for line, i in str_grid {
        for c, j in line {
            if c == '@' {
                robot = { j, i }
            }
            grid_set(&grid, { j, i }, byte(c))
        }
    }

    robot_big := robot
    robot_big.x *= 2
    grid_big: Grid
    grid_big.width = grid.width*2
    grid_big.height = grid.height
    grid_big.data = make([]byte, grid_big.width*grid_big.height)
    for y in 0..<grid.height {
        for x in 0..<grid.width {
            switch grid_get(grid, { x, y }) {
            case '.':
                grid_set(&grid_big, { x*2, y }, '.')
                grid_set(&grid_big, { x*2 + 1, y }, '.')
            case 'O':
                grid_set(&grid_big, { x*2, y }, '[')
                grid_set(&grid_big, { x*2 + 1, y }, ']')
            case '@':
                grid_set(&grid_big, { x*2, y }, '@')
                grid_set(&grid_big, { x*2 + 1, y }, '.')
            case '#':
                grid_set(&grid_big, { x*2, y }, '#')
                grid_set(&grid_big, { x*2 + 1, y }, '#')
            }
        }
    }

    moves := make([dynamic][2]int)
    for line in str_move {
        for c in line {
            switch c {
            case '^':
                append(&moves, [2]int { 0, -1 })
            case 'v':
                append(&moves, [2]int { 0, 1 })
            case '<':
                append(&moves, [2]int { -1, 0 })
            case '>':
                append(&moves, [2]int { 1, 0 })
            }
        }
    }
    buf: [256]byte
    for m, i in moves {
        robot_move(&grid, &robot, m)
        robot_move(&grid_big, &robot_big, m)
    }
    grid_print(grid)
    grid_print(grid_big)

    ans1 := gps_count(grid)
    ans2 := gps_count(grid_big)
    return ans1, ans2 
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

