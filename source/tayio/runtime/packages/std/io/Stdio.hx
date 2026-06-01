package tayio.runtime.packages.std.io;

class Stdio extends NativeNamespace
{
    public function new()
    {
        super("io");
        add("out", new Stdout());
    }
}
