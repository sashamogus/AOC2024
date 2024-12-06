package aoc2024_day1

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:slice"

count :: proc(s: []int, f: int) -> int {
    c := 0
    for n in s {
        if n == f {
            c += 1
        }
    }
    return c
}

main :: proc() {
    data, ok := os.read_entire_file("input.txt")
    if !ok {
        fmt.eprintln("Failed to read")
        return
    }
    lines := strings.split_lines(string(data))
    nums1, nums2: [dynamic]int
    for line in lines {
        if line == "" { continue }
        pair := strings.split(line, "   ")
        num1, ok1 := strconv.parse_int(pair[0])
        num2, ok2 := strconv.parse_int(pair[1])
        append(&nums1, num1)
        append(&nums2, num2)
    }
    
    slice.sort(nums1[:])
    slice.sort(nums2[:])

    total_dist := 0
    for i in 0..<len(nums1) {
        total_dist += abs(nums1[i] - nums2[i])
    }

    similarity := 0
    for i in 0..<len(nums1) {
        similarity += count(nums2[:], nums1[i])*nums1[i]
    }
    fmt.println(similarity)
}
