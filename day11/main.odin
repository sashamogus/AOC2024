package aoc2024_day11

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

blink_map: map[[2]int]int

blink_count :: proc(n, depth: int) -> int {
    if depth == 0 {
        return 1
    }
    m, m_ok := blink_map[{ n, depth }]
    if m_ok {
        return m
    }
    ret: int
    if n == 0 {
        ret = blink_count(1, depth - 1)
    } else {
        str := fmt.tprint(n)
        if len(str) % 2 == 0 {
            lhs := str[:len(str) / 2]
            rhs := str[len(str) / 2:]
            l, l_ok := strconv.parse_int(lhs)
            r, r_ok := strconv.parse_int(rhs)
            assert(l_ok)
            assert(r_ok)
            ret = blink_count(l, depth - 1) + blink_count(r, depth - 1)
        } else {
            ret = blink_count(n*2024, depth - 1)
        }
    }
    blink_map[{ n, depth }] = ret
    return ret
}

blink_sum :: proc(nums: []int, depth: int) -> int {
    sum: int
    for n in nums {
        sum += blink_count(n, depth)
    }
    return sum
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    nums_str := strings.split(lines[0], " ")

    nums := make([dynamic]int)
    for str in nums_str {
        n, n_ok := strconv.parse_int(str)
        assert(n_ok)
        append(&nums, n)
    }

    ans1 := blink_sum(nums[:], 25)
    ans2 := blink_sum(nums[:], 75)
    return ans1, ans2
}


main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("example2.txt"))
        fmt.println(process_file("input.txt"))
    }
}

