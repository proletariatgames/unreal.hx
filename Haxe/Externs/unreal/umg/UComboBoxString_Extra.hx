package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/ContentWidget.h", "Components/ComboBoxString.h")
extern class UComboBoxString_Extra {
  public var OnSelectionChanged (get,never): FOnSelectionChangedEvent;
}
