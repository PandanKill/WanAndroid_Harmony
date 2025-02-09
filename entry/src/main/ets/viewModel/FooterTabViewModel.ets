export class FooterTabViewModel {
  private tabTools: FooterTab[] = []

  constructor() {
    this.tabTools.push(new FooterTab($r('app.string.tab_home'), $r('app.media.home_normal'),
      $r('app.media.home_select')));
    this.tabTools.push(new FooterTab($r('app.string.tab_nav'), $r('app.media.nav_normal'), $r('app.media.nav_select')));
    this.tabTools.push(new FooterTab($r('app.string.tab_ans'), $r('app.media.ans_normal'), $r('app.media.ans_select')));
    this.tabTools.push(new FooterTab($r('app.string.tab_project'), $r('app.media.project_normal'),
      $r('app.media.project_select')));
    this.tabTools.push(new FooterTab($r('app.string.tab_mine'), $r('app.media.mine_normal'),
      $r('app.media.mine_select')));
  }

  getTabList(): FooterTab[] {
    return this.tabTools
  }
}

export class FooterTab {
  private name: Resource;
  private iconNormal: Resource;
  private iconSelected: Resource;

  constructor(name: Resource, iconNormal: Resource, iconSelected: Resource) {
    this.name = name;
    this.iconNormal = iconNormal;
    this.iconSelected = iconSelected;
  }

  getName(): Resource {
    return this.name;
  }

  getIcon(): Resource {
    return this.iconNormal;
  }

  getIconSelected(): Resource {
    return this.iconSelected;
  }
}