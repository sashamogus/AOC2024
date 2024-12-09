package aoc2024_day9

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"

print_blocks :: proc(blocks: []int) {
    for b in blocks {
        if b == -1 {
            fmt.print('.')
        } else {
            fmt.print(b)
        }
    }
    fmt.println()
}

generate_blocks :: proc(line: string) -> []int {
    blocks := make([dynamic]int)
    is_file := true
    file_id: int
    for r in line {
        n := int(r - '0')
        assert(n >= 0)
        assert(n < 10)

        b := -1
        if is_file {
            b = file_id
            file_id += 1
        }
        for _ in 0..<n {
            append(&blocks, b)
        }
        is_file = !is_file
    }
    return blocks[:]
}

move_blocks :: proc(blocks: []int) {
    last_block := len(blocks) - 1
    for i in 0..<len(blocks) {
        if blocks[i] != -1 { continue }

        for j := last_block; j > i; j -= 1 {
            if blocks[j] != -1 {
                blocks[i] = blocks[j]
                blocks[j] = -1
                last_block = j - 1
                break
            }
        }
    }
}

move_files :: proc(blocks: []int) {
    file_end: int
    prev := -1
    for i := len(blocks) - 1; i >= 0; i -= 1 {
        if prev == -1 && blocks[i] != -1 {
            file_end = i
        } else if prev != blocks[i] {
            file_slice := blocks[i + 1:file_end + 1]
            space_start, space_size: int
            for j in 0..=i {
                if blocks[j] == -1 {
                    if space_size == 0 {
                        space_start = j
                    }
                    space_size += 1
                    if space_size >= len(file_slice) {
                        space_slice := blocks[space_start:space_start + space_size]
                        copy(space_slice, file_slice)
                        slice.fill(file_slice, -1)
                        break
                    }
                } else {
                    space_size = 0
                }
            }
            file_end = i
        }

        prev = blocks[i]
    }
}

checksum :: proc(blocks: []int) -> int {
    sum: int
    for b, i in blocks {
        if b == -1 {
            continue
        }
        sum += b*i
    }
    return sum
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    line := lines[0]

    blocks := generate_blocks(line)
    blocks2 := slice.clone(blocks)
    move_blocks(blocks)
    ans1 := checksum(blocks)

    move_files(blocks2)
    ans2 := checksum(blocks2)
    return ans1, ans2
}

main :: proc() {
    {
        fmt.println(process_file("input.txt"))
    }
}

