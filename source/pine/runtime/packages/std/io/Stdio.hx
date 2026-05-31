package pine.runtime.packages.std.io;

class Stdio extends NativeNamespace
{
    public function new()
    {
        super("pine.std.io");
        add("out", new Stdout());
    }
}
