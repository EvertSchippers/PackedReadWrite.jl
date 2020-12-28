using PackedReadWrite
using BenchmarkTools

struct Simple
    int32::Int32
    float64::Float64
    byte1::UInt8
    byte2::UInt8
    single::Float32
end

function packed_size(::Type{T}) where T
    sum(sizeof.(fieldtypes(T)))
end

function handcrafted(io::IO, ::Type{T}) where T <: Simple
    Simple(read(io, Int32), 
            read(io, Float64),
            read(io, UInt8),
            read(io, UInt8),
            read(io, Float32))
end

function test_base_read(io::T) where T
    seekstart(io)
    while !eof(io)
        read(io, Simple)
    end
end

function test_handcrafted(io::T) where T
    seekstart(io)
    while !eof(io)
        handcrafted(io, Simple)
    end
end

function test_generic_read(io::T) where T
    seekstart(io)
    while !eof(io)
        PackedReadWrite.read_struct(io, Simple)
    end
end

n = 1000
data = IOBuffer(rand(UInt8, n * packed_size(Simple)))

@info "Handcrafted, hard-coded specialized method:"
@btime test_handcrafted(data)
#   6.300 μs (0 allocations: 0 bytes)

@info "Generic read, before caching reflection:"
@btime test_generic_read(data)
#   88.000 μs (0 allocations: 0 bytes)

@reflect Simple

@info "Generic read, after caching reflection:"
@btime test_generic_read(data)
#   6.280 μs (0 allocations: 0 bytes)

Base.read(io::IO, ::Type{Simple}) = read_struct(io, Simple)

@info "Using new Base.read method:"
@btime test_base_read(data)
#   6.280 μs (0 allocations: 0 bytes)

