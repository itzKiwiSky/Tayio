package taiyo.runtime.packages.std.crypto;

import haxe.io.Bytes;
import taiyo.lexer.LangError;
import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.Value;
import taiyo.runtime.NativeUtils;
import haxe.crypto.Sha256;
import haxe.crypto.Sha1;
import haxe.crypto.Md5;
import haxe.crypto.Base64;
import haxe.crypto.Sha224;

class TaiyoCrypto implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var mod:Map<String, Value> = [];
        
        mod.set("sha256", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "sha256", 1);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'sha256() expects an string as first argument'));
                
            return Ok(StringVal(Sha256.encode(str)));
        }));
        
        mod.set("sha224", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "sha224", 1);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'sha224() expects an string as first argument'));
                
            return Ok(StringVal(Sha224.encode(str)));
        }));
        
        mod.set("sha1", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "sha1", 1);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'sha1() expects an string as first argument'));
                
            return Ok(StringVal(Sha1.encode(str)));
        }));
        
        mod.set("md5", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "md5", 1);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'md5() expects an string as first argument'));
                
            return Ok(StringVal(Md5.encode(str)));
        }));
        
        mod.set("encodeBase64", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "encodeBase64", 1);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'encodeBase64() expects an string as first argument'));
                
            return Ok(StringVal(Base64.encode(Bytes.ofString(str))));
        }));
        
        mod.set("decodeBase64", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "decodeBase64", 1);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'decodeBase64() expects an string as first argument'));
                
            var result:Bytes = Base64.decode(str);
            return Ok(StringVal(result.getString(0, result.length)));
        }));
        
        return mod;
    }
}
