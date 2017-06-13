/* Hand created since it's not a USTRUCT */

package unreal;

@:glueCppIncludes("Math/RotationMatrix.h")

@:uextern extern class FRotationMatrix extends FMatrix {

   @:uname('.ctor')
   public static function createWithRotator(rot:Const<PRef<FRotator>>) : FRotationMatrix;
   @:uname('new')
   public static function createNewWithRotator(rot:Const<PRef<FRotator>>) : POwnedPtr<FRotationMatrix>;
}
