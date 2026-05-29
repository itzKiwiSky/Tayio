package cli;

class Ansi
{
    // Reset
    public static inline var RESET = "\033[0m";
    
    // Atributos de texto
    public static inline var BOLD = "\033[1m";
    public static inline var DIM = "\033[2m";
    public static inline var ITALIC = "\033[3m";
    public static inline var UNDERLINE = "\033[4m";
    public static inline var BLINK = "\033[5m";
    public static inline var REVERSE = "\033[7m";
    public static inline var HIDDEN = "\033[8m";
    public static inline var STRIKE = "\033[9m";
    
    // Foreground (texto)
    public static inline var BLACK = "\033[30m";
    public static inline var RED = "\033[31m";
    public static inline var GREEN = "\033[32m";
    public static inline var YELLOW = "\033[33m";
    public static inline var BLUE = "\033[34m";
    public static inline var MAGENTA = "\033[35m";
    public static inline var CYAN = "\033[36m";
    public static inline var WHITE = "\033[37m";
    public static inline var DEFAULT_FG = "\033[39m";
    
    // Foreground brilhante
    public static inline var BRIGHT_BLACK = "\033[90m";
    public static inline var BRIGHT_RED = "\033[91m";
    public static inline var BRIGHT_GREEN = "\033[92m";
    public static inline var BRIGHT_YELLOW = "\033[93m";
    public static inline var BRIGHT_BLUE = "\033[94m";
    public static inline var BRIGHT_MAGENTA = "\033[95m";
    public static inline var BRIGHT_CYAN = "\033[96m";
    public static inline var BRIGHT_WHITE = "\033[97m";
    
    // Background
    public static inline var BG_BLACK = "\033[40m";
    public static inline var BG_RED = "\033[41m";
    public static inline var BG_GREEN = "\033[42m";
    public static inline var BG_YELLOW = "\033[43m";
    public static inline var BG_BLUE = "\033[44m";
    public static inline var BG_MAGENTA = "\033[45m";
    public static inline var BG_CYAN = "\033[46m";
    public static inline var BG_WHITE = "\033[47m";
    public static inline var DEFAULT_BG = "\033[49m";
    
    // Background brilhante
    public static inline var BG_BRIGHT_BLACK = "\033[100m";
    public static inline var BG_BRIGHT_RED = "\033[101m";
    public static inline var BG_BRIGHT_GREEN = "\033[102m";
    public static inline var BG_BRIGHT_YELLOW = "\033[103m";
    public static inline var BG_BRIGHT_BLUE = "\033[104m";
    public static inline var BG_BRIGHT_MAGENTA = "\033[105m";
    public static inline var BG_BRIGHT_CYAN = "\033[106m";
    public static inline var BG_BRIGHT_WHITE = "\033[107m";
    
    // Cores de 256 e RGB
    public static inline function color256(n:Int):String
        return '\033[38;5;${n}m';
        
    public static inline function bgColor256(n:Int):String
        return '\033[48;5;${n}m';
        
    public static inline function rgb(r:Int, g:Int, b:Int):String
        return '\033[38;2;${r};${g};${b}m';
        
    public static inline function bgRgb(r:Int, g:Int, b:Int):String
        return '\033[48;2;${r};${g};${b}m';
        
    // Cursor
    public static inline function up(n:Int)
        return '\033[${n}A';
        
    public static inline function down(n:Int)
        return '\033[${n}B';
        
    public static inline function right(n:Int)
        return '\033[${n}C';
        
    public static inline function left(n:Int)
        return '\033[${n}D';
        
    public static inline function goTo(row:Int, col:Int)
        return '\033[${row};${col}H';
        
    public static inline var CLEAR_SCREEN = "\033[2J";
    public static inline var CLEAR_LINE = "\033[2K";
}
