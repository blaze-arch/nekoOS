import strutils

proc write(x: string) =
    echo x # for example.. he-he..

let writeprc = (proc (x: string))(write)

echo cast[uint]((proc (x: string))(write))

let writeprc2 = cast[proc(x: string) {.nimcall.}](writeprc)

writeprc2("test1")

#[

proc write[T](x: T): string = $x

# let myprc = write # error!
let myprc = write[int] # ok
echo myprc(5) # "5"


proc write(x: string): string = "hi"
proc write(x: int): string = "bye"

# let myprc = write # error!
let myprc = (proc (arg: string): string)(write) # argument names don't have to match
echo myprc("hi") # "hi"

]#