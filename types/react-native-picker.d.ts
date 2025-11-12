declare module '@react-native-picker/picker' {
  import * as React from 'react';
  import {
    StyleProp,
    ViewStyle,
    TextStyle,
    ColorValue,
    GestureResponderEvent,
  } from 'react-native';

  export type PickerValue = string | number | null | undefined;

  export type PickerProps<T = PickerValue> = React.PropsWithChildren<{
    selectedValue?: T;
    onValueChange?: (itemValue: T, itemIndex: number) => void;
    enabled?: boolean;
    mode?: 'dialog' | 'dropdown';
    prompt?: string;
    testID?: string;
    style?: StyleProp<ViewStyle>;
    itemStyle?: StyleProp<TextStyle>;
    dropdownIconColor?: ColorValue;
    dropdownIconRippleColor?: ColorValue;
    numberOfLines?: number;
    onFocus?: (event: GestureResponderEvent) => void;
    onBlur?: (event: GestureResponderEvent) => void;
  }>;

  export interface PickerItemProps<T = PickerValue> {
    label: string;
    value?: T;
    color?: ColorValue;
    testID?: string;
    enabled?: boolean;
  }

  export class Picker<T = PickerValue> extends React.Component<PickerProps<T>> {
    static Item: React.ComponentClass<PickerItemProps>;
  }

  export const PickerIOS: typeof Picker;
}

