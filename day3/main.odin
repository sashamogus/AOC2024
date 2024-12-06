package aoc2024_day3

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:os"
import "core:slice"


Stage :: enum {
    M,
    U,
    L,
    Open,
    Num1,
    Num2,
    Do,
    Dont,
}

main :: proc() {
    data, ok := os.read_entire_file("input.txt")

    NUMBERS :: "0123456789"
    num1, num2: [3]byte
    len1, len2: int

    str_do   := "do()"
    str_dont := "don't()"
    do_index: int
    stage := Stage.M

    total: int
    start: int
    for c, i in data {
        switch stage {
        case .M:
            if c == 'm' {
                start = i
                stage = .U
            } else if c == 'd' {
                do_index = 1
                stage = .Dont
            }
        case .U:
            if c == 'u' { stage = .L } else { stage = .M }
        case .L:
            if c == 'l' { stage = .Open } else { stage = .M }
        case .Open:
            if c == '(' {
                len1 = 0
                num1 = '0'
                stage = .Num1
            } else {
                stage = .M
            }
        case .Num1:
            if strings.contains_rune(NUMBERS, rune(c)) {
                if len1 < 3 {
                    num1[len1] = c
                    len1 += 1
                } else {
                    stage = .M
                }
            } else if c == ',' && len1 > 0 {
                len2 = 0
                num2 = '0'
                stage = .Num2
            } else {
                stage = .M
            }
        case .Num2:
            if strings.contains_rune(NUMBERS, rune(c)) {
                if len2 < 3 {
                    num2[len2] = c
                    len2 += 1
                } else {
                    stage = .M
                }
            } else if c == ')' && len2 > 0 {
                fmt.println(string(data[start:i+1]))
                fmt.printfln("num1 = %s, num2 = %s", string(num1[:len1]), string(num2[:len2]))
                n1, n1_ok := strconv.parse_int(string(num1[:len1]))
                n2, n2_ok := strconv.parse_int(string(num2[:len2]))
                total += n1*n2
                stage = .M
            } else {
                stage = .M
            }
        case .Do:
            if c == str_do[do_index] {
                do_index += 1
                if do_index >= len(str_do) {
                    stage = .M
                }
            } else {
                do_index = 0
            }
        case .Dont:
            if c == str_dont[do_index] {
                do_index += 1
                if do_index >= len(str_dont) {
                    do_index = 0
                    stage = .Do
                }
            } else {
                stage = .M
            }
        }
    }

    fmt.println(total)
}

