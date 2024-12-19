package aoc2024_day19

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

is_pattern_possible :: proc(pattern: string, towels: []string) -> bool {
    for towel in towels {
        if strings.has_prefix(pattern, towel) {
            if len(pattern) == len(towel) {
                return true
            } else {
                if is_pattern_possible(pattern[len(towel):], towels) {
                    return true
                }
            }
        }
    }

    return false
}

pattern_cache: map[string]int
pattern_count :: proc(pattern: string, towels: []string) -> int {
    if pattern in pattern_cache {
        return pattern_cache[pattern]
    }
    sum: int
    for towel in towels {
        if strings.has_prefix(pattern, towel) {
            if len(pattern) == len(towel) {
                sum += 1
            } else {
                sum += pattern_count(pattern[len(towel):], towels)
            }
        }
    }
    pattern_cache[pattern] = sum

    return sum
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    towels := strings.split(lines[0], ",")
    for &towel in towels {
        if towel[0] == ' ' {
            towel = towel[1:]
        }
    }

    clear(&pattern_cache)
    ans1, ans2: int
    for line, i in lines[2:] {
        if is_pattern_possible(line, towels) {
            ans1 += 1
        }
        ans2 += pattern_count(line, towels)
    }

    return ans1, ans2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

