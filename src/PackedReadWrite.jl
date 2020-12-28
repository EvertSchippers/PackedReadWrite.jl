module PackedReadWrite

export @reflect, read_struct, write_struct

"""
    @reflect(type)
implements methods for `fieldtypes` and `fieldnames` as constants for this `type`.
This makes other methods that use e.g. `fieldtypes(type)` (like `read_struct` does) very fast as it can 
now totally compile.

`type` must be a struct type.
"""
macro reflect(type)

    if !Base.eval(__module__, :(isstructtype($type)))
        error("Can only extend field... methods for struct types.")
    end
 
    types = Base.eval(__module__, :(fieldtypes($type)))
    names = Base.eval(__module__, :(fieldnames($type)))    
    num_fields = length(types)

    constructor_ok = Base.eval(__module__, :(hasmethod($type, $types)))
    
    Base.eval(__module__, quote
        Base.fieldtypes(::Type{T}) where T <: $type = $types
        Base.fieldnames(::Type{T}) where T <: $type = $names
        Base.fieldcount(::Type{T}) where T <: $type = $num_fields        

        PackedReadWrite.hasfullconstructor(::Type{T}) where T <: $type = $constructor_ok
    end)
    
    return
end

function hasfullconstructor(::Type{T})::Bool where T
    hasmethod(T, fieldtypes(T))
end

"""
    read_struct(io::IO, ::Type{T})
Reads a struct type `T` from `io`, field by field. In this version, it requires for `T`
to have a constructor accepting the fields in the same order as they are defined in.

Optionally call `@reflect T` in your module to speed up (>10x) this method for type instances of type `T`. 
"""
function read_struct(io::IO, ::Type{T}) where T
    
    if !(isstructtype(T))
        error("`$T` is not a struct type.")            
    end
    
    types = fieldtypes(T)

    if !(hasfullconstructor(T))
        error("No valid constructor found for $type.")    
    end

    T(read.(Ref(io), types)...)
end

"""
    write_struct(io::IO, sample::T) where T
Writes a instance of struct type `T` to `io`, field-by-field.

Optionally call `@reflect T` in your module to speed up (>10x) this method for type instances of type `T`. 
"""
function write_struct(io::IO, sample::T) where T

    if !(isstructtype(T))
        error("`$T` is not a struct type.")
    end

    fields = fieldnames(T)
    
    sum(write.(Ref(io), getfield.(Ref(sample), fields)))
end

end # module
