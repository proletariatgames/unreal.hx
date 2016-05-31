package unreal.umg;

import unreal.slatecore.ESelectInfo;

@:glueCppIncludes("UMG.h", "Types/SlateEnums.h", "Components/ComboBoxString.h")
@:uname('UComboBoxString.FOnSelectionChangedEvent')
typedef FOnSelectionChangedEvent = DynamicMulticastDelegate<FOnSelectionChangedEvent,FString->ESelectInfo->Void>;
