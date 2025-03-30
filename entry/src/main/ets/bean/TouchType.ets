/**
 * 按键类型
 */
export enum CustomTouchType {
  Down,
  Up,
  Move,
  Cancel,
  Undefined
}


@Observed
export class EventState {
  type: CustomTouchType = CustomTouchType.Undefined;
  x: number = 0;
  y: number = 0
}
