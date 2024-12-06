package aoc2024_day5

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Rule :: struct {
    first, second: int,
}

validate :: proc(rules: []Rule, nums: []int) -> bool {
    num_rules := make([dynamic]Rule, context.temp_allocator)
    for num, i in nums {
        if i == 0 { continue }

        clear(&num_rules)
        for rule in rules {
            if rule.first == num {
                append(&num_rules, rule)
            }
        }

        for j in 0..<i {
            for rule in num_rules {
                if nums[j] == rule.second {
                    return false
                }
            }
        }
    }

    return true
}

reorder :: proc(rules: []Rule, nums: []int) {
    num_rules := make([dynamic]Rule, context.temp_allocator)
    for i := 1; i < len(nums); i += 1 {
        num := nums[i]
        clear(&num_rules)
        for rule in rules {
            if rule.first == num {
                append(&num_rules, rule)
            }
        }

        swap: for j in 0..<i {
            for rule in num_rules {
                if nums[j] == rule.second {
                    nums[i] = nums[j]
                    nums[j] = num
                    i = 0
                    break swap
                }
            }
        }
    }
}

main :: proc() {
    data, os_ok := os.read_entire_file("input.txt")
    assert(os_ok)

    data_lines := strings.split_lines(string(data))

    empty, found := slice.linear_search(data_lines, "")
    rule_lines, update_lines := slice.split_at(data_lines, empty)
    
    rules := make([]Rule, len(rule_lines))
    for line, i in rule_lines {
        pair := strings.split(line, "|")
        num1, ok1 := strconv.parse_int(pair[0])
        num2, ok2 := strconv.parse_int(pair[1])
        rules[i] = { num1, num2 }
        assert(ok1)
        assert(ok2)
    }

    sum, sum_invalid: int
    for line in update_lines {
        if line == "" { continue }
        spl := strings.split(line, ",")
        nums := make([]int, len(spl), context.temp_allocator)
        for str, i in spl {
            num, ok := strconv.parse_int(str)
            nums[i] = num
            assert(ok)
        }

        if validate(rules, nums) {
            sum += nums[len(nums) / 2]
        } else {
            reorder(rules, nums)
            sum_invalid += nums[len(nums) / 2]
        }

        free_all(context.temp_allocator)
    }
    fmt.println(sum_invalid)
}
