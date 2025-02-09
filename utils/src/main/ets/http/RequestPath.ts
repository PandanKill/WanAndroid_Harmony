class RequestPath {
  //baseUrl
  readonly baseUrl: string = "https://www.wanandroid.com"

  //登录
  readonly PATH_LOGIN = "/user/login"

  //首页Banner
  readonly PATH_HOME_BANNER = "/banner/json"
  //置顶
  readonly PATH_TOP = "/article/top/json"
  //获取导航数据
  readonly PATH_NAV = "/navi/json"
  //体系数据
  readonly PATH_TREE = "/tree/json"
  //回答数据
  readonly PATH_WENDA = "/popular/wenda/json"
  //项目tabs
  readonly PATH_PROJECT_TREE = "/project/tree/json"
  //公众号列表
  readonly PATH_WXARTICLE_CHAPTERS = "/wxarticle/chapters/json"
  //热词
  readonly PATH_HOTKEY_JSON = "/hotkey/json"

  //注册
  static readonly PATH_REGISTER = "/user/register"

  //退出
  static readonly PATH_USER_EXIT = "/user/logout/json"
}


export const requestPath = new RequestPath()