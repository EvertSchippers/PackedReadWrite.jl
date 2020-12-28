module PackedReadWrite

export @reflect, read_struct, write_struct

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

function write_struct(io::IO, sample::T) where T

    if !(isstructtype(T))
        error("`$T` is not a struct type.")
    end

    fields = fieldnames(T)
    
    sum(write.(Ref(io), getfield.(Ref(sample), fields)))
end

end # module
