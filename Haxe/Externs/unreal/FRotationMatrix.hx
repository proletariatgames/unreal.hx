/* Hand created since it's not a USTRUCT */

package unreal;

@:glueCppIncludes("Math/RotationMatrix.h")

@:uextern extern class FRotationMatrix extends FMatrix {

   @:uname('new')
   public static function createWithRotator(rot:Const<PRef<FRotator>>) : PHaxeCreated<FRotationMatrix>;
}
