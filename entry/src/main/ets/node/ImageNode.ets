import { createMyNode, getMyNode, MyNodeController } from "./MyImageDetailNodeController"

@Component
export struct ImageNode {
  @State myNodeController: MyNodeController | undefined = new MyNodeController(false)

  aboutToAppear(): void {
    // Get a custom node.
    let node = getMyNode();
    if (node === undefined) {
      // Creating a user-defined node.
      createMyNode(this.getUIContext());
    }
    this.myNodeController = getMyNode();
  }

  aboutToDisappear(): void {
    if (this.myNodeController !== undefined) {
      // Nodal tree.
      this.myNodeController.onRemove();
    }
  }

  build() {
    NodeContainer(this.myNodeController)
  }
}