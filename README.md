# PackedReadWrite.jl
This package provides efficient generic methods to read and write structs from and to IO streams.

Using the `@reflect` macro, `read_struct` and `write_struct` can now completely specialize to specific types, making them as fast as handcrafted specialized methods:

```
using PackagedReadWrite

struct Simple
    a::Int16
    b::Float64
end

io = IOBuffer(rand(UInt8,10))

# this is directly possible for all structs which have a default constructor:
s = read_struct(io, Simple)

# after calling this macro however, `read_struct` will be 10x faster.
@reflect Simple

seekstart(io)
s = read_struct(io, Simple) # now 10x faster

# to be specific, `read_struct` will be exactly as fast as the following `my_read`, which is written by hand solely for the `Simple` type.

function my_read(io::IO, ::Type{Simple})
    Simple( read(io, Int16), read( io, Float64) )
end
```

Check out `\benchmark\benchmark.jl` to see for your self. Run `julia --project=.` with the terminal in the `\benchmark` folder (since it has a `Manifest.toml` pointing to `PackedReadWrite` at the relative path `".."` and not by repository or absolute path).

## TODO
- "Endianness" has not been kept in mind at all - it should be made possible to indicate using little or big endian when writing or reading.
- In theory, this should work for structs which have proper struct types as fields, but it has not been covered in tests.
- Hunting for and covering edge cases in unit tests.
- Using `fieldoffsets` and `reinterpret` is should be possible to create a fallback read method for types that don't have a constructor.
  - Possibly, using the constructor should be the fall back? Who's to say that the method with the correct signature is indeed the constructor and has indeed the fields in the same order as returned by `fieldtypes`? Current implementation, though naive, covers 90+% of the use cases: reading or writing binary data into structs you define yourself for that purpose.
- CI/CD