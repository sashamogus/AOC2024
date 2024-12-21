package aoc2024_day21

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

key_to_pos :: proc(layout: string, key: byte) -> [2]int {
    index, found := slice.linear_search(transmute([]byte)layout, key)
    assert(found)
    return { index % 3, index / 3 }
}

append_char :: proc(str: string, char: byte) -> string {
    return fmt.tprintf("%s%c", str, char)
}

// Porting u/evouga's solution
// https://www.reddit.com/r/adventofcode/comments/1hj2odw/comment/m33lhla/
Edge :: struct {
    cur, dst: [2]int,
    depth: int,
}

memo := make(map[Edge]int)

cheapest_dir_pad :: proc(cur, dst: [2]int, nrobots: int) -> int {
    edge := Edge { cur, dst, nrobots }
    if edge in memo {
        return memo[edge]
    }

    answer := 0x7fff_ffff_ffff_ffff
    Visit :: struct {
        pos: [2]int,
        presses: string,
    }
    q := make([dynamic]Visit, context.temp_allocator)
    append(&q, Visit { cur, "" })

    for len(q) > 0 {
        v := pop(&q)
        if v.pos == dst {
            rec := cheapest_robot(append_char(v.presses, 'A'), nrobots - 1)
            answer = min(answer, rec)
            continue
        }
        if v.pos == { 0, 0 } {
            continue
        }

        if v.pos.x < dst.x {
            append(&q, Visit { v.pos + { 1, 0 }, append_char(v.presses, '>') })
        } else if v.pos.x > dst.x {
            append(&q, Visit { v.pos + { -1, 0 }, append_char(v.presses, '<') })
        }
        if v.pos.y < dst.y {
            append(&q, Visit { v.pos + { 0, 1 }, append_char(v.presses, 'v') })
        } else if v.pos.y > dst.y {
            append(&q, Visit { v.pos + { 0, -1 }, append_char(v.presses, '^') })
        }
    }

    memo[edge] = answer
    return answer
}

cheapest_robot :: proc(presses: string, nrobots: int) -> int {
    if nrobots == 1 {
        return len(presses)
    }

    pad_config := "X^A<v>"
    cur := [2]int { 2, 0 }
    sum: int
    for r in presses {
        next := key_to_pos(pad_config, byte(r))
        sum += cheapest_dir_pad(cur, next, nrobots)
        cur = next
    }
    return sum
}

cheapest :: proc(cur, dst: [2]int, nrobots: int) -> int {
    answer := 0x7fff_ffff_ffff_ffff
    Visit :: struct {
        pos: [2]int,
        presses: string,
    }
    q := make([dynamic]Visit, context.temp_allocator)
    append(&q, Visit { cur, "" })

    for len(q) > 0 {
        v := pop(&q)
        if v.pos == dst {
            rec := cheapest_robot(append_char(v.presses, 'A'), nrobots)
            answer = min(answer, rec)
            continue
        }
        if v.pos == { 0, 3 } {
            continue
        }

        if v.pos.x < dst.x {
            append(&q, Visit { v.pos + { 1, 0 }, append_char(v.presses, '>') })
        } else if v.pos.x > dst.x {
            append(&q, Visit { v.pos + { -1, 0 }, append_char(v.presses, '<') })
        }
        if v.pos.y < dst.y {
            append(&q, Visit { v.pos + { 0, 1 }, append_char(v.presses, 'v') })
        } else if v.pos.y > dst.y {
            append(&q, Visit { v.pos + { 0, -1 }, append_char(v.presses, '^') })
        }
    }

    return answer
}

complexity :: proc(str: string, nrobots: int) -> int {
    n, n_ok := strconv.parse_int(str[:len(str) - 1])
    assert(n_ok)

    numpad := "789456123 0A"

    sum: int
    pos := key_to_pos(numpad, 'A')
    for r in str {
        next := key_to_pos(numpad, byte(r))
        sum += cheapest(pos, next, nrobots)
        pos = next
        free_all(context.temp_allocator)
    }
    return sum*n
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    ans1, ans2: int
    for line in lines {
        ans1 += complexity(line, 3)
        ans2 += complexity(line, 26)
    }

    return ans1, ans2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

