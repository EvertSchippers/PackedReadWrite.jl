module PackedReadWrite

export @enable_read, @enable_write

macro enable_read(type)
   
    if !Base.eval(__module__, :(isstructtype($type)))
        error("Can only create `read` method for struct types.")
    end
 
    # tuples with the field types and names:
    # to be "dynamically hard-coded" into the read method
    types = Base.eval(__module__, :(fieldtypes($type)))
    names = Base.eval(__module__, :(fieldnames($type)))
       
    if !Base.eval(__module__, :(hasmethod($type, $types)))
        error("No valid constructor found for $type.")
    end
    
    Base.eval(__module__, quote

        function Base.read(io::IO, type::Type{$type})
            $type(read.(Ref(io), $types)...)
        end
    
    end)

    return nothing
end

macro enable_write(type)
   
    if !Base.eval(__module__, :(isstructtype($type)))
        error("Can only create `write` method for struct types.")
    end
 
    # tuples with the field names:
    # to be "dynamically hard-coded" into the write method
    names = Base.eval(__module__, :(fieldnames($type)))
    
    Base.eval(__module__, quote

        function Base.write(io::IO, item::$type)
            return sum(write.(Ref(io), getfield.(Ref(item), $names)))
        end
    
    end)

    return nothing
end

end # module
