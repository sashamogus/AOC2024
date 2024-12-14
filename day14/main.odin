package aoc2024_day14

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Robot :: struct {
    p, v: [2]int,
}

print_robots :: proc(robots: []Robot, width, height: int) {
    grid := make([]int, width*height, context.temp_allocator)
    for r in robots {
        grid[r.p.y*width + r.p.x] += 1
    }
    for b, i in grid {
        if i %% width == 0 {
            fmt.println()
        }
        if b == 0 {
            fmt.print('.')
        } else {
            fmt.print('#')
        }
    }
    fmt.println()
    free_all(context.temp_allocator)
}

png_score :: proc(robots: []Robot, width, height: int) -> int {
    grid := make([]int, width*height, context.temp_allocator)
    for r in robots {
        grid[r.p.y*width + r.p.x] += 1
    }
    prev: int
    score: int
    for b in grid {
        if prev != b {
            score += 1
        }
        prev = b
    }
    free_all(context.temp_allocator)
    return score
}

simulate :: proc(robots: []Robot, seconds, width, height: int) {
    buf: [256]byte
    for i in 0..<seconds {
        for &r in robots {
            r.p += r.v
            r.p.x = r.p.x %% width
            r.p.y = r.p.y %% height
        }
        score := png_score(robots, width, height)
        if score < 800 {
            fmt.println(i, score) // Check for part 2
        }
    }
}

safety_factor :: proc(robots: []Robot, width, height: int) -> int {
    wh := width / 2
    hh := height / 2
    tl, tr, bl, br: int
    for r in robots {
        if r.p.x < wh {
            if r.p.y < hh {
                tl += 1
            } else if r.p.y > hh {
                bl += 1
            }
        } else if r.p.x > wh {
            if r.p.y < hh {
                tr += 1
            } else if r.p.y > hh {
                br += 1
            }
        }
    }
    return tl*tr*bl*br
}

process_file :: proc(filename: string, width, height: int) -> int {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    robots := make([dynamic]Robot)
    for line in lines {
        s := strings.split(line, " ")
        p: [2]int
        {
            pstr := strings.split(s[0], ",")
            px, px_ok := strconv.parse_int(pstr[0][2:])
            py, py_ok := strconv.parse_int(pstr[1])
            assert(px_ok)
            assert(py_ok)
            p.x = px
            p.y = py
        }
        v: [2]int
        {
            vstr := strings.split(s[1], ",")
            vx, vx_ok := strconv.parse_int(vstr[0][2:])
            vy, vy_ok := strconv.parse_int(vstr[1])
            assert(vx_ok)
            assert(vy_ok)
            v.x = vx
            v.y = vy
        }
        append(&robots, Robot { p, v })
    }

    simulate(robots[:], 100, width, height)
    ans1 := safety_factor(robots[:], width, height)
    return ans1
}

main :: proc() {
    {
        fmt.println(process_file("example.txt", 11, 7))
        fmt.println(process_file("input.txt", 101, 103))
    }
}

