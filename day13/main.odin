package aoc2024_day13

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:strconv"

Machine :: struct {
    a, b, prize: [2]int,
}


// https://www.youtube.com/watch?v=vXqlIOX2itM
fewest_tokens :: proc(machine: Machine) -> (int, bool) {
    d := machine.a[0]*machine.b[1] - machine.b[0]*machine.a[1]
    dx := machine.prize[0]*machine.b[1] - machine.b[0]*machine.prize[1]
    dy := machine.a[0]*machine.prize[1] - machine.prize[0]*machine.a[1]
    if dx % d == 0 && dy % d == 0 {
        a_num := dx/d
        b_num := dy/d
        return a_num*3 + b_num, true
    }
    return 0, false
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    // Parsing
    machines := make([dynamic]Machine)
    {
        m: Machine
        for line in lines {
            if line == "" { continue }
            s := strings.split(line, ": ")
            xy := strings.split(s[1], ", ")
            x, x_ok := strconv.parse_int(xy[0][2:])
            y, y_ok := strconv.parse_int(xy[1][2:])
            assert(x_ok)
            assert(y_ok)
            switch s[0] {
            case "Button A":
                m.a = { x, y }
            case "Button B":
                m.b = { x, y }
            case "Prize":
                m.prize = { x, y }
                append(&machines, m)
            }
        }
    }

    ans1, ans2: int
    for m in machines {
        {
            t, t_ok := fewest_tokens(m)
            if t_ok {
                ans1 += t
            }
        }
        {
            m2 := m
            m2.prize += 10000000000000
            t, t_ok := fewest_tokens(m2)
            if t_ok {
                ans2 += t
            }
        }
    }

    return ans1, ans2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

