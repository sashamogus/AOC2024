package aoc2024_day2

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:slice"

is_safe :: proc(s: []int) -> bool {
    dec: bool
    for i in 1..<len(s) {
        new_dec := s[i] < s[i - 1]
        if new_dec != dec && i != 1 {
            return false
        }
        dec = new_dec

        if s[i] == s[i - 1] {
            return false
        }

        if abs(s[i] - s[i - 1]) > 3 {
            return false
        }
    }

    return true
}

is_safe_dumpener :: proc(s: []int) -> bool {
    if is_safe(s) {
        return true
    }

    lol := make([]int, len(s) - 1)
    for i in 0..<len(s) {
        for j in 0..<len(lol) {
            if j >= i {
                lol[j] = s[j+1]
            } else {
                lol[j] = s[j]
            }
        }

        if is_safe(lol) {
            return true
        }
    }
    return false
}

main :: proc() {
    context.allocator = context.temp_allocator
    data, ok := os.read_entire_file("input.txt")
    if !ok {
        fmt.eprintln("Failed to read")
        return
    }

    count := 0
    lines := strings.split_lines(string(data))
    for line in lines {
        if line == "" { continue }

        nums_str := strings.split(line, " ")
        nums: [dynamic]int
        for str in nums_str {
            num, ok := strconv.parse_int(str)
            append(&nums, num)
        }

        if is_safe_dumpener(nums[:]) {
            count += 1
        }

        //fmt.printfln("%v, %s", is_safe(nums[:]), line)
    }
    fmt.println(count)
}
