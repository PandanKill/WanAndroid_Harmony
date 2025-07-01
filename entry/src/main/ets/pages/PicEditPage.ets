import SizeConstant from '../constants/SizeConstant'
import { fileIo } from '@kit.CoreFileKit'

@Entry
@Component
struct PicEditPage {
  @State imageUri: string = ''
  //是否开启抗锯齿 true开启
  private setting: RenderingContextSettings = new RenderingContextSettings(true)
  //创建 context
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting)
  @State points: number[][] = [];

  build() {
    Column() {
      Canvas(this.canvasContext)
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_PERCENT_60)
        .onReady(() => {
          const ctx: CanvasRenderingContext2D = this.canvasContext
          // ctx.drawImage(, 0, 0, 300, 300); // 绘制底图
        })
        .onTouch((event) => {
          if (event.type === TouchType.Down || event.type === TouchType.Move) {
            this.points.push([event.touches[0].x, event.touches[0].y]);
            this.drawCurve(); // 实时绘制路径
          }
        })

      SaveButton({
        text: SaveDescription.SAVE_IMAGE
      }).onClick(async (_, result) => {
        if (result === SaveButtonOnClickResult.SUCCESS) {
          const base64 = this.canvasContext.toDataURL(); // 获取画布数据
          // const arrayBuffer = base64ToArrayBuffer(base64); // Base64转二进制
          // await this.saveToGallery(arrayBuffer);
        }
      })
    }
  }

  private drawCurve() {
    const ctx = this.canvasContext;
    ctx.beginPath();
    ctx.moveTo(this.points[0][0], this.points[0][1]);
    for (let i = 1; i < this.points.length; i++) {
      ctx.lineTo(this.points[i][0], this.points[i][1]);
    }
    ctx.strokeStyle = '#FF0000';
    ctx.lineWidth = 5;
    ctx.stroke();
  }
}