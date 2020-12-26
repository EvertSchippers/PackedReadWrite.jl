
using Test
using PackedReadWrite

struct Example
    float::Float32
    byte::UInt8
    int::Int32
end

struct ExamplePrivate
    ExamplePrivate() = new(1, 2, 3)
    float::Float32
    byte::UInt8
    int::Int32
end

module SomeOtherModule
    struct OtherStruct
        byte1::UInt8
        byte2::UInt8
    end
end

@testset "Test read." begin

    @enable_read(Example)

    example = Example(10,20,30)
    io = IOBuffer()
    write(io, example.float)
    write(io, example.byte)
    write(io, example.int)
    seekstart(io)
    example_read = read(io, Example)
    @test example_read == example

    @enable_read(SomeOtherModule.OtherStruct)

    io = IOBuffer()
    other = SomeOtherModule.OtherStruct(1,2)
    write(io, other.byte1)
    write(io, other.byte2)
    seekstart(io)
    other_read = read(io, SomeOtherModule.OtherStruct)
    @test other_read == other

end

@testset "Test read errors." begin
    
    # just to show that this does not throw when run using a working struct:
    include_string(Main, "@enable_read(Example)")
    
    # and these to catch compile/load errors for examples that shouldn't work:
    @test_throws LoadError include_string(Main, "@enable_read(Int)")
    @test_throws LoadError include_string(Main, "@enable_read(ExamplePrivate)")
    
end