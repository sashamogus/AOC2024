package aoc2024_day7

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

parse_line :: proc(line: string) -> (int, []int) {
    spl := strings.split(line, ": ")
    v, v_ok := strconv.parse_int(spl[0])
    assert(v_ok)

    rhs := strings.split(spl[1], " ")
    nums := make([]int, len(rhs))
    for str, i in rhs {
        n_ok: bool
        nums[i], n_ok = strconv.parse_int(str)
        assert(n_ok)
    }
    return v, nums
}

is_valid :: proc(v: int, nums: []int) -> bool {
    loop_count := 1 << u64(len(nums) - 1)
    for comb in 0..<loop_count {
        sum := nums[0]
        b := 1
        for i in 1..<len(nums) {
            if b & comb != 0 {
                sum += nums[i]
            } else {
                sum *= nums[i]
            }
            b *= 2
        }

        if sum == v {
            return true
        }
    }
    return false
}

is_valid2 :: proc(v: int, nums: []int) -> bool {
    loop_count := 3
    for _ in 2..<len(nums) {
        loop_count *= 3
    }
    for comb in 0..<loop_count {
        sum := nums[0]
        b := comb
        for i in 1..<len(nums) {
            switch b % 3 {
            case 0:
                sum += nums[i]
            case 1:
                sum *= nums[i]
            case 2:
                str := fmt.tprintf("%d%d", sum, nums[i])
                ok: bool
                sum, ok = strconv.parse_int(str)
                assert(ok)
            }
            if sum > v {
                break
            }
            b /= 3
        }

        if sum == v {
            return true
        }
    }
    return false
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))

    context.allocator = context.temp_allocator
    sum, sum2: int
    for line, i in lines {
        if line == "" { continue }
        if (i % 50) == 0 {
            fmt.printfln("Lines processed: %d", i)
        }

        v, nums := parse_line(line)
        if is_valid(v, nums) {
            sum += v
        }
        if is_valid2(v, nums) {
            sum2 += v
        }
        free_all(context.temp_allocator)
    }

    return sum, sum2
}

main :: proc() {
    {
        v, l := parse_line("21037: 9 7 18 13")
        defer delete(l)
        assert(v == 21037)
        assert(len(l) == 4)
        assert(l[0] == 9)
        assert(l[1] == 7)
        assert(l[2] == 18)
        assert(l[3] == 13)
    }

    {
        //v, l := parse_line("7290: 6 8 6 15")
        //defer delete(l)
        //fmt.println(is_valid2(v, l))
    }

    {
        n, m := process_file("input.txt")
        fmt.println(n)
        fmt.println(m)
    }
}

