package aoc2024_day12

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

region :: proc(grid: Grid, mapped: ^Grid, pos: [2]int) -> (int, int) {
    context.allocator = context.temp_allocator

    num, per: int
    char := grid_get(grid, pos)
    stack := make([dynamic][2]int)
    append(&stack, pos)
    grid_set(mapped, pos, '#')
    num += 1

    for limit in 0..=100000 {
        assert(limit < 100000)

        if len(stack) == 0 {
            break
        }
        p := pop(&stack)

        DIRS :: [4][2]int { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 }, }
        for d in DIRS {
            next := p + d
            if !grid_out_of_bound(grid, next) {
                if grid_get(grid, next) == char && grid_get(mapped^, next) != '#' {
                    append(&stack, next)
                    grid_set(mapped, next, '#')
                    num += 1
                }
            }
            if grid_get(grid, next) != char {
                per += 1
            }
        }
    }

    free_all(context.temp_allocator)

    return num, per
}

region_sides :: proc(grid: Grid, mapped: ^Grid, pos: [2]int) -> (int, int) {
    context.allocator = context.temp_allocator

    num: int
    char := grid_get(grid, pos)
    stack := make([dynamic][2]int)
    append(&stack, pos)
    grid_set(mapped, pos, '$')
    num += 1

    tl := pos
    br := pos

    for limit in 0..=100000 {
        assert(limit < 100000)

        if len(stack) == 0 {
            break
        }
        p := pop(&stack)
        tl = { min(tl.x, p.x), min(tl.y, p.y) }
        br = { max(br.x, p.x), max(br.y, p.y) }

        DIRS :: [4][2]int { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 }, }
        for d in DIRS {
            next := p + d
            if !grid_out_of_bound(grid, next) {
                if grid_get(grid, next) == char && grid_get(mapped^, next) != '$' {
                    append(&stack, next)
                    grid_set(mapped, next, '$')
                    num += 1
                }
            }
        }
    }

    sides: int
    // Count up and down
    for y in tl.y..=br.y {
        prev_up   := byte('$')
        prev_down := byte('$')
        for x in tl.x..=br.x {
            p := [2]int { x, y }
            if grid_get(mapped^, p) == '$' {
                up   := grid_get(mapped^, p + { 0, -1 })
                down := grid_get(mapped^, p + { 0,  1 })
                if prev_up   == '$' && up   != '$' { sides += 1 }
                if prev_down == '$' && down != '$' { sides += 1 }
                prev_up   = up
                prev_down = down
            } else {
                prev_up   = '$'
                prev_down = '$'
            }
        }
    }

    // Count left and right
    for x in tl.x..=br.x {
        prev_left  := byte('$')
        prev_right := byte('$')
        for y in tl.y..=br.y {
            p := [2]int { x, y }
            if grid_get(mapped^, p) == '$' {
                left  := grid_get(mapped^, p + { -1, 0 })
                right := grid_get(mapped^, p + {  1, 0 })
                if prev_left  == '$' && left  != '$' { sides += 1 }
                if prev_right == '$' && right != '$' { sides += 1 }
                prev_left  = left
                prev_right = right 
            } else {
                prev_left  = '$'
                prev_right = '$'
            }
        }
    }


    // Set all $ to #
    for y in tl.y..=br.y {
        for x in tl.x..=br.x {
            p := [2]int { x, y }
            if grid_get(mapped^, p) == '$' {
                grid_set(mapped, p, '#')
            }
        }
    }

    free_all(context.temp_allocator)

    return num, sides
}

price :: proc(grid: Grid) -> int {
    mapped := grid
    mapped.data = slice.clone(grid.data)
    defer delete(mapped.data)

    slice.fill(mapped.data, '.')
    sum: int
    for y in 0..<grid.height {
        for x in 0..<grid.width {
            if grid_get(mapped, { x, y }) != '#' {
                num, per := region(grid, &mapped, { x, y })
                sum += num*per
            }
        }
    }
    return sum
}

price_discount :: proc(grid: Grid) -> int {
    mapped := grid
    mapped.data = slice.clone(grid.data)
    defer delete(mapped.data)

    slice.fill(mapped.data, '.')
    sum: int
    for y in 0..<grid.height {
        for x in 0..<grid.width {
            if grid_get(mapped, { x, y }) != '#' {
                num, sides := region_sides(grid, &mapped, { x, y })
                sum += num*sides
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

    price1 := price(grid)
    price2 := price_discount(grid)
    return price1, price2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

