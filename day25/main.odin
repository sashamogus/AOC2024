package aoc2024_day25

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

KEY_SIZE :: 7
KEY_CMP_SIZE :: KEY_SIZE - 2
KEY_STRIDE :: KEY_SIZE + 1

Key :: [5]int
Lock :: [5]int

does_fit :: proc(key: Key, lock: Lock) -> bool {
    sum := key + lock
    for s in sum {
        if s > KEY_CMP_SIZE {
            return false
        }
    }
    return true
}

fit_count :: proc(keys: []Key, locks: []Lock) -> int {
    count: int
    for k in keys {
        for l in locks {
            if does_fit(k, l) {
                count += 1
            }
        }
    }
    return count
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))

    keys := make([dynamic]Key)
    locks := make([dynamic]Lock)
    for i in 0..<len(lines) / KEY_STRIDE {
        st := i*KEY_STRIDE
        key_lines := lines[st:st + KEY_SIZE]

        if key_lines[0] == "#####" {
            key: Key
            for kline, j in key_lines {
                for r, k in kline {
                    if r == '#' {
                        key[k] = max(key[k], j)
                    }
                }
            }
            append(&keys, key)
        } else {
            lock: Lock
            for kline, j in key_lines {
                for r, k in kline {
                    if r == '.' {
                        lock[k] = max(lock[k], j)
                    }
                }
            }
            lock = KEY_SIZE - lock - 2
            append(&locks, lock)
        }
    }

    count := fit_count(keys[:], locks[:])
    return count, 0
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("input.txt"))
    }
}

