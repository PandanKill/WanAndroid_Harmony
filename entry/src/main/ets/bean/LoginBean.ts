export class LoginBean {
  private username: string
  private password: string

  constructor(userN: string, pwd: string) {
    this.username = userN
    this.password = pwd
  }

  getUsername(): string {
    return this.username
  }

  getPwd(): string {
    return this.password
  }
}