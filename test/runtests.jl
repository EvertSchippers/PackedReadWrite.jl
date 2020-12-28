
using Test
using PackedReadWrite

struct Example
    float::Float32
    byte::UInt8
    int::Int32
end

@reflect Example

struct ExampleNoReflect
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

@reflect ExamplePrivate

module SomeOtherModule
    struct OtherStruct
        byte1::UInt8
        byte2::UInt8
    end
end

@reflect SomeOtherModule.OtherStruct

@testset "Test read." begin

    example = Example(10,20,30)
    io = IOBuffer()
    write(io, example.float)
    write(io, example.byte)
    write(io, example.int)
    seekstart(io)
    example_read = read_struct(io, Example)
    @test example_read == example


    example = ExampleNoReflect(10,20,30)
    io = IOBuffer()
    write(io, example.float)
    write(io, example.byte)
    write(io, example.int)
    seekstart(io)
    example_read = read_struct(io, ExampleNoReflect)
    @test example_read == example

    io = IOBuffer()
    other = SomeOtherModule.OtherStruct(1,2)
    write(io, other.byte1)
    write(io, other.byte2)
    seekstart(io)
    other_read = read_struct(io, SomeOtherModule.OtherStruct)
    @test other_read == other

end

@testset "Test read errors." begin

    io = IOBuffer(rand(UInt8, 100))

    @test_throws Exception read_struct(io, ExamplePrivate)
    @test_throws Exception read_struct(io, Int64)
    
end

@testset "Test write." begin

    example = Example(10,20,30)
    io = IOBuffer()
    bytes_written = write_struct(io, example)
    @test bytes_written == 9
    @test bytes_written == position(io)    
    seekstart(io)
    @test read(io, Float32) == 10
    @test read(io, UInt8) == 20
    @test read(io, Int32) == 30
 

    example = ExampleNoReflect(10,20,30)
    io = IOBuffer()
    bytes_written = write_struct(io, example)
    @test bytes_written == 9
    @test bytes_written == position(io)    
    seekstart(io)
    @test read(io, Float32) == 10
    @test read(io, UInt8) == 20
    @test read(io, Int32) == 30

    io = IOBuffer()
    example_private = ExamplePrivate()
    write_struct(io, example_private)
    seekstart(io)
    @test read(io, Float32) == 1
    @test read(io, UInt8) == 2
    @test read(io, Int32) == 3

    other = SomeOtherModule.OtherStruct(1,2)
    io = IOBuffer()
    @test write_struct(io, other) == 2
    seekstart(io)
    @test read(io, UInt8) == 1
    @test read(io, UInt8) == 2

end

@testset "Test write error." begin
    io = IOBuffer()
    @test_throws Exception write_struct(io, 42)
end

struct ExampleParam{T}
    item::T
end

@reflect ExampleParam{UInt16}

@testset "Test ExampleParam" begin

    io = IOBuffer()
    @test write_struct(io, ExampleParam{UInt16}(42)) == 2
    seekstart(io)
    @test read_struct(io, ExampleParam{UInt16}).item == 42

end
