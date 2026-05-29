package pine;

class Position
{
    var line:Int = 1;
    var index:Int = -1;
    var col:Int = -1;
    
    public function advance(currentChar:String)
    {
        index++;
        col++;
        if (~/[;\n]/.match(currentChar))
        {
            line++;
            col = 0;
        }
    }
}
