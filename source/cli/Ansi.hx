package cli;

class Ansi
{
    // Reset
    public static var RESET = "\033[0m";
    
    // Atributos de texto
    public static var BOLD = "\033[1m";
    public static var DIM = "\033[2m";
    public static var ITALIC = "\033[3m";
    public static var UNDERLINE = "\033[4m";
    public static var BLINK = "\033[5m";
    public static var REVERSE = "\033[7m";
    public static var HIDDEN = "\033[8m";
    public static var STRIKE = "\033[9m";
    
    // Foreground (texto)
    public static var BLACK = "\033[30m";
    public static var RED = "\033[31m";
    public static var GREEN = "\033[32m";
    public static var YELLOW = "\033[33m";
    public static var BLUE = "\033[34m";
    public static var MAGENTA = "\033[35m";
    public static var CYAN = "\033[36m";
    public static var WHITE = "\033[37m";
    public static var DEFAULT_FG = "\033[39m";
    
    // Foreground brilhante
    public static var BRIGHT_BLACK = "\033[90m";
    public static var BRIGHT_RED = "\033[91m";
    public static var BRIGHT_GREEN = "\033[92m";
    public static var BRIGHT_YELLOW = "\033[93m";
    public static var BRIGHT_BLUE = "\033[94m";
    public static var BRIGHT_MAGENTA = "\033[95m";
    public static var BRIGHT_CYAN = "\033[96m";
    public static var BRIGHT_WHITE = "\033[97m";
    
    // Background
    public static var BG_BLACK = "\033[40m";
    public static var BG_RED = "\033[41m";
    public static var BG_GREEN = "\033[42m";
    public static var BG_YELLOW = "\033[43m";
    public static var BG_BLUE = "\033[44m";
    public static var BG_MAGENTA = "\033[45m";
    public static var BG_CYAN = "\033[46m";
    public static var BG_WHITE = "\033[47m";
    public static var DEFAULT_BG = "\033[49m";
    
    // Background brilhante
    public static var BG_BRIGHT_BLACK = "\033[100m";
    public static var BG_BRIGHT_RED = "\033[101m";
    public static var BG_BRIGHT_GREEN = "\033[102m";
    public static var BG_BRIGHT_YELLOW = "\033[103m";
    public static var BG_BRIGHT_BLUE = "\033[104m";
    public static var BG_BRIGHT_MAGENTA = "\033[105m";
    public static var BG_BRIGHT_CYAN = "\033[106m";
    public static var BG_BRIGHT_WHITE = "\033[107m";
    
    // Cores de 256 e RGB
    public static function color256(n:Int):String
        return '\033[38;5;${n}m';
        
    public static function bgColor256(n:Int):String
        return '\033[48;5;${n}m';
        
    public static function rgb(r:Int, g:Int, b:Int):String
        return '\033[38;2;${r};${g};${b}m';
        
    public static function bgRgb(r:Int, g:Int, b:Int):String
        return '\033[48;2;${r};${g};${b}m';
        
    // Cursor
    public static function up(n:Int)
        return '\033[${n}A';
        
    public static function down(n:Int)
        return '\033[${n}B';
        
    public static function right(n:Int)
        return '\033[${n}C';
        
    public static function left(n:Int)
        return '\033[${n}D';
        
    public static function goTo(row:Int, col:Int)
        return '\033[${row};${col}H';
        
    public static var CLEAR_SCREEN = "\033[2J";
    public static var CLEAR_LINE = "\033[2K";
}
