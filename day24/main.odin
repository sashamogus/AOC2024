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

process_file :: proc(filename: string) -> (int, int) {
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
    return z, 0
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

