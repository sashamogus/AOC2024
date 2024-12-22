package aoc2024_day22

import "core:fmt"
import "core:os"
import "core:math"
import "core:strings"
import "core:strconv"

mix_and_prune :: proc(n, secret: int) -> int {
    n := n ~ secret
    return n %% 16777216
}

generate_next :: proc(n: int) -> int {
    n := mix_and_prune(n*64, n)
    n = mix_and_prune(n/32, n)
    n = mix_and_prune(n*2048, n)
    return n
}

find_best_seqence :: proc(prices, price_changes: [][2000]int) -> int {
    memo := make([]map[[4]int]int, len(prices), context.temp_allocator)
    for &m, j in memo {
        m = make(map[[4]int]int, context.temp_allocator)
        pr := prices[j]
        pc := price_changes[j]
        for i in 0..<2000 - 3 {
            key: [4]int
            copy(key[:], pc[i:i + 4])
            if key not_in m {
                m[key] = pr[i + 3]
            }
        }
    }

    memo_all := make(map[[4]int]int, context.temp_allocator)
    for m in memo {
        for k, v in m {
            if k not_in memo_all {
                memo_all[k] = v
            } else {
                memo_all[k] += v
            }
        }
    }

    best_score: int
    for k, v in memo_all {
        if best_score < v {
            best_score = v
        }
    }
    free_all(context.temp_allocator)

    return best_score
}

process_file :: proc(filename: string) -> (int, int) {
    data, ok := os.read_entire_file(filename)
    assert(ok)

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1]

    prices := make([][2000]int, len(lines))
    price_changes := make([][2000]int, len(lines))
    ans1, ans2: int
    for line, j in lines {
        n, n_ok := strconv.parse_int(line)
        assert(n_ok)

        pr := &prices[j]
        pc := &price_changes[j]
        prev := n %% 10
        for i in 0..<2000 {
            n = generate_next(n)
            pr[i] = (n %% 10)
            pc[i] = (n %% 10) - prev
            prev = n %% 10
        }
        ans1 += n
    }
    ans2 = find_best_seqence(prices, price_changes)

    return ans1, ans2
}

main :: proc() {
    {
        fmt.println(process_file("example.txt"))
        fmt.println(process_file("example2.txt"))
        fmt.println(process_file("input.txt"))
    }
}

