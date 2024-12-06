package aoc2024_day5

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"

Rule :: struct {
    first, second: int,
}

main :: proc() {
    data, ok := os.read_entire_file("input.txt")
    if !ok {
        return
    }

    data_lines := strings.split_lines(string(data))

    empty, found := slice.linear_search(data_lines, "")
    rule_lines, update_lines := slice.split_at(data_lines, empty)

}
