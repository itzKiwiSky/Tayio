# Pine

Pine is a simple, weakly typed scripting language with focus to be used as internal tool for high performance systems
You can use pine inside your tools to script actions that you don't want to recompile every time

Is written in haxe, I made this project with the idea to learn the development process about
how interpreters / compilers work under the hood.

## Take a look

```
use pine.std.io

# Create a main function and say hello to the world
func main() do
    out.println("Hello World")
end
```

### A cool feature

If you don't want to inject all the functions inside the global namespace, no problem, you can inject inside the function scope, so you can use inside a sandboxed area

```
# Is the same as the first example, but now you can only use "print" or "println" inside the main function

func main() uses pine.std.io[out] do
    println("Hello world")
end
```

## Some syntax showcase

### Variable declaration

```
# use local for scoped variables
local var = 1

# use global for variables that are using globally on the program
global var = 1
```

### functions

```
# you need a main entry point to begin btw
func main() do
    myFunc()
end

func myFunc() uses pine.std.io[out] do
    println("Hello World")
end
```

and pass function as argument for other functions

```
use pine.std.io

func main() do
    runFunc(func() do
        out.println("Hey I'm inside this function")
    end)
end

func runFunc(fn) do
    fn()
end
```

Contributions are open
