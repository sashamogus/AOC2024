package aoc2024_pasta

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "base:intrinsics"

is_sets_same :: proc(set1, set2: [3]string) -> bool {
    set2 := set2
    for i in set1 {
        if !slice.contains(set2[:], i) {
            return false
        }
    }
    return true
}

DIRS :: [4][2]int { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, }

process_file :: proc(filename: string) -> int {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    connections := make([][2]string, len(lines))
    for line, i in lines {
        connections[i] = [2]string { line[:2], line[3:] }
    }
    
    c_map := make(map[string][dynamic]string)
    for c in connections {
        if c[0] not_in c_map {
            c_map[c[0]] = make([dynamic]string)
        }
        if c[1] not_in c_map {
            c_map[c[1]] = make([dynamic]string)
        }
        append(&c_map[c[0]], c[1])
        append(&c_map[c[1]], c[0])
    }

    three_sets := make([dynamic][3]string)
    for k, v in c_map {
        for c in v {
            for ca in c_map[c] {
                if slice.contains(v[:], ca) {
                    append(&three_sets, [3]string { k, c, ca })
                }
            }
        }
    }

    #reverse for t, i in three_sets {
        contain_t: bool
        for str in t {
            if str[0] == 't' {
                contain_t = true
                break
            }
        }
        if !contain_t {
            unordered_remove(&three_sets, i)
            continue
        }
        for j := i - 1; j >= 0; j -= 1 {
            if is_sets_same(t, three_sets[j]) {
                unordered_remove(&three_sets, i)
                break
            }
        }
    }
    ans1 := len(three_sets)

    set_array := make([dynamic]string)
    test_array := make([dynamic]string)
    biggest_set: int
    for k, v in c_map {
        clear(&set_array)
        append(&set_array, k)
        for c in v {
            append(&set_array, c)
        }

        test_limit := int(1 << uint(len(set_array)))
        for test_index in 0..<test_limit {
            if intrinsics.count_ones(test_index) <= biggest_set {
                continue
            }

            clear(&test_array)
            b := 1
            for c, i in set_array {
                if b & test_index != 0 {
                    append(&test_array, c)
                }
                b *= 2
            }

            valid_set := true
            loop_i: for ci in test_array {
                cons := c_map[ci]
                for cj in test_array {
                    if cj == ci { continue }
                    if !slice.contains(cons[:], cj) {
                        valid_set = false
                        break loop_i
                    }
                }
            }
            if valid_set {
                biggest_set = len(test_array)
                slice.sort(test_array[:])
                for t in test_array {
                    fmt.printf("%s,", t) // print out answer for part 2
                }
                fmt.println()
            }
        }
    }

    return ans1
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

