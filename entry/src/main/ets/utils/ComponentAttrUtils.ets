import { componentUtils } from "@kit.ArkUI";

/**
 * 计算组件属性
 */
export class ComponentAttrUtils {
  public static getRectInfoById(context: UIContext, id: string): RectInfoInPx {
    if (!context || !id) {
      throw new Error("组件未找到")
    }
    //参数不为空
    let componentInfo: componentUtils.ComponentInfo = context.getComponentUtils().getRectangleById(id)

    if (!componentInfo) {
      throw new Error("组件未找到")
    }
    let rstRect: RectInfoInPx = new RectInfoInPx()
    //宽度被缩的大小
    const widthScaleGap = componentInfo.size.width * (1 - componentInfo.scale.x) / 2;
    //高度缩放值
    const heightScaleGap = componentInfo.size.height * (1 - componentInfo.scale.y) / 2;
    //控件矩阵的 left
    rstRect.left = componentInfo.translate.x + componentInfo.screenOffset.x + widthScaleGap;
    rstRect.top = componentInfo.translate.y + componentInfo.screenOffset.y + heightScaleGap;
    rstRect.right =
      componentInfo.translate.x + componentInfo.screenOffset.x + componentInfo.size.width - widthScaleGap;
    rstRect.bottom =
      componentInfo.translate.y + componentInfo.screenOffset.y + componentInfo.size.height - heightScaleGap;
    rstRect.width = rstRect.right - rstRect.left;
    rstRect.height = rstRect.bottom - rstRect.top;
    return {
      left: rstRect.left,
      right: rstRect.right,
      top: rstRect.top,
      bottom: rstRect.bottom,
      width: rstRect.width,
      height: rstRect.height
    };
  }
}

/**
 * 组件矩阵
 */
export class RectInfoInPx {
  left: number = 0;
  top: number = 0;
  right: number = 0;
  bottom: number = 0;
  width: number = 0;
  height: number = 0;
}