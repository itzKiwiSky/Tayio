# Pine

Pine is a simple, weakly typed scripting language with focus to be used as internal tool for high performance systems
You can use pine inside your tools to script actions that you don't want to recompile every time

Is written in haxe, I made this project with the idea to learn the development process about
how interpreters / compilers work under the hood.

## Take a look

```
use pine.std

# Create a main function and say hello to the world
func main() do
    out.println("Hello World")
end
```

### A cool feature

If you don't want to inject all the functions inside the global namespace, no problem, you can inject inside the function scope, so you can use inside a sandboxed area

```
# Is the same as the first example, but now you can only use "print" or "println" inside the main function

func main() uses pine.std do
    println("Hello world")
end
```

Contributions are open
