import { BuilderNode, NodeController } from "@kit.ArkUI";
import { ChatPicDetailContent } from "../component/ChatPicDetailContent";
import SizeConstant from "../constants/SizeConstant";


@Builder
function CardBuilder() {
  ChatPicDetailContent({
    // detailMessage: message,
    // chatPicDetailContent: this.showPicContent
  }).width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
}

export class MyNodeController extends NodeController {
  private CardNode: BuilderNode<[]> | null = null;
  private wrapBuilder: WrappedBuilder<[]> = wrapBuilder(CardBuilder);
  private needCreate: boolean = false;
  private isRemove: boolean = false;

  constructor(create: boolean) {
    super();
    this.needCreate = create;
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.isRemove === true) {
      return null;
    }
    if (this.needCreate && this.CardNode === null) {
      this.CardNode = new BuilderNode(uiContext);
      this.CardNode.build(this.wrapBuilder);
    }
    if (this.CardNode === null) {
      return null;
    }
    return this.CardNode!.getFrameNode()!;
  }

  getNode(): BuilderNode<[]> | null {
    return this.CardNode;
  }

  setNode(node: BuilderNode<[]> | null) {
    this.CardNode = node;
    this.rebuild();
  }

  onRemove() {
    this.isRemove = true;
    this.rebuild();
    this.isRemove = false;
  }

  init(uiContext: UIContext) {
    this.CardNode = new BuilderNode(uiContext);
    this.CardNode.build(this.wrapBuilder);
  }
}

let myNode: MyNodeController | undefined;

export const createMyNode = (uiContext: UIContext) => {
  myNode = new MyNodeController(false);
  myNode.init(uiContext);
}

export const getMyNode = (): MyNodeController | undefined => {
  return myNode;
}