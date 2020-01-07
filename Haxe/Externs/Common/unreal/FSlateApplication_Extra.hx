package unreal;

import unreal.inputcore.*;
import unreal.slatecore.*;

extern class FSlateApplication_Extra {
  public static var CursorPointerIndex(default, never):Const<Int32>;

  public function GetPressedMouseButtons():Const<PRef<TSet<FKey>>>;

  public function GetPlatformApplication():TSharedPtr<GenericApplication>;

  /**
  * Called by the native application in response to a mouse button press. Routs the event to Slate Widgets.
  *
  * @param  PlatformWindow  The platform window the event originated from, used to set focus at the platform level.
  *                         If Invalid the Mouse event will work but there will be no effect on the platform.
  * @param  InMouseEvent    Mouse event
  * @return  Was this event handled by the Slate application?
  */
  public function ProcessMouseButtonDownEvent(PlatformWindow:Const<PRef<TSharedPtr<FGenericWindow>>>, InMouseEvent:Const<PRef<FPointerEvent>>) : Bool;

  /**
   * Called by the native application in response to a mouse button release. Routs the event to Slate Widgets.
   *
   * @param  InMouseEvent  Mouse event
   * @return  Was this event handled by the Slate application?
  */
  public function ProcessMouseButtonUpEvent(InMouseEvent:Const<PRef<FPointerEvent>>) : Bool;

  /**
   * Called by the native application in response to a mouse move. Routs the event to Slate Widgets.
   *
   * @param  InMouseEvent  Mouse event
   * @param  bIsSynthetic  True when the even is synthesized by slate.
   * @return  Was this event handled by the Slate application?
   */
  public function ProcessMouseMoveEvent(MouseEvent:Const<PRef<FPointerEvent>>, bIsSynthetic:Bool) : Bool;

	/** Releases the focus for all users from whatever it currently is on. */
  public function ClearAllUserFocus(ReasonFocusIsChanging:unreal.slatecore.EFocusCause = unreal.slatecore.EFocusCause.SetDirectly) : Void;
}
