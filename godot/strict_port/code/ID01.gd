extends Node

# Function prototypes
func rt_udivmod32_core(dividend: uint, divisor: uint) -> ulonglong
func rt_sdivmod32_core(dividend: int, divisor: int) -> ulonglong

# Function: rt_udiv32
func rt_udiv32(dividend: uint, divisor: uint) -> uint:
    return int(rt_udivmod32_core(dividend, divisor) >> 32)

# Function: rt_umod32
func rt_umod32(dividend: uint, divisor: uint) -> uint:
    return int(rt_udivmod32_core(dividend, divisor))

# Function: rt_sdiv32
func rt_sdiv32(dividend: int, divisor: int) -> int:
    return int(rt_sdivmod32_core(dividend, divisor) >> 32)

# Function: rt_smod32
func rt_smod32(dividend: int, divisor: int) -> int:
    return int(rt_sdivmod32_core(dividend, divisor))

# Function: rt_sdivmod32_core
func rt_sdivmod32_core(dividend: int, divisor: int) -> ulonglong:
    var r: ulonglong
    var quot: uint
    var rem: uint

    if dividend < 0:
        if divisor < 0:
            r = rt_udivmod32_core(-(dividend), -(divisor))
            quot = int(r >> 32)
            rem = -(int(r))
        else:
            r = rt_udivmod32_core(-(dividend), divisor)
            quot = -(int(r >> 32))
            rem = -(int(r))
    elif divisor < 0:
        r = rt_udivmod32_core(dividend, -(divisor))
        quot = -(int(r >> 32))
        rem = int(r)
    else:
        return rt_udivmod32_core(dividend, divisor)

    return (ulonglong)quot << 32 | rem

# Function: rt_udivmod32_core
func rt_udivmod32_core(dividend: uint, divisor: uint) -> ulonglong:
    var quot: uint
    var mid: uint
    var n: uint
    var d: uint
    var hi: uint
    var sum: uint
    var lo: uint

    if dividend < divisor:
        return (ulonglong)dividend

    if dividend <= 0xffff:
        return (ulonglong)(dividend // divisor) << 32 | dividend % divisor

    if divisor <= 0xffff:
        mid = (dividend >> 16) % divisor << 16 | (dividend & 0xffff)
        quot = (dividend >> 16) // divisor << 16 | mid // divisor
        return (ulonglong)quot << 32 | mid % divisor

    n = dividend
    d = divisor
    while (0xffff < d):
        n = n >> 1
        d = d >> 1

    quot = n // d & 0xffff

    while true:
        lo = (divisor & 0xffff) * quot
        hi = (divisor >> 16) * quot
        sum = (hi << 16 | hi >> 16) + lo

        if (sum >= lo) and (sum <= dividend):
            break

        quot = int(ushort(int(quot) - 1))

    return (ulonglong)quot << 32 | dividend - sum
        
