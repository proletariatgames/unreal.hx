package unreal.slate;

extern class FInputChord_Extra {

	@:expr({
		var DisplayName = '';
		if (get_bCmd())
		{
			DisplayName += 'Cmd-';
		}
		if (get_bCtrl())
		{
			DisplayName += 'Ctrl-';
		}
		if (get_bShift())
		{
			DisplayName += 'Shift-';
		}
		if (get_bAlt())
		{
			DisplayName += 'Alt-';
		}
		DisplayName += get_Key().GetDisplayName().toString();
		return FText.fromString(DisplayName);
	}) public function GetDisplayName() : FText;
}