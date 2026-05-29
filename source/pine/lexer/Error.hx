package pine.lexer;

class Error
{
    var start:Int;
    var end:Int;
    var errName:String;
    var details:String;
    
    public function new(startPos:Int, endPos:Int, errorName:String, det:String)
    {
        start = startPos;
        end = endPos;
        errName = errorName;
        details = det;
    }
    
    public function toString()
    {
        var text:String = "";
        text += '$errName : $details\n';
        text += 'line: $start';
        return text;
    }
}
