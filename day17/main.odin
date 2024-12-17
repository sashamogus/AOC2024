package aoc2024_day17

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

execute_program :: proc(a, b, c: int, program: []int) -> []int {
    a := a
    b := b
    c := c
    output := make([dynamic]int)
    ip: int
    for limit in 0..=100000 {
        assert(limit < 100000)
        if ip >= len(program) {
            break
        }

        opcode := program[ip]
        operand := program[ip + 1]
        ip += 2
        eope := operand
        switch operand {
        case 4:
            eope = a
        case 5:
            eope = b
        case 6:
            eope = c
        case 7:
            fmt.println("Operand of 7 is illegal")
            break
        }

        switch opcode {
        case 0: // Adv
            a = a >> uint(eope)
        case 1: // Bxl
            b = b ~ operand
        case 2: // Bst
            b = eope %% 8
        case 3: // Jnz
            if a != 0 {
                ip = operand
            }
        case 4: // Bxc
            b = b ~ c
        case 5: // Out
            append(&output, eope %% 8)
        case 6: // Bdv
            b = a >> uint(eope)
        case 7: // Cdv
            c = a >> uint(eope)
        }
    }
    return output[:]
}

// Same thing but halt at first output
execute_program_one_output :: proc(a, b, c: int, program: []int) -> int {
    a := a
    b := b
    c := c
    ip: int
    for limit in 0..=100000 {
        assert(limit < 100000)
        if ip >= len(program) {
            break
        }

        opcode := program[ip]
        operand := program[ip + 1]
        ip += 2
        eope := operand
        switch operand {
        case 4:
            eope = a
        case 5:
            eope = b
        case 6:
            eope = c
        case 7:
            fmt.println("Operand of 7 is illegal")
            break
        }

        switch opcode {
        case 0: // Adv
            a = a >> uint(eope)
        case 1: // Bxl
            b = b ~ operand
        case 2: // Bst
            b = eope %% 8
        case 3: // Jnz
            if a != 0 {
                ip = operand
            }
        case 4: // Bxc
            b = b ~ c
        case 5: // Out
            return eope %% 8
        case 6: // Bdv
            b = a >> uint(eope)
        case 7: // Cdv
            c = a >> uint(eope)
        }
    }
    return -1
}

find_a :: proc(a: int, program: []int, test: int) -> int {
    for i in 0..<8 {
        new_a := (a << 3) | i
        if execute_program_one_output(new_a, 0, 0, program) == program[test] {
            if test == 0 {
                return new_a
            } else {
                f := find_a(new_a, program, test - 1)
                if f != -1 {
                    return f
                }
            }
        }
    }
    return -1
}

process_file :: proc(filename: string) -> int {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    a, b, c: int
    {
        spl := strings.split(lines[0], ": ")
        a_ok: bool
        a, a_ok = strconv.parse_int(spl[1])
        assert(a_ok)
    }
    {
        spl := strings.split(lines[1], ": ")
        b_ok: bool
        b, b_ok = strconv.parse_int(spl[1])
        assert(b_ok)
    }
    {
        spl := strings.split(lines[2], ": ")
        c_ok: bool
        c, c_ok = strconv.parse_int(spl[1])
        assert(c_ok)
    }

    program := make([dynamic]int)
    {
        spl := strings.split(lines[4], ": ")
        nums := strings.split(spl[1], ",")
        for str in nums {
            n, n_ok := strconv.parse_int(str)
            assert(n_ok)
            append(&program, n)
        }
    }
    fmt.println(execute_program(a, b, c, program[:]))

    for i in 0..<8 {
        a = find_a(i, program[:], len(program) - 1)
        if a != -1 {
            return a
        }
    }

    return -1
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("example2.txt"))
        fmt.println(process_file("input.txt"))
    }
}

