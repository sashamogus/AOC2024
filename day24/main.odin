package aoc2024_day24

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Gate :: struct {
    a, b, op, out: string,
}

reg_to_int :: proc(wire_map: map[string]int, reg_name: byte) -> int {
    result: int
    for k, v in wire_map {
        if k[0] == reg_name {
            e, e_ok := strconv.parse_int(k[1:])
            assert(e_ok)
            result |= v << uint(e)
        }
    }
    return result
}

int_to_reg :: proc(wire_map: ^map[string]int, reg_name: byte, value: int) {
    for k, v in wire_map {
        if k[0] == reg_name {
            e, e_ok := strconv.parse_int(k[1:])
            assert(e_ok)
            b := 1 << uint(e)
            wire_map[k] = value & b != 0 ? 1 : 0
        }
    }
}

simulate_circuit :: proc(gates: []Gate, wire_map: map[string]int) -> int {
    wires := make(map[string]int, context.temp_allocator)
    for k, v in wire_map {
        wires[k] = v
    }
    gates := slice.clone_to_dynamic(gates, context.temp_allocator)

    for limit in 0..=100000 {
        assert(limit < 100000)
        if len(gates) == 0 {
            break
        }

        dead := true
        #reverse for g, i in gates {
            if g.a not_in wires { continue }
            if g.b not_in wires { continue }

            dead = false
            switch g.op {
            case "AND":
                wires[g.out] = wires[g.a] & wires[g.b]
            case "OR":
                wires[g.out] = wires[g.a] | wires[g.b]
            case "XOR":
                wires[g.out] = wires[g.a] ~ wires[g.b]
            }
            unordered_remove(&gates, i)
        }
        if dead {
            return -1
        }
    }

    z := reg_to_int(wires, 'z')
    free_all(context.temp_allocator)
    return z
}

bad_bits :: proc(gates: []Gate, wire_map: ^map[string]int, bits: int) -> []int {
    result := make([dynamic]int)
    for i in 0..<bits {
        b := 1 << uint(i)
        for j in 0..<4 {
            x := j & 1 != 0 ? b : 0
            y := j & 2 != 0 ? b : 0
            int_to_reg(wire_map, 'x', x)
            int_to_reg(wire_map, 'y', y)
            z := simulate_circuit(gates, wire_map^)
            if z != x + y {
                append(&result, i)
                break
            }
        }
    }
    return result[:]
}

process_file :: proc(filename: string) -> int {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    empty_line, empty_found := slice.linear_search(lines, "")
    assert(empty_found)
    wires_str, gates_str := slice.split_at(lines, empty_line)
    gates_str = gates_str[1:]

    wire_map := make(map[string]int)
    for wstr in wires_str {
        n, n_ok := strconv.parse_int(wstr[5:])
        assert(n_ok)
        wire_map[wstr[:3]] = n
    }
    
    gates := make([]Gate, len(gates_str))
    for gstr, i in gates_str {
        spl := strings.split(gstr, " ")
        defer delete(spl)
        a := spl[0]
        b := spl[2]
        op := spl[1]
        out := spl[4]
        gates[i] = Gate { a, b, op, out }
    }
    
    z := simulate_circuit(gates, wire_map)

    if filename == "input.txt" {
        xys := make([dynamic]string)
        zs := make([dynamic]string)
        others := make([dynamic]string)
        for gstr in gates_str {
            if gstr[0] == 'x' || gstr[8] == 'x' || gstr[0] == 'y' || gstr[8] == 'y' {
                append(&xys, gstr)
            } else if gstr[len(gstr) - 3] == 'z' {
                append(&zs, gstr)
            } else {
                append(&others, gstr)
            }
        }

        slice.sort_by(xys[:], proc(a, b: string) -> bool {
            return strings.compare(a[1:], b[1:]) == -1
        })

        slice.sort_by(zs[:], proc(a, b: string) -> bool {
            a_len := len(a)
            b_len := len(b)
            a_cmp := a[a_len - 2: a_len]
            b_cmp := b[b_len - 2: b_len]
            return strings.compare(a_cmp, b_cmp) == -1
        })

        slice.sort_by(others[:], proc(a, b: string) -> bool {
            return strings.compare(a[4:7], b[4:7]) == -1
        })

        f, f_err := os.open("gates.txt", os.O_CREATE)
        if f_err != nil {
            fmt.println(f_err)
        }
        fmt.fprintln(f, "Inputs")
        for xystr in xys {
            fmt.fprintln(f, xystr)
        }
        fmt.fprintln(f) 

        fmt.fprintln(f, "Outputs")
        for zstr in zs {
            fmt.fprintln(f, zstr)
        }
        fmt.fprintln(f) 

        fmt.fprintln(f, "Middles")
        for ostr in others {
            fmt.fprintln(f, ostr)
        }
        fmt.fprintln(f) 
        os.flush(f)
        os.close(f)

        fmt.println(bad_bits(gates, &wire_map, 45))
    }
    
    return z
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }

    // I found those manually lol
    bad_wires := []string {
        "z10",
        "z21",
        "z33",
        "nks",
        "gpr",
        "ghp",
        "krs",
        "cpm",
    }
    slice.sort(bad_wires)
    for w in bad_wires {
        fmt.printf("%s,", w)
    }
}

